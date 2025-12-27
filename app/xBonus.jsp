<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

    AccountInfo info = new AccountInfo(userid);
    if(x.isEmpty() || userid.isEmpty() || (sessionid.isEmpty() && !isAllowedMultiSession(userid))){
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
        return;

    }else if(globalEnableMaintainance){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalMaintainanceMessage);
        mainObj.put("errorcode", "maintenance");
        out.print(mainObj);
        return;

    }else if(isSessionExpired(userid,sessionid)){
		mainObj.put("status", "ERROR");
		mainObj.put("message", globalExpiredSessionMessage);
        mainObj.put("errorcode", "session");
		out.print(mainObj);
        return;
    }

    if(x.equals("claim_winstrike_bonus")){
        String appreference = request.getParameter("appreference");
        String bonuscode = info.winstrike_eventid + "-" + info.winstrike_category;
        if(isBonusExists(userid, bonuscode)){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Your win strike bonus is already claimed!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        ExecuteQuery("INSERT INTO tblbonus set accountid='"+userid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='"+info.winstrike_type.toLowerCase()+" bonus', bonuscode='"+ bonuscode +"', bonusdate=current_date, amount="+info.winstrike_bonus+", dateclaimed=current_timestamp");
        ExecuteQuery("UPDATE tblsubscriber set winstrike_available=0, winstrike_enabled=1 where accountid='"+userid+"'");

        ExecuteSetScore(info.operatorid, sessionid, appreference, userid, info.fullname, "ADD", info.winstrike_bonus, info.winstrike_type.toLowerCase() + " bonus", userid);
        SendBonusNotification(userid, "You have received "+String.format("%,.2f", info.bonus_amount) + " from "+info.winstrike_type.toLowerCase()+" bonus", info.winstrike_bonus);
        
        mainObj.put("status", "OK"); 
        mainObj = api_account_info(mainObj, userid, false);
        mainObj = api_promotion_list(mainObj, info.operatorid);
        mainObj.put("message", "You have successfully claim your "+info.winstrike_type.toLowerCase()+" bonus! Congratulations");
        out.print(mainObj);

    }else{

        if(isBalanceAvailable(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Please withdraw your credit balance in order to claim your bonus!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(isTherePendingDeposit(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Bonus cannot be claim due to pending deposit");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(isTherePendingWithdrawal(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Bonus cannot be claim due to pending withdrawal!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if((info.ispromoactive ) && info.creditbal > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You are currently promo actived!");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        if(x.equals("claim_referral_bonus")){
            String appreference = request.getParameter("appreference");
            
            DateWeekly dw = new DateWeekly();
            ReferralBonus bonus_prev = new ReferralBonus(userid, dw.current_week_from, dw.current_week_to);

            if(bonus_prev.amount == 0){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Referral bonus not available! Please Refresh your account");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
                
            }else if(isBonusExists(userid, "WRB-"+dw.prev_week_code)){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Referral bonus is already claimed!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            }

            ClearExistingBonus(userid);
            ExecuteQuery("INSERT INTO tblbonus set accountid='"+userid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='weekly referral bonus', bonuscode='WRB-"+dw.prev_week_code+"', bonusdate=current_date, amount="+bonus_prev.amount+", dateclaimed=current_timestamp");
            ExecuteSetScore(info.operatorid, sessionid, appreference, userid, info.fullname, "ADD", bonus_prev.amount, "weekly referral bonus", userid);
            SendBonusNotification(userid, "You have received "+String.format("%,.2f", bonus_prev.amount) + " from weekly referral bonus", bonus_prev.amount);

            mainObj.put("status", "OK");
            mainObj = api_referral_summary(mainObj, userid);
            mainObj.put("message", "You have successfully claim your referral bonus! Congratulations");
            out.print(mainObj);

        }else if(x.equals("claim_referral_commission")){
            String appreference = request.getParameter("appreference");
            
            DateWeekly dw = new DateWeekly();
            DownlineWinlossCockfight wls_prev = new DownlineWinlossCockfight(userid, dw.prev_week_from, dw.prev_week_to);
            DownlineWinlossCasino wlc_prev = new DownlineWinlossCasino(userid, dw.prev_week_from, dw.prev_week_to);
            double totalPrevWinloss = wls_prev.winloss + wlc_prev.winloss;
            double prevCommission = (totalPrevWinloss < 0 ? -totalPrevWinloss * 0.05 : 0);
            
            if(prevCommission > 3388) prevCommission = 3388;
            if(prevCommission == 0){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Referral commission not available! Please Refresh your account");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
                
            }else if(isBonusExists(userid, "WRC-"+dw.prev_week_code)){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Referral commission is already claimed!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            }

            ClearExistingBonus(userid);
            ExecuteQuery("INSERT INTO tblbonus set accountid='"+userid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='5% weekly referral comission', bonuscode='WRC-"+dw.prev_week_code+"', bonusdate=current_date, amount="+prevCommission+", dateclaimed=current_timestamp");
            ExecuteSetScore(info.operatorid, sessionid, appreference, userid, info.fullname, "ADD", prevCommission, "5% weekly referral comission", userid);
            SendBonusNotification(userid, "You have received "+String.format("%,.2f", prevCommission) + " from 5% weekly referral comission", prevCommission);

            mainObj.put("status", "OK");
            mainObj = api_referral_summary(mainObj, userid);
            mainObj.put("message", "You have successfully claim your referral commission! Congratulations");
            out.print(mainObj);

        }else if(x.equals("claim_rebate_bonus")){
            String appreference = request.getParameter("appreference"); 
            
            if(!info.rebate_available){
                mainObj.put("status", "ERROR");
                mainObj.put("message","You have no rebate bonus at this time! Bonus can be claim after 12 midnight");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;

            }else if(isBonusExistsByDate(userid, "rebate", info.bonus_date)){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Your rebate bonus is already claimed!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            }

            double amount = info.totaldeposit * 0.08;
            if(amount > 1688) amount = 1688;
            
            ClearExistingBonus(userid);
            ExecuteQuery("INSERT INTO tblbonus set accountid='"+userid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='8% daily rebate bonus', bonuscode='rebate', bonusdate='" +info.bonus_date+ "', amount="+amount+", dateclaimed=current_timestamp");
            ExecuteQuery("UPDATE tblsubscriber set rebate_enabled=1, bonus_amount="+amount+" where accountid='"+userid+"'");

            ExecuteSetScore(info.operatorid, sessionid, appreference, userid, info.fullname, "ADD", amount, "8% daily rebate bonus", userid);
            SendBonusNotification(userid, "You have received "+String.format("%,.2f", amount) + " from 8% rebate bonus", amount);

            mainObj.put("status", "OK"); 
            mainObj = api_rebate_promo(mainObj, userid);
            mainObj = api_turnover_promo(mainObj, userid);
            mainObj = api_promotion_list(mainObj, info.operatorid);
            mainObj.put("message", "You have successfully claim your daily rebate bonus! Congratulations");
            out.print(mainObj);

        }else if(x.equals("claim_turnover_bonus")){
            String appreference = request.getParameter("appreference");
        
            TurnoverBonus turnover = new TurnoverBonus(userid);
            if(turnover.bonus == 0){
                mainObj.put("status", "ERROR");
                mainObj.put("message","You have no turnover bonus at this time!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;

            }else if(isBonusExistsByDate(userid, "turnover", turnover.bonusdate)){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Your turnover bonus is already claimed!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;

            }
            
            ClearExistingBonus(userid);
            ExecuteQuery("INSERT INTO tblbonus set accountid='"+userid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='daily turnover cash bonus', bonuscode='turnover', bonusdate=current_date, amount="+turnover.bonus+", dateclaimed=current_timestamp");
            ExecuteSetScore(info.operatorid, sessionid, appreference, userid, info.fullname, "ADD", turnover.bonus, "daily turnover cash bonus", userid);
            SendBonusNotification(userid, "You have received "+String.format("%,.2f", turnover.bonus) + " from daily turnover cash bonus", turnover.bonus);
            
            mainObj.put("status", "OK"); 
            mainObj = api_rebate_promo(mainObj, userid);
            mainObj = api_turnover_promo(mainObj, userid);
            mainObj = api_promotion_list(mainObj, info.operatorid);
            mainObj.put("message", "You have successfully claim your daily rebate bonus! Congratulations");
            out.print(mainObj);
        
        }else if(x.equals("claim_socialmedia_bonus")){
            String appreference = request.getParameter("appreference");

            if(isBonusExistsByReference(userid, "socialmedia", appreference)){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Your social media bonus is already claimed!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            }
            
            ClearExistingBonus(userid);
            ExecuteQuery("INSERT INTO tblbonus set accountid='"+userid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='social media bonus', bonuscode='socialmedia', bonusdate=current_date, amount="+info.bonus_amount+", dateclaimed=current_timestamp");
            ExecuteQuery("UPDATE tblsubscriber set socialmedia_available=0, socialmedia_enabled=1 where accountid='"+userid+"'");

            ExecuteSetScore(info.operatorid, sessionid, appreference, userid, info.fullname, "ADD", info.bonus_amount, "social media bonus", userid);
            SendBonusNotification(userid, "You have received "+String.format("%,.2f", info.bonus_amount) + " from social media bonus", info.bonus_amount);
            
            mainObj.put("status", "OK"); 
            mainObj = api_account_info(mainObj, userid, false);
            mainObj = api_promotion_list(mainObj, info.operatorid);
            mainObj.put("message", "You have successfully claim your social media bonus! Congratulations");
            out.print(mainObj);

        }else if(x.equals("claim_weekly_loss")){
            String appreference = request.getParameter("appreference");
            
            DateWeekly dw = new DateWeekly();
            PlayerTotalDeposit dep_prev = new PlayerTotalDeposit(userid, dw.prev_week_from, dw.prev_week_to);
            PlayerWinlossCockfight wls_prev = new PlayerWinlossCockfight(userid, dw.prev_week_from, dw.prev_week_to);
            PlayerWinlossCasino wlc_prev = new PlayerWinlossCasino(userid, dw.prev_week_from, dw.prev_week_to);
            double totalPrevWinloss = wls_prev.winloss + wlc_prev.winloss;
            double prevRebate = (totalPrevWinloss < 0 ? -totalPrevWinloss * 0.05 : 0);
            
            if(prevRebate == 0){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Weekly loss rebate not available! Please Refresh your account");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
                
            }else if(isBonusExists(userid, "WRW-"+dw.prev_week_code)){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Weekly loss rebate is already claimed!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;

            }else if(dep_prev.totaldeposit < 688){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Your weekly total deposits don't meet the minimum deposit requirements!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            
            }
            
            if(prevRebate > 1688) prevRebate = 1688; ClearExistingBonus(userid);
            ExecuteQuery("INSERT INTO tblbonus set accountid='"+userid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='5% weekly loss rebate', bonuscode='WRW-"+dw.prev_week_code+"', bonusdate=current_date, amount="+prevRebate+", dateclaimed=current_timestamp");
            ExecuteQuery("UPDATE tblsubscriber set weekly_loss_enabled=1, rebate_enabled=0 where accountid='"+userid+"'");
            ExecuteSetScore(info.operatorid, sessionid, appreference, userid, info.fullname, "ADD", prevRebate, "5% weekly loss rebate", userid);
            SendBonusNotification(userid, "You have received "+String.format("%,.2f", prevRebate) + " from 5% weekly loss rebate", prevRebate);

            mainObj.put("status", "OK");
            mainObj = api_weekly_rebate_winloss(mainObj, userid);
            mainObj = api_promotion_list(mainObj, info.operatorid);
            mainObj.put("message", "You have successfully claim your weekly loss rebate! Congratulations");
            out.print(mainObj);

        }else if(x.equals("claim_custom_bonus")){
            String promocode = request.getParameter("promocode");
            String appreference = request.getParameter("appreference");
            PromotionInfo promo = new PromotionInfo(promocode);
            
            double turnover = 0;  double rollover = 0;
            if(promo.fix_amount) turnover = promo.amount * promo.turnover;
            else turnover = (info.newdeposit + (info.newdeposit * (promo.amount / 100))) * promo.turnover;

            if(promo.fix_amount) rollover = promo.amount * promo.rollover;
            else rollover = (info.newdeposit + (info.newdeposit * (promo.amount / 100))) * promo.rollover;

            double bonus = 0;
            if(promo.fix_amount) bonus = promo.amount;
            else bonus = info.newdeposit * (promo.amount / 100);

            bonus = (promo.max_claim > 0 ? (bonus > promo.max_claim ? promo.max_claim : bonus) : bonus);

            if(promo.approval){
                ExecuteQuery("INSERT INTO tblbonus set accountid='"+userid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='"+rchar(promo.title)+"', bonuscode='"+promocode+"', bonusdate=current_date, amount="+bonus+", approved=0, dateclaimed=current_timestamp");
                mainObj.put("status", "OK");
                mainObj = api_account_info(mainObj, userid, false);
                mainObj = api_custom_promo(mainObj, userid);
                mainObj = api_promotion_list(mainObj, info.operatorid);
                mainObj.put("message", "Your "+promo.title+" promotion has been submitted for approval! Please wait 1-15 minutes while we are processing your request");
                out.print(mainObj);
            }else{
                
                ClearExistingBonus(userid);
                ExecuteQuery("INSERT INTO tblbonus set accountid='"+userid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='"+rchar(promo.title)+"', bonuscode='"+promocode+"', bonusdate=current_date, amount="+bonus+", approved=1, dateclaimed=current_timestamp");
                ExecuteQuery("UPDATE tblsubscriber set custom_promo_enabled=1, custom_promo_code='"+promocode+"',custom_promo_name='"+rchar(promo.title)+"', custom_promo_turnover="+turnover+", custom_promo_rollover="+rollover+", custom_promo_maxwd="+promo.maxwithdraw+" where accountid='"+userid+"'");
                ExecuteSetScore(info.operatorid, sessionid, appreference, userid, info.fullname, "ADD", bonus, rchar(promo.title), userid);
                SendBonusNotification(userid, "You have received "+String.format("%,.2f", bonus) + " from " + rchar(promo.title), bonus);
                
                mainObj.put("status", "OK");
                mainObj = api_account_info(mainObj, userid, false);
                mainObj = api_custom_promo(mainObj, userid);
                mainObj = api_promotion_list(mainObj, info.operatorid);
                mainObj.put("message", "");
                out.print(mainObj);
            }
            
        }else{
            mainObj.put("status", "ERROR");
            mainObj.put("message","request not valid");
            mainObj.put("errorcode", "404");
            out.print(mainObj);
        }
    
    }
}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("app-x-bonus",e.getMessage());
}
%>