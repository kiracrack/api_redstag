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

    if(x.equals("customer_list")){
        boolean isagent = Boolean.parseBoolean(request.getParameter("isagent"));
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

        String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " fullname like '%" + rchar(keyword) + "%' or " +
                    " displayname like '%" + rchar(keyword) + "%' or " +
                    " username like '%" + rchar(keyword) + "%' or " +
                    " address like '%" + rchar(keyword) + "%'" +
                    ")";

        mainObj = LoadCustomer(mainObj, userid, isagent, search, pgno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("search_account")){
        String operatorid = getOperatorid(userid);
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;
       

        String search = " (" +
                    " a.accountid like '%" + rchar(keyword) + "%' or " +
                    " fullname like '%" + rchar(keyword) + "%' or " +
                    " displayname like '%" + rchar(keyword) + "%' or " +
                    " username like '%" + rchar(keyword) + "%' or " +
                    " address like '%" + rchar(keyword) + "%'" +
                    ")";

        mainObj = SearchCustomer(mainObj, operatorid, search, pgno);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("fetch_account_info")){
        String accountid = request.getParameter("accountid");

        mainObj = FetchAccountInfo(mainObj, accountid);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
    
    }else if(x.equals("set_customer_info")){
        String mode = request.getParameter("mode");
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        String mobilenumber = request.getParameter("mobilenumber");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        boolean iscash = Boolean.parseBoolean(request.getParameter("iscash"));
        String commission = request.getParameter("commission");
        boolean isagent = Boolean.parseBoolean(request.getParameter("isagent"));
        String appreference = request.getParameter("appreference");
        double amount = Double.parseDouble(request.getParameter("amount"));

        commission = (commission.length() == 0 ? "0" : commission);
        
        if(CountQry("tblsubscriber", "username='"+username+"'  and accountid<>'"+accountid+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Account username " + username + " is already exists!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if (mobilenumber.length()> 0 && CountQry("tblsubscriber", "mobilenumber='"+mobilenumber+"'  and accountid<>'"+accountid+"'") > 0) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", mobilenumber + " is already exists!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(amount > 0 && CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal < "+amount+"") > 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Your score balance is insuficient");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        String masteragentid = getMasterAgentid(userid);
        if (mode.equals("add")){
            String operatorid = getOperatorid(userid);
            String referralcode = getAccountReferralCode();
            accountid = getOperatorAccount(operatorid, "series_subscriber");
            ExecuteQuery("insert into tblsubscriber set operatorid='"+operatorid+"', isnewaccount=1, referralcode='"+referralcode+"', accountid='"+accountid+"', fullname=ucase('"+rchar(fullname)+"'), displayname=ucase('"+rchar(fullname)+"'), username=LCASE('" + username + "'), password=AES_ENCRYPT('"+rchar(password)+"', '"+globalPassKey+"'), dateregistered=current_timestamp, accounttype='"+(isagent ? "agent" : (iscash ? "player_cash" : "player_non_cash"))+"', isagent="+isagent+", agentid='"+userid+"', masteragentid='"+masteragentid+"',iscashaccount=" + iscash + ", commissionrate='" + commission + "'");
           
            if(amount > 0){
                if(DirectAddScoreScore(sessionid, appreference, "", userid, accountid, amount)){
                    mainObj.put("message", (isagent? "Agent" : "Player")+" Successfully Added! <br/><br/>Account No. "+accountid+"<br/>Account Name: "+fullname+"<br/>Amount "+String.format("%,.2f", amount)+"");
                }
            }else{
                 mainObj.put("message", (isagent? "Agent" : "Player")+" Successfully Added! <br/><br/>Account No. "+accountid+"<br/>Account Name: "+fullname);
            }
            
        }else{
            ExecuteQuery("UPDATE tblsubscriber set fullname=ucase('"+rchar(fullname)+"'), mobilenumber='"+mobilenumber+"', username=LCASE('" + username + "') " + (password.length() > 0 ? ", password=AES_ENCRYPT('"+rchar(password)+"', '"+globalPassKey+"')" : "" ) + ", dateupdated=current_timestamp,masteragentid='"+masteragentid+"', accounttype='"+(isagent ? "agent" : (iscash ? "player_cash" : "player_non_cash"))+"', iscashaccount=" + iscash + ", commissionrate=" + commission + " where accountid='"+accountid+"'");
            mainObj.put("message", (isagent? "Agent" : "Player")+" Successfully Updated! <br/><br/>Account No. "+accountid+"<br/>Account Name "+fullname);
        }
        
        mainObj = FetchCustomerInfo(mainObj, accountid);
        mainObj.put("creditbal", getLatestCreditBalance(userid));
        mainObj.put("status", "OK");
        out.print(mainObj);
    
    } else if(x.equals("customer_block")){
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        String reason = request.getParameter("reason");
        boolean isagent = Boolean.parseBoolean(request.getParameter("isagent"));
 

        ExecuteQuery("update tblsubscriber set blocked=1, blockedreason='"+globalAgentBlockedMessage + (reason.length() > 0 ? "<br><br>Reason: " + reason: "") + "',dateblocked=current_timestamp where accountid = '"+accountid+"';");
        SendAccountStatusNotification(accountid, "block", globalAgentBlockedTitle, globalAgentBlockedMessage + (reason.length() > 0 ? "<br><br>Reason: " + reason: ""));

        mainObj.put("status", "OK");
        mainObj.put("message","Account successfully blocked");
        mainObj = FetchCustomerInfo(mainObj, accountid);
        out.print(mainObj);

    } else if(x.equals("customer_unblock")){
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        boolean isagent = Boolean.parseBoolean(request.getParameter("isagent"));
        
        ExecuteQuery("update tblsubscriber set blocked=0, blockedreason='',dateblocked=null where accountid = '"+accountid+"';");
        SendAccountStatusNotification(accountid, "unblock", globalAgentUnBlockedTitle, globalAgentUnBlockedMessage);

        mainObj.put("status", "OK");
        mainObj.put("message","Account successfully unblocked");
        mainObj = FetchCustomerInfo(mainObj, accountid);
        out.print(mainObj);

    } else if(x.equals("customer_upgrade")){
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        String commission = request.getParameter("commission");

        ExecuteQuery("update tblsubscriber set isagent=1, iscashaccount=0, commissionrate='" + commission + "', dateupdated=current_timestamp where accountid = '"+accountid+"';");
        SendUpgradeAccountNotification(accountid, "Account Upgraded", "Your account was upgraded to agent account. Please re-login your account");

        mainObj.put("status", "OK");
        mainObj.put("message","Account "+fullname+" successfully upgraded");
        mainObj = FetchCustomerInfo(mainObj, accountid);
        out.print(mainObj); 

    } else if(x.equals("agent_downline")){
        String accountid = request.getParameter("accountid");
        String keyword = request.getParameter("keyword");
        String pageno = request.getParameter("pageno");
        int pgno  =  Integer.parseInt(pageno) * GlobalRecordsLimit;

        String search = " and (" +
                    " accountid like '%" + rchar(keyword) + "%' or " +
                    " fullname like '%" + rchar(keyword) + "%' or " +
                    " displayname like '%" + rchar(keyword) + "%' or " +
                    " username like '%" + rchar(keyword) + "%' or " +
                    " address like '%" + rchar(keyword) + "%'" +
                    ")";

        mainObj.put("status", "OK");
        mainObj = LoadDownline(mainObj, accountid, search, GlobalRecordsLimit);
        out.print(mainObj);

    } else if(x.equals("change_password")){
        String accountid = request.getParameter("accountid");
        String password = request.getParameter("password");
    
        ExecuteQuery("update tblsubscriber set password=AES_ENCRYPT('"+rchar(password)+"', '"+globalPassKey+"'), dateupdated=current_timestamp where accountid = '"+accountid+"';");
        
        mainObj.put("status", "OK");
        mainObj.put("message","Password successfull changed");
        out.print(mainObj);

    } else if(x.equals("query_customer_balance")){
        String accountid = request.getParameter("accountid");
         
        mainObj.put("status", "OK");
        mainObj.put("creditbal", getLatestCreditBalance(accountid));
        mainObj.put("message","response success");
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
      logError("app-x-customer",e.getMessage());
}
%>

<%!public boolean DirectAddScoreScore(String sessionid, String appreference, String  reference, String userid, String accountid, double amount) {
    try{
        String operatorid =  getOperatorid(userid);
        String transactionno = getOperatorSeriesID(operatorid,"series_credit_transfer");

        String account_to_name = getAccountName(accountid);
        Boolean sent = LogLedger(userid, sessionid, appreference, transactionno,"transfer score to "+ FirstName(account_to_name) + (reference.length() > 0? " (" + reference.toLowerCase() + ")" : ""),amount,0, userid);
        
        String account_from_name = getAccountName(userid);
        Boolean received = LogLedger(accountid,sessionid, appreference,transactionno, "received score from "+ FirstName(account_from_name) + (reference.length() > 0? " (" + reference.toLowerCase() + ")" : ""), 0, amount, userid);

        if (sent && received){
            ExecuteQuery("insert into tblcredittransfer set sessionid='"+sessionid+"', operatorid='"+operatorid+"', appreference='"+appreference+"', transactionno='"+transactionno+"', account_from='"+userid+"',account_to='"+accountid+"',amount='"+amount+"',reference='"+rchar(reference)+"',trnby='"+userid+"',datetrn=current_timestamp");
            SendTransferScoreNotification(accountid, userid, account_from_name, amount);
        }else{
            return false;
        }
    
    }catch(Exception e){
        return false;
    }
   
    return true;
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

<%!public JSONObject FetchCustomerInfo(JSONObject mainObj, String accountid) {
      mainObj = DBtoJson(mainObj, "customer", "select accountid,fullname,username,mobilenumber,creditbal,commissionrate,commissionbal,iscashaccount,photourl,photoupdated,isagent,agentid,blocked,lastlogindate,current_timestamp from tblsubscriber as a where accountid='" + accountid + "'");
      return mainObj;
}
%>

<%!public JSONObject LoadCustomer(JSONObject mainObj,String userid, boolean isagent, String search, Integer pgno) {
      mainObj = DBtoJson(mainObj, "customer", "select accountid,fullname,username,mobilenumber,creditbal,commissionrate,commissionbal,iscashaccount,photourl,photoupdated,isagent,agentid,blocked,lastlogindate,current_timestamp from tblsubscriber as a where (agentid='"+userid+"' or agentid in (select accountid from tblsubscriber where agentid='"+userid+"' and iscashaccount=1)) and isagent=" + isagent + search + " and deleted=0 order by fullname asc limit " + Integer.toString(pgno));
      return mainObj;
}
%>

<%!public JSONObject SearchCustomer(JSONObject mainObj, String operatorid, String search, Integer pgno) {
      mainObj = DBtoJson(mainObj, "account", sqlAccountQuery + " where a.operatorid='"+operatorid+"' and " + search + " and deleted=0 group by a.accountid order by fullname asc limit " + Integer.toString(pgno));
      return mainObj;
}
%>

<%!public JSONObject FetchAccountInfo(JSONObject mainObj, String accountid) {
      mainObj = DBtoJson(mainObj, "account", sqlAccountQuery + " where a.accountid='"+accountid+"'");
      return mainObj;
}
%>

<%!public JSONObject LoadDownline(JSONObject mainObj,String userid, String search, Integer pgno) {
    mainObj = DBtoJson(mainObj, "downline", "select accountid,fullname,username,mobilenumber,creditbal,commissionrate,commissionbal,iscashaccount,photourl,photoupdated,isagent,agentid,blocked,lastlogindate,current_timestamp from tblsubscriber as a where isagent=1 and agentid='" + userid + "' " + search + " and deleted=0 order by fullname asc limit " + Integer.toString(pgno));
    return mainObj;
}
%>
 