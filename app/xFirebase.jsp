<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>

<%
    String api_file = "app-x-firebase";
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
 
    if(x.equals("update_token")){
        String firetoken = request.getParameter("token");
        ExecuteQuery("update tblgeneralsettings set firebasetoken='"+firetoken+"'");
        mainObj.put("status", "OK");
        mainObj.put("message", "success");
        out.print(mainObj);

    }else{
        out.print(error_invalid_request(mainObj));
    }

}catch (Exception e){
    out.print(error_invalid_request(mainObj));
    logError(api_file,e.getMessage());
}
%>
