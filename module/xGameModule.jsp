<%!public void ExecutePostBet(String platform, String eventid, String sessionid, String appreference, String operatorid, String userid, String bet_choice, double bet_amount, String ws_selection, boolean banker, boolean dummy, boolean test, boolean promo, String display_id, String display_name) {
    AccountInfo account = new AccountInfo(userid);
    EventInfo event = new EventInfo(eventid, false);

    String transactionno = getOperatorSeriesID(operatorid,"series_fight_bet");
    String Command = " set operatorid='"+operatorid+"', "
                            + " accountid='"+userid+"', "
                            + " banker="+ banker +","
                            + " dummy="+ dummy +","
                            + " test="+ test +","
                            + " promo="+ promo +","
                            + " display_id='"+ display_id +"',"
                            + " display_name='"+ rchar(display_name) +"',"
                            + " sessionid='"+sessionid+"', "
                            + " appreference='"+appreference+"', "
                            + " platform='"+platform+"', "
                            + " masteragentid='"+account.masteragentid+"', "
                            + " agentid='"+account.agentid+"', "
                            + " arenaid='"+event.arenaid+"', " 
                            + " eventid='"+eventid+"', "
                            + " eventkey='"+eventid+"-"+event.eventkey+"', "
                            + " fightkey='"+event.fightkey+"', "
                            + " fightnumber='"+event.fightnumber+"', "
                            + " postingdate='"+event.postingdate+"', "
                            + " transactionno='"+transactionno+"', "
                            + " bet_choice='"+bet_choice+"', "
                            + " bet_amount='"+bet_amount+"', "
                            + " ws_selection='"+ws_selection+"', "
                            + " lose_amount='"+bet_amount+"', "
                            + " datetrn=current_timestamp";
    if(dummy){
        if(banker) LogLedgerDirect(userid, sessionid, appreference, transactionno, (banker ? "banker" : "choose") +" bet "+ (bet_choice.equals("M") ? "meron" : (bet_choice.equals("W") ? "wala" : "draw")) +"  (fight#"+event.fightnumber+"@"+event.arena+")",bet_amount,0, userid);    
        ExecuteDummy("insert into tblfightbets " + Command);
    }else{
        ExecuteBet("insert into tblfightbets " + Command);
        ExecuteResult("UPDATE tblsubscriber set winstrike_selection='"+ws_selection+"' where accountid='"+userid+"'");
        //ExecuteBet("insert into tblfightbetslogs " + Command);
        if(isBetRecordFound(userid, sessionid, appreference, event.fightkey, transactionno, bet_amount)){
            LogLedger(userid, sessionid, appreference, transactionno, (banker ? "banker" : "choose") +" bet "+ (bet_choice.equals("M") ? "meron" : (bet_choice.equals("W") ? "wala" : "draw")) +"  (fight#"+event.fightnumber+"@"+event.arena+")",bet_amount,0, userid);    
        }else{
            logError("error-post-bet", "Fightkey: " + event.fightkey + ", accountid: " + userid + ", transactionno: " + transactionno +  ", amount: " + bet_amount);
        }
    }
  }
 %>

<%!public boolean isBetRecordFound(String accountid, String sessionid, String appreference, String fightkey, String transactionno, double amount){
    return CountQry("tblfightbets", "accountid='"+accountid+"' and sessionid='"+sessionid+"' and appreference='"+appreference+"' and fightkey='"+fightkey+"' and transactionno='"+transactionno+"' and bet_amount="+amount+"") > 0;
}%>

<%!public void ExecuteComputeBets(String operatorid, String fightkey, String result, boolean isDraw, boolean isCancelled, String cancelledReason,  double oddMeron, double oddWala){
     OperatorInfo operator = new OperatorInfo(operatorid);

     ExecuteResult("update tblfightbets set " 
                        + " result='"+result+"', "
                        + " odd=if(win,if(bet_choice='M',"+oddMeron+","+oddWala+"), if(bet_choice='M',"+oddMeron+","+oddWala+")),"
                        + " win_amount="+(isDraw || isCancelled ? "0" : "if(win,(bet_amount*if(bet_choice='M',"+oddMeron+","+oddWala+"))-bet_amount,0)")+", " 
                        + " lose_amount="+(isDraw || isCancelled ? "0" : "if(win,0,bet_amount)")+", " 
                        + " payout_amount=if(win,(bet_amount*if(bet_choice='M',"+oddMeron+","+oddWala+")),0), " 
                        + " gros_ge_rate='"+GlobalFightCommission+"', " 
                        + " gros_ge_total="+(isDraw || isCancelled ? "0" : "(bet_amount*"+GlobalFightCommission+")")+", " 
                        + " gros_op_rate='"+operator.op_com_rate+"', " 
                        + " gros_op_total="+(isDraw || isCancelled ? "0" : "(bet_amount*"+operator.op_com_rate+")")+", " 
                        + " gros_be_rate='"+operator.be_com_rate+"', " 
                        + " gros_be_total="+(isDraw || isCancelled ? "0" : "(bet_amount*"+operator.be_com_rate+")")+ ", "
                        + " cancelled=" + isCancelled + ", "  
                        + " cancelledreason='" + (isDraw ? "Draw fight" : cancelledReason) + "' "  
                        + " where operatorid='"+operatorid+"' and fightkey='"+fightkey+"' and (bet_choice='M' or bet_choice='W')");

    ExecuteResult("update tblfightbets set " 
                        + " result='"+result+"', "
                        + " odd="+operator.draw_rate+","
                        + " win_amount=if(win,(bet_amount*"+operator.draw_rate+"),0), " 
                        + " lose_amount=if(win,0,bet_amount), " 
                        + " payout_amount=if(win,(bet_amount*"+operator.draw_rate+")+bet_amount,0), " 
                        + " gros_ge_rate=if(win,0,'"+GlobalFightCommission+"'), " 
                        + " gros_ge_total=if(win,0,(bet_amount*"+GlobalFightCommission+")), " 
                        + " gros_op_rate=if(win,0,'"+operator.op_com_rate+"'), " 
                        + " gros_op_total=if(win,0,(bet_amount*"+operator.op_com_rate+")), " 
                        + " gros_be_rate=if(win,0,'"+operator.be_com_rate+"'), " 
                        + " gros_be_total=if(win,0,(bet_amount*"+operator.be_com_rate+")) " 
                        + " where operatorid='"+operatorid+"' and fightkey='"+fightkey+"' and bet_choice='D'");
}%>

<%!public JSONObject FetchMyBet(JSONObject mainObj, String accountid, String fightkey) {
    mainObj = DBtoJson(mainObj, "score_bet", "SELECT eventid,fightnumber,transactionno,bet_choice,bet_amount FROM tblfightbets where accountid='"+accountid+"' and fightkey='"+fightkey+"';");
    return mainObj;
 }
 %>
 
<%!public JSONObject FetchCurrentBets(JSONObject mainObj, String fightkey, String operatorid) {
    mainObj = DBtoJson(mainObj, "current_bets", "SELECT operatorid, (select arenaname from tblarena where arenaid=a.arenaid) as arena, display_id, display_name, bet_choice, bet_amount FROM tblfightbets as a where fightkey='"+fightkey+"' and operatorid='"+operatorid+"';");
    return mainObj;
}
%>
 
<%!public void ExecuteReturnBetsDraw(String operatorid, String fightkey, String session, String referenceno){
    try{
        ResultSet rst = null; 
        rst = SelectQuery("select dummy,arenaid,(select arenaname from tblarena where arenaid=a.arenaid) as arena,eventid,accountid,appreference,fightnumber,sum(bet_amount) totalbet from tblfightbets as a where operatorid='"+operatorid+"' and fightkey='"+fightkey+"' and (bet_choice='M' or bet_choice='W') group by accountid");
        while(rst.next()){
            String uid = rst.getString("accountid");
            String arena = rst.getString("arena");
            String arenaid = rst.getString("arenaid");
            String eventid = rst.getString("eventid");
            String fightnumber = rst.getString("fightnumber");
            String sessionid = rst.getString("appreference");
            double totalbet = rst.getDouble("totalbet");
            boolean dummy = rst.getBoolean("dummy");

            String ledger = "return score (draw fight#"+fightnumber+"@"+arena+")";

            if(!isLogFightFound(uid,sessionid,arenaid,eventid,fightkey,ledger,totalbet)){
                LogFightNotification(uid,sessionid,arenaid,eventid,fightkey,ledger,totalbet);
                if(!dummy) LogLedgerDirect(uid, sessionid, fightkey, referenceno, ledger, 0, totalbet, "CONTROLLER");
            }
            
        }
        rst.close();
    }catch(SQLException e){
        logError("ExecuteReturnBetsDraw",e.toString());
    }
}%>

<%!public void ExecuteReturnBetsCancelled(String operatorid, String fightkey, String session, String referenceno, boolean notify, String reason){
    try{
        ResultSet rst = null; 
        rst = SelectQuery("select dummy,banker,test,accountid,arenaid,(select arenaname from tblarena where arenaid=a.arenaid) as arena,eventid,appreference,platform,fightnumber, bet_choice, sum(bet_amount) totalbet, ws_selection from tblfightbets as a where operatorid='"+operatorid+"' and fightkey='"+fightkey+"' group by accountid");
        while(rst.next()){
            String uid = rst.getString("accountid");
            String arena = rst.getString("arena");
            String arenaid = rst.getString("arenaid");
            String eventid = rst.getString("eventid");
            String sessionid = rst.getString("appreference");
            String fightnumber = rst.getString("fightnumber");
            String bet_choice = rst.getString("bet_choice");
            double totalbet = rst.getDouble("totalbet");
            String platform = rst.getString("platform");
            boolean dummy = rst.getBoolean("dummy");
            boolean banker = rst.getBoolean("banker");
            boolean test = rst.getBoolean("test");
            String ws_selection = rst.getString("ws_selection");

            String ledger = "return score (cancelled fight#"+fightnumber+"@"+ arena + (reason.length() > 0 ? " - " + reason : "") + ")";

            if(!isLogFightFound(uid,sessionid,arenaid,eventid,fightkey,ledger,totalbet)){
                if(!dummy && !banker && !test) VerifyWinStreak(ws_selection, uid, fightnumber, arenaid, eventid, bet_choice, totalbet, "C");
                LogFightNotification(uid,sessionid,arenaid,eventid,fightkey,ledger,totalbet);
                if(!dummy) LogLedgerDirect(uid, sessionid, fightkey, referenceno, ledger, 0, totalbet, "CONTROLLER");
            }

            if(notify){
                String event_desc = "Arena " +  rst.getString("arena") + " - Fight #" + rst.getString("fightnumber");
                SendResultNotification(platform, "Return Bets", rst.getString("accountid"), "C", event_desc, rst.getDouble("totalbet"), 0,  true, "Your bets is cancelled! " + reason);
            }
        }
        rst.close();

    }catch(SQLException e){
        logError("ExecuteReturnBetsCancelled",e.toString());
    }
}%>


<%!public void NotifyPlayersResult(String fightkey, String eventid, String fightnumber, String session, String referenceno){
    try{
        ResultSet rst = null; 
        rst = SelectQuery("select accountid,appreference,arenaid,dummy,banker,test,platform, MAX(IF(win,ROUND(odd,3),0)) as win_odd,IF(!win,ROUND(odd,3),0) as loss_odd, result, " 
                                + " (select arenaname from tblarena where arenaid=a.arenaid) as arena, " 
                                + " sum(bet_amount) totalbet, " 
                                + " ws_selection, "
                                + " bet_choice, " 
                                + " if(win,bet_choice,'') win_choice, " 
                                + " sum(if(win,bet_amount,0)) totalwinbet, " 
                                + " sum(if(cancelled,bet_amount,0)) as totalcancelled, " 
                                + " ROUND(sum(if(win,win_amount,0)),2) as totalwin, "
                                + " ROUND(sum(lose_amount),2) as totallose, "
                                + " ROUND(sum(if(win,payout_amount,0)),2) as totalpayout, "
                                + " cancelledreason " 
                                + " from tblfightbets as a where fightkey='"+fightkey+"' group by accountid");
        while(rst.next()){
            boolean execute_notify = false;
            String description = "";
            String uid = rst.getString("accountid");
            String arena = rst.getString("arena");
            String arenaid = rst.getString("arenaid");
            String sessionid = rst.getString("appreference");
            String bet_choice = rst.getString("bet_choice");
            String win_choice = rst.getString("win_choice");
            String odd = rst.getString("win_odd");
            String result = rst.getString("result");
            String cancelledreason = rst.getString("cancelledreason");
            double totalbet = rst.getDouble("totalbet");
            double totalwinbet = rst.getDouble("totalwinbet");
            double totalwin = rst.getDouble("totalwin");
            double totallose = rst.getDouble("totallose");
            double totalpayout = rst.getDouble("totalpayout");
            double totalcancelled = rst.getDouble("totalcancelled");
            String platform = rst.getString("platform");
            String ws_selection = rst.getString("ws_selection");
            double amount = totalwin - totallose;

            boolean dummy = rst.getBoolean("dummy");
            boolean banker = rst.getBoolean("banker");
            boolean test = rst.getBoolean("test");
        
            if(totalpayout > 0){
                String ledger = (result.equals("M") ? "meron win" : (result.equals("W") ? "wala win" : "result draw")) + " ("+odd+"% fight#"+fightnumber+"@"+arena+")";
                if(!isLogFightFound(uid,sessionid,arenaid,eventid,fightkey,ledger,totalpayout)){
                    if(totallose==0 && !dummy && !banker && !test) VerifyWinStreak(ws_selection, uid, fightnumber, arenaid, eventid, win_choice, totalwinbet, result);
                    LogFightNotification(uid,sessionid,arenaid, eventid,fightkey,ledger,totalpayout);
                    if(!dummy) LogLedgerDirect(uid, sessionid, fightkey, referenceno, ledger ,0, totalpayout, "CONTROLLER");
                    execute_notify = true;
                }
            }
            
            String event_desc = "Arena " + arena + " - Result Fight #" + fightnumber;
            String loss_desc = "Your bet loss on fight #"+fightnumber+"!";

            if(totalwin==0 && totallose==0){ 
                if(totalbet > 0 && !dummy && !banker && !test) RecordWinStreak(ws_selection, uid, fightnumber, arenaid, eventid, bet_choice, totalbet, result);
                SendResultNotification(platform, "Return Bets", uid, result, event_desc, (totalcancelled > 0 ? totalcancelled : totalbet), 0, true, "Your bets is cancelled! " + (!result.equals("D") ? cancelledreason : ""));

            }else if(totalwin==0 && totallose > 0){
                if(!isLogFightFound(uid,sessionid,arenaid,eventid,fightkey,loss_desc,amount)){
                    ResetGameStreak(ws_selection, uid, eventid);
                    LogFightNotification(uid,sessionid,arenaid,eventid,fightkey,loss_desc,amount);
                    SendResultNotification(platform, "Loss Amount", uid, result, event_desc, amount, 0, false, loss_desc);
                }

            }else{
                //Your bet 100.00 win (67.00 @ 1.67%) and lose 50 from other bets
                if(execute_notify){
                    description = "Your bet " + FormatCurrency(String.valueOf(totalwinbet))+ " win ("+FormatCurrency(String.valueOf(totalwin))+" @ "+odd+"% on fight #"+fightnumber+")" + (totallose > 0 ? " and loss "+FormatCurrency(String.valueOf(totallose))+" from other bets" : "") + (totalcancelled > 0 ? " and "+totalcancelled+" cancelled from other bets" : "");
                    SendResultNotification(platform, (amount >= 0 ? "Total Winning Amount" : "Total Loss Amount"), uid, result, event_desc, amount, (totalpayout > 0 ? totalpayout : 0), false, description);
                }
            }
        }
        rst.close();
    }catch(SQLException e){
        logError("NotifyPlayersResult",e.toString());
    }
}%>

<%!public boolean isLogFightFound(String accountid, String sessionid, String arenaid, String eventid, String fightkey, String description, double amount){
    boolean recordFound = false;
    if(CountQry("tblfightlogs", "accountid='"+accountid+"' and sessionid='"+sessionid+"' and arenaid='"+arenaid+"' and eventid='"+eventid+"' and fightkey='"+fightkey+"' and description='"+description+"' and amount='"+amount+"'") > 0) {
        recordFound = true;
    }
    return recordFound;
}%>

<%!public void LogFightNotification(String accountid, String sessionid,  String arenaid, String eventid, String fightkey, String description, double amount){
    ExecuteResult("INSERT into tblfightlogs set accountid='"+accountid+"', sessionid='"+sessionid+"', arenaid='"+arenaid+"', eventid='"+eventid+"', fightkey='"+fightkey+"', description='"+description+"', amount='"+amount+"'");
}%>

<%!public void VerifyWinStreak(String category, String accountid, String fightno, String arenaid, String eventid, String bet_choice, double amount, String result){
    if(!category.isEmpty()){
        if(isPromotionEnabled("promo_win_strike")){
            AccountType account = new AccountType(accountid);
            if(account.isonlineagent){
                WinstrikeCounter counter = new WinstrikeCounter(eventid);
                if(counter.totalstrike < 9){
                    WinStrikeChecker ws = new WinStrikeChecker(accountid);
                    if(!ws.winstrike_available){
                        int winstrike = CountWinstrike(category, accountid, eventid);
                        if(winstrike > 0) {
                            if(ws.cockfight_eventid.equals(eventid)){
                                int fightnumber = Integer.parseInt(fightno);
                                if((fightnumber - 1) == ws.cockfight_fightno){
                                    RecordWinStreak(category, accountid, fightno, arenaid, eventid, bet_choice, amount, result);
                                }else{
                                    if(winstrike < 7){
                                        ResetGameStreak(category, accountid, eventid);
                                        RecordWinStreak(category, accountid, fightno, arenaid, eventid, bet_choice, amount, result);
                                    }
                                }
                            }else{
                                if(winstrike < 7){
                                    ResetGameStreak(category, accountid, eventid);
                                    RecordWinStreak(category, accountid, fightno, arenaid, eventid, bet_choice, amount, result);
                                }
                            }
                        }else{
                            RecordWinStreak(category, accountid, fightno, arenaid, eventid, bet_choice, amount, result);
                        }
                    }
                }
            }
        }
    }
}%>

<%!public void ResetGameStreak(String category, String accountid, String eventid){
    int winstrike = CountWinstrike(category, accountid, eventid);
    if(winstrike < 7) ExecuteResult("DELETE FROM tblfightwinstrike where category='"+category+"' and accountid='"+accountid+"' and eventid='"+eventid+"'");
}%>

<%!public void RecordWinStreak(String category, String accountid, String fightno, String arenaid, String eventid, String bet_choice, double amount, String result){
    if(!category.isEmpty()){
        ExecuteResult("INSERT INTO tblfightwinstrike set category='"+category+"', accountid='"+accountid+"', arenaid='"+arenaid+"', eventid='"+eventid+"', fightnumber='"+fightno+"', bet_choice='"+bet_choice+"', bet_amount='"+amount+"',result='"+result+"', datetrn=current_timestamp");
        ExecuteResult("UPDATE tblsubscriber set cockfight_fightno='"+fightno+"', cockfight_eventid='"+eventid+"' where accountid='"+accountid+"'");

        int winstrike = CountWinstrike(category, accountid, eventid);
        if(winstrike >= 7){
            WinStrikeBonus bonus = new WinStrikeBonus(category);
            WinstrikeCounter counter = new WinstrikeCounter(eventid);
            if(category.equals("silver")){
                if(counter.silver < 3){
                    ExecuteResult("UPDATE tblevent set winstrike_silver=winstrike_silver+1 where eventid='"+eventid+"'");
                    ExecuteResult("UPDATE tblsubscriber set winstrike_available=1, winstrike_eventid='"+eventid+"', winstrike_bonus='"+bonus.bonus_amount+"', winstrike_category='"+category+"' where accountid='"+accountid+"'");
                }

            }else if(category.equals("gold")){
                if(counter.gold < 3){
                    ExecuteResult("UPDATE tblevent set winstrike_gold=winstrike_gold+1 where eventid='"+eventid+"'");
                    ExecuteResult("UPDATE tblsubscriber set winstrike_available=1, winstrike_eventid='"+eventid+"', winstrike_bonus='"+bonus.bonus_amount+"', winstrike_category='"+category+"' where accountid='"+accountid+"'");
                } 

            }else if(category.equals("platinum")){
                if(counter.platinum < 3){
                    ExecuteResult("UPDATE tblevent set winstrike_platinum=winstrike_platinum+1 where eventid='"+eventid+"'");
                    ExecuteResult("UPDATE tblsubscriber set winstrike_available=1, winstrike_eventid='"+eventid+"', winstrike_bonus='"+bonus.bonus_amount+"', winstrike_category='"+category+"' where accountid='"+accountid+"'");
                } 
            }
        }
    }
}%>

<%!public void LogCancelledFight(String operatorid, String arenaid, String eventid, String eventkey, String fightkey, String fightnumber, String postingdate, String deviceid){
    OperatorInfo operator = new OperatorInfo(operatorid);

    ExecuteResult("DELETE from tblfightsummary where fightkey='"+fightkey+"' and operatorid='"+operatorid+"'");
    ExecuteResult("INSERT into tblfightsummary set " 
                + " operatorid='"+operatorid+"', "
                + " arenaid='"+arenaid+"', "
                + " eventid='"+eventid+"', "
                + " eventkey='"+eventkey+"', "
                + " fightkey='"+fightkey+"', "
                + " fightnumber='"+fightnumber+"', "
                + " postingdate='"+postingdate+"', "
                + " result='C', "
                + " gros_ge_rate='"+GlobalFightCommission+"', " 
                + " gros_op_rate='"+operator.op_com_rate+"', " 
                + " gros_be_rate='"+operator.be_com_rate+"', " 
                + " datetrn=current_timestamp, "
                + " trnby='"+deviceid+"'");
}%>

<%!public void LogFightResult(String referenceno, String arenaid, String eventid, String eventkey, String fightkey, String fightnumber, String postingdate, String result){
    ExecuteResult("DELETE from tblfightresult where fightkey='"+fightkey+"'");
    ExecuteResult("INSERT into tblfightresult set " 
                + " referenceno='"+referenceno+"', "
                + " arenaid='"+arenaid+"', "
                + " eventid='"+eventid+"', "
                + " eventkey='"+eventkey+"', "
                + " fightkey='"+fightkey+"', "
                + " fightnumber='"+fightnumber+"', "
                + " postingdate='"+postingdate+"', "
                + " result='"+result+"', "
                + " datetrn=current_timestamp");

    if(result.equals("M")){
        ExecuteResult("UPDATE tblevent set total_win_meron=total_win_meron + 1 where eventid='"+eventid+"'");
    }else if(result.equals("W")){
        ExecuteResult("UPDATE tblevent set total_win_wala=total_win_wala + 1 where eventid='"+eventid+"'");
    }else if(result.equals("D")){
        ExecuteResult("UPDATE tblevent set total_draw=total_draw + 1 where eventid='"+eventid+"'");
    }else if(result.equals("C")){
        ExecuteResult("UPDATE tblevent set total_cancelled=total_cancelled + 1 where eventid='"+eventid+"'");
    }
}%>


<%!public void RefundErrorBets( String arenaid, String currentkey){
    try{
        if(CountQry("tblfightbets", "arenaid='"+arenaid+"' and fightkey <> '"+currentkey+"'") > 0){
            ResultSet rst = null;
            rst = SelectQuery("SELECT eventid, operatorid, arenaid, (select arenaname from tblarena where arenaid=a.arenaid) as arena, accountid, sessionid, fightnumber, fightkey, platform, ifnull((select fullname from tblsubscriber where accountid=a.accountid),'') as fullname, sum(bet_amount) as totalbets FROM `tblfightbets` as a where arenaid='"+arenaid+"' and fightkey <> '"+currentkey+"' and dummy=0 group by fightkey,accountid");
            while(rst.next()){
                double amount = Double.parseDouble(rst.getString("totalbets"));
                String arena = rst.getString("arena");
                String eventid = rst.getString("eventid");
                String operatorid = rst.getString("operatorid");
                String accountid = rst.getString("accountid");
                String fullname = rst.getString("fullname");
                String sessionid = rst.getString("sessionid");
                String fightnumber = rst.getString("fightnumber");
                String fightkey = rst.getString("fightkey");
                String platform = rst.getString("platform");
                
                ExecuteSetScore(operatorid, sessionid, fightkey, accountid, fullname, "ADD", amount, "refund error bets (fight#"+fightnumber+"@"+arena+")", "SYSTEM");
                
                String event_desc = "Arena " +  arena + " - Fight #" + fightnumber;
                SendResultNotification(platform, "Return Bets", accountid, "C", event_desc, amount, 0,  true, "Your score is refunded due to error bet posting");

                if(CountQry("tblfightbets", "fightkey='"+fightkey+"' and accountid='"+accountid+"'") > 0){
                    ExecuteQuery("DELETE FROM tblfightbetserror where fightkey='"+fightkey+"' and accountid='"+accountid+"';");
                    ExecuteQuery("INSERT INTO tblfightbetserror (operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason) " 
                                + " SELECT operatorid,accountid,banker,dummy,test,promo,display_id,display_name,sessionid,appreference,platform,masteragentid,agentid,arenaid,eventid,eventkey,fightkey,fightnumber,postingdate,transactionno,bet_choice,bet_amount,ws_selection,result,win,odd,win_amount,lose_amount,payout_amount,gros_ge_rate,gros_ge_total,gros_op_rate,gros_op_total,gros_be_rate,gros_be_total,prof_op_rate,prof_op_total,prof_ag_rate,prof_ag_total,datetrn,cancelled,cancelledreason FROM tblfightbets where arenaid='"+arenaid+"' and fightkey='"+fightkey+"' and accountid='"+accountid+"'");
                    
                    ExecuteQuery("DELETE FROM tblfightbets where arenaid='"+arenaid+"' and fightkey='"+fightkey+"' and accountid='"+accountid+"';");
                }
            }
            rst.close();

            ExecuteQuery("DELETE FROM tblfightbets where arenaid='"+arenaid+"' and fightkey <> '"+currentkey+"' and dummy=1;");
        }
    }catch(SQLException e){
        logError("RefundErrorBets",e.toString());
    }
}%>

<%!public JSONObject FetchDummyBet(JSONObject mainObj, String accountid, String fightkey) {
    mainObj = DBtoJson(mainObj, "SELECT eventid,fightnumber,transactionno,bet_choice,bet_amount FROM tblfightbets where accountid='"+accountid+"' and fightkey='"+fightkey+"';");
    return mainObj;
 }
 %>

 <%!public JSONObject CurrentEventSummary(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "bet_summary",  "SELECT operatorid, "
                            + " count(if(bet_choice='M',1,null)) as countMeron, "
                            + " count(if(bet_choice='D',1,null)) as countDraw, "
                            + " count(if(bet_choice='W',1,null)) as countWala, "
                            + " sum(if(bet_choice='M',bet_amount,0)) as totalMeron, "
                            + " sum(if(bet_choice='D',bet_amount,0)) as totalDraw, "
                            + " sum(if(bet_choice='W',bet_amount,0)) as totalWala "
                            + " FROM tblfightbets where eventid='"+eventid+"' group by operatorid");
    return mainObj;
 }
 %>

<%!public JSONObject CurrentBetSummary(JSONObject mainObj, String fightkey, String operatorid) {
    mainObj = DBtoJson(mainObj, "SELECT operatorid, "
                            + " count(if(bet_choice='M',1,null)) as countMeron, "
                            + " count(if(bet_choice='D',1,null)) as countDraw, "
                            + " count(if(bet_choice='W',1,null)) as countWala, "
                            + " sum(if(bet_choice='M',bet_amount,0)) as totalMeron, "
                            + " sum(if(bet_choice='D',bet_amount,0)) as totalDraw, "
                            + " sum(if(bet_choice='W',bet_amount,0)) as totalWala "
                            + " FROM tblfightbets where fightkey='"+fightkey+"' and operatorid='"+operatorid+"'");
    return mainObj;
 }
 %>

<%!public JSONObject CurrentBetSummaryAll(JSONObject mainObj, String fightkey) {
    mainObj = DBtoJson(mainObj, "current_bets",  "SELECT operatorid, "
                            + " count(if(bet_choice='M',1,null)) as countMeron, "
                            + " count(if(bet_choice='D',1,null)) as countDraw, "
                            + " count(if(bet_choice='W',1,null)) as countWala, "
                            + " sum(if(bet_choice='M',bet_amount,0)) as totalMeron, "
                            + " sum(if(bet_choice='D',bet_amount,0)) as totalDraw, "
                            + " sum(if(bet_choice='W',bet_amount,0)) as totalWala "
                            + " FROM tblfightbets where fightkey='"+fightkey+"' group by operatorid");
    return mainObj;
 }
 %>
 
 <%!public String CurrentDateTime(){
    LocalDateTime myDateObj = LocalDateTime.now();
    DateTimeFormatter myFormatObj = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    return myDateObj.format(myFormatObj);
  }
%>




