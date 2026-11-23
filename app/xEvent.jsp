<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>

<%
    String api_file = "app-x-event";
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
    String appreference = request.getParameter("appreference"); 
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
    
    if(x.equals("arena")){ 
        mainObj.put("status", "OK");
        mainObj = getActiveArena(mainObj);
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 

    }else if(x.equals("event_info")){
        String eventid = request.getParameter("eventid");

        AccountInfo info = new AccountInfo(userid);
        if(info.custom_promo_enabled){
            PromotionInfo promo = new PromotionInfo(info.custom_promo_code);
            if(!promo.cockfight){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Your current promo is not allowed to play cockfight");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }

        mainObj.put("status", "OK");
        mainObj = getAccountInformation(mainObj, userid);
        mainObj = getEventInfo(mainObj, eventid);
        mainObj.put("message","request returned valid");
        out.print(mainObj);
        
    }else{
        out.print(error_invalid_request(mainObj));
    }

}catch (Exception e){
    out.print(error_invalid_request(mainObj));
    logError(api_file,e.getMessage());
}
%>

<%!public boolean MaxBet(String userid, String fightkey, double addBet, double maxbet) {
    double totalBet = Double.parseDouble(QuerySingleData("ifnull(sum(bet_amount),0)","totalbet", "tblfightbets where accountid='" + userid + "' and fightkey='"+fightkey+"'")); 
    if((totalBet+addBet) > maxbet){
        return true;
    }else{
        return false;
    }
  }
 %>