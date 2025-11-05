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

    if(x.equals("new_withdrawal")){
        if(isTherePendingWithdrawal(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have already a pending withdrawal! We only allow one withdrawal at a time");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        mainObj.put("status", "OK");
        mainObj = getBankAccounts(mainObj, userid); 
        mainObj = api_account_info(mainObj, userid, false); 
    
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 

    }else if(x.equals("withdrawal_list_upline")){
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

        String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " accountno like '%" + rchar(keyword) + "%' or " +
                    " accountname like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " (select remittancename from tblremittance where code=a.remittanceid) like '%" + rchar(keyword) + "%'" +
                    ")";

        mainObj = LoadWithdrawalUpline(mainObj, userid, search, pgno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
        
    }else if(x.equals("withdrawal_list_downline")){
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

       String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " accountno like '%" + rchar(keyword) + "%' or " +
                    " accountname like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " (select remittancename from tblremittance where code=a.remittanceid) like '%" + rchar(keyword) + "%'" +
                    ")";

        mainObj.put("status", "OK");
        mainObj = LoadWithdrawalDownline(mainObj, userid, search, pgno);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("withdrawal_request")){
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        boolean confirmed = Boolean.parseBoolean(request.getParameter("confirmed"));
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

       String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " accountno like '%" + rchar(keyword) + "%' or " +
                    " accountname like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " (select remittancename from tblremittance where code=a.remittanceid) like '%" + rchar(keyword) + "%'" +
                    ")";
       
        /*if(userid.equals("101-00003")){
            userid = "101-00019";
        }*/
        
        mainObj.put("status", "OK");
        mainObj = LoadWithdrawalRequest(mainObj, userid, confirmed, search, pgno);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

        
    }else if(x.equals("query_withdrawal")){
        String refno = request.getParameter("refno");
        
        mainObj = QueryWithdrawal(mainObj, refno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
        
    }else if(x.equals("create_withdrawal")){
        String bid = request.getParameter("bid");
        String note = request.getParameter("note");
        double amount = Double.parseDouble(CC(request.getParameter("amount")));
        String appreference = request.getParameter("appreference");
        String platform = request.getParameter("platform"); if(platform == null) platform = "android";
    
        if(CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal < "+amount+"") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Amount must be not more than account balance");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        
         }else if(CountQry("tblbankaccounts", "id='"+bid+"' and deleted=0") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Bank account not found!");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(isTherePendingWithdrawal(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have already a pending withdrawal! We only allow one withdrawal at a time");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }

        AccountInfo info = new AccountInfo(userid);
        if(info.rebate_enabled){
            double turnover = (info.bonus_amount * 3);
            if(info.creditbal < turnover){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Insufficient turnover amount! your credit score must 3X your rebate bonus");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }else if(info.creditbal != amount){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Credit score from rebate's bonus must be withdraw all credit balance");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }

        if(info.midnight_enabled){
            double turnover = (info.midnight_amount * 2);
                if(info.creditbal < turnover){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Insufficient turnover amount! your credit score must 2X your deposit + midnight bonus");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }else if(info.creditbal != amount){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Credit score from deposit + midnight bonus must be withdraw all credit balance");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }

        if(info.telco_enabled){
            double turnover = (info.telco_deposit * 2);
            double creditwithdraw = (info.telco_withdraw + info.creditbal);
            double totalwithdraw = (info.telco_withdraw  + amount);
            if(amount < 100){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Minimum withdrawal for telco credit is 100");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }else if(creditwithdraw < turnover){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Insufficient turnover amount! your withdrawal must be 2X on your telco credit deposit");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }else if(totalwithdraw > 2000){
                double withdrawLeft = (2000 - info.telco_withdraw); 
                mainObj.put("status", "ERROR");
                mainObj.put("message", "You have only " + FormatCurrency(String.valueOf(withdrawLeft)) + " left allowable maximum telco withdrawal amount");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }

        if(info.welcome_enabled){
            double turnover = 0;
            String turnover_type = "";
            String welcome_type = "";

            if(info.welcome_rate == 30){
                turnover = info.welcome_amount * 6;
                welcome_type = "6";

            }else if(info.welcome_rate == 50){
                turnover = info.welcome_amount * 3;
                welcome_type = "3";

            }else if(info.welcome_rate == 100){
                turnover = info.welcome_amount * 7;
                welcome_type = "7";
            }

            if(info.creditbal < turnover){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Insufficient turnover amount! your credit score must be " + welcome_type + "X your total welcome bonus");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }else if(info.creditbal != amount){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Credit score from deposit + welcome bonus must be withdraw all credit balance");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }

        if(info.daily_enabled){
            if(info.creditbal != amount){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Credit score from deposit + daily bonus must be withdraw all credit balance");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }

        if(info.socialmedia_enabled){
            double turnover = (info.bonus_amount * 20);
            if(amount < turnover){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Credit score from social media bonus must be 20x total score turnover");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }else if(info.creditbal != amount){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Credit score must be withdraw all credit balance");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }

        if(info.custom_promo_enabled){
            PromotionInfo promo = new PromotionInfo(info.custom_promo_code);
            
            double turnover = 0;
            if(promo.fix_amount) turnover = promo.amount * promo.turnover;
            else turnover = (info.newdeposit + (info.newdeposit * (promo.amount / 100))) * promo.turnover;

            if(amount < turnover){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Credit score from "+info.custom_promo_code.replace("_", " ")+" must be "+FormatNumber(String.valueOf(turnover))+" or greater than total turnover");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }else if(info.creditbal != amount){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Credit score must be withdraw all credit balance");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }
        
        BankInfo bank = new BankInfo(bid);
        RemitInfo remit = new RemitInfo(bank.remittanceid);
        
        String refno = getOperatorSeriesID(info.operatorid,"series_withdrawal");  
        LogLedger(userid, sessionid, appreference, refno, "withdraw score",amount, 0, userid);
        
        boolean showOperatorAccount = false;
        if(isMasterAgentDisplayOperatorBank(info.masteragentid)) showOperatorAccount = true;
        if(isAgentDisplayOperatorBank(info.agentid)) showOperatorAccount = true;
        if(info.displayoperatorbank) showOperatorAccount = true;

        String agentid = "";
        if(showOperatorAccount){
            agentid = info.masteragentid;
        }

        double cashout = 0;
        String promo_code = "";
        String promo_name = "";
        if(info.telco_enabled){
            cashout = amount - (amount * 0.15);
            promo_code = "telco_deposit";
            promo_name = "telco deposit";

        }else if(info.welcome_enabled){
            cashout = amount - info.welcome_bonus;
             promo_code = "promo_welcome";
             promo_name = "welcome bonus";

        }else if(info.daily_enabled){
            cashout = amount * (100 - info.daily_rate) / 100;
            promo_code = "promo_daily";
            promo_name = info.daily_rate + "% daily bonus";

        }else if(info.midnight_enabled){
            cashout = amount - info.midnight_bonus;
            promo_code = "promo_midnight";
            promo_name = "midnight bonus";
        
        }else if(info.socialmedia_enabled){
            cashout = 30;
            promo_code = "promo_socialmedia";
            promo_name = "social media bonus";

         }else if(info.custom_promo_enabled && info.custom_promo_maxwd != 0){
            if(info.custom_promo_maxwd > 0){
                cashout = (amount <= info.custom_promo_maxwd ? amount : info.custom_promo_maxwd);
            }else{
                cashout = (amount * info.custom_promo_maxwd);
            }
            promo_code = info.custom_promo_code;
            promo_name = info.custom_promo_name;

        }else{
            cashout = amount;
        }

        ExecuteQuery("insert into tblwithdrawal set refno='"+refno+"', "
                        + " accountid='"+userid+"', "
                        + " agentid='"+agentid+"', "
                        + " operatorid='"+info.operatorid+"', "
                        + " isbank="+remit.isbank+", "
                        + " iscashaccount="+info.iscashaccount+", "
                        + " remittanceid='"+bank.remittanceid+"', "
                        + " accountno='"+bank.accountnumber+"', "
                        + " accountname='"+rchar(bank.accountname)+"', "
                        + " note='"+rchar(note)+"', "
                        + " amount='"+amount+"', "
                        + " deducted="+ (amount != cashout) +", "
                        + " cashout='"+cashout+"', "
                        + " promocode='"+promo_code+"', "
                        + " promoname='"+promo_name+"', "
                        + " datetrn=current_timestamp");

        SendNewWithdrawalNotification(refno, agentid, userid, FormatCurrency(String.valueOf(cashout)));

        mainObj.put("status", "OK");
        if(platform.equals("webapi")){
            mainObj = api_withdrawal_list(mainObj, userid);
        }else{
            mainObj = LoadWithdrawalUpline(mainObj, userid, "", GlobalRecordsLimit);
        }
        mainObj.put("creditbal", getLatestCreditBalance(userid));
        mainObj.put("message","Your withdrawal successfully posted! Please wait 1-15 minutes while we are processing your request.");
        out.print(mainObj);
        

    }else if(x.equals("confirm_withdrawal")){
        String refno = request.getParameter("refno");
        String accountid = request.getParameter("accountid");
        String imgbase64 = request.getParameter("receipt");
        String appreference = request.getParameter("appreference");
        String fullname = getAccountName(accountid);

        WithdrawalInfo withdraw = new WithdrawalInfo(refno);
        if(withdraw.iscashaccount){
            if(CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal < "+withdraw.amount+"") > 0){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Insufficient credit balance! credit already used");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            }
            LogLedger(userid, sessionid, appreference, refno, "approved " +FirstName(fullname)+ " withdrawal", 0, withdraw.amount, userid);
        }

        ServletContext serveapp = request.getSession().getServletContext();
        String url = AttachedReceipt(serveapp, "receipt/withdrawal", imgbase64, refno);

        ExecuteQuery("UPDATE tblwithdrawal set confirmed=1,dateconfirm=current_timestamp,attachment='"+url+"' where refno='"+refno+"' and accountid='"+accountid+"'");
        SendRequestNotificationCount(userid);
        SendBankingNotification(refno, accountid, "withdrawal", "Good News!", "Your withdrawal was approved by your agent! Congratulation..", (withdraw.cashout > 0 ? withdraw.cashout : withdraw.amount));
        
        ClearExistingBonus(accountid);

        AccountInfo info = new AccountInfo(accountid);
        if(info.telco_enabled){
            if(info.creditbal == withdraw.amount){
                ExecuteQuery("UPDATE tblsubscriber set telco_enabled=0, telco_withdraw=0 where accountid='"+accountid+"'");
            }else{
                ExecuteQuery("UPDATE tblsubscriber set telco_withdraw=(telco_withdraw+" + withdraw.amount + ") where accountid='"+accountid+"'");
            }
        }

        mainObj.put("status", "OK");
        mainObj.put("creditbal", getLatestCreditBalance(userid));
        mainObj = LoadWithdrawalDownline(mainObj, userid, " and refno='"+refno+"' ", GlobalRecordsLimit);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message","Downline withdrawal successfully confirmed!");
        out.print(mainObj);
        
    }else if(x.equals("cancel_withdrawal")){
        String refno = request.getParameter("refno");
        String accountid = request.getParameter("accountid");
        String reason = request.getParameter("reason");
        String appreference = request.getParameter("appreference");

        if(CountQry("tblwithdrawal", "refno='"+refno+"' and confirmed=1 and cancelled=0") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Sorry! withdrawal is already approved");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(CountQry("tblwithdrawal", "refno='"+refno+"' and cancelled=1") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Sorry! withdrawal is already cancelled");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        WithdrawalInfo info = new WithdrawalInfo(refno);
        if(info.iscashaccount){
            LogLedger(info.accountid, sessionid, appreference, refno, "cancelled withdrawal",0, info.amount, info.accountid);
        }

        ExecuteQuery("UPDATE tblwithdrawal set cancelled=1,datecancelled=current_timestamp,cancelledreason='"+rchar(reason)+"' where refno='"+refno+"' and accountid='"+accountid+"'");
        SendRequestNotificationCount(userid);
        SendBankingNotification(refno, accountid, "withdrawal", "Ohhh no!", "Your withdrawal was cancelled by your agent", info.amount);
        
        mainObj.put("status", "OK");
        mainObj = LoadWithdrawalDownline(mainObj, userid, " and refno='"+refno+"' ", GlobalRecordsLimit);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message","Downline withdrawal successfully cancelled!");
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
      logError("app-x-withdrawal",e.getMessage());
}
%>

 <%!public JSONObject LoadWithdrawalRequest(JSONObject mainObj,String agentid, boolean confirmed, String search, Integer pgno) {
      mainObj = DBtoJson(mainObj, "withdrawal", sqlWithdrawalQuery + " where (agentid='"+agentid+"' or agentid in (select accountid from tblsubscriber where agentid='"+agentid+"' and iscashaccount=1)) and confirmed=" + confirmed + " and cancelled=0 " + search + "  order by id desc limit " + Integer.toString(pgno));
      return mainObj;
 }
 %>