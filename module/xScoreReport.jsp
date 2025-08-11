<%!public JSONObject LoadScoreLedger(JSONObject mainObj, String userid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "score_ledger", "select date_format(datetrn, '%m/%d/%y') as 'date2', concat(date_format(datetrn, '%m/%d/%y'),'<br/><span style=\"font-size: 2.5vw\">',date_format(datetrn, '%H:%i:%s%p'),'</span>') as 'date', date_format(datetrn, '%r') as 'time', description, if(debit>0, -debit, credit) as amount, debit, credit, currentbal from tblcreditledger where accountid='"+userid+"'  and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by id asc ");
      return mainObj;
 }
 %>

<%!public JSONObject LoadSabongBetsReport(JSONObject mainObj, String userid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "game_report", "select date_format(datetrn, '%m/%d/%y') as 'date', result, date_format(datetrn, '%r') as 'time',concat(fightnumber, if(length(ws_selection) > 0,concat(' (',ws_selection,')',''),'')) as fightnumber, transactionno, bet_amount, "
            + "  eventid, arena, if(bet_choice='M','Meron',if(bet_choice='W','Wala', 'Draw')) as bet_choice, odd, concat(odd,'%') as odds, bet_actual from " 
            + " (SELECT fightnumber, ws_selection, transactionno, bet_amount,  datetrn, eventid, (select arenaname from tblarena where arenaid=a.arenaid) as arena, bet_choice,ROUND(odd,3) as odd, if(cancelled,'Cancelled', if(result='M','Meron',if(result='W','Wala', 'Draw'))) as result, " 
            + " round(if(cancelled,0,if(win,win_amount, if(result='D', 0, -lose_amount) )),2) as bet_actual "
            + " FROM tblfightbets2 as a where accountid='"+userid+"') as x where date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by datetrn asc");
      return mainObj;
 }%>

 <%!public JSONObject LoadCasinoBetsReport(JSONObject mainObj, String userid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "game_report", "select * from(select datetrn, 'Infinity' as provider, date_format(datetrn, '%m/%d/%y') as 'date',  date_format(datetrn, '%r') as 'time', gamename, bet, win, winlose from tblgamelogs_infinity where login='"+userid+"' union all "
                                + " select datetrn, 'Funky', date_format(datetrn, '%m/%d/%y'),date_format(datetrn, '%r'),gamename,stake, winamount,winamount-stake from tblgamelogs_funky where playerid='"+userid+"' and (betstatus='W' or betstatus='L')) as x where date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by datetrn asc");
      return mainObj;
 }%>
