<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || userid.isEmpty() || (sessionid.isEmpty() && !isAllowedMultiSession(userid))){
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
        return;

    }else if(globalEnableMaintainance){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalMaintainanceMessage);
        mainObj.put("errorcode", "maintenance");
        out.print(mainObj);
        return;

    }else if(isSessionExpired(userid,sessionid)){
		mainObj.put("status", "ERROR");
		mainObj.put("message", globalExpiredSessionMessage);
        mainObj.put("errorcode", "session");
		out.print(mainObj);
        return;

    }
    
    if(x.equals("load_profile")){
        mainObj = getAccountInformation(mainObj, userid);
        mainObj.put("status", "OK");
        mainObj.put("message", "Profile successfully updated");
        out.print(mainObj);

    }else if(x.equals("update_profile")){
        String firstname = request.getParameter("firstname");
        String lastname = request.getParameter("lastname");
        String displayname = request.getParameter("displayname");
        String codename = request.getParameter("codename");
        String birthdate = request.getParameter("birthdate");
        String address = request.getParameter("address");
        String emailaddress = request.getParameter("emailaddress");
        String mobilenumber = request.getParameter("mobilenumber");

        if(CountQry("tblsubscriber", "mobilenumber='" + mobilenumber + "' and accountid<>'"+userid+"' and mobilenumber<>''") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Whatsapp " +mobilenumber+" is already exists!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);

        }else{
            ExecuteQuery("update tblsubscriber set " 
                            + " firstname='"+rchar(firstname)+"', "
                            + " lastname='"+rchar(lastname)+"', "
                            + " displayname='"+rchar(displayname)+"', " 
                            + " codename='" + rchar(codename) + "', " 
                            + " birthdate='"+ birthdate +"', " 
                            + " address='"+rchar(address)+"', " 
                            + " emailaddress='"+emailaddress+"', " 
                            + " mobilenumber='"+mobilenumber+"' "
                            + (!isProfileConfirmed(userid) ? ", confirmed=1, dateconfirmed=current_timestamp " : "")
                            + " where accountid='"+userid+"'");
                            
            mainObj = getAccountInformation(mainObj, userid);
            mainObj.put("status", "OK");
            mainObj.put("message", "Profile successfully updated");
            out.print(mainObj);
        }
    }else if(x.equals("update_photo")){
        String avatar = request.getParameter("avatar");
        String encodedImage = request.getParameter("encodedImage");
        ServletContext serveapp = request.getSession().getServletContext();
        
        String url = AttachedPhoto(serveapp, "users", encodedImage, userid);

        ExecuteQuery("update tblsubscriber set photoupdated=current_timestamp,avatar='"+avatar+"', photourl='"+url+"' where accountid='"+userid+"'");
        ExecuteQuery("update tblchatbox set imgprofile='"+url+"' where userid='"+userid+"' and (imgprofile='' or imgprofile<>'"+url+"')");
        mainObj = getAccountInformation(mainObj, userid);
        mainObj.put("status", "OK");
        mainObj.put("message", "Photo successfully updated");
        out.print(mainObj);

    }else if(x.equals("change_password")){
        String oldpassword = request.getParameter("oldpass");
        String password = request.getParameter("password");

        if(CountQry("tblsubscriber", "password=AES_ENCRYPT('"+oldpassword+"', '"+globalPassKey+"') and accountid='" + userid + "'") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Your old password is invalid");
            mainObj.put("errorcode", "100");
            out.print(mainObj);

        }else if(CountQry("tblpasswordhistory", "password=AES_ENCRYPT('"+password+"', '"+globalPassKey+"') and userid='" + userid + "'") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You just entered your old password. Please enter new password");
            mainObj.put("errorcode", "100");
            out.print(mainObj);

        }else{
            ExecuteQuery("insert into tblpasswordhistory set userid='"+userid+"', password=AES_ENCRYPT('"+password+"', '"+globalPassKey+"'),changedate=current_timestamp");
            ExecuteQuery("update tblsubscriber set password=AES_ENCRYPT('"+password+"', '"+globalPassKey+"') where accountid='" + userid + "'");
             
            mainObj.put("status", "OK");
            mainObj.put("message", "Password successfully changed");
            out.print(mainObj);
        }

    }else if(x.equals("deposit_instruction")){
        String instruction = request.getParameter("instruction");

        ExecuteQuery("update tblsubscriber set deposit_instruction='"+rchar(instruction)+"' where accountid='" + userid + "'");
        mainObj.put("status", "OK");
        mainObj.put("message", "Deposit transaction successfull updated!");
        out.print(mainObj);
    
    }else if(x.equals("bank_account_list")){
        AccountInfo info = new AccountInfo(userid);

        mainObj.put("status", "OK");
        mainObj = getBankAccounts(mainObj, userid);
        mainObj = getRemittances(mainObj, info.operatorid);
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 
        
    }else if(x.equals("update_bank_account")){
        String id = request.getParameter("id");
        String mode = request.getParameter("mode");
        String remittanceid = request.getParameter("remittanceid");
        String accountnumber = request.getParameter("accountno");
        String accountname = request.getParameter("accountname");
        boolean preferred = Boolean.parseBoolean(request.getParameter("preferred")); 

        if(CountQry("tblbankaccounts", "accountnumber='"+accountnumber+"' and deleted=0 and id<>'"+id+"'") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Account number " +accountnumber+" is already exists!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        if(preferred) ExecuteQuery("UPDATE tblbankaccounts set preferred=0 where accountid='"+userid+"'");

        if(mode.equals("edit")){
            ExecuteQuery("UPDATE tblbankaccounts set accountnumber='"+accountnumber+"',accountname='"+rchar(accountname)+"',remittanceid='"+remittanceid+"', preferred="+preferred+" where id='"+id+"'");
            mainObj.put("message","Bank account successfully updated!");
        }else{
            ExecuteQuery("INSERT INTO tblbankaccounts set accountid='"+userid+"', accountnumber='"+accountnumber+"',accountname='"+rchar(accountname)+"',remittanceid='"+remittanceid+"', preferred="+preferred+", dateadded=current_timestamp");
            mainObj.put("message","Bank account successfully added!");
        }
        
        mainObj = getBankAccounts(mainObj, userid);
        mainObj.put("status", "OK");
        out.print(mainObj);
    
    }else if(x.equals("delete_bank_account")){
        String id = request.getParameter("id");

        ExecuteQuery("UPDATE tblbankaccounts set deleted=1, datedeleted=current_timestamp where id='"+id+"'");
        
        mainObj = getBankAccounts(mainObj, userid);
        mainObj.put("status", "OK");
        mainObj.put("message","Bank account successfully deleted!");
        out.print(mainObj);
        
    }else if(x.equals("get_referral_code")){
			String referralcode = "";
			for (int i = 1; i <= 10; ++i) {
				referralcode = RandomStringUtils.randomAlphabetic(2).toUpperCase()+RandomStringUtils.randomNumeric(4).toUpperCase();
				if (CountQry("tblsubscriber", "referralcode='"+referralcode+"'") == 0){
					ExecuteQuery("update tblsubscriber set referralcode='"+referralcode+"' where accountid='"+userid+"'");
					break;
				}     
			}
			mainObj.put("status", "OK");
			mainObj.put("referralcode", referralcode);
			mainObj.put("message", "Referal code successfully generated");
			out.print(mainObj);

    }else if(x.equals("update_token")){
	  		String token = request.getParameter("token");
	  		ExecuteQuery("update tblsubscriber set tokenid='"+token+"' where accountid='"+userid+"'");
  			mainObj.put("status", "OK");
  			mainObj.put("message", "Account successfully signin");
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
      logError("app-x-profile",e.getMessage());
}
%>
