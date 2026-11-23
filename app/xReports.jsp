<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xScoreReport.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xGameModule.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>
<%@ include file="../module/xApiModule.jsp" %>
<%@ include file="../module/xApiClass.jsp" %>
<%@ include file="../module/xPusher.jsp" %>

<%

    String api_file = "app-x-reports";
    JSONObject mainObj = new JSONObject();
    
try{
    
    String ipaddress = getIpAddress(request);
    if (hasMaliciousData(api_file, request, ipaddress)) {
        out.print(error_invalid_request(mainObj));
        return;
    }

    String token = null;
    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String deviceid = request.getParameter("deviceid");
    String sessionid = request.getParameter("sessionid");
 
    String authHeader = request.getHeader("Authorization");    
    if (authHeader != null  && authHeader.startsWith("Bearer ")) {
        token = authHeader.substring(7);
    }

    if(x.isEmpty() || userid.isEmpty() || (sessionid.isEmpty() && !isAllowedMultiSession(userid, deviceid))){
        out.print(error_invalid_request(mainObj));
        return;
 
    }else if(globalEnableMaintainance){
        out.print(error_system_maintenance(mainObj));
        return;

    }else if(isSessionExpired(userid,sessionid)){
		out.print(error_session_expired(mainObj));
        return;
    }

    JwtVerification jwt = new JwtVerification(token, ipaddress, api_file);
    if(!jwt.valid) {
        out.print(error_token_authorization(mainObj, jwt.message));
        return;
    }
 
    if(x.equals("score_ledger")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = LoadScoreLedger(mainObj, accountid, datefrom, dateto);
        mainObj.put("message", "data synchronized");
        out.print(mainObj);

    }else if(x.equals("game_report_cockfight")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        AccountInfo info = new AccountInfo(accountid);

        mainObj = LoadSabongBetsReport(mainObj, accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("api_player", info.api_player);
        mainObj.put("message", "data synchronized");
        out.print(mainObj);

    }else if(x.equals("game_report_casino")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = LoadCasinoGameReport(mainObj, accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message", "data synchronized");
        out.print(mainObj);
 
    } else if(x.equals("score_request")){
        boolean customer = Boolean.parseBoolean(request.getParameter("customer"));
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

        String search = " and (userid like '%" + rchar(keyword) + "%' or (select fullname from tblsubscriber where accountid=a.userid) like '%" + rchar(keyword) + "%')";

        mainObj = LoadScoreRequest(mainObj, userid, customer, search, pgno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
 
    }else if(x.equals("get_player_bets")){ 
        String fightkey = request.getParameter("fightkey");
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = FetchCurrentBets(mainObj, fightkey, operatorid);
        mainObj.put("message","request returned valid");
        out.print(mainObj);

    /* api admin functions */
     }else if(x.equals("api_score_report")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = api_score_report(mainObj, userid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message", "response valid");
        out.print(mainObj);

    }else if(x.equals("api_winloss_report")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = api_winloss_report(mainObj, userid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message", "data synchronized");
        out.print(mainObj);

 
    /* api admin functions */
        
    }else{
        out.print(error_invalid_request(mainObj));
    }

}catch (Exception e){
    out.print(error_invalid_request(mainObj));
    logError(api_file,e.getMessage());
}
%>
 
