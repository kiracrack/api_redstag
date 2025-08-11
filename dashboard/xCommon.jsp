<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>

<%
JSONObject mainObj = new JSONObject();
try{
    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || userid.isEmpty() || sessionid.isEmpty()){
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
        return;
        
    }else if(isAdminSessionExpired(userid,sessionid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalExpiredSessionMessageDashboard);
        mainObj.put("errorcode", "session");
        out.print(mainObj);
        return;
        
    }else if(isAdminAccountBlocked(userid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalAdminAccountBlocked);
        mainObj.put("errorcode", "blocked");
        out.print(mainObj);
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
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
    }
}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("dashboard-x-common",e.toString());
}
%>

 <%!public JSONObject SearchAccount(JSONObject mainObj, String accountid) {
      mainObj = DBtoJson(mainObj, "select accountid, username, fullname, creditbal from tblsubscriber where accountid='"+accountid+"'");
      return mainObj;
  }
 %>