<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xSmsModule.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));

    if(globalEnableMaintainance){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalMaintainanceMessage);
        mainObj.put("errorcode", "maintenance");
        out.print(mainObj);
        return;
    }

     if(x.equals("request_otp")){
        String mode =  request.getParameter("mode");
        String appreference =  request.getParameter("appreference");
        String mobilenumber =  request.getParameter("mobilenumber");

        if(mode.equals("password") && !isValidMobileNumber(mobilenumber) ){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Mobile number not found!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(mode.equals("signup") && CountQry("tblsubscriber", "mobilenumber='"+mobilenumber+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", mobilenumber + " is already exists! Please use another mobile number");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        String otpcode = getRandomAlphaNumeric();
        String message="Your One-Time PIN (OTP) is "+otpcode+". This pin is valid within 30 mins";
        ExecuteQuery("insert into tblotp set appreference='"+appreference+"', mobilenumber='6"+mobilenumber+"', otpcode='"+otpcode+"',message='"+message+"',daterequested=current_timestamp, dateexpired=current_timestamp + INTERVAL 30 MINUTE");
        SendOTP(appreference,  mobilenumber, otpcode, message);
         
        mainObj.put("status", "OK");
        mainObj.put("mode", mode);
        mainObj.put("appreference", appreference);
        mainObj.put("mobilenumber", mobilenumber);
        mainObj.put("message", "");
        //mainObj.put("message", "<font color=\"red\"><b>Note: This message is for testing only. API not yet available!</b></font><br/><br/>Your One-Time PIN (OTP)<br/><b><font color=\"red\">"+otpcode+"</font></b>");
        out.print(mainObj);

     }else if(x.equals("confirm_otp")){
        String mode = request.getParameter("mode");
        String appreference = request.getParameter("appreference");
        String mobilenumber = request.getParameter("mobilenumber");
        String otpcode = request.getParameter("otpcode");

        if(!isOTPValid(otpcode,appreference, "6" + mobilenumber)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "OTP you entered is not valid!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
         
        }else if(isOTPExpired(otpcode,appreference, "6" + mobilenumber)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Your OTP is already expired! Please request another one");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        ExecuteQuery("update tblotp set confirmed=1 where mobilenumber='"+mobilenumber+"' and otpcode='"+otpcode+"' and appreference='"+appreference+"'");
        
        if(mode.equals("password")){
            mainObj.put("accountid", getAccountid(mobilenumber));
            mainObj.put("message", "Your mobile number successfully verified! You can now change your password");
            
        }else if(mode.equals("signup")){
            mainObj.put("message", "Your mobile number successfully verified! You can now proceed registration");
        }
        
        mainObj.put("status", "OK");
        mainObj.put("mode", mode);
        out.print(mainObj);

    }else if(x.equals("reset_password")){
        String accountid =  request.getParameter("accountid");
        String password =  request.getParameter("password");

        if(CountQry("tblpasswordhistory", "password=AES_ENCRYPT('"+password+"', '"+globalPassKey+"') and userid='" + accountid + "'") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You just entered your old password. Please enter new password");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        ExecuteQuery("insert into tblpasswordhistory set userid='"+accountid+"', password=AES_ENCRYPT('"+password+"', '"+globalPassKey+"'),changedate=current_timestamp");
        ExecuteQuery("update tblsubscriber set password=AES_ENCRYPT('"+rchar(password)+"', '"+globalPassKey+"'), accessattempt=0, accesslocklevel=0, accesslockexpiry=null, accesslockdescription='' where accountid='"+accountid+"'");

        mainObj.put("status", "OK");
        mainObj.put("message", "Password successfully changed! Please proceed login");
        mainObj.put("errorcode", "100");
        out.print(mainObj);

    }else if(x.equals("signup_account")){
        String fullname =  rchar(request.getParameter("fullname"));
        String mobilenumber =  rchar(request.getParameter("mobile"));
        String username = rchar(request.getParameter("username"));
        String password = rchar(request.getParameter("password"));
        String referral = rchar(request.getParameter("referral"));
        String deviceid = request.getParameter("deviceid");
        String devicename = request.getParameter("devicename");
        String reference = request.getParameter("reference");
        String location = request.getParameter("location"); if(location == null) location = "";
        String latitude = request.getParameter("latitude"); if(latitude == null) latitude = "";
        String longitude = request.getParameter("longitude"); if(longitude == null) longitude = "";

        String agentid = ""; String operatorid = ""; String masteragentid = "";
        
        if(referral.length() > 0 && !ReferralValid(referral) ){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You entered invalid referral code.");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(!ReferralValid(referral) && GlobalDefaultOperator.length() == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "No active operator at this time, Please contact your agent and ask referral code and try again");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(CountQry("tblsubscriber", "username='"+username+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Username " + username + " is already exists!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(mobilenumber.length() > 0 && CountQry("tblsubscriber", "mobilenumber='"+mobilenumber+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", mobilenumber + " is already exists! Please use another mobile number");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(username.length() > 20) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Your username is too long. Please enter username not morethan 20 character");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        if(ReferralValid(referral)){
            AgentReferralInfo info = new AgentReferralInfo(referral);
            agentid = info.accountid;
            operatorid = info.operatorid;
            masteragentid = info.masteragentid;
        }else{
            agentid = getOwnersAccount(GlobalDefaultOperator);
            AccountInfo info = new AccountInfo(agentid);
            operatorid = info.operatorid;
            masteragentid = info.masteragentid;
        }

        String imgbase64= request.getParameter("imgbase64"); if(imgbase64 == null) imgbase64 = "";
        ServletContext serveapp = request.getSession().getServletContext();

        String regno = getOperatorSeriesID(operatorid,"series_registration");
        String url = AttachedPhoto(serveapp, "signup", imgbase64, regno);

        ExecuteQuery("insert into tblregistration set regno='"+regno+"', "
                        + " fullname=ucase('"+rchar(fullname)+"'), "
                        + " mobilenumber='" + mobilenumber + "', " 
                        + " username=LCASE('" + username + "'), " 
                        + " password='"+rchar(password)+"', "
                        + " referralcode='"+referral+"', "
                        + " operatorid='"+operatorid+"', "
                        + " masteragentid='"+masteragentid+"', "
                        + " agentid='"+agentid+"', "
                        + " photourl='"+url+"', "
                        + " deviceid='"+deviceid+"', "
                        + " devicename='"+devicename+"', "
                        + " location='"+rchar(location)+"', "
                        + " latitude='"+latitude+"', "
                        + " longitude='"+longitude+"', "
                        + " dateregister=current_timestamp, "
                        + " reference='"+rchar(reference)+"'");

        //SendNewRegistrationNotification(regno, agentid, fullname, mobilenumber, username, location, url);

        /*mainObj.put("status", "OK");
        mainObj.put("message", "Your account successfully submitted for approval! We will call you once your account is approved");
        out.print(mainObj);*/

        if (ApprovedDirectAccount(regno)){
            mainObj.put("status", "OK");
            mainObj.put("message", "Congratulation! Your account successfully registered! Please proceed login your account");
            out.print(mainObj);
        }

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
      logError("app-x-public",e.getMessage());
}
%>

<%!public boolean isOTPValid(String otpcode, String appreference, String mobilenumber) {
    boolean valid = false;
    if(CountQry("tblotp", "otpcode='"+otpcode+"' and appreference='"+appreference+"' and mobilenumber='"+mobilenumber+"' and confirmed=0") > 0){
        valid = true;
    }
    return valid;
  }
 %>

<%!public boolean isOTPExpired(String otpcode, String appreference, String mobilenumber) {
    boolean valid = false;
    if(CountQry("tblotp", "otpcode='"+otpcode+"' and appreference='"+appreference+"' and mobilenumber='"+mobilenumber+"' and dateexpired < current_timestamp and confirmed=0") > 0){
        valid = true;
    }
    return valid;
  }
 %>

<%!public boolean isValidMobileNumber(String mobilenumber) {
    boolean valid = false;
    if(CountQry("tblsubscriber", "mobilenumber='"+mobilenumber+"'") > 0){
        valid = true;
    }
    return valid;
  }
 %>

<%!public boolean ReferralValid(String referralcode) {
    boolean valid = false;
    if(referralcode.length() > 0 && CountQry("tblsubscriber", "referralcode='"+referralcode+"' and deleted=0") > 0){
        valid = true;
    }
    return valid;
  }
 %>

<%!public String getOwnersAccount(String operatorid) {
    String ownersaccount = QueryDirectData("ownersaccountid","tbloperator where companyid='" + operatorid + "'");
    return ownersaccount;
  }
 %>

<%!public boolean ApprovedDirectAccount(String refno) {
    NewAccountInfo info = new NewAccountInfo(refno);
    String newid = getOperatorAccount(info.operatorid, "series_subscriber");
    String referralcode = getAccountReferralCode();
    ExecuteQuery("insert into tblsubscriber set operatorid='"+info.operatorid+"', "
                + " accountid='"+newid+"', "
                + " fullname=ucase('"+rchar(info.fullname)+"'), "
                + " displayname=ucase('"+rchar(info.fullname)+"'), " 
                + " mobilenumber='"+info.mobilenumber+"', " 
                + " username=LCASE('" + info.username + "'), "
                + " password=AES_ENCRYPT('"+rchar(info.password)+"', '"+globalPassKey+"'), "
                + " dateregistered=current_timestamp, "
                + " accounttype='player_cash', isagent=0, "
                + " agentid='"+info.agentid+"', "
                + " masteragentid='"+info.masteragentid+"', "
                + " photourl='"+info.photourl+"', "
                + " address='"+rchar(info.location)+"', "
                + " referralcode='"+referralcode+"', "
                + " reference='"+rchar(info.reference)+"', "
                + " iscashaccount=1, isnewaccount=1");

    ExecuteQuery("insert into tblpasswordhistory set userid='"+newid+"', password=AES_ENCRYPT('"+rchar(info.password)+"', '"+globalPassKey+"'),changedate=current_timestamp");
    ExecuteQuery("UPDATE tblregistration set approved=1, dateapproved=current_timestamp where regno='"+refno+"'");
    return true;
  }
 %>