<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>

<%
    String api_file = "app-x-play";
    JSONObject mainObj = new JSONObject();
    
try{
   
    String ipaddress = getIpAddress(request);
    if (hasMaliciousData(api_file, request, ipaddress)) {
        out.print(error_invalid_request(mainObj));
        return;
    }

    String token = null;
    String x = Decrypt(request.getParameter("x")); 
    String sessionid = request.getParameter("sessionid"); 

    if(x.isEmpty() || sessionid.isEmpty()){
        out.print(error_invalid_request(mainObj));
        return;
 
    }else if(globalEnableMaintainance){
        out.print(error_system_maintenance(mainObj));
        return;

    } 
    if(x.equals("open_game")){
        if(!isSessionAvailable(sessionid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Invalid game sessionid");
            out.print(mainObj);
            return;
        }

        mainObj.put("status", "OK");
        mainObj = LoadGameSession(mainObj, sessionid);
        mainObj.put("message", "response valid");
        out.print(mainObj);
    }else{
        out.print(error_invalid_request(mainObj));
    }

}catch (Exception e){
    out.print(error_invalid_request(mainObj));
    logError(api_file,e.getMessage());
}
%>
 
<%!public boolean isSessionAvailable(String sessionid) {
    return CountQry("tblgamesession", "gamesession='"+sessionid+"' AND expiry > NOW()") > 0;
  }
%>

<%!public JSONObject LoadGameSession(JSONObject mainObj, String sessionid) {
    mainObj = DBtoJson(mainObj, "select gameurl from tblgamesession where gamesession='"+sessionid+"'");
    return mainObj;
 }
 %>