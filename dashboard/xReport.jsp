<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xScoreReport.jsp" %>
<%@ include file="../module/xWinlossSabong.jsp" %>
<%@ include file="../module/xWinlossCasino.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
 
<%
    JSONObject mainObj = new JSONObject();
try{
    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || userid.isEmpty() || sessionid.isEmpty()){
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
        return;
        
    }else if(isAdminSessionExpired(userid,sessionid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalExpiredSessionMessageDashboard);
        mainObj.put("errorcode", "session");
        out.print(mainObj);
        return;
    
    }else if(isAdminAccountBlocked(userid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalAdminAccountBlocked);
        mainObj.put("errorcode", "blocked");
        out.print(mainObj);
        return;
    }

    if(x.equals("report_template")){
        mainObj.put("status", "OK");
        mainObj = load_report_template(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("fight_bets_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        boolean dummy = Boolean.parseBoolean(request.getParameter("dummy"));
        boolean watcher = Boolean.parseBoolean(request.getParameter("watcher"));
        boolean test = Boolean.parseBoolean(request.getParameter("test"));

        mainObj.put("status", "OK");
        mainObj = fight_bets_report(mainObj,operatorid,range,datefrom,dateto,dummy,watcher,test);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("fight_bets_summary")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = fight_bets_summary(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);
    
    }else if(x.equals("score_transfer_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = score_transfer_report(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("account_deposit_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = account_deposit_report(mainObj, false, operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("operator_deposit_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = account_deposit_report(mainObj, true, operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("account_withdrawal_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = account_withdrawal_report(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("bet_watcher_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = bet_watcher_report(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("online_account_signup")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = online_account_signup(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("registered_account_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = registered_account_report(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("online_deposit_withdraw")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = online_deposit_withdraw(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);


    }else if(x.equals("casino_game_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = casino_game_report(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);
    
    }else if(x.equals("casino_summary_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = casino_summary_report(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("casino_per_game_summary")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = casino_per_game_summary(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("casino_master_agent_summary")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = casino_master_agent_summary(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("regular_bonus_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = regular_bonus_report(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("custom_bonus_report")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = custom_bonus_report(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("regular_bonus_withdrawal")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = regular_bonus_withdrawal(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

     }else if(x.equals("custom_bonus_withdrawal")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = custom_bonus_withdrawal(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("forfeited_bonus_credit")){
        String operatorid = request.getParameter("operatorid");
        boolean range = Boolean.parseBoolean(request.getParameter("range"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = forfeited_bonus_credit(mainObj,operatorid,range,datefrom,dateto);
        mainObj.put("message", "Successfull Synchronized");
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
    logError("dashboard-x-report",e.toString());
}
%>
<%!public JSONObject load_report_template(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "report_template", "select * from tblreporttemplate order by id asc");
      return mainObj;
 }
 %>

<%!public JSONObject fight_bets_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto, boolean dummy, boolean watcher, boolean test) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " accountid as 'Account No.', "
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as 'Account Name', "
                              + " (select fullname from tblsubscriber where accountid=a.masteragentid) as 'Master Agent', "
                              + " (select fullname from tblsubscriber where accountid=a.agentid) as 'Agent', "
                              + " platform as 'Platform', " 
                              + " (select arenaname from tblarena where arenaid=a.arenaid) as 'Arena', " 
                              + " eventid as 'Event', " 
                              + " fightnumber as 'Fight No.', " 
                              + " case when bet_choice='M' then 'Meron' when bet_choice='W' then 'Wala' else 'Draw' end as 'Choice', " 
                              + " bet_amount as 'Bet Amount', "
                              + " transactionno as 'Transaction No.', " 
                              + " case when result='M' then 'Meron' when result='W' then 'Wala' else 'Draw' end as 'Result', "
                              + " if(win, 'WIN', if(result='D','CANCELLED','LOSS')) as 'Bet Status', "
                              + " if(win_amount > 0, win_amount, -lose_amount) as 'Win/Loss', "
                              + " concat(ROUND(odd,3),'%') as 'Odd', "
                              + " payout_amount as 'Payout', "
                              + " gros_ge_rate as 'GC Rate', "
                              + " gros_ge_total as 'GC Total', "
                              + " gros_op_rate as 'OP Rate', "
                              + " gros_op_total as 'OP Total', "
                              + " gros_be_rate as 'BE Rate', "
                              + " gros_be_total as 'BE Total', "
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblfightbets2 as a where cancelled=0 and if(win_amount > 0, win_amount, -lose_amount) != 0 " 
                              + " and operatorid='"+operatorid+"' "
                              + (dummy ? "" : " and dummy=0 ") 
                              + (watcher ? "" : " and banker=0 ") 
                              + (test ? "" : " and test=0 ")  
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account No.', 'center'  union all "
                              + " select 2, 'Account Name', 'left'  union all "
                              + " select 3, 'Master Agent', 'left'  union all "
                              + " select 4, 'Agent', 'left'  union all "
                              + " select 5, 'Platform', 'center'  union all "
                              + " select 6, 'Arena', 'center'  union all "
                              + " select 7, 'Event', 'center'  union all "
                              + " select 8, 'Fight No.', 'center'  union all "
                              + " select 9, 'Choice', 'center'  union all "
                              + " select 10, 'Bet Amount', 'right'  union all "
                              + " select 11, 'Transaction No.', 'center'  union all "
                              + " select 12, 'Result', 'center'  union all "
                              + " select 13, 'Bet Status', 'center'  union all "
                              + " select 14, 'Win/Loss', 'right'  union all "
                              + " select 15, 'Odd', 'center'  union all "
                              + " select 16, 'Payout', 'right'  union all "
                              + " select 17, 'GC Rate', 'center'  union all "
                              + " select 18, 'GC Total', 'right'  union all "
                              + " select 19, 'OP Rate', 'center'  union all "
                              + " select 20, 'OP Total', 'right'  union all "
                              + " select 21, 'BE Rate', 'center'  union all "
                              + " select 22, 'BE Total', 'right'  union all "
                              + " select 23, 'Date', 'center'  union all "
                              + " select 24, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject fight_bets_summary(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select "
                              + " accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " accountid as 'Account No.', " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as 'Account Name', " 
                              + " (select fullname from tblsubscriber where accountid=a.masteragentid) as 'Master Agent', " 
                              + " (select fullname from tblsubscriber where accountid=a.agentid) as 'Agent', " 
                              + " group_concat(distinct (select arenaname from tblarena where arenaid=a.arenaid)) as 'Arena', " 
                              + " group_concat(distinct platform) as 'Platform', " 
                              + " (select creditbal from tblsubscriber where accountid=a.accountid) as 'Score Balance', " 
                              + " sum(if(promo, 0, win_amount)) - sum(if(promo, 0, lose_amount)) as 'Actual' "
                              + " sum(if(promo, win_amount, 0)) - sum(if(promo, lose_amount, 0)) as 'Promo' "
                              + " sum(win_amount) - sum(lose_amount) as 'Win/Loss' "
                              + " from tblfightbets2 as a where operatorid='"+operatorid+"' and dummy=0 and banker=0 and test=0 and cancelled=0 "
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " group by accountid");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account No.', 'center'  union all "
                              + " select 2, 'Account Name', 'left'  union all "
                              + " select 3, 'Master Agent', 'left'  union all "
                              + " select 4, 'Agent', 'left'  union all "
                              + " select 5, 'Arena', 'center'  union all "
                              + " select 6, 'Platform', 'center'  union all "
                              + " select 7, 'Score Balance', 'right'  union all "
                              + " select 8, 'Actual', 'right'  union all "
                              + " select 9, 'Promo', 'right'  union all "
                              + " select 10, 'Win/Loss', 'right'"
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject score_transfer_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select " 
                              + " transactionno as 'Transaction No', " 
                              + " account_from as 'Sender ID', " 
                              + " (select fullname from tblsubscriber where accountid=a.account_from) as 'Sender Name', "
                              + " account_to as 'Receiver ID', " 
                              + " (select fullname from tblsubscriber where accountid=a.account_to) as 'Receiver Name', "
                              + " amount as 'Amount', " 
                              + " reference as 'Reference', " 
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblcredittransfer as a where id > 0 " 
                              + " and operatorid='"+operatorid+"' "
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Transaction No', 'center' union all "
                              + " select 2, 'Sender ID', 'center' union all "
                              + " select 3, 'Sender Name', 'left'  union all "
                              + " select 4, 'Receiver ID', 'center'  union all "
                              + " select 5, 'Receiver Name', 'left'  union all "
                              + " select 6, 'Amount', 'right'  union all "
                              + " select 7, 'Reference', 'left'  union all "
                              + " select 8, 'Date', 'center'  union all "
                              + " select 9, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject account_deposit_report(JSONObject mainObj, boolean isOperatorAccount, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " accountid as 'Account ID', "
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as 'Fullname', "
                              + " (select Username from tblsubscriber where accountid=a.accountid) as 'Username', "
                              + " refno as 'Deposit No', " 
                              + " case when deposit_type='CDM' then 'CASH DEPOSIT' when deposit_type='OBT' then 'INTERNET BANKING' else '' end  as 'Deposit Type', " 
                              + " (select remittancename from tblremittance where code=a.remittanceid) as 'Bank Name', "
                              + " (select accountnumber from tblbankaccounts where id=a.bankid) as 'Account Number', "
                              + " (select accountname from tblbankaccounts where id=a.bankid) as 'Account Name', "
                              + " sender_name as 'Sender Account Name', " 
                              + " referenceno as 'Reference No', " 
                              + " amount as 'Amount', " 
                              + " note as 'Note', " 
                              + " (select fullname from tblsubscriber where accountid=a.agentid) as 'Agent', "
                              + " if(cancelled,'CANCELLED',if(confirmed,'COMPLETED','PENDING')) as 'Status', " 
                              + " date_format(date_deposit,'%Y-%m-%d') as 'Date', " 
                              + " date_format(time_deposit,'%r') as 'Time' "
                              + " from tbldeposits as a where operatoraccount = " + isOperatorAccount + " " 
                              + " and operatorid='"+operatorid+"' " 
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account ID', 'center' union all "
                              + " select 2, 'Fullname', 'left'  union all "
                              + " select 3, 'Username', 'center'  union all "
                              + " select 4, 'Deposit No', 'center'  union all "
                              + " select 5, 'Deposit Type', 'center'  union all "
                              + " select 6, 'Bank Name', 'left'  union all "
                              + " select 7, 'Account Number', 'center'  union all "
                              + " select 8, 'Account Name', 'left'  union all "
                              + " select 9, 'Sender Account Name', 'left'  union all "
                              + " select 10, 'Reference No', 'center'  union all "
                              + " select 11, 'Amount', 'right'  union all "
                              + " select 12, 'Note', 'left'  union all "
                              + " select 13, 'Agent', 'center'  union all "
                              + " select 14, 'Status', 'center'  union all "
                              + " select 15, 'Date', 'center'  union all "
                              + " select 16, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject account_withdrawal_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " accountid as 'Account ID', "
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as 'Fullname', "
                              + " (select Username from tblsubscriber where accountid=a.accountid) as 'Username', "
                              + " refno as 'Withdrawal No', " 
                              + " (select remittancename from tblremittance where code=a.remittanceid) as 'Remittance', "
                              + " accountno as 'Account No', " 
                              + " accountname as 'Account Name', " 
                              + " amount as 'Amount Withdraw', " 
                              + " cashout as 'Net Cashout', " 
                              + " amount-cashout as 'Returned Bonus', " 
                              + " promoname as 'Promo', " 
                              + " note as 'Note', " 
                              + " (select fullname from tblsubscriber where accountid=a.agentid) as 'Agent', "
                              + " if(cancelled,'CANCELLED',if(confirmed,'COMPLETED','PENDING')) as 'Status', " 
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblwithdrawal as a where confirmed=1 and cancelled=0 " 
                              + " and operatorid='"+operatorid+"' "
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account ID', 'center' union all "
                              + " select 2, 'Fullname', 'left'  union all "
                              + " select 3, 'Username', 'center'  union all "
                              + " select 4, 'Withdrawal No', 'center' union all "
                              + " select 5, 'Remittance', 'left'  union all "
                              + " select 6, 'Account No', 'center'  union all "
                              + " select 7, 'Account Name', 'left'  union all "
                              + " select 8, 'Amount Withdraw', 'right'  union all "
                              + " select 9, 'Net Cashout', 'right'  union all "
                              + " select 10, 'Returned Bonus', 'right'  union all "
                              + " select 11, 'Promo', 'left'  union all "
                              + " select 12, 'Note', 'left'  union all "
                              + " select 13, 'Agent', 'center'  union all "
                              + " select 14, 'Status', 'center'  union all "
                              + " select 15, 'Date', 'center'  union all "
                              + " select 16, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject bet_watcher_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select "
                              + " eventid as 'Arena', " 
                              + " fightnumber as 'Fight No.', " 
                              + " total_meron as 'Total Meron', " 
                              + " total_wala as 'Total Wala', " 
                              + " total_difference as 'Total Difference', " 
                              + " case when auto_bet_choice='M' then 'Meron' when auto_bet_choice='W' then 'Wala' else 'Draw' end as 'Auto Bet Choice', " 
                              + " auto_bet_amount as 'Auto Bet Amount', " 
                              + " CONCAT(ROUND(auto_bet_percent,2),'%') as 'Bet Percentage', " 
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblbetwatcher as a where id > 0 " 
                              + " and operatorid='"+operatorid+"' " 
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Arena', 'center' union all "
                              + " select 2, 'Fight No.', 'center'  union all "
                              + " select 3, 'Total Meron', 'right'  union all "
                              + " select 4, 'Total Wala', 'right'  union all "
                              + " select 5, 'Total Difference', 'right'  union all "
                              + " select 6, 'Auto Bet Choice', 'center'  union all "
                              + " select 7, 'Auto Bet Amount', 'right'  union all "
                              + " select 8, 'Bet Percentage', 'center'  union all "
                              + " select 9, 'Date', 'center'  union all "
                              + " select 10, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject online_account_signup(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, " 
                              + " fullname as fullname, "
                              + " accountid as 'Account ID', " 
                              + " fullname as 'Fullname', " 
                              + " username as 'Username', " 
                              + " mobilenumber as 'Mobile Number', " 
                              + " creditbal as 'Current Score', " 
                              + " (select ifnull(sum(amount),0) from tbldeposits where accountid=a.accountid and confirmed=1 and cancelled=0) as 'Total Deposit', " 
                              + " (select ifnull(sum(amount),0) from tblwithdrawal where accountid=a.accountid and confirmed=1 and cancelled=0) as 'Total Withdraw', " 
                              + " date_format(dateregistered,'%Y-%m-%d %r') as 'Date Registered', " 
                              + " reference as 'Signup Reference', " 
                              + " date_format(lastlogindate,'%Y-%m-%d %r') as 'Last Date Login' " 
                              + " from tblsubscriber as a where deleted = 0 and masteragentid = (select ownersaccountid from tbloperator where companyid='"+operatorid+"') " 
                              + " and operatorid='"+operatorid+"' "
                              + (range ? " and date_format(dateregistered,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by dateregistered asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account ID', 'center' union all "
                              + " select 2, 'Fullname', 'left'  union all "
                              + " select 3, 'Username', 'center'  union all "
                              + " select 4, 'Mobile Number', 'center'  union all "
                              + " select 5, 'Current Score', 'right'  union all "
                              + " select 6, 'Total Deposit', 'right'  union all "
                              + " select 7, 'Total Withdraw', 'right'  union all "
                              + " select 8, 'Date Registered', 'center'  union all "
                              + " select 9, 'Signup Reference', 'left'  union all "
                              + " select 10, 'Last Date Login', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject registered_account_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, " 
                              + " fullname as fullname, "
                              + " accountid as 'Account ID', " 
                              + " fullname as 'Fullname', " 
                              + " username as 'Username', " 
                              + " (select fullname from tblsubscriber where accountid=a.masteragentid) as 'Master Agent', "
                              + " (select fullname from tblsubscriber where accountid=a.agentid) as 'Agent', "
                              + " mobilenumber as 'Mobile Number', " 
                              + " creditbal as 'Current Score', " 
                              + " date_format(dateregistered,'%Y-%m-%d %r') as 'Date Registered', " 
                              + " reference as 'Signup Reference', " 
                              + " date_format(lastlogindate,'%Y-%m-%d %r') as 'Last Date Login' " 
                              + " from tblsubscriber as a where deleted = 0 and operatorid='"+operatorid+"' "
                              + (range ? " and date_format(dateregistered,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by dateregistered asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account ID', 'center' union all "
                              + " select 2, 'Fullname', 'left'  union all "
                              + " select 3, 'Username', 'center'  union all "
                              + " select 4, 'Master Agent', 'left'  union all "
                              + " select 5, 'Agent', 'left'  union all "
                              + " select 6, 'Mobile Number', 'center'  union all "
                              + " select 7, 'Current Score', 'right'  union all "
                              + " select 8, 'Date Registered', 'center'  union all "
                              + " select 9, 'Signup Reference', 'left'  union all "
                              + " select 10, 'Last Date Login', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject online_deposit_withdraw(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select *, accountid as 'Account ID', fullname as 'Fullname' from (select accountid, "
                                + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                                + " refno as 'Transaction No', "
                                + " accountno as 'Account No', "
                                + " accountname as 'Account Name', "
                                + " 0 as 'Deposits', "
                                + " amount as 'Withdrawal', "
                                + " date_format(datetrn,'%Y-%m-%d') as 'Date', "
                                + " date_format(datetrn,'%r') as 'Time',  "
                                + " datetrn, "
                                + " operatorid " 
                                + " from tblwithdrawal as a where confirmed=1 and cancelled=0 "
                                + " and (select masteragentid from tblsubscriber where accountid=a.accountid) in (select ownersaccountid from tbloperator where operatorid='101')  "
                                + " union all "
                                + " select accountid, "
                                + " (select fullname from tblsubscriber where accountid=b.accountid) as fullname, "
                                + " refno as 'Transaction No', "
                                + " (select accountnumber from tblbankaccounts where id=b.bankid) as 'Account No', "
                                + " (select accountname from tblbankaccounts where id=b.bankid) as 'Account Name', "
                                + " amount as 'Deposits', "
                                + " 0 as 'Withdrawal', "
                                + " date_format(datetrn,'%Y-%m-%d') as 'Date', "
                                + " date_format(datetrn,'%r') as 'Time',  "
                                + " datetrn,  "
                                + " operatorid " 
                                + " from tbldeposits as b where operatoraccount=1 and confirmed=1 and cancelled=0) as x "
                                + " where operatorid='" + operatorid + "' "
                                + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                                + " order by datetrn asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account ID', 'center' union all "
                              + " select 2, 'Fullname', 'left'  union all "
                              + " select 3, 'Transaction No', 'center' union all "
                              + " select 4, 'Account No', 'center'  union all "
                              + " select 5, 'Account Name', 'left'  union all "
                              + " select 6, 'Deposits', 'right'  union all "
                              + " select 7, 'Withdrawal', 'right'  union all "
                              + " select 8, 'Date', 'center'  union all "
                              + " select 9, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

 <%!public JSONObject casino_game_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, Provider," 
                              + " fullname as fullname, "
                              + " accountid as 'Account ID', " 
                              + " fullname as 'Account Name', " 
                              + " (select fullname from tblsubscriber where accountid=a.masteragentid) as 'Master Agent', " 
                              + " (select fullname from tblsubscriber where accountid=a.agentid) as 'Agent', " 
                              + " sum(totalbets) as 'Turnover', " 
                              + " sum(totalwin) as 'Total Win', " 
                              + " sum(winloss) as 'Win/Loss' " 
                              + " from tblgamesummary as a where operatorid='"+operatorid+"' "
                              + (range ? " and date_format(gamedate,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " group by accountid,provider order by sum(winloss) asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Provider', 'center' union all "
                              + " select 2, 'Account ID', 'center' union all "
                              + " select 3, 'Account Name', 'left'  union all "
                              + " select 4, 'Master Agent', 'left'  union all "
                              + " select 5, 'Agent', 'left'  union all "
                              + " select 6, 'Turnover', 'right'  union all "
                              + " select 7, 'Total Win', 'right'  union all "
                              + " select 8, 'Win/Loss', 'right'"
                              + "");
      return mainObj;
 }
 %>

 <%!public JSONObject casino_summary_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select   " 
                              + " if(provider='infinity','NEKO',ucase(provider)) as Provider, " 
                              + " sum(totalbets) as 'Turnover', " 
                              + " sum(totalwin) as 'Total Win', " 
                              + " sum(winloss) as 'Win/Loss' " 
                              + " from tblgamesummary as a where operatorid='"+operatorid+"' "
                              + (range ? " and date_format(gamedate,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " and masteragentid <> (select testaccountid from tbloperator where operatorid='"+operatorid+"') group by provider order by sum(winloss) asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Provider', 'center'  union all "
                              + " select 2, 'Turnover', 'right'  union all "
                              + " select 3, 'Total Win', 'right'  union all "
                              + " select 4, 'Win/Loss', 'right'"
                              + "");
      return mainObj;
 }
 %>
 <%!public JSONObject casino_per_game_summary(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select *, winloss as 'Win/Loss' from (select " 
                              + " a.gamename as 'Game Name', " 
                              + " if(a.provider='infinity','NEKO',ucase(a.provider)) as Provider, " 
                              + " ifnull(sum(if(promo, 0, b.winloss)),0) as 'Actual', " 
                              + " ifnull(sum(if(promo, b.winloss, 0)),0) as 'Promo', " 
                              + " ifnull(sum(b.winloss),0) as 'winloss' " 
                              + " FROM tblgamelist as a left join tblgamesummary as b on a.gameid=b.gameid where b.operatorid='"+operatorid+"' "
                              + (range ? " and date_format(b.gamedate,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " and b.masteragentid <> (select testaccountid from tbloperator where operatorid='"+operatorid+"') "
                              + " and isenable=1 group by b.gameid) as x order by WinLoss;");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Provider', 'center'  union all "
                              + " select 2, 'Game Name', 'left'  union all "
                              + " select 3, 'Actual', 'right'  union all "
                              + " select 4, 'Promo', 'right'  union all "
                              + " select 5, 'Win/Loss', 'right'"
                              + "");
      return mainObj;
 }
 %>


 <%!public JSONObject casino_master_agent_summary(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select " 
                              + " (select fullname from tblsubscriber where accountid=a.masteragentid) as 'Master Agent', " 
                              + " if(provider='infinity','NEKO',ucase(provider)) as Provider, " 
                              + " sum(if(promo, 0, winloss)) as 'Actual', " 
                              + " sum(if(promo, winloss, 0)) as 'Promo', " 
                              + " sum(winloss) as 'Win/Loss' " 
                              + " from tblgamesummary as a where operatorid='"+operatorid+"' "
                              + (range ? " and date_format(gamedate,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " and masteragentid <> (select testaccountid from tbloperator where operatorid='"+operatorid+"') "
                              + " group by provider,masteragentid");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Master Agent', 'left'  union all "
                              + " select 2, 'Provider', 'center'  union all "
                              + " select 3, 'Actual', 'right'  union all "
                              + " select 4, 'Promo', 'right'  union all "
                              + " select 5, 'Win/Loss', 'right'"
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject regular_bonus_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select "
                              + " accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " accountid as 'Account No.', " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as 'Account Name', " 
                              + " bonus_type as 'Bonus Type', " 
                              + " amount as 'Amount', " 
                              + " date_format(bonusdate,'%Y-%m-%d') as 'Bonus Date', "
                              + " date_format(dateclaimed,'%Y-%m-%d %r') as 'Date Claim'  " 
                              + " from tblbonus as a where operatorid='"+operatorid+"' and bonuscode not in (select promocode from tblpromotion where build_in=0) "
                              + (range ? " and date_format(dateclaimed,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : ""));

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account No.', 'center'  union all "
                              + " select 2, 'Account Name', 'left'  union all "
                              + " select 3, 'Bonus Type', 'left'  union all "
                              + " select 4, 'Amount', 'right'  union all " 
                              + " select 5, 'Bonus Date', 'center'  union all "
                              + " select 6, 'Date Claim', 'center' "
                              + "");
      return mainObj;
 }
 %>

 <%!public JSONObject custom_bonus_report(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select "
                              + " accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " accountid as 'Account No.', " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as 'Account Name', " 
                              + " bonus_type as 'Bonus Type', " 
                              + " amount as 'Amount', " 
                              + " date_format(bonusdate,'%Y-%m-%d') as 'Bonus Date', "
                              + " date_format(dateclaimed,'%Y-%m-%d %r') as 'Date Claim'  " 
                              + " from tblbonus as a where operatorid='"+operatorid+"' and bonuscode in (select promocode from tblpromotion where build_in=0) "
                              + (range ? " and date_format(dateclaimed,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : ""));

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account No.', 'center'  union all "
                              + " select 2, 'Account Name', 'left'  union all "
                              + " select 3, 'Bonus Type', 'left'  union all "
                              + " select 4, 'Amount', 'right'  union all " 
                              + " select 5, 'Bonus Date', 'center'  union all "
                              + " select 6, 'Date Claim', 'center' "
                              + "");
      return mainObj;
 }
 %>

 <%!public JSONObject regular_bonus_withdrawal(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " accountid as 'Account ID', "
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as 'Fullname', "
                              + " (select Username from tblsubscriber where accountid=a.accountid) as 'Username', "
                              + " refno as 'Withdrawal No', " 
                              + " amount as 'Amount Withdraw', " 
                              + " cashout as 'Net Cashout', " 
                              + " amount-cashout as 'Returned Bonus', " 
                              + " promoname as 'Promo', " 
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblwithdrawal as a where confirmed=1 and cancelled=0 and amount-cashout > 0 " 
                              + " and (promocode in (select promocode from tblpromotion where build_in=1) or promocode='telco_deposit') "
                              + " and operatorid='"+operatorid+"' "
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account ID', 'center' union all "
                              + " select 2, 'Fullname', 'left'  union all "
                              + " select 3, 'Username', 'center'  union all "
                              + " select 4, 'Withdrawal No', 'center' union all "
                              + " select 5, 'Amount Withdraw', 'right'  union all "
                              + " select 6, 'Net Cashout', 'right'  union all "
                              + " select 7, 'Returned Bonus', 'right'  union all "
                              + " select 8, 'Promo', 'left'  union all "
                              + " select 9, 'Date', 'center'  union all "
                              + " select 10, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

<%!public JSONObject custom_bonus_withdrawal(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " accountid as 'Account ID', "
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as 'Fullname', "
                              + " (select Username from tblsubscriber where accountid=a.accountid) as 'Username', "
                              + " refno as 'Withdrawal No', " 
                              + " amount as 'Amount Withdraw', " 
                              + " cashout as 'Net Cashout', " 
                              + " promoname as 'Promo', " 
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblwithdrawal as a where confirmed=1 and cancelled=0 and amount-cashout > 0 " 
                              + " and promocode in (select promocode from tblpromotion where build_in=0) "
                              + " and operatorid='"+operatorid+"' "
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account ID', 'center' union all "
                              + " select 2, 'Fullname', 'left'  union all "
                              + " select 3, 'Username', 'center'  union all "
                              + " select 4, 'Withdrawal No', 'center' union all "
                              + " select 5, 'Amount Withdraw', 'right'  union all "
                              + " select 6, 'Net Cashout', 'right'  union all "
                              + " select 7, 'Promo', 'left'  union all "
                              + " select 8, 'Date', 'center'  union all "
                              + " select 9, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>

 <%!public JSONObject forfeited_bonus_credit(JSONObject mainObj, String operatorid, boolean range, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "report", "select accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " accountid as 'Account ID', "
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as 'Fullname', "
                              + " (select Username from tblsubscriber where accountid=a.accountid) as 'Username', "
                              + " bonus_type as 'Bonus Type', " 
                              + " amount as 'Amount', " 
                              + " date_format(datetrn,'%Y-%m-%d') as 'Date', " 
                              + " date_format(datetrn,'%r') as 'Time' "
                              + " from tblbonusreturn as a where bonus_code not in (select promocode from tblpromotion where build_in=0) and operatorid='"+operatorid+"' "
                              + (range ? " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'" : "") 
                              + " order by id asc");

      mainObj = DBtoJson(mainObj, "column", "select 0 as colIndex, '' as colname, '' as colalign union all "
                              + " select 1, 'Account ID', 'center' union all "
                              + " select 2, 'Fullname', 'left'  union all "
                              + " select 3, 'Username', 'center'  union all "
                              + " select 4, 'Bonus Type', 'center' union all "
                              + " select 5, 'Amount', 'right'  union all "
                              + " select 6, 'Date', 'center'  union all "
                              + " select 7, 'Time', 'center' "
                              + "");
      return mainObj;
 }
 %>