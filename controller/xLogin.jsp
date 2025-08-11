<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String deviceid = request.getParameter("deviceid");

    if(isControllerBlocked(deviceid)){
        mainObj.put("status", "BLOCKED");
        mainObj.put("message","Your controller was blocked by administrator!");
        mainObj.put("errorcode", "100");
        out.print(mainObj);
        return;
    }

    if(x.equals("active_arena") || x.equals("event_list")){ 
        Double appVersion = Double.parseDouble(request.getParameter("appversion"));
        boolean request_grant = Boolean.parseBoolean(request.getParameter("request_grant"));

        if(!CheckDeviceAuthorization(deviceid)){
            if(!request_grant){
                if(!CheckRegisteredDevice(deviceid)){
                    mainObj.put("status", "UNAUTHORIZED");
                    mainObj.put("message","Your device is not authorized to use this app! Please contact your provider.");
                    out.print(mainObj);
                    return;
                }else{
                    mainObj.put("status", "DEVICE_REQUESTED");
                    mainObj.put("message","Your device authorization request is now for approval! Please reload your app controller in a few minutes");
                    out.print(mainObj);
                    return;
                }
            }else if(request_grant){
                RequestDeviceAuthorization(deviceid);

                mainObj.put("status", "DEVICE_REQUESTED");
                mainObj.put("message","Your device authorization request is now for approval! Please reload your app controller in a few minutes");
                out.print(mainObj);
                return;
            }
        }
        
        if(CheckAppUpdate(appVersion)){
            mainObj.put("status", "UPDATE");
            mainObj.put("message","A new update available! Download it now to proceed.");
            mainObj = getControllerUpdate(mainObj);
            out.print(mainObj);
            return;
        }

        String sessionid = UUID.randomUUID().toString();
        ExecuteQuery("update tblcontroller set sessionid='"+sessionid+"', lastlogin=current_timestamp where deviceid='"+deviceid+"'");
        ExecuteQuery("DELETE FROM tblcreditledgerlogs where trnby='CONTROLLER'");
        
        mainObj.put("status", "OK");
        mainObj = getActiveArena(mainObj);
        mainObj = getGeneralSettings(mainObj);
        mainObj = getDummyAccount(mainObj);
        mainObj.put("sessionid", sessionid);
        mainObj.put("message","request returned valid");
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
      logError("controller-x-login",e.toString());
}
%>

<%!public boolean CheckDeviceAuthorization(String deviceid) {
    if(CountQry("tblcontroller", "deviceid='"+deviceid+"' and approved=1") == 0){
        return false;
    }else{
         return true;
    }
  }
 %>

  <%!public boolean CheckRegisteredDevice(String deviceid) {
    if(CountQry("tblcontroller", "deviceid='"+deviceid+"'") == 0){
        return false;
    }else{
         return true;
    }
  }
 %>

 <%!public boolean RequestDeviceAuthorization(String deviceid) {
    if(CountQry("tblcontroller", "deviceid='"+deviceid+"'") == 0){
        ExecuteQuery("insert into tblcontroller set deviceid='"+deviceid+"', lastlogin=current_timestamp");
        return true;
    }else{
         return false;
    }
  }
 %>

 <%!public boolean CheckAppUpdate(Double appVersion) {
    boolean available = false;
    if(CountQry("tblversioncontrol", "controllerversion>" + appVersion + "") > 0){
        available = true;
    }
    return available;
  }
 %>
 