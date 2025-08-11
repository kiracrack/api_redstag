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

    if(x.equals("load_admin")){
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = LoadAdminAccounts(mainObj, operatorid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("delete_admin")){
        String id = request.getParameter("id");
        String operatorid = request.getParameter("operatorid");

        ExecuteQuery("UPDATE tbladminaccounts set deleted=1,datedeleted=current_timestamp,deletedby='"+userid+"' where id='"+id+"'");
        LogActivity(userid,"delete admin account id#" + id);   

        mainObj = LoadAdminAccounts(mainObj, operatorid);
        mainObj.put("status", "OK");
        mainObj.put("message","Admin account successfully deleted");
        out.print(mainObj); 

    }else if(x.equals("set_admin_info")){
        String operatorid = request.getParameter("operatorid");

        boolean edit = Boolean.parseBoolean(request.getParameter("edit"));
        String id = request.getParameter("id");
        String fullname = request.getParameter("fullname");
        String mobilenumber = request.getParameter("mobile");
        String emailaddress = request.getParameter("email");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        boolean operatoradmin = Boolean.parseBoolean(request.getParameter("operatoradmin"));
        boolean allow_add = Boolean.parseBoolean(request.getParameter("allow_add"));
        boolean allow_edit = Boolean.parseBoolean(request.getParameter("allow_edit"));
        boolean allow_delete = Boolean.parseBoolean(request.getParameter("allow_delete"));
        boolean allow_dummy = Boolean.parseBoolean(request.getParameter("allow_dummy"));
        boolean allow_bet_watcher = Boolean.parseBoolean(request.getParameter("allow_bet_watcher"));
        boolean allow_banker = Boolean.parseBoolean(request.getParameter("allow_banker"));
        String allow_menu_access = request.getParameter("allow_menu_access");

        if (CountQry("tbladminaccounts", "fullname='"+fullname+"'  and id<>'"+id+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Fullname already exists");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if (CountQry("tbladminaccounts", "username='"+username+"'  and id<>'"+id+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Username already exists");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        String query = "fullname='"+rchar(fullname)+"', "
                    + " mobilenumber='"+mobilenumber+"', "
                    + " emailaddress='"+emailaddress+"', "
                    + " operatoradmin="+operatoradmin+", "
                    + " operatorid='"+operatorid+"', "
                    + " username='"+username+"', " 
                    + " allow_add="+allow_add+", "
                    + " allow_edit="+allow_edit+", "
                    + " allow_delete="+allow_delete+", "
                    + " allow_dummy="+allow_dummy+", "
                    + " allow_bet_watcher="+allow_bet_watcher+", "
                    + " allow_banker="+allow_banker+", "
                    + (password.length() > 0 ? " password=AES_ENCRYPT('"+rchar(password)+"', '"+globalPassKey+"'), " : "" ) 
                    + allow_menu_access;

        if (edit){
            ExecuteQuery("UPDATE tbladminaccounts set " + query + " dateupdated=current_timestamp where id='"+id+"'");
            mainObj.put("message","Operator Sucessfully Updated");
            LogActivity(userid,"update admin's " + fullname + " information");   
        }else{
            String new_id = getSystemSeriesID("series_admin");
            ExecuteQuery("insert into tbladminaccounts set id='"+new_id+"', " + query + " dateregistered=current_timestamp, dateupdated=current_timestamp");
            mainObj.put("message","Admin Account Sucessfully Added!");
            LogActivity(userid,"added admin's account name " + fullname);   
        }
        mainObj = LoadAdminAccounts(mainObj, operatorid);
        mainObj.put("status", "OK");
        out.print(mainObj);  

    } else if(x.equals("block_admin")){
        String id = request.getParameter("id");
        String operatorid = request.getParameter("operatorid");
        String fullname = request.getParameter("fullname");
        String reason = request.getParameter("reason");
        
        ExecuteQuery("update tbladminaccounts set blocked=1, blockedreason='"+rchar(reason)+"',dateblocked=current_timestamp where id = '"+id+"';");
        LogActivity(userid,"blocked admin " + fullname + "");   

        mainObj.put("status", "OK");
        mainObj.put("message","Admin account successfully blocked");
        mainObj = LoadAdminAccounts(mainObj, operatorid);
        out.print(mainObj);

    }else if(x.equals("unblock_admin")){
        String id = request.getParameter("id");
        String fullname = request.getParameter("fullname");
        String operatorid = request.getParameter("operatorid");
        
        ExecuteQuery("update tbladminaccounts set blocked=0, blockedreason='',dateblocked=null where id = '"+id+"';");
        LogActivity(userid,"unblocked admin " + fullname + "");   

        mainObj.put("status", "OK");
        mainObj.put("message","Admin account successfully unblocked");
        mainObj = LoadAdminAccounts(mainObj, operatorid);
        out.print(mainObj);

    }else if(x.equals("update_profile_info")){
        String fullname = request.getParameter("fullname");
        String mobile = request.getParameter("mobile");
        String email = request.getParameter("email");
        String username = request.getParameter("username");


        if (CountQry("tbladminaccounts", "fullname='"+fullname+"'  and id<>'"+userid+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Fullname already exists");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if (CountQry("tbladminaccounts", "username='"+username+"'  and id<>'"+userid+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Username already exists");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
            
        }
        
        ExecuteQuery("update tbladminaccounts set fullname='"+rchar(fullname)+"', mobilenumber='"+mobile+"',emailaddress='"+email+"',username='"+username+"' where id = '"+userid+"';");
        LogActivity(userid,"update own admin profile");   

        mainObj.put("status", "OK");
        mainObj.put("message","Account successfully updated");
        mainObj = getAdminProfile(mainObj, userid);
        out.print(mainObj);
    
    }else if(x.equals("update_profile_password")){
        String old_password = request.getParameter("old_password");
        String new_password = request.getParameter("new_password");

        if (CountQry("tbladminaccounts", "password=AES_ENCRYPT('"+old_password+"', '"+globalPassKey+"') and id='"+userid+"'") == 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Invalid old password! Please try again");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        ExecuteQuery("update tbladminaccounts set password=AES_ENCRYPT('"+new_password+"', '"+globalPassKey+"') where id = '"+userid+"';");
        LogActivity(userid,"update own admin password");   

        mainObj.put("status", "OK");
        mainObj.put("message","Password successfully changed!");
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
      logError("dashboard-x-operators",e.toString());
}
%>

<%!public JSONObject LoadAdminAccounts(JSONObject mainObj, String operatorid) {
    mainObj = DBtoJson(mainObj, "admin", "select *, date_format(dateregistered, '%M %d, %Y %r') as datereg, " 
                        + " date_format(lastlogin, '%M %d, %Y %r') as datelog, "
                        + " (select companyname from tbloperator where companyid=a.operatorid) as operator, " 
                        + " if(blocked,'Blocked', 'Active') as status from tbladminaccounts as a where deleted=0 and operatorid='"+operatorid+"'");
    return mainObj;
 }
 %>