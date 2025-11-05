<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xGameModule.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
   JSONObject apiObj = new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String deviceid = request.getParameter("deviceid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || deviceid.isEmpty() || sessionid.isEmpty()){
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
        return;

    }else if(isControllerRemoved(deviceid)){
        mainObj.put("status", "BLOCKED");
        mainObj.put("message","Your controller was removed by administrator!");
        mainObj.put("errorcode", "100");
        out.print(mainObj);
        return;

    }else if(isControllerBlocked(deviceid)){
        mainObj.put("status", "BLOCKED");
        mainObj.put("message","Your controller was blocked by administrator!");
        mainObj.put("errorcode", "100");
        out.print(mainObj);
        return;
    }

    PushFirebaseUsers(GlobalDefaultOperator, false);

    if(x.equals("change_fight_status")){ 
        String eventid = request.getParameter("eventid");
        String status = request.getParameter("status");
        EventInfo event = new EventInfo(eventid, true);

        ArrayList operatorList = new ArrayList();
        operatorList = getActiveOperator();

        String arenaid = event.arenaid;
        String eventkey = event.eventkey;
        String fightkey = event.fightkey;
        String postingdate = event.postingdate;
        String fightnumber = event.fightnumber;
        
        if(event.status.equals("closed") || event.status.equals("result")){
            if(!status.equals("cancelled")){
                mainObj.put("status", "OK");
                mainObj.put("fightkey", fightkey);
                mainObj = getEventInfo(mainObj, eventid);
                mainObj = CurrentBetSummaryAll(mainObj, fightkey);
                mainObj.put("message","request returned valid");
                out.print(mainObj);
                return;
            }
        }

        boolean betWatcherExecuted = false;
        if(status.equals("cancelled")){
            ExecuteCancelledFight(sessionid, deviceid, arenaid, eventid, eventkey, fightkey, postingdate, fightnumber, "");
            apiObj = api_result_info(apiObj, eventid);
        }else{
            ExecuteResult("update tblevent set current_status='"+status+"' where eventid='"+eventid+"'");
        }

        if(status.equals("closed")){ /*trigger bet watcher*/
            for (int i=0; i < operatorList.size(); i++){
                String operatorid = operatorList.get(i).toString();
                OperatorInfo operator = new OperatorInfo(operatorid);
                FightDetails fd = new FightDetails(fightkey, operatorid, operator.betwatcherincludedummybets);
                double totalBetMeron = fd.totalMeron;
                double totalBetWala = fd.totalWala;

                double totalAllBets = 0; double ratioMeron = 0; double ratioWala = 0;
                double oddMeron = 0; double oddWala = 0;

                if(totalBetMeron != 0 || totalBetWala != 0){
                    totalAllBets = totalBetMeron + totalBetWala;
                    ratioMeron =  totalAllBets / totalBetMeron;
                    ratioWala =  totalAllBets / totalBetWala;
                    
                    oddMeron = ratioMeron-(ratioMeron * GlobalFightCommission);
                    oddWala = ratioWala-(ratioWala * GlobalFightCommission);

                    if(operator.enableBetWatcher && isBetWatcherAvailable(operator.betwacherid)){
                        if(oddWala <= operator.betwatcherodds){ /*execute bet watcher for meron*/
                            double randomBet = Double.parseDouble(RandomBetPercentage()) / 100;
                            double betDifference = (totalBetWala - totalBetMeron);
                            double betToAdd = betDifference * randomBet;

                            if(betToAdd <= operator.betwatchermaxamount){
                                Random rand = new Random();
                                int method =  rand.nextInt(10 - 1) + 1;

                                if(method % 2 == 0){
                                    RandomDummyAccount dummy = new RandomDummyAccount();
                                    ExecuteRecordAutoBet(eventid, operatorid, fightkey, fightnumber, totalBetMeron, totalBetWala, betDifference, "M", randomBet, betToAdd);
                                    ExecutePostBet("android",eventid, sessionid, sessionid, operatorid, operator.betwacherid, "M",Val(betToAdd), "", true, false, false, false, dummy.accountno, dummy.dummyname);
                                    betWatcherExecuted = true;
                                }
                            }
                        }

                        if(oddMeron <= operator.betwatcherodds){ /*execute bet watcher for wala*/
                            double randomBet = Double.parseDouble(RandomBetPercentage()) / 100;
                            double betDifference = (totalBetMeron - totalBetWala);
                            double betToAdd = betDifference * randomBet;

                            if(betToAdd <= operator.betwatchermaxamount){
                                Random rand = new Random();
                                int method =  rand.nextInt(10 - 1) + 1;

                                if(method % 2 == 0){
                                    RandomDummyAccount dummy = new RandomDummyAccount();
                                    ExecuteRecordAutoBet(eventid, operatorid, fightkey, fightnumber, totalBetMeron, totalBetWala, betDifference, "W", randomBet, betToAdd);
                                    ExecutePostBet("android",eventid, sessionid, sessionid, operatorid, operator.betwacherid, "W", Val(betToAdd), "", true, false, false, false, dummy.accountno, dummy.dummyname);
                                    betWatcherExecuted = true;
                                }
                            }
                        }
                    }

                    if(operator.enablebetbalancer){ /*execute bet balancer*/
                        boolean isMeronFound = isLargeBetExists(operatorid, fightkey, "M" ,operator.betbalanceramount);
                        boolean isWalaFound = isLargeBetExists(operatorid, fightkey, "W", operator.betbalanceramount);

                        if(isMeronFound && isWalaFound){
                        }else{
                            Random rand = new Random();
                            int method1 =  rand.nextInt(10 - 1) + 1;
                            int method2 =  rand.nextInt(10 - 1) + 1;

                            if(method1 % 2 == 0){
                                ExecuteBetBalancer(eventid, operatorid, fightkey, sessionid, isMeronFound, isWalaFound, operator.dummy_account_1, operator.dummy_account_2);
                            }else{
                                if(method2 % 2 == 0){
                                    ExecuteBetBalancer(eventid, operatorid, fightkey, sessionid, isMeronFound, isWalaFound, operator.dummy_account_1, operator.dummy_account_2);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        UpdateFightNumber(fightkey, fightnumber);
        mainObj.put("status", "OK");
        mainObj.put("fightkey", fightkey);
        mainObj = getEventInfo(mainObj, eventid);
        mainObj = CurrentBetSummaryAll(mainObj, fightkey);
        mainObj.put("message","request returned valid");
        out.print(mainObj);

        apiObj = api_event_info(apiObj, eventid);
        PusherPost(eventid, apiObj);

        for (int i=0; i < operatorList.size(); i++){
            String operatorid = operatorList.get(i).toString();
            
            JSONObject obj_operator = new JSONObject();
            obj_operator.put("plasada", GlobalFightCommission);
            obj_operator = api_current_fight_summary(obj_operator, fightkey, operatorid);
            PusherPost(eventid, obj_operator);
        }

        RefundErrorBets(arenaid,fightkey);

    }else if(x.equals("post_win")){ 
        String eventid = request.getParameter("eventid");
        String fightkey = request.getParameter("fightkey");
        String result = request.getParameter("result");

        EventInfo event = new EventInfo(eventid, true);
        if(event.status.equals("closed")){
            ExecuteResult("update tblevent set current_status='result', fight_result='"+result+"' where eventid='"+eventid+"'");
        }

        mainObj.put("status", "OK");
        mainObj = getEventInfo(mainObj, eventid);
        mainObj.put("message","request returned valid");
        out.print(mainObj);

        apiObj = api_event_info(apiObj, eventid);
        PusherPost(eventid, apiObj);

    }else if(x.equals("post_cancel")){ 
        String eventid = request.getParameter("eventid");
    
        EventInfo event = new EventInfo(eventid, true);
        if(event.status.equals("result")){
            ExecuteResult("update tblevent set current_status='closed', fight_result='' where eventid='"+eventid+"'");
        }
       
        mainObj.put("status", "OK");
        mainObj = getEventInfo(mainObj, eventid);
        mainObj.put("message","request returned valid");
        out.print(mainObj);

        apiObj = api_event_info(apiObj, eventid);
        PusherPost(eventid, apiObj);

    }else if(x.equals("post_result")){ 
        String eventid = request.getParameter("eventid");
        
        String newFightkey = "";

        EventInfo event = new EventInfo(eventid, true);
        String result = event.result;
        String arenaid = event.arenaid;
        String eventkey = event.eventkey;
        String fightkey = event.fightkey;
        String postingdate = event.postingdate;
        String fightnumber = event.fightnumber;

        if(event.status.equals("result")){
            boolean isMeron = (result.equals("M") ? true : false);
            boolean isDraw = (result.equals("D") ? true : false);
            boolean isWala = (result.equals("W") ? true : false);

            boolean isCancelled = false;
            String cancelledReason = "";

            ArrayList operatorList = new ArrayList();
            operatorList = getActiveOperator();

            int totaltrn = CountQry("tblfightbets", "fightkey='"+fightkey+"' and dummy=0");
            ExecuteResult("update tblfightbets set win=0 where fightkey='"+fightkey+"'");
            
            String referenceno = getSystemSeriesID("series_result", 7);
            LogFightResult(referenceno, arenaid, eventid, eventkey, fightkey, fightnumber, postingdate, result);

            for (int i=0; i < operatorList.size(); i++){
                String operatorid = operatorList.get(i).toString();
                OperatorInfo operator = new OperatorInfo(operatorid);

                FightDetails fd = new FightDetails(fightkey, operatorid, true);
                int bettorMeron = fd.countMeron;
                int bettorDraw = fd.countDraw;
                int bettorWala = fd.countWala;
                double totalBetMeron = fd.totalMeron;
                double totalBetDraw = fd.totalDraw;
                double totalBetWala = fd.totalWala;

                double totalAllBets = 0; double ratioMeron = 0; double ratioWala = 0;
                double oddMeron = 0; double oddWala = 0;
                
                if(isDraw){
                    ExecuteResult("update tblfightbets set win=1 where fightkey='"+fightkey+"' and bet_choice='D' and operatorid='"+operatorid+"'");
                }

                if(totalBetMeron > 0 && totalBetWala > 0){
                    totalAllBets = totalBetMeron + totalBetWala;
                    ratioMeron =  totalAllBets / totalBetMeron;
                    ratioWala =  totalAllBets / totalBetWala;
                    
                    oddMeron = ratioMeron-(ratioMeron * GlobalFightCommission);
                    oddWala = ratioWala-(ratioWala * GlobalFightCommission);

                    if(oddMeron < 1.3 || oddWala < 1.3){  
                        isCancelled = true;
                        cancelledReason = (oddMeron < 1.3 ? "Meron" : "Wala") + " odds is 1.2%";
                    }else{
                        isCancelled = false;
                        ExecuteResult("update tblfightbets set win=1 where fightkey='"+fightkey+"' and bet_choice='"+result+"' and operatorid='"+operatorid+"'");
                    }
                }else{
                    isCancelled = true;
                    cancelledReason = "No bets from other side";
                }
            
                ExecuteComputeBets(operatorid, fightkey, result, isDraw, isCancelled, cancelledReason,  oddMeron, oddWala);
                if(isDraw){
                    ExecuteReturnBetsDraw(operatorid, fightkey, sessionid,referenceno);
                }else if(isCancelled){
                    ExecuteReturnBetsCancelled(operatorid, fightkey,sessionid,referenceno, false, cancelledReason);
                }

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
                            + " trnby='"+deviceid+"'");
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
            newFightkey = UUID.randomUUID().toString();
            String newFightNumber = String.valueOf(Integer.parseInt(fightnumber) + 1);
            ExecuteResult("DELETE from tblfightbets where fightkey='"+fightkey+"'"); 
            ExecuteResult("UPDATE tblevent set current_status='standby',fightkey='"+eventid+"-"+newFightNumber+"-"+newFightkey+"',fightnumber='"+newFightNumber+"' where eventid='"+eventid+"'"); 
        }

        mainObj.put("status", "OK");
        mainObj = getEventInfo(mainObj, eventid);
        mainObj.put("message","request returned valid");
        out.print(mainObj);

        apiObj = api_event_info(apiObj, eventid);
        apiObj = api_result_info(apiObj, eventid);
        PusherPost(eventid, apiObj);

        RefundErrorBets(arenaid, newFightkey);

    }else if(x.equals("get_player_bets")){ 
        String fightkey = request.getParameter("fightkey");
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = FetchCurrentBets(mainObj, fightkey, operatorid);
        mainObj.put("message","request returned valid");
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
      logError("controller-x-game",e.getMessage());
}
%>

 <%!public boolean isBetWatcherAvailable(String betwacherid) {
    if(CountQry("tblsubscriber", "accountid='"+betwacherid+"'") > 0){
        return true;
    }else{
         return false;
    }
  }
 %>

<%!public void ExecuteCancelledFight(String sessionid, String deviceid, String arenaid, String eventid, String eventkey, String fightkey, String postingdate, String fightnumber, String reason){
    ExecuteResult("update tblevent set current_status='cancelled' where eventid='"+eventid+"'");

    int totaltrn = CountQry("tblfightbets", "fightkey='"+fightkey+"'");
            
    String referenceno = getSystemSeriesID("series_result", 7);
    LogFightResult(referenceno, arenaid, eventid, eventkey, fightkey, fightnumber, postingdate, "C");

    ArrayList operator = new ArrayList();
    operator = getActiveOperator();
    for (int i=0; i < operator.size(); i++){
        String operatorid = operator.get(i).toString();
        LogCancelledFight(operatorid, arenaid, eventid, eventkey, fightkey, fightnumber, postingdate, deviceid);
        ExecuteReturnBetsCancelled(operatorid,fightkey,sessionid,referenceno, true, reason);
    }
    
    if(totaltrn > 0){
        ExecuteResult("update tblfightbets set cancelled=1, cancelledreason='Cancelled fight" + (reason.length() > 0 ? " (" + reason + ")" : "") + "', win_amount=0, lose_amount=0 where fightkey='"+fightkey+"'");
        BackupBetsTable(fightkey);
        ExecuteResult("DELETE from tblfightbets where fightkey='"+fightkey+"'"); 
    }

    int newFightNumber = Integer.parseInt(fightnumber) + 1;
    String newFightkey = UUID.randomUUID().toString();
    ExecuteResult("update tblevent set current_status='standby',fightkey='"+eventid+"-"+newFightNumber+"-"+newFightkey+"',fightnumber='"+newFightNumber+"' where eventid='"+eventid+"'");
}%>

<%!public void BackupBetsTable(String fightkey) {
    if(CountQry("tblfightbets", "fightkey='"+fightkey+"'") > 0){
        ExecuteResult("DELETE from tblfightbets2 where fightkey='"+fightkey+"'");
        ExecuteResult("DELETE from tblfightbetsdummy where fightkey='"+fightkey+"'");

        ExecuteResult("INSERT INTO tblfightbets2 (operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason) " 
            + " SELECT operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason FROM tblfightbets where fightkey='"+fightkey+"' and dummy=0");

        ExecuteResult("INSERT INTO tblfightbetsdummy (operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason) " 
            + " SELECT operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason FROM tblfightbets where fightkey='"+fightkey+"' and dummy=1");
    }
}
%>

<%!public void UpdateFightNumber(String fightkey, String fightnumber){
    ExecuteResult("UPDATE tblfightbets set fightnumber='"+fightnumber+"' where fightkey='"+fightkey+"'"); 
}%>

<%!public void ExecuteRecordAutoBet(String eventid, String operatorid, String fightkey, String fightnumber, double totalBetMeron, double totalBetWala, double betDifference, String choice, double autoBet, double betToAdd){
    ExecuteResult("insert into tblbetwatcher set eventid='"+eventid+"', operatorid='"+operatorid+"',fightkey='"+fightkey+"',fightnumber='"+fightnumber+"',total_meron='"+totalBetMeron+"',total_wala='"+totalBetWala+"',total_difference='"+betDifference+"',auto_bet_choice='"+choice+"',auto_bet_percent='"+autoBet+"',auto_bet_amount='"+betToAdd+"', datetrn=current_timestamp");
}%>

<%!public void ExecuteBetBalancer(String eventid, String operatorid, String fightkey, String sessionid, boolean isMeronFound, boolean isWalaFound, String dummy_account_1, String dummy_account_2){
    RandomDummyAccount dummy = new RandomDummyAccount();
    FinalBets finalBets = new FinalBets(operatorid, fightkey);
    
    if(isMeronFound){
        if(finalBets.oddMeron > 1.7){
            double random = Double.parseDouble(RandomBetBalancer()) / 100;
            double balancer = finalBets.totalMeron * random;
            ExecutePostBet("android",eventid, sessionid, sessionid, operatorid, dummy_account_1, "M", Val(balancer), "", false, true, false, false, dummy.accountno, dummy.dummyname);
        }
    }

    if(isWalaFound){
        if(finalBets.oddWala > 1.7){
            double random = Double.parseDouble(RandomBetBalancer()) / 100;
            double balancer = finalBets.totalWala * random;
            ExecutePostBet("android",eventid, sessionid, sessionid, operatorid, dummy_account_2, "W", Val(balancer), "", false, true, false, false, dummy.accountno, dummy.dummyname);
        }
    }
   
}%>

<%!public boolean isLargeBetExists(String operatorid, String fightkey, String bet_choice, double amount) {
    boolean found = false;
    try{
        ResultSet rst = SelectQuery("select sum(bet_amount) as total_bets from tblfightbets where operatorid='"+operatorid+"' and fightkey='"+fightkey+"' and bet_choice='"+bet_choice+"' and dummy=0 and banker=0 and test=0 group by accountid");
        while(rst.next()){
            double totalbets = rst.getDouble("total_bets");
            if(totalbets >= amount){
                found = true;
            }
        }
        rst.close();
    }catch(SQLException e){
        logError("module-islarge_bet_exists",e.toString());
    }
    return found;
  }
 %>


 