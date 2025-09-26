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
    String sessionid = request.getParameter("sessionid");
 
    if(x.isEmpty() || sessionid.isEmpty()){
        mainObj.put("status", "ERROR");
        mainObj.put("message","forbidden");
        mainObj.put("errorcode", "403");
        out.print(mainObj);
        return;

    }else if(!isSessionValid(sessionid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", "game session is invalid");
        mainObj.put("errorcode", "session");
        out.print(mainObj);
        return;
    }

    if(x.equals("auth_login")){
        AccountSession info = new AccountSession(sessionid);
        
        if(LogLoginSession(info.accountid, sessionid, "webapp", "webapp", "")){
            mainObj.put("status", "OK");
            mainObj = api_account_info(mainObj, info.accountid, true);
            mainObj.put("message","login succeeded");
            out.print(mainObj);
        }
 
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
      logError("api-x-login",e.getMessage());
}
%>