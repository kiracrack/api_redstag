<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>

<%
    String api_file = "dashboard-x-common";
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
    String sessionid = request.getParameter("sessionid");

    String authHeader = request.getHeader("Authorization");
    if (authHeader != null  && authHeader.startsWith("Bearer ")) {
        token = authHeader.substring(7);
    }

    if(x.isEmpty() || userid.isEmpty() || sessionid.isEmpty()){
        out.print(error_invalid_request(mainObj));
        return;
        
    }else if(isAdminSessionExpired(userid,sessionid)){
        out.print(error_admin_session(mainObj));
        return;
        
    }else if(isAdminAccountBlocked(userid)){
        out.print(error_admin_blocked(mainObj));
        return;
    }
    
    if(x.equals("search_account")){
        String accountid = request.getParameter("accountid");
        
        if(CountQry("tblsubscriber", "accountid='"+accountid+"' and  isfreecredit=0") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Account number not found");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        mainObj.put("status", "OK");
        mainObj = SearchAccount(mainObj, accountid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

     }else if(x.equals("search_free_account")){
        String accountid = request.getParameter("accountid");
        
        if(CountQry("tblsubscriber", "accountid='"+accountid+"' and isfreecredit=1") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message",accountid + " - Free account number not found");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(CountQry("tblsubscriber", "freeaccountid='"+accountid+"'") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", accountid + " - This free account is already linked to other account");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }

        mainObj.put("status", "OK");
        mainObj = SearchAccount(mainObj, accountid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("notification_test")){
        SendBroadcastNewEvent();
        
        mainObj.put("status", "OK");
        mainObj.put("message", "Notification test successfull executed");
        out.print(mainObj);
    }else{
        out.print(error_invalid_request(mainObj));
    }
}catch (Exception e){
    out.print(error_invalid_request(mainObj));
    logError(api_file, e.getMessage());
}
%>

 <%!public JSONObject SearchAccount(JSONObject mainObj, String accountid) {
      mainObj = DBtoJson(mainObj, "select accountid, username, fullname, creditbal from tblsubscriber where accountid='"+accountid+"'");
      return mainObj;
  }
 %>