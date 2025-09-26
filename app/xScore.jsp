<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

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

    if(x.equals("set_score")){
        String accountid =  request.getParameter("accountid");
        String appreference =  request.getParameter("appreference");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String mode = request.getParameter("mode");
        String refno = request.getParameter("refno");
        String reference =  request.getParameter("reference");

        AccountInfo info = new AccountInfo(accountid);
        if(CountQry("tblsubscriber", "accountid='"+accountid+"' and blocked=0") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Invalid account number");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
            
        }else if(CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal < "+amount+"") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Your score balance is insuficient");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.rebate_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "This account is rebate bonus enabled mode. Transfer score and deposit is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && info.midnight_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "This account is midnight bonus enabled mode. Transfer score and deposit is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.welcome_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "This account is welcome bonus enabled mode. Transfer score and deposit is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.daily_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "This account is daily bonus enabled mode. Transfer score and deposit is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

         }else if(info.iscashaccount && info.socialmedia_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "This account is social media enabled mode. Transfer score and deposit is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.winstrike_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "This account is win strike enabled mode. Transfer score and deposit is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.special_bonus_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "This account is spcial bonus enabled mode. Transfer score and deposit is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.custom_promo_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on "+ info.custom_promo_name +" bonus account mode. deposit is not available");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }

        String operatorid =  getOperatorid(userid);
        String transactionno = getOperatorSeriesID(operatorid,"series_credit_transfer");

        String account_to_name = getAccountName(accountid);
        Boolean sent = LogLedger(userid, sessionid, appreference, transactionno,"transfer score to "+ FirstName(account_to_name) + (reference.length() > 0? " (" + reference.toLowerCase() + ")" : ""),amount,0, userid);
        
        String account_from_name = getAccountName(userid);
        String description = (mode.equals("deposit") ? "approve deposit" : "received score from "+ FirstName(account_from_name)) + (reference.length() > 0? " (" + reference.toLowerCase() + ")" : ""); 
        Boolean received = LogLedger(accountid,sessionid, appreference,transactionno, description, 0, amount, userid);

        if (sent && received){
            ExecuteQuery("insert into tblcredittransfer set sessionid='"+sessionid+"', operatorid='"+operatorid+"', appreference='"+appreference+"', transactionno='"+transactionno+"', account_from='"+userid+"',account_to='"+accountid+"',amount='"+amount+"',reference='"+rchar(reference)+"',trnby='"+userid+"',datetrn=current_timestamp");
            if(mode.equals("direct") || mode.equals("request")){
                if(mode.equals("request")){
                    ExecuteQuery("UPDATE tblcreditrequest set confirmed=1, dateconfirmed=current_timestamp where refno='"+refno+"'");
                    mainObj = LoadScoreRequest(mainObj, userid, true, "", GlobalRecordsLimit);
                    mainObj = getTotalRequestNotification(mainObj, userid);
                }
                
                mainObj.put("customer_id", accountid);
                mainObj.put("customer_balance", getLatestCreditBalance(accountid));
                mainObj.put("message", "Credit score sent! <br/>Account No. "+accountid+"<br/>Account Name "+account_to_name+"<br/>Amount "+String.format("%,.2f", amount)+"");

                SendTransferScoreNotification(accountid, userid, account_from_name, amount);

            }else if(mode.equals("deposit")){
                DepositInfo dep = new DepositInfo(refno);
                if(dep.confirmed){
                    mainObj.put("status", "ERROR");
                    mainObj.put("message", "Deposit is already confirmed");
                    mainObj.put("errorcode", "400");
                    out.print(mainObj);
                    return;
                }
                
                ExecuteQuery("UPDATE tbldeposits set confirmed=1,dateconfirm=current_timestamp where refno='"+refno+"' and accountid='"+accountid+"'");
                if(info.daily_enabled) ExecuteQuery("UPDATE tblsubscriber set daily_enabled=0, daily_rate=0 where accountid='"+accountid+"'");
                if(info.welcome_enabled) ExecuteQuery("UPDATE tblsubscriber set welcome_enabled=0, welcome_rate=0, welcome_bonus=0, welcome_amount=0 where accountid='"+accountid+"'");
                if(info.socialmedia_enabled) ExecuteQuery("UPDATE tblsubscriber set socialmedia_enabled=0, bonus_amount=0 where accountid='"+accountid+"'");
                if(info.rebate_enabled) ExecuteQuery("UPDATE tblsubscriber set rebate_enabled=0, bonus_amount=0 where accountid='"+accountid+"'");
                if(info.midnight_enabled) ExecuteQuery("UPDATE tblsubscriber set midnight_enabled=0, midnight_bonus=0, midnight_amount=0 where accountid='"+accountid+"'");
                if(info.weekly_loss_enabled) ExecuteQuery("UPDATE tblsubscriber set weekly_loss_enabled=0 where accountid='"+accountid+"'");
                if(info.special_bonus_enabled) ExecuteQuery("UPDATE tblsubscriber set special_bonus_enabled=0 where accountid='"+accountid+"'");
                if(info.custom_promo_enabled) ExecuteQuery("UPDATE tblsubscriber set custom_promo_enabled=0, custom_promo_code='',custom_promo_name='', custom_promo_turnover=0, custom_promo_maxwd=0, newdeposit=0 where accountid='"+accountid+"'");
                
                if(info.isonlineagent){
                    
                    if(info.totaldeposit == 0){
                        ExecuteQuery("UPDATE tblsubscriber set newdeposit="+dep.amount+", totaldeposit="+dep.amount+", bonus_date=current_date where accountid='"+accountid+"'");
                    }else{
                        if(info.rebate_available){
                            ExecuteQuery("UPDATE tblsubscriber set newdeposit="+dep.amount+", totaldeposit="+dep.amount+", bonus_date=current_date where accountid='"+accountid+"'");
                        }else{
                            if(isRebateDateValid(accountid)){
                                ExecuteQuery("UPDATE tblsubscriber set newdeposit="+dep.amount+", totaldeposit=(totaldeposit+"+dep.amount+") where accountid='"+accountid+"' and bonus_date=current_date");
                            }else{
                                ExecuteQuery("UPDATE tblsubscriber set newdeposit="+dep.amount+", totaldeposit="+dep.amount+", bonus_date=current_date where accountid='"+accountid+"'");
                            }
                        } 
                    }

                    if(dep.midnight_amount > 0){
                        LogLedger(accountid,sessionid, appreference,transactionno, "10% midnight bonus of " + FormatCurrency(String.valueOf(dep.amount)), 0, dep.midnight_amount, userid);
                        ExecuteQuery("UPDATE tblsubscriber set midnight_enabled=1, midnight_bonus="+ dep.midnight_amount +", midnight_amount="+ (amount + dep.midnight_amount) +" where accountid='"+accountid+"'");
                        ExecuteQuery("INSERT INTO tblbonus set accountid='"+accountid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='10% midnight bonus', bonuscode='midnight', bonusdate=current_date, amount="+dep.midnight_amount+", dateclaimed=current_timestamp");
                        amount = dep.amount + dep.midnight_amount;
                    }

                    if(info.isnewaccount){
                        if(dep.welcome_bonus){
                            double totalBonus = dep.amount * (dep.welcome_rate / 100);
                            double welcomeBonus = 0;

                            if(dep.welcome_rate == 30){
                                welcomeBonus = (totalBonus > 50 ? 50 : totalBonus);
                            
                            }else if(dep.welcome_rate == 50){
                                welcomeBonus = (totalBonus > 388 ? 388 : totalBonus);

                            }else if(dep.welcome_rate == 100){
                                welcomeBonus = (totalBonus > 1288 ? 1288 : totalBonus);
                            }

                            if(dep.telco){
                                ExecuteQuery("UPDATE tblsubscriber set isnewaccount=0, welcome_enabled=1, welcome_rate="+dep.welcome_rate+", welcome_bonus="+ welcomeBonus +", welcome_amount="+ (dep.amount + welcomeBonus) +"  where accountid='"+accountid+"'");
                                ExecuteQuery("INSERT INTO tblbonus set accountid='"+accountid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='" + String.valueOf(dep.welcome_rate) + "% welcome bonus', bonuscode='welcome', bonusdate=current_date, amount="+welcomeBonus+", dateclaimed=current_timestamp");
                                LogLedger(accountid,sessionid, appreference, transactionno,  String.valueOf(dep.welcome_rate) + "% welcome bonus of " + FormatCurrency(String.valueOf(dep.amount)), 0, welcomeBonus, userid);
                                if(dep.amount >= 50) ExecuteQuery("INSERT INTO tblreferral set accountid='"+accountid+"', referredid='"+info.agentid+"', deposit_amount="+dep.amount+", referral_bonus=15, datedeposit=current_timestamp");
                            
                            }else{
                                ExecuteQuery("UPDATE tblsubscriber set isnewaccount=0, welcome_enabled=1, welcome_rate="+dep.welcome_rate+", welcome_bonus="+ welcomeBonus +", welcome_amount="+ (dep.amount + welcomeBonus) +"  where accountid='"+accountid+"'");
                                ExecuteQuery("INSERT INTO tblbonus set accountid='"+accountid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='" + String.valueOf(dep.welcome_rate) + "% welcome bonus', bonuscode='welcome', bonusdate=current_date, amount="+welcomeBonus+", dateclaimed=current_timestamp");
                                LogLedger(accountid,sessionid, appreference, transactionno,  String.valueOf(dep.welcome_rate) + "% welcome bonus of " + FormatCurrency(String.valueOf(dep.amount)), 0, welcomeBonus, userid);
                                //referral comission meet all conditions
                                ExecuteQuery("INSERT INTO tblreferral set accountid='"+accountid+"', referredid='"+info.agentid+"', deposit_amount="+dep.amount+", referral_bonus=15, datedeposit=current_timestamp");
                            }
                            amount = dep.amount + welcomeBonus;
                        }
                    }else{
                        if(dep.telco){
                            double telcodeposit = info.creditbal+dep.amount;
                            ExecuteQuery("UPDATE tblsubscriber set telco_enabled=1, telco_deposit="+telcodeposit+" where accountid='"+accountid+"'");
                        }else{
                            ExecuteQuery("UPDATE tblsubscriber set telco_enabled=0, telco_deposit=0, telco_withdraw=0 where accountid='"+accountid+"'");
                        }
                        
                        if(dep.daily_bonus){
                            double dailybonus = dep.amount * (dep.daily_rate / 100);
                            if(dailybonus >=288) dailybonus = 288;
                            ExecuteQuery("UPDATE tblsubscriber set daily_enabled=1, daily_rate="+dep.daily_rate+" where accountid='"+accountid+"'");
                            ExecuteQuery("INSERT INTO tblbonus set accountid='"+accountid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='" + String.valueOf(dep.daily_rate) + "% daily bonus', bonuscode='daily', bonusdate=current_date, amount="+dailybonus+", dateclaimed=current_timestamp");
                            LogLedger(accountid,sessionid, appreference, transactionno,  String.valueOf(dep.daily_rate) + "% daily bonus of " + FormatCurrency(String.valueOf(dep.amount)), 0, dailybonus, userid);
                            amount = dep.amount + dailybonus;
                        }
                    }
                }
                
                mainObj = LoadDepositDownline(mainObj, userid, " and refno='"+ refno + "'", GlobalRecordsLimit);
                mainObj = getTotalRequestNotification(mainObj, userid);
                mainObj.put("message","Downline deposit successfully confirmed!");

                SendBankingNotification(refno, accountid, "deposit", "Good News!", "Your deposit was approved by your agent! Congratulation..", amount);
            }

            SendRequestNotificationCount(userid);
            mainObj.put("creditbal", getLatestCreditBalance(userid));
            mainObj.put("status", "OK");
            out.print(mainObj);

            ExecuteQuery("UPDATE tblsubscriber set isnewaccount=0 where accountid='"+accountid+"'");
        }else{
            mainObj.put("status", "ERROR");
            mainObj.put("message","System encounter problem while processing your request");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
        }
    }else if(x.equals("remove_score")){
        String accountid =  request.getParameter("accountid");
        String appreference =  request.getParameter("appreference");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String reference =  request.getParameter("reference");

        if(CountQry("tblsubscriber", "accountid='"+accountid+"'") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Invalid account number");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
            
        }else if(CountQry("tblsubscriber", "accountid='"+accountid+"' and creditbal < "+amount+"") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Amount must be not more than account balance");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        String operatorid =  getOperatorid(userid);
        String transactionno = getOperatorSeriesID(operatorid,"series_credit_transfer");

        String remove_from = getAccountName(accountid);
        Boolean add = LogLedger(userid,sessionid, appreference,transactionno, "remove score from "+ FirstName(remove_from) + (reference.length() > 0? " (" + reference.toLowerCase() + ")" : ""), 0, amount, userid);

        String remove_by = getAccountName(userid);
        Boolean remove = LogLedger(accountid, sessionid, appreference, transactionno,"remove score by "+ FirstName(remove_by) + (reference.length() > 0? " (" + reference.toLowerCase() + ")" : ""),amount,0, accountid);

        if (add && remove){
            ExecuteQuery("insert into tblcredittransfer set sessionid='"+sessionid+"', operatorid='"+operatorid+"', appreference='"+appreference+"', transactionno='"+transactionno+"', account_from='"+accountid+"',account_to='"+userid+"',amount='"+amount+"',reference='"+rchar(reference)+"',trnby='"+userid+"',datetrn=current_timestamp");
            mainObj.put("status", "OK");
            mainObj.put("creditbal", getLatestCreditBalance(userid));
            mainObj.put("customer_id", accountid);
            mainObj.put("customer_balance", getLatestCreditBalance(accountid));
            mainObj.put("message", "Credit score removed and added to your account!");
            out.print(mainObj);
            SendScoreNotification(accountid, false, amount);
        }else{
            mainObj.put("status", "ERROR");
            mainObj.put("message","System encounter problem while processing your request");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
        }

    }else if(x.equals("request_score")){
        String appreference =  request.getParameter("appreference");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String platform = request.getParameter("platform"); if(platform == null) platform = "android";

        if(amount > 10000){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Request failed: Amount exceeds allowed limit");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(isTherePendingScoreRequest(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You already have a pending score request! We only allow one request at a time");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }

        AccountInfo ai = new AccountInfo(userid);
 
        String transactionno = getOperatorSeriesID(ai.operatorid,"series_load_request");
        ExecuteQuery("insert into tblcreditrequest set refno='"+transactionno+"', sessionid='"+sessionid+"', operatorid='"+ai.operatorid+"', appreference='"+appreference+"', userid='"+userid+"',agentid='"+ai.agentid+"',amount='"+amount+"',daterequest=current_timestamp");
        
        mainObj.put("status", "OK");
        if(platform.equals("webapi")) mainObj = api_score_request(mainObj, userid);
        mainObj.put("message", "Your request successfully sent to you upline " + ai.agentname);
        out.print(mainObj);

        SendScoreRequestNotification(transactionno, ai.agentid, userid, ai.fullname, amount);

    }else if(x.equals("cancel_score_request")){
        String refno = request.getParameter("refno");
        SendRequestNotificationCount(userid);
        
        ExecuteQuery("UPDATE tblcreditrequest set cancelled=1, datecancelled=current_timestamp where refno='"+refno+"'");
        mainObj.put("status", "OK");
        mainObj = LoadScoreRequest(mainObj, userid, true, "", GlobalRecordsLimit);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message", "Request successfully cancelled");
        out.print(mainObj);
 
    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
    }

}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("app-x-score",e.getMessage());
}
%>
 

  <%!public boolean isRebateDateValid(String userid) {
    return CountQry("tblsubscriber", "accountid='"+userid+"' and bonus_date=current_date") > 0;
  }
%>