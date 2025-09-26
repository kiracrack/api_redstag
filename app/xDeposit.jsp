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

    if(x.equals("deposit_list_upline")){
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno = Integer.parseInt(pageno) * GlobalRecordsLimit;

        String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " referenceno like '%" + rchar(keyword) + "%' or " +
                    " (select remittancename from tblremittance where code=a.remittanceid) like '%" + rchar(keyword) + "%'" +
                    ")";

        mainObj = LoadDepositUpline(mainObj, userid, search, pgno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("deposit_list_downline")){
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

        String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " referenceno like '%" + rchar(keyword) + "%' or " +
                    " (select fullname from tblsubscriber where accountid=a.accountid) like '%" + rchar(keyword) + "%' or " +
                    " (select remittancename from tblremittance where code=a.remittanceid) like '%" + rchar(keyword) + "%'" +
                    ")";

        mainObj.put("status", "OK");
        mainObj = LoadDepositDownline(mainObj, userid, search, pgno);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("deposit_request")){
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        boolean confirmed = Boolean.parseBoolean(request.getParameter("confirmed"));
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

        String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " note like '%" + rchar(keyword) + "%' or " +
                    " referenceno like '%" + rchar(keyword) + "%' or " +
                    " (select fullname from tblsubscriber where accountid=a.accountid) like '%" + rchar(keyword) + "%' or " +
                    " (select remittancename from tblremittance where code=a.remittanceid) like '%" + rchar(keyword) + "%'" +
                    ")";

        /*if(userid.equals("101-00003")){
            userid = "101-00019";
        }*/
                
        mainObj.put("status", "OK");
        mainObj = LoadDepositRequest(mainObj, userid, confirmed, search, pgno);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
    
    }else if(x.equals("new_deposit")){
        AccountInfo info = new AccountInfo(userid);
        boolean showOperatorAccount = false;

        if(!isBankAccountExist(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Please create bank account first");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(isTherePendingDeposit(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have already a pending deposit! Multiple deposits is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && info.rebate_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on rebate bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && info.midnight_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on midnight bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && info.welcome_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on welcome bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && info.daily_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on daily bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.socialmedia_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on social media account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.winstrike_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on win strike account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && info.weekly_loss_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on weekly loss rebate account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.special_bonus_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on special bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && info.custom_promo_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", info.custom_promo_name +" enabled. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }

        mainObj.put("status", "OK");
        mainObj = LoadTelcoList(mainObj);
        mainObj = api_operator_bank(mainObj, info.operatorid);
        mainObj = api_account_info(mainObj, userid, false); 
        mainObj = api_promotion_status(mainObj, info.operatorid);
        mainObj.put("message","Result synchronized");
        out.print(mainObj);


    }else if(x.equals("query_deposit")){
        String refno = request.getParameter("refno");
        
        mainObj = QueryDeposit(mainObj, refno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("confirm_deposit")){
        String refno = request.getParameter("refno");
        String accountid = request.getParameter("accountid");

        if(isDepositAlreadyConfirmed(userid, refno)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Deposit already confirmed!");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        ExecuteQuery("UPDATE tbldeposits set confirmed=1,dateconfirm=current_timestamp where refno='"+refno+"' and accountid='"+accountid+"'");
        SendRequestNotificationCount(userid);
        SendBankingNotification(refno, accountid, "deposit", "Good News!", "Your deposit was approved by your agent! Congratulation..", 0);
        
        mainObj.put("status", "OK");
        mainObj = LoadDepositDownline(mainObj, userid, "", GlobalRecordsLimit);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message","Downline deposit successfully confirmed!");
        out.print(mainObj);
    
    
    }else if(x.equals("create_deposit")){
        String appreference = request.getParameter("appreference");
        String deposit_type = request.getParameter("deposit_type");
        String remittanceid = request.getParameter("remittanceid");
        String bankid = request.getParameter("bankid");
        String sender_name = request.getParameter("sender_name");
        String date_deposit = request.getParameter("date_deposit");
        String time_deposit = request.getParameter("time_deposit");
        String amount = request.getParameter("amount");
        String referenceno = request.getParameter("referenceno");
        String note = request.getParameter("note");
        boolean midnight_bonus = Boolean.parseBoolean(request.getParameter("midnight_bonus"));
        double welcome_bonus = Double.parseDouble(request.getParameter("welcome_bonus"));
        double daily_bonus = Double.parseDouble(request.getParameter("daily_bonus"));

        String platform = request.getParameter("platform"); if(platform == null) platform = "android";
        AccountInfo info = new AccountInfo(userid);

        if(!info.midnight_available) midnight_bonus = false;
        if(!info.isnewaccount) welcome_bonus = 0;

        if(isTherePendingDeposit(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have already a pending deposit! Multiple deposits is not allowed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
            
        }else if(info.iscashaccount && daily_bonus > 0  && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You must clear your credit balance when claiming daily bonus");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && info.rebate_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on rebate bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && info.midnight_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on midnight bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.welcome_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on welcome bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.daily_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on daily bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

         }else if(info.iscashaccount && info.socialmedia_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on social media account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.winstrike_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on win strike account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(deposit_type.equals("TELCO") && !info.telco_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You must clear your credit balance before making telco deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(!deposit_type.equals("TELCO") && info.telco_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on telco credit account mode. Clear your balance to proceed new deposit for banking. Please withdraw your exisiting telco credit before create new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.weekly_loss_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on weekly loss rebate account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.special_bonus_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on special bonus account mode. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        }else if(info.iscashaccount && info.custom_promo_enabled && info.creditbal > 1){
            mainObj.put("status", "ERROR");
            mainObj.put("message", info.custom_promo_name +" enabled. Clear your balance to proceed new deposit");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        
        
        }else if(!deposit_type.equals("TELCO") && welcome_bonus >= 50){
            if(welcome_bonus == 50 && Double.parseDouble(amount) < 10){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Minimum banking deposit amount for 50% welcome bonus is 10");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }else if(welcome_bonus == 100 && Double.parseDouble(amount) < 500){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Minimum banking deposit amount for 100% welcome bonus is 500");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
           
        }else if(deposit_type.equals("TELCO") && welcome_bonus == 30 && Double.parseDouble(amount) < 10){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Minimum telco deposit amount for welcome bonus is 10");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        String agentid = info.agentid;
        String operatorid = info.operatorid;
    
        String imgbase64 = request.getParameter("receipt");
        ServletContext serveapp = request.getSession().getServletContext();

        String refno = getOperatorSeriesID(operatorid,"series_deposit");  
        String url = AttachedReceipt(serveapp, "receipt/deposit", imgbase64, refno);
        
        boolean showOperatorAccount = false;
        if(isMasterAgentDisplayOperatorBank(info.masteragentid)) showOperatorAccount = true;
        if(isAgentDisplayOperatorBank(info.agentid)) showOperatorAccount = true;
        if(info.displayoperatorbank) showOperatorAccount = true;

        if(showOperatorAccount){
            agentid = info.masteragentid;
        }
        
        BankInfo bank = new BankInfo(bankid);
        if(!isLogLedgerFound(userid, sessionid, appreference, "making deposit", 0, Double.parseDouble(amount), userid)){
            LogLedgerTransaction(userid, sessionid, appreference, "making deposit", 0, Double.parseDouble(amount), userid);

            ExecuteQuery("insert into tbldeposits set refno='"+refno+"', "
                        + " accountid='"+userid+"', "
                        + " operatorid='"+operatorid+"', "
                        + " operatoraccount="+bank.isoperator+", "
                        + " bankid='"+bankid+"', "
                        + " agentid='"+agentid+"', "
                        + " deposit_type='"+deposit_type+"', "
                        + " iscashaccount="+info.iscashaccount+", "
                        + " remittanceid='"+remittanceid+"', "
                        + " sender_name='"+rchar(sender_name)+"', "
                        + " date_deposit='"+date_deposit+"', "
                        + " time_deposit='"+time_deposit+":00', "
                        + " amount='"+amount+"', "
                        + " referenceno='"+referenceno+"', "
                        + " note='"+rchar(note)+"', "
                        + " midnight_bonus="+midnight_bonus+", "
                        + " midnight_amount="+ (midnight_bonus ? (Double.parseDouble(amount) * 0.1) : 0 ) + ", "
                        + " welcome_bonus="+ (welcome_bonus > 0) +", "
                        + " welcome_rate="+ welcome_bonus + ", "
                        + " daily_bonus="+ (daily_bonus > 0) +", "
                        + " daily_rate="+ daily_bonus + ", "
                        + " datetrn=current_timestamp, " 
                        + " attachment='"+url+"'");

            AccountInfo agentinfo = new AccountInfo(agentid);
            if(agentinfo.iscashaccount){
                SendNewDepositNotification(refno, getAgentID(agentid), userid, FormatCurrency(amount));
            }else{
                SendNewDepositNotification(refno, agentid, userid, FormatCurrency(amount));
            }
        }
        
        mainObj.put("status", "OK");
        if(platform.equals("webapi")){
            mainObj = api_deposit_list(mainObj, userid);
        }else{
            mainObj = LoadDepositUpline(mainObj, userid, "", GlobalRecordsLimit);
        }
        mainObj.put("message","Your deposit successfully posted! Please wait 1-15 minutes while we are processing your request");
        out.print(mainObj);
 
    }else if(x.equals("cancel_deposit")){
        String refno = request.getParameter("refno");
        String accountid = request.getParameter("accountid");
        String reason = request.getParameter("reason");

        DepositInfo dep = new DepositInfo(refno);
        ExecuteQuery("UPDATE tbldeposits set cancelled=1,datecancelled=current_timestamp,cancelledreason='"+rchar(reason)+"' where refno='"+refno+"' and accountid='"+accountid+"'");
        SendRequestNotificationCount(userid);
        SendBankingNotification(refno, accountid, "deposit", "Ohhh no!", "Your deposit was cancelled by your agent", dep.amount);

        mainObj.put("status", "OK");
        mainObj = LoadDepositDownline(mainObj, userid, " and refno='"+refno+"' ", GlobalRecordsLimit);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message","Downline deposit successfully cancelled!");
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
      logError("app-x-deposit",e.getMessage());
}
%>

<%!public JSONObject LoadDepositRequest(JSONObject mainObj,String agentid,  boolean confirmed, String search, Integer pgno) {
      mainObj = DBtoJson(mainObj, "deposit", sqlDepositQuery + " where (agentid='"+agentid+"' or agentid in (select accountid from tblsubscriber where agentid='"+agentid+"' and iscashaccount=1)) and confirmed=" + confirmed + " and cancelled=0 " + search + " order by id desc limit " + Integer.toString(pgno));
      return mainObj;
 }
 %>
