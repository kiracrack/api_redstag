<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xApiModule.jsp" %>
<%@ include file="../module/xApiClass.jsp" %>

<%
   JSONObject mainObj = new JSONObject();
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
        DeniedAddress(key, referer);
        mainObj.put("status", "ERROR");
        mainObj.put("message", "header x-requested is not allowed");
        mainObj.put("errorcode", "405");
        out.print(mainObj);
        return;

    }else if(globalEnableMaintainance){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalMaintainanceMessage);
        mainObj.put("errorcode", "400");
        out.print(mainObj);
        return;
    }
  
    if(x.equals("winloss-report")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        OperatorInfoApi api = new OperatorInfoApi(key);
        mainObj = api_winloss_report(mainObj, api.agentid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("score-report")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        OperatorInfoApi api = new OperatorInfoApi(key);
        mainObj = api_score_report(mainObj, api.agentid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("player-bets")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        OperatorInfoApi api = new OperatorInfoApi(key);
        mainObj = api_player_bets(mainObj, api.agentid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message","query succeeded");
        out.print(mainObj); 

    }else if(x.equals("player-accounts")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        OperatorInfoApi api = new OperatorInfoApi(key);
        mainObj = api_player_accounts(mainObj, api.agentid, datefrom, dateto);
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
      logError("api-x-account",e.getMessage());
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

 