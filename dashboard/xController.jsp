<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
 
<%
    String api_file = "dashboard-x-controller";
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
        out.print(error_invalid_request(mainObj));
    }
}catch (Exception e){
    out.print(error_invalid_request(mainObj));
    logError(api_file, e.getMessage());
}
%>

<%!public JSONObject LoadController(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "controller", "select *, if(blocked,'BLOCKED',if(approved,'APPROVED','FOR APPROVAL')) as status, "
                              + " date_format(lastlogin,'%Y-%m-%d') as 'date', " 
                              + " date_format(lastlogin,'%r') as 'time' from tblcontroller");
      return mainObj;
 }
 %>
