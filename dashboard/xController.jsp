<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
 
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

    if(x.equals("load_controller")){
        mainObj.put("status", "OK");
        mainObj = LoadController(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("approved_controller")){
        boolean approved = Boolean.parseBoolean(request.getParameter("approved"));
        String deviceid = request.getParameter("deviceid");
        String devicename = request.getParameter("devicename");
        
        if(approved){
                ExecuteQuery("update tblcontroller set approved=1, devicename='"+rchar(devicename)+"' where deviceid = '"+deviceid+"';");
                LogActivity(userid,"approved controller " + devicename);   
        }else{
                ExecuteQuery("update tblcontroller set devicename='"+rchar(devicename)+"' where deviceid = '"+deviceid+"';");
                LogActivity(userid,"change controller name " + devicename);   
        }
    
        mainObj.put("status", "OK");
        mainObj.put("message","Controller successfully "+(approved ? "approved!" : "saved!"));
        mainObj = LoadController(mainObj);
        out.print(mainObj);

    }else if(x.equals("block_unblock_controller")){
        boolean block = Boolean.parseBoolean(request.getParameter("block"));
        String deviceid = request.getParameter("deviceid");
        
        if(block){
                ExecuteQuery("update tblcontroller set blocked=1 where deviceid = '"+deviceid+"';");
                LogActivity(userid,"blocked controller " + deviceid); 
        }else{
                ExecuteQuery("update tblcontroller set blocked=0 where deviceid = '"+deviceid+"';");
                LogActivity(userid,"unblocked controller " + deviceid); 
        }

        mainObj.put("status", "OK");
        mainObj.put("message","Controller successfully "+(block ? "blocked!" : "unblocked!"));
        mainObj = LoadController(mainObj);
        out.print(mainObj);

    }else if(x.equals("delete_controller")){
        String deviceid = request.getParameter("deviceid");
        
        ExecuteQuery("DELETE FROM tblcontroller where deviceid = '"+deviceid+"';");

        mainObj.put("status", "OK");
        mainObj.put("message","Controller successfully deleted!");
        mainObj = LoadController(mainObj);
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
      logError("dashboard-x-controller",e.toString());
}
%>

<%!public JSONObject LoadController(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "controller", "select *, if(blocked,'BLOCKED',if(approved,'APPROVED','FOR APPROVAL')) as status, "
                              + " date_format(lastlogin,'%Y-%m-%d') as 'date', " 
                              + " date_format(lastlogin,'%r') as 'time' from tblcontroller");
      return mainObj;
 }
 %>
