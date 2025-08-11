<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>

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

    if(x.equals("new_account")){
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

        String search = " and (mobilenumber like '%" + rchar(keyword) + "%' or fullname like '%" + rchar(keyword) + "%')";

        mainObj = LoadNewAccount(mainObj, userid, search, pgno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("approve_account")){
        String refno = request.getParameter("refno");
        NewAccountInfo info = new NewAccountInfo(refno);

        if(CountQry("tblsubscriber", "username='"+info.username+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Account username " + info.username + " is already exists!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if (info.mobilenumber.length()> 0 && CountQry("tblsubscriber", "mobilenumber='"+info.mobilenumber+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", info.mobilenumber + " is already exists!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        String referralcode = getAccountReferralCode();
        String newid = getOperatorAccount(info.operatorid, "series_subscriber");
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
        //SendRequestNotificationCount(userid);

        mainObj.put("status", "OK");
        mainObj = LoadNewAccount(mainObj, userid, "", GlobalRecordsLimit);
        mainObj = getTotalRequestNotification(mainObj, userid);
        mainObj.put("message","New Player Successfully Added");
        out.print(mainObj);

        LogActivity(userid,"added player account name " + info.fullname);   

    }else if(x.equals("cancel_account")){
        String refno = request.getParameter("refno");
 
        ExecuteQuery("UPDATE tblregistration set deleted=1, datedeleted=current_timestamp where regno='"+refno+"'");
        mainObj.put("status", "OK");
        mainObj = LoadNewAccount(mainObj, userid, "", GlobalRecordsLimit);
        mainObj = getTotalRequestNotification(mainObj, userid);
        //SendRequestNotificationCount(userid);
        mainObj.put("message", "Request successfully cancelled");
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
      logError("app-x-registration",e.getMessage());
}
%>

 
 