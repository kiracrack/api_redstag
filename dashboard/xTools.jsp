<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xGameModule.jsp" %>
<%
    JSONObject mainObj = new JSONObject();
    JSONObject apiObj = new JSONObject();

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

    if(x.equals("emergency_disable_app")){
        Boolean disable = Boolean.parseBoolean(request.getParameter("disable"));
    
        ExecuteQuery("UPDATE tblgeneralsettings set under_maintenance="+disable+"");
        mainObj.put("message",(disable?  "Server maintenance mode sucessfully enabled" : "Server maintenance mode sucessfully disabled"));
        LogActivity(userid,(disable? "set emergency disabled app" : "set app enabled"));   
        
        mainObj = getGeneralSettings(mainObj);
        mainObj.put("status", "OK");
        out.print(mainObj);

        if(disable){
            apiObj.put("maintenance", disable);
            apiObj.put("title", "Notice");
            apiObj.put("message", globalMaintainanceMessage);
            PusherPost("global", apiObj);
        }
        
    
    }else if(x.equals("clear_ledger_logs")){
        
        if(!globalEnableMaintainance){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Cannot proceed clearing game ledger logs! Please enable maintenance mode");
            mainObj.put("errorcode", "101");
            out.print(mainObj);
            return;
        }

        ExecuteQuery("TRUNCATE tblcreditledgerlogs");
        LogActivity(userid,"cleared game ledger logs");   
        
        mainObj.put("status", "OK");
        mainObj.put("message","Game ledger successfully cleared");
        out.print(mainObj);

    }else if(x.equals("clear_dummy_transaction")){
        if(!globalEnableMaintainance){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Cannot proceed clearing dummy transaction! Please enable maintenance mode");
            mainObj.put("errorcode", "101");
            out.print(mainObj);
            return;
        }

        ExecuteQuery("delete from tblfightbets2 where dummy=1;");
        ExecuteQuery("delete FROM tblcreditledger where accountid='101-00017';");
        ExecuteQuery("delete FROM tblcreditledger where accountid='101-00018';");
        ExecuteQuery("delete FROM tblcreditledger where accountid='102-00002';");
        ExecuteQuery("delete FROM tblcreditledger where accountid='102-00003';");
        LogActivity(userid,"cleared dummy transaction");   
        
        mainObj.put("status", "OK");
        mainObj.put("message","Dummy transaction successfully cleared");
        out.print(mainObj);

    }else if(x.equals("reverse_result")){
        String fightkey = request.getParameter("fightkey");

        if(isCancelled(fightkey)){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Fight number is already cancelled!");
            mainObj.put("errorcode", "101");
            out.print(mainObj);
            return;
        }

        ErrorResultInfo info = new ErrorResultInfo(fightkey);
        String eventid = info.eventid;
        String result = info.result;
        String arenaid = info.arenaid;
        String eventkey = info.eventkey;
        String postingdate = info.postingdate;
        String fightnumber = info.fightnumber;
        String referenceno = info.referenceno;

        result = (result.equals("W") ? "M" : "W");

        RestoreBetsTable(fightkey);
        int totaltrn = CountQry("tblfightbets", "fightkey='"+fightkey+"' and dummy=0");
        
        if(totaltrn == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","No bets have founds, and restored not successfull");
            mainObj.put("errorcode", "101");
            out.print(mainObj);
            return;
        }
        ExecuteReverseBalance(fightkey);

        ExecuteResult("DELETE FROM tblfightlogs where fightkey='"+fightkey+"'");
        ExecuteResult("DELETE FROM tblcreditledger where appreference='"+fightkey+"'");
        
        boolean isMeron = (result.equals("M") ? true : false);
        boolean isDraw = (result.equals("D") ? true : false);
        boolean isWala = (result.equals("W") ? true : false);

        boolean isCancelled = false;
        String cancelledReason = "";

        ArrayList operatorList = new ArrayList();
        operatorList = getActiveOperator();

        ExecuteResult("update tblfightbets set win=0 where fightkey='"+fightkey+"'");
        
        for (int i=0; i < operatorList.size(); i++){
            String operatorid = operatorList.get(i).toString();
            OperatorInfo operator = new OperatorInfo(operatorid);

            ErrorFightOdds fd = new ErrorFightOdds(fightkey, operatorid);
            double oddMeron = fd.oddMeron;
            double oddWala = fd.oddWala;
 
            ExecuteResult("update tblfightbets set win=1 where fightkey='"+fightkey+"' and bet_choice='"+result+"' and operatorid='"+operatorid+"'");
            ExecuteComputeBets(operatorid, fightkey, result, isDraw, isCancelled, cancelledReason,  oddMeron, oddWala);
           
           
            FightSummary fs = new FightSummary(fightkey, operatorid);
            double totalPlayerBets = fs.totalMeron + fs.totalDraw + fs.totalWala;
            
            ExecuteResult("DELETE from tblfightsummary where fightkey='"+fightkey+"' and operatorid='"+operatorid+"'");
            ExecuteResult("INSERT into tblfightsummary set " 
                        + " operatorid='"+operatorid+"', "
                        + " arenaid='"+arenaid+"',"
                        + " eventid='"+eventid+"', "
                        + " eventkey='"+eventkey+"', "
                        + " fightkey='"+fightkey+"', "
                        + " fightnumber='"+fightnumber+"', "
                        + " postingdate='"+postingdate+"', "
                        + " bettors_meron='"+fs.countMeron+"', "
                        + " bettors_draw='"+fs.countDraw+"', "
                        + " bettors_wala='"+fs.countWala+"', "
                        + " total_meron='"+fs.totalMeron+"', "
                        + " total_draw='"+fs.totalDraw+"', "
                        + " total_wala='"+fs.totalWala+"', "
                        + " total_bets='"+ totalPlayerBets +"', "
                        + " odd_meron='"+oddMeron+"', "
                        + " odd_wala='"+oddWala+"', "
                        + " result='"+result+"', "
                        + " win_amount="+fs.totalWinAmount+", " 
                        + " lose_amount="+fs.totalLoseAmount+", " 
                        + " payout_amount="+fs.totalPayout+", " 
                        + " gros_ge_rate='"+GlobalFightCommission+"', " 
                        + " gros_ge_total="+ (isDraw || isCancelled ? 0 : (totalPlayerBets) * GlobalFightCommission) +", " 
                        + " gros_op_rate='"+operator.op_com_rate +"', " 
                        + " gros_op_total="+(isDraw || isCancelled ? 0 : (totalPlayerBets) * operator.op_com_rate )+", " 
                        + " gros_be_rate='"+operator.be_com_rate+"', " 
                        + " gros_be_total="+(isDraw || isCancelled ? 0 : (totalPlayerBets) * operator.be_com_rate)+", "
                        + " datetrn=current_timestamp, "
                        + " trnby='ADMIN'");
        }
        
        //finalizing entries and transfer log entries
        BackupBetsTable(fightkey);
        int done_bets = CountQry("tblfightbets2", "fightkey='"+fightkey+"'");
    
        if(totaltrn != done_bets){
            mainObj.put("status", "ERROR");
            mainObj.put("message","An error encounter while executing result confirmation. Please try again");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        NotifyPlayersResult(fightkey, eventid, fightnumber, sessionid, referenceno);
        
        //start new fight
        ExecuteResult("DELETE from tblfightbets where fightkey='"+fightkey+"'"); 
        ExecuteQuery("UPDATE tblfightresult set result='"+result+"' where fightkey='"+fightkey+"';");

        mainObj.put("status", "OK");
        mainObj.put("message","Winning scores and result has been successfully reversed!");
        out.print(mainObj);

        apiObj = api_event_info(apiObj, eventid);
        apiObj = api_result_info(apiObj, eventid);
        PusherPost(eventid, apiObj);

    }else if(x.equals("cancel_result")){
        String fightkey = request.getParameter("fightkey");

        if(isCancelled(fightkey)){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Fight number is already cancelled!");
            mainObj.put("errorcode", "101");
            out.print(mainObj);
            return;
        }

        FightSummaryDetails fsd = new FightSummaryDetails(fightkey);
        String message_return_winning = "auto deduct - arena error posting result (fight#"+fsd.fightnumber+" cancelled)";
        String message_return_bets = "return bets - arena error posting result (fight#"+fsd.fightnumber+" cancelled)";

        /*perform deduct winning score*/
        ResultSet rst_deduct = null;  
        rst_deduct =  SelectQuery("SELECT operatorid, accountid, (select fullname from tblsubscriber where accountid=a.accountid) as fullname, ROUND(sum(if(win,payout_amount,0)),2) as totalpayout FROM `tblfightbets2` as a where fightkey='"+fightkey+"' and win=1 group by accountid");
        while(rst_deduct.next()){
            double amount = Double.parseDouble(rst_deduct.getString("totalpayout"));
            String operatorid = rst_deduct.getString("operatorid");
            String accountid = rst_deduct.getString("accountid");
            String fullname = rst_deduct.getString("fullname");

            ExecuteSetScore(operatorid, sessionid, fightkey, accountid, fullname, "DEDUCT", amount, message_return_winning, userid);
        }
        rst_deduct.close();

        /*perform return bet score*/
        ResultSet rst_add = null;  
        rst_add =  SelectQuery("SELECT operatorid, accountid, (select fullname from tblsubscriber where accountid=a.accountid) as fullname, sum(bet_amount) as totalbets FROM `tblfightbets2` as a where fightkey='"+fightkey+"' group by accountid");
        while(rst_add.next()){
            double amount = Double.parseDouble(rst_add.getString("totalbets"));
            String operatorid = rst_add.getString("operatorid");
            String accountid = rst_add.getString("accountid");
            String fullname = rst_add.getString("fullname");

            ExecuteSetScore(operatorid, sessionid, fightkey, accountid, fullname, "ADD", amount, message_return_bets, userid);
        }
        rst_add.close();

        ExecuteQuery("UPDATE tblfightsummary set result='C' where fightkey='"+fightkey+"';");
        ExecuteQuery("UPDATE tblfightresult set result='C' where fightkey='"+fightkey+"';");

        if(CountQry("tblfightbets2", "fightkey='"+fightkey+"'") > 0){
            ExecuteQuery("DELETE FROM tblfightbetserror where fightkey='"+fightkey+"';");
            ExecuteQuery("INSERT INTO tblfightbetserror (operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason) " 
                        + " SELECT operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason FROM tblfightbets2 where fightkey='"+fightkey+"' and dummy=0");
            
            ExecuteQuery("DELETE FROM tblfightbets2 where fightkey='"+fightkey+"';");
        }
        
        mainObj.put("status", "OK");
        mainObj.put("message","Winning scores has been reversed and result successfully cancelled!");
        out.print(mainObj);
       
    }else if(x.equals("fight_result_logs")){
        String operatorid = request.getParameter("operatorid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = LoadFightResultLogs(mainObj, operatorid, datefrom, dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("fight_transaction")){
        String operatorid = request.getParameter("operatorid");
        String fightkey = request.getParameter("fightkey");
        String mode = request.getParameter("mode");

        mainObj.put("status", "OK");
        mainObj = LoadFightResultDetails(mainObj, operatorid, fightkey);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("cancelled_fight_logs")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = LoadCancelledFightLogs(mainObj, datefrom, dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("missing_bet_logs")){
        String operatorid = request.getParameter("operatorid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = LoadMissingBetLogs(mainObj, operatorid, datefrom, dateto);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("load_images")){
        mainObj.put("status", "OK");
        mainObj = LoadImages(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("upload_image")){
        String filename = request.getParameter("filename");
        String extension = request.getParameter("extension");
        String imagebinary = request.getParameter("imagebinary");
         
        if(isImageExists(filename)){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Filename is already exists!");
            mainObj.put("errorcode", "101");
            out.print(mainObj);
            return;
        }

        ServletContext serveapp = request.getSession().getServletContext();
        String imageurl = AttachedImage(serveapp, imagebinary, filename + extension);
        
        ExecuteQuery("insert into tblimages set filename='"+filename+"', extension='"+extension+"', imageurl='"+imageurl+"'");

        mainObj.put("status", "OK");
        mainObj = LoadImages(mainObj);
        mainObj.put("message", "Image successfully uploaded");
        out.print(mainObj);

     }else if(x.equals("delete_image")){
        String id = request.getParameter("id");
        
        ImageInfo img = new ImageInfo(id);
        ServletContext serveapp = request.getSession().getServletContext();
        DeleteImage(serveapp, img.filename);
        
        ExecuteQuery("DELETE from tblimages where id='"+id+"'");

        mainObj.put("status", "OK");
        mainObj = LoadImages(mainObj);
        mainObj.put("message", "Image successfully deleted");
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
    logError("dashboard-x-tools",e.toString());
}
%>

<%!public boolean isCancelled(String fightkey) {
    return CountQry("tblfightsummary", "fightkey='"+fightkey+"' and result='C'") > 0;
  }
%>

<%!public boolean isTransactionFound(String fightkey) {
    return CountQry("tblfightbets", "fightkey='"+fightkey+"'") > 0;
  }
%>

<%!public boolean isImageExists(String filename) {
    return CountQry("tblimages", "filename='"+filename+"'") > 0;
  }
%>


<%!public JSONObject LoadFightResultLogs(JSONObject mainObj, String operatorid, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "fight_result", "select eventid,fightkey,fightnumber, case  when result='M' then 'MERON'  when result='D' then 'DRAW' when result='W' then 'WALA' else 'CANCELLED' end as result, "
                            + " date_format(datetrn,'%Y-%m-%d') as 'date', " 
                            + " date_format(datetrn,'%r') as 'time' " 
                            + " from tblfightresult as a where date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'");
    return mainObj;
}
%>

<%!public JSONObject LoadFightResultDetails(JSONObject mainObj, String operatorid, String fightkey) {
    mainObj = DBtoJson(mainObj, "fight_transaction", "select accountid, " 
                              + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                              + " eventid, " 
                              + " fightnumber, " 
                              + " case when bet_choice='M' then 'Meron' when bet_choice='W' then 'Wala' else 'Draw' end as 'bet_choice', " 
                              + " bet_amount, "
                              + " case when result='M' then 'Meron' when result='W' then 'Wala' else 'Draw' end as 'result', "
                              + " if(win, 'WIN', if(result='D','CANCELLED','LOSS')) as 'bet_status', "
                              + " concat(ROUND(odd,3),'%') as 'odd', "
                              + " payout_amount, "
                              + " date_format(datetrn,'%Y-%m-%d') as 'date', " 
                              + " date_format(datetrn,'%r') as 'time' "
                              + " from tblfightbets2 as a where operatorid='"+operatorid+"' and fightkey='"+fightkey+"' and dummy=0 order by id asc");
    return mainObj;
}
%>

<%!public JSONObject LoadCancelledFightLogs(JSONObject mainObj, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "cancelled_fight", "select eventid,fightkey,fightnumber, "
                            + " if((select count(*) from tblfightlogs where fightkey=a.fightkey)>0,(select count(*) from tblfightlogs where fightkey=a.fightkey  and (accountid<> (select dummy_account_1 from tbloperator where companyid=a.operatorid) and accountid<> (select dummy_account_2 from tbloperator where companyid=a.operatorid))),(select count(*) from tblfightlogs2 where fightkey=a.fightkey  and (accountid<> (select dummy_account_1 from tbloperator where companyid=a.operatorid) and accountid<> (select dummy_account_2 from tbloperator where companyid=a.operatorid)))) as return_count,"
                            + " (select count(distinct accountid) from tblfightbets2 where fightkey=a.fightkey  and (accountid<> (select dummy_account_1 from tbloperator where companyid=a.operatorid) and accountid<> (select dummy_account_2 from tbloperator where companyid=a.operatorid))) as bets_count,"
                            + " (select count(*) from tblcreditledger where appreference=a.fightkey and (accountid<> (select dummy_account_1 from tbloperator where companyid=a.operatorid) and accountid<> (select dummy_account_2 from tbloperator where companyid=a.operatorid))) as ledger_count,"
                            + " date_format(datetrn,'%Y-%m-%d') as 'date', " 
                            + " date_format(datetrn,'%r') as 'time' " 
                            + " from tblfightsummary as a where result='C' and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"'");
    return mainObj;
}
%>


<%!public JSONObject LoadMissingBetLogs(JSONObject mainObj, String operatorid,  String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "missing_bet", "select  date_format(datetrn,'%Y-%m-%d') as 'date', eventid, fightkey, fightnumber, " 
                              + " count(*) totalbettors, "
                              + " sum(bet_amount) totalbets "
                              + " from tblfightbets as a where operatorid='"+operatorid+"' and "
                              + " fightkey not in (select fightkey from tblevent where event_active=1) and dummy=0 and " 
                              + " date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' group by fightkey");
    return mainObj;
}
%>

<%!public JSONObject LoadImages(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "images", "select * from tblimages");
    return mainObj;
}
%>

<%!public void ExecuteReverseBalance(String fightkey){
    try{
        ResultSet rst = null; 
        rst = SelectQuery("select accountid, credit from tblcreditledger where appreference='"+fightkey+"'");
        while(rst.next()){
            String uid = rst.getString("accountid"); 
            double amount = rst.getDouble("credit");
            ReverseBalance(uid, amount);
        }
        rst.close();
    }catch(SQLException e){
        logError("ExecuteReverseBalance",e.toString());
    }
}%>

<%!public void RestoreBetsTable(String fightkey) {
    if(CountQry("tblfightbets2", "fightkey='"+fightkey+"'") > 0){
        ExecuteResult("DELETE from tblfightbets where fightkey='"+fightkey+"'");

        ExecuteResult("INSERT INTO tblfightbets (operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason) " 
            + " SELECT operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,datetrn,cancelled,cancelledreason FROM tblfightbets2 where fightkey='"+fightkey+"'");
    }
}
%>

<%!public void BackupBetsTable(String fightkey) {
    if(CountQry("tblfightbets", "fightkey='"+fightkey+"'") > 0){
        ExecuteResult("DELETE from tblfightbets2 where fightkey='"+fightkey+"'");

        ExecuteResult("INSERT INTO tblfightbets2 (operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason) " 
            + " SELECT operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason FROM tblfightbets where fightkey='"+fightkey+"' and dummy=0");
    }
}
%>
