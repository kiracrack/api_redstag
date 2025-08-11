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

    if(x.equals("load_dummy_Account")){
        mainObj.put("status", "OK");
        mainObj = LoadDummyNames(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("upload_dummy_name")){
        String file_content = request.getParameter("file_content");
        
        ExecuteQuery("DELETE FROM tbldummyname");
        String line = "";
        BufferedReader bufReader = new BufferedReader(new StringReader(file_content));
        while((line=bufReader.readLine()) != null ){
            String[] parts = line.split(",");
            ExecuteQuery("INSERT INTO tbldummyname set accountno='"+QuoteValue(parts[0])+"', dummyname='"+QuoteValue(parts[1])+"'");
        }

        mainObj.put("status", "OK");
        mainObj.put("message","Dummy account successfully uploaded!");
        mainObj = LoadDummyNames(mainObj);
        out.print(mainObj);

    }else if(x.equals("load_dummy_settings")){
        mainObj.put("status", "OK");
        mainObj = LoadDummySettings(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);
    
    }else if(x.equals("set_dummy_settings")){
        String time_am = request.getParameter("time_am");
        String range_am_from = request.getParameter("range_am_from");
        String range_am_to = request.getParameter("range_am_to");
        String time_pm = request.getParameter("time_pm");
        String range_pm_from = request.getParameter("range_pm_from");
        String range_pm_to = request.getParameter("range_pm_to");
        String time_eve = request.getParameter("time_eve");
        String range_eve_from = request.getParameter("range_eve_from");
        String range_eve_to = request.getParameter("range_eve_to");
        String time_mid = request.getParameter("time_mid");
        String range_mid_from = request.getParameter("range_mid_from");
        String range_mid_to = request.getParameter("range_mid_to");
        
        String CommandQuery = "time_am='"+time_am+"', "
                    + " range_am_from='"+range_am_from+"', "
                    + " range_am_to='"+range_am_to+"', "
                    + " time_pm='"+time_pm+"', " 
                    + " range_pm_from='"+range_pm_from+"', " 
                    + " range_pm_to='"+range_pm_to+"', " 
                    + " time_eve='"+time_eve+"', "
                    + " range_eve_from='"+range_eve_from+"', "
                    + " range_eve_to='"+range_eve_to+"', "
                    + " time_mid='"+time_mid+"', "
                    + " range_mid_from='"+range_mid_from+"', "
                    + " range_mid_to='"+range_mid_to+"'";

        if(CountRecord("tbldummysettings") > 0){
            ExecuteQuery("update tbldummysettings set " + CommandQuery);
        }else{
            ExecuteQuery("insert into tbldummysettings set " + CommandQuery);
        }

        mainObj.put("status", "OK");
        mainObj.put("message","Settings successfully saved");
        mainObj = LoadDummySettings(mainObj);
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
      logError("dashboard-x-dummy",e.toString());
}
%>

<%!public JSONObject LoadDummyNames(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "dummy_account", "select * from tbldummyname");
      return mainObj;
}
%>

<%!public JSONObject LoadDummySettings(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "dummy_settings", "select * from tbldummysettings");
      return mainObj;
}
%>