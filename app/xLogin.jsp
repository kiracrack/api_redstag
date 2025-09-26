<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xGameModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
   JSONObject apiObj = new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));

    if(globalEnableMaintainance){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalMaintainanceMessage);
        mainObj.put("errorcode", "maintenance");
        out.print(mainObj);
        return;
    }

    if(x.equals("check_update")){
         Double appVersion = Double.parseDouble(request.getParameter("appversion"));
        if(CheckAppUpdate(appVersion)){
            mainObj.put("status", "UPDATE");
            mainObj.put("message","A new update available! Download it now to proceed.");
            mainObj = getAndroidUpdate(mainObj);
            out.print(mainObj);
        }else{
            mainObj.put("status", "UPDATED");
            mainObj.put("message","Your app is updated");
            out.print(mainObj);
        }

    }else if(x.equals("login_access")){
        String appreference = request.getParameter("appreference");
        boolean autologin = Boolean.parseBoolean(request.getParameter("autologin"));
        String userid = request.getParameter("userid");
        String sessionid = request.getParameter("sessionid");
        String username = rchar(request.getParameter("username"));
        String password = rchar(request.getParameter("password"));
        String deviceid = request.getParameter("deviceid");
        String devicename = request.getParameter("devicename");
        String ipaddress = request.getParameter("ipaddress");
        Double appVersion = Double.parseDouble(request.getParameter("appversion"));
        if(!isValiIpAddress(ipaddress)) ipaddress = "";

        if(AccessBlocked(username)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", BlockedReason(username));
            mainObj.put("errorcode", "access_blocked");
            out.print(mainObj);
            return;
        
        }else if(isOperatorBlocked(username)){
            mainObj.put("message", OperatorBlockedReason(username));
            mainObj.put("status", "ERROR");
            mainObj.put("errorcode", "access_blocked");
            out.print(mainObj);
            return;
        
        }else if(AccessLocked(username)){
            mainObj.put("message", LockedReason(username));
            mainObj.put("status", "ERROR");
            mainObj.put("errorcode", "access_blocked");
            out.print(mainObj);
            return;

        }else if(autologin && AccessAutoLogin(userid, sessionid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Login session has been expired!");
            mainObj.put("errorcode", "session_expired");
            out.print(mainObj);
            return;

        }else if(!autologin && AccessLoginAttempt(username, password)){
            if(CheckAccessRegistration(username, password)){
                mainObj.put("message", "Your account is currently for approval! Please contact your agent");
                mainObj.put("status", "ERROR");
                mainObj.put("errorcode", "access_for_approval");
                out.print(mainObj);
            }else{
                mainObj = LockAccessAttempt(mainObj, username);
                mainObj.put("status", "ERROR");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
            }
            return;

        }else if(!devicename.equals("webapp") && CheckAppUpdate(appVersion)){
            mainObj.put("status", "UPDATE");
            mainObj.put("message","A new update available! Download it now to proceed.");
            mainObj = getAndroidUpdate(mainObj);
            out.print(mainObj);
            return;
        }

        try{
            String accountid = (autologin? userid : getAccountid(username, password));
            String newsessionid = (isAllowedMultiSession(accountid) ? "" : UUID.randomUUID().toString()); 

            AccountInfo info = new AccountInfo(accountid);
            if(!devicename.equals("webapp") && info.api_enabled){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Your account is available on web version only");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            }else if(info.api_player){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Your account is allowed to enter this version!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
            }

            OperatorInfo op = new OperatorInfo(info.operatorid);
            if(info.referralcode.length() == 0){
                String referralcode = getAccountReferralCode();
                ExecuteQuery("update tblsubscriber set referralcode='"+referralcode+"' where accountid='"+accountid+"'");
            }

            if(op.testaccountid.equals(info.masteragentid)) {
                ExecuteAddTestCredit(info.operatorid, accountid, info.fullname, info.masteragentid, info.creditbal, newsessionid, appreference);
            } 

            if(LogLoginSession(accountid, newsessionid, deviceid, devicename, ipaddress)){
                mainObj.put("status", "OK");
                mainObj.put("mode", "registered");

                if(devicename.equals("webapp")){
                    mainObj = api_account_info(mainObj, accountid, true);
                }else{
                    mainObj = getActiveArena(mainObj);
                    mainObj = getRemittances(mainObj, info.operatorid);
                    mainObj = getGeneralSettings(mainObj);
                    mainObj = getAccountInformation(mainObj, accountid);
                    mainObj = getTotalRequestNotification(mainObj, accountid);
                    
                    //mainObj = getEventInfo(mainObj, event.eventid);
                    //mainObj = FetchMyBet(mainObj, userid, event.fightkey);
                    
                }
                
                mainObj.put("message","Login successfull");
                out.print(mainObj);

                PushFirebaseUsers(info.operatorid, true);

                apiObj = api_account_info(apiObj, accountid, false);
                PusherPost(accountid, apiObj);
                
                ExecuteQuery("DELETE FROM tblcreditledgerlogs where trnby='"+accountid+"'");
                ExecuteQuery("DELETE FROM tblgamelogs where accountid='"+accountid+"' and date_format(datetrn,'%Y-%m-%d') < DATE_SUB(CURDATE(), INTERVAL 1 DAY)");
                if(!isAllowedMultiSession(accountid)) SendNewLoginSessionNotification(accountid, appreference, deviceid, "session", "New Device Login", "System detected new device login! Your session from this device will be disconnected. <br><br> If this wasn't you, or if you believe that an unauthorized person has accessed your account, please reset your password right away.");
            }else{
                mainObj.put("status", "ERROR");
                mainObj.put("message","Server encounter error while processing your request. Please try again later");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
            }

        }catch(Exception e){
            mainObj.put("status", "ERROR");
            mainObj.put("message",e.toString());
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            logError("app-x-login",e.getMessage());
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
      logError("app-x-login",e.getMessage());
}
%>

<%!public boolean isOperatorBlocked(String username) {
    boolean blocked = false;
    if(CountQry("tblsubscriber", "username='"+username+"' and operator_blocked=1") > 0){
        blocked = true;
    }
    return blocked;
  }
%>

<%!public String OperatorBlockedReason(String username) {
    String nessage = QuerySingleData("operator_blocked_message", "operator_blocked_message", "tblsubscriber where username='" + username + "' and operator_blocked=1");
    return nessage;
  }
%>

<%!public boolean AccessBlocked(String username) {
    boolean blocked = false;
    if(CountQry("tblsubscriber", "username='"+username+"' and  blocked=1") > 0){
        blocked = true;
    }
    return blocked;
  }
%>

<%!public String BlockedReason(String username) {
    String nessage = QueryDirectData("blockedreason","tblsubscriber where username='" + username + "' and blocked=1");
    return nessage;
  }
%>

<%!public boolean AccessLocked(String username) {
    boolean locked = false;
    if(CountQry("tblsubscriber", "username='"+username+"' and accesslockexpiry > current_timestamp") > 0){
        locked = true;
    }
    return locked;
  }
 %>

<%!public String LockedReason(String username) {
    String nessage = QuerySingleData("ifnull(concat(accesslockdescription, ' ', ROUND(time_to_sec((TIMEDIFF(accesslockexpiry,NOW()))) / 60), ' min(s)'),'')", "error_details", "tblsubscriber where username='" + username + "' and accesslockexpiry > current_timestamp") + " or contact your upline for password reset" ;
    return nessage;
  }
%>

<%!public boolean AccessAutoLogin(String userid, String sessionid) {
    boolean invalid = false;
    if(CountQry("tblsubscriber", "accountid='"+userid+"' and sessionid='"+sessionid+"'") == 0){
        invalid = true;
    }
    return invalid;
  }
 %>

<%!public boolean CheckAccessRegistration(String username, String password) {
    boolean exist = false;
    if(CountQry("tblregistration", "username='"+username+"' and password=AES_ENCRYPT('"+password.replace("'","")+"', '"+globalPassKey+"') and deleted=0 and approved=0") > 0){
        exist = true;
    }
    return exist;
  }
 %>

<%!public boolean AccessLoginAttempt(String username, String password) {
    boolean invalid = false;
    if(CountQry("tblsubscriber", "username='"+username+"' and password=AES_ENCRYPT('"+password.replace("'","")+"', '"+globalPassKey+"') and deleted=0") == 0){
        invalid = true;
    }
    return invalid;
  }
 %>

 <%!public JSONObject LockAccessAttempt(JSONObject mainObj, String username) {
    if(CountQry("tblsubscriber", "username='" + username + "' and accessattempt > 3 and accesslocklevel=0 and deleted=0") > 0){
        ExecuteQuery("update tblsubscriber set accessattempt=0, accesslockexpiry=current_timestamp + INTERVAL 5 MINUTE,accesslocklevel=1,accesslockdescription='Account was locked due to multiple login attempt! Please try again in' where username='" + username + "'");
        mainObj.put("message","Account was locked due to multiple login attempt! Please try again in (5 mins) or contact your upline for password reset");
        mainObj.put("errorcode", "access_blocked");

    }else if(CountQry("tblsubscriber", "username='" + username + "' and accessattempt > 3 and accesslocklevel=1 and deleted=0") > 0){
        ExecuteQuery("update tblsubscriber set accessattempt=0, accesslockexpiry=current_timestamp + INTERVAL 1 HOUR,accesslocklevel=2,accesslockdescription='Account was locked due to multiple login attempt! Please try again in' where username='" + username + "'");
        mainObj.put("message","Account was locked due to multiple login attempt! Please try again in (1 hour) or contact your upline for password reset");
        mainObj.put("errorcode", "access_blocked");

    }else if(CountQry("tblsubscriber", "username='" + username + "' and accessattempt > 3 and accesslocklevel=2 and deleted=0") > 0){
        ExecuteQuery("update tblsubscriber set accessattempt=0, accesslockexpiry=null,accesslocklevel=0,accesslockdescription='', blocked=1, dateblocked=current_timestamp, blockedreason='Sorry your account was blocked due to several login attempts! Please contact your upline for password reset' where username='" + username + "'");
        mainObj.put("message","Sorry your account was blocked due to several login attempts! Please contact your upline for password reset");
        mainObj.put("errorcode", "access_blocked");

    }else{
        ExecuteQuery("update tblsubscriber set accessattempt=accessattempt+1,accesslockexpiry=null where username='" + username + "' and deleted=0");
        mainObj.put("message","Invalid username and password! Please try again");
        mainObj.put("errorcode", "access_error");
    }
    return mainObj;
  }
 %>

<%!public boolean CheckAppUpdate(Double appVersion) {
    boolean available = false;
    if(CountQry("tblversioncontrol", "appversion>" + appVersion + "") > 0){
        available = true;
    }
    return available;
  }
 %>

<%!public void ExecuteAddTestCredit(String operatorid, String accountid, String accountname, String masteragentid, double credit, String sessionid, String appreference) {
    double testCredit = 88;
    if(!CurrentlyLog(accountid)){
        if(credit < testCredit){
            double addCredit = testCredit - credit;

            String transactionno = getOperatorSeriesID(operatorid,"series_credit_transfer");
            LogLedger(accountid,sessionid, appreference,transactionno, "received score from operator", 0, addCredit, accountid);
            LogLedger(masteragentid, sessionid, appreference, transactionno,"auto add test score to (" + accountname.toLowerCase() + ")", addCredit, 0, accountid);
            ExecuteQuery("insert into tblcredittransfer set sessionid='"+sessionid+"', operatorid='"+operatorid+"', appreference='"+appreference+"', transactionno='"+transactionno+"', account_from='"+masteragentid+"',account_to='"+accountid+"',amount='"+addCredit+"',reference='auto add test score',trnby='"+accountid+"',datetrn=current_timestamp");
        }else{
            double lessCredit = credit - testCredit;
            String transactionno = getOperatorSeriesID(operatorid,"series_credit_transfer");
            LogLedger(accountid,sessionid, appreference,transactionno, "removed score by operator", lessCredit, 0, accountid);
            LogLedger(masteragentid, sessionid, appreference, transactionno,"auto remove test score from (" + accountname.toLowerCase() + ")", 0, lessCredit, accountid);
        }
    }
}
%>

<%!public boolean CurrentlyLog(String accountid) {
    boolean login = false;
    if(CountQry("tblsubscriber", "accountid='" + accountid + "' and date_format(lastlogindate,'%Y-%m-%d')=current_date") > 0){
        login = true;
    }
    return login;
  }
 %>

 <%!public boolean isValiIpAddress(String ip) {
    String PATTERN = "^((0|1\\d?\\d?|2[0-4]?\\d?|25[0-5]?|[3-9]\\d?)\\.){3}(0|1\\d?\\d?|2[0-4]?\\d?|25[0-5]?|[3-9]\\d?)$";

    return ip.matches(PATTERN);
  }
 %>