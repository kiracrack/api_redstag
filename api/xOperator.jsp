<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xApiModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String key = request.getParameter("key");
    String referer = request.getParameter("referer");

    if(x.isEmpty() || key.isEmpty() || referer.isEmpty()){
        mainObj.put("status", "ERROR");
        mainObj.put("message","forbidden");
        mainObj.put("errorcode", "403");
        out.print(mainObj);
        return;
    }else if(!isApiKeyValid(key)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", "api request forbidden");
        mainObj.put("errorcode", "403");
        out.print(mainObj);
        return;
    }else if(!isInWhiteList(key, referer)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", "header x-requested is not allowed");
        mainObj.put("errorcode", "405");
        out.print(mainObj);
        return;
    }else if(globalEnableMaintainance){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalMaintainanceMessage);
        mainObj.put("errorcode", "maintenance");
        out.print(mainObj);
        return;
    }

    OperatorInfoApi info = new OperatorInfoApi(key);

    if(x.equals("player-accounts-report")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = api_player_accounts(mainObj, info.agentid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("winloss-summary-report")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        OperatorWinlossApi p = new OperatorWinlossApi(info.agentid, datefrom, dateto);
        mainObj = api_winloss_summary_report(mainObj, info.agentid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("totalwinloss", p.winloss);
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("detail-bets-report")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        OperatorWinlossApi p = new OperatorWinlossApi(info.agentid, datefrom, dateto);
        mainObj = api_detail_bets_report(mainObj, info.agentid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("totalwinloss", p.winloss);
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("total-profit-reports")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = api_total_profit_report(mainObj, info.agentid, info.commissionrate, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message","query succeeded");
        out.print(mainObj);


    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","bad request, method not valid");
        mainObj.put("errorcode", "400");
        out.print(mainObj);
    }

}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", "bad request, missing parameter");
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("api-x-operator",e.getMessage());
}
%>

<%!public boolean isBlocked(String userid) {
    boolean blocked = false;
    if(CountQry("tblsubscriber", "accountid='"+userid+"' and  blocked=1") > 0){
        blocked = true;
    }
    return blocked;
  }
%>

<%!public JSONObject api_player_accounts(JSONObject mainObj, String agentid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "data", "select accountid, api_identifier as 'identifier', creditbal as score, fullname as accountname, date_format(lastlogindate,'%Y-%m-%d') as datelogin, date_format(lastlogindate,'%r') as timelogin, " 
                    + " date_format(dateregistered,'%Y-%m-%d') as datecreated, date_format(dateregistered,'%r') as timecreated, "
                    + " blocked, date_format(dateblocked,'%Y-%m-%d') as dateblocked, date_format(dateblocked,'%r') as timeblocked "
                    + " from tblsubscriber where agentid='"+agentid+"'  and date_format(dateregistered, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by dateregistered asc");
      return mainObj;
 }
 %>

 <%!public JSONObject api_winloss_summary_report(JSONObject mainObj, String agentid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "data", "select "
                    + " accountid, " 
                    + " (select fullname from tblsubscriber where accountid=a.accountid) as accountname, "
                    + " (select creditbal from tblsubscriber where accountid=a.accountid) as 'scorebalance', " 
                    + " ROUND(sum(win_amount) - sum(lose_amount),2) as 'winloss' "
                    + " from tblfightbets2 as a where agentid='"+agentid+"' and cancelled=0 "
                    + " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' " 
                    + " group by accountid");
      return mainObj;
 }%>

 <%!public JSONObject api_detail_bets_report(JSONObject mainObj, String agentid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "data", "select id, accountid, transactionno, "
                + " (select fullname from tblsubscriber where accountid=x.accountid) as accountname, "
                + " date_format(datetrn, '%Y-%m-%d') as 'date', result, date_format(datetrn, '%r') as 'time', fightnumber, bet_amount, "
                + " eventid, if(bet_choice='M','Meron',if(bet_choice='W','Wala', 'Draw')) as bet_choice, odd,  winloss from " 
                + " (SELECT id, accountid, transactionno, fightnumber, bet_amount, datetrn, eventid, "
                + " bet_choice,ROUND(odd,3) as odd, if(cancelled,'Cancelled', if(result='M','Meron',if(result='W','Wala', 'Draw'))) as result, " 
                + " round(if(cancelled,0,if(win,win_amount, -lose_amount)),2) as winloss "
                + " FROM tblfightbets2 where agentid='"+agentid+"') as x where date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by id asc");
      return mainObj;
 }%>

  <%!public JSONObject api_total_profit_report(JSONObject mainObj, String agentid, Double commissionrate, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "data", "select winloss as total_winloss, ROUND(winloss * (" + commissionrate + " / 100), 2) as total_earn, ROUND(winloss - (winloss * (" + commissionrate + " / 100)), 2) as total_remittance from (select ROUND(sum(win_amount) - sum(lose_amount),2) as winloss from tblfightbets2 as a where agentid='"+agentid+"' and cancelled=0 "
                    + " and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"') as x");
      return mainObj;
 }%>