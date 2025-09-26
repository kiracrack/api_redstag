<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xScoreReport.jsp" %>
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
    
    if(x.equals("load_agents")){
        String operatorid = request.getParameter("operatorid");
        String masteragentid = request.getParameter("masteragentid");
        String keywords = request.getParameter("keywords");
        
        mainObj.put("status", "OK");
        mainObj = LoadAgents(mainObj, masteragentid, keywords);
        mainObj = LoadSelectAgent(mainObj, masteragentid);
        mainObj = LoadApiWhitelist(mainObj, operatorid);
        
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("load_agents_downline")){
        String operatorid = request.getParameter("operatorid");
        String masteragentid = request.getParameter("masteragentid");
         
        mainObj.put("status", "OK");
        mainObj = LoadSelectAgent(mainObj, masteragentid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    
     }else if(x.equals("load_banks")){
        String accountid = request.getParameter("accountid");

        mainObj.put("status", "OK");
        mainObj = LoadAgentBank(mainObj, accountid);
        mainObj = getRemittances(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("load_agent_master")){
         String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = LoadAgentMaster(mainObj, operatorid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("load_master_agents")){
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = LoadMasterAgents(mainObj, operatorid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);
    
    }else if(x.equals("select_agent")){
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = LoadOperatorAgent(mainObj, operatorid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("load_whitelist")){
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = LoadApiWhitelist(mainObj, operatorid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("set_agent_info")){
        String mode = request.getParameter("mode");
        String operatorid = request.getParameter("operatorid");
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        String mobile = request.getParameter("mobile");
        String accounttype = request.getParameter("accounttype");
        String masteragentid = request.getParameter("masteragentid");
        String agentid = request.getParameter("agentid");
        String commission = request.getParameter("commission");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        boolean displayoperatorbank = Boolean.parseBoolean(request.getParameter("displayoperatorbank"));
        
        commission = (commission.length() == 0 ? "0" : commission);

        if (CountQry("tblsubscriber", "fullname='"+fullname+"'  and accountid<>'"+accountid+"' and operatorid='"+operatorid+"'") > 0) {
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Agent fullname is already exists!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
        }else if (CountQry("tblsubscriber", "username='"+username+"'  and accountid<>'"+accountid+"'") > 0) {
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Agent username " + username + " already exists!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
        }else if (mobile.length()> 0 && CountQry("tblsubscriber", "mobilenumber='"+mobile+"' and accountid<>'"+accountid+"'") > 0) {
                mainObj.put("status", "ERROR");
                mainObj.put("message", mobile + " is already exists!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);

        }else if (CountQry("tblsubscriber", "masteragentid<>'"+masteragentid+"' and accountid = '"+accountid+"' and masteragent=0") > 0) {
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Transfering account to other master agent is not allowed!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);

        } else {
                String agent = "";
                if (accounttype.equals("master")){
                    agent = ",masteragent=1,isagent=0, agentid=''";
                }else if (accounttype.equals("agent")){
                    agent = ",masteragent=0, isagent=1, agentid='" + agentid + "'";
                }else{
                    if(accounttype.equals("player_non_cash")){
                        agent = ",masteragent=0, isagent=0, iscashaccount=0, agentid='" + agentid + "'";
                    }else{
                        agent = ",masteragent=0, isagent=0, iscashaccount=1, agentid='" + agentid + "'";
                    }
                }

                if (mode.equals("add")){
                    String newid = getOperatorAccount(operatorid, "series_subscriber");
                    String referralcode = getAccountReferralCode();
                    ExecuteQuery("insert into tblsubscriber set operatorid='"+operatorid+"', isnewaccount=1, referralcode='"+referralcode+"', accountid='"+newid+"', fullname='"+rchar(fullname)+"', displayname='"+rchar(fullname)+"', mobilenumber='"+rchar(mobile)+"', username=LCASE('" + username + "'), password=AES_ENCRYPT('"+rchar(password)+"', '"+globalPassKey+"'), dateregistered=current_timestamp, displayoperatorbank="+displayoperatorbank+", accounttype='"+accounttype+"' " + agent + " "+ (accounttype.equals("master") ? ", masteragentid='"+newid+"'" : ", masteragentid='"+masteragentid+"' ") +  ", commissionrate='" + commission + "' ");
                    mainObj.put("message","Agent Account Successfully Added");
                    LogActivity(userid,"added agent account name " + fullname);   
                }else{
                    ExecuteQuery("UPDATE tblsubscriber set operatorid='"+operatorid+"',fullname='"+rchar(fullname)+"', mobilenumber='"+rchar(mobile)+"', username=LCASE('" + username + "') " + (password.length() > 0 ? ", password=AES_ENCRYPT('"+rchar(password)+"', '"+globalPassKey+"')" : "" ) + ", dateupdated=current_timestamp, displayoperatorbank="+displayoperatorbank+", accounttype='"+accounttype+"' " + agent + " "+ (accounttype.equals("master") ? ", masteragentid='"+accountid+"'" : ", masteragentid='"+masteragentid+"' ") + ", commissionrate='" + commission + "' where accountid='"+accountid+"'");
                    mainObj.put("message","Agent Account Successfully Updated");
                    LogActivity(userid,"update agent account " + fullname + " information");   
                }
                mainObj = LoadAgentProfile(mainObj, accountid);
                mainObj = LoadOperatorAgent(mainObj, operatorid);
                mainObj.put("status", "OK");
                out.print(mainObj);    
                
        }
    } else if(x.equals("block_agent")){
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        String reason = request.getParameter("reason");
        
        ExecuteQuery("update tblsubscriber set blocked=1, blockedreason='"+globalAgentBlockedMessage + (reason.length() > 0 ? "<br><br>Reason: " + reason: "") + "',dateblocked=current_timestamp where accountid = '"+accountid+"';");
        LogActivity(userid,"blocked agent account " + fullname + "");   

        SendAccountStatusNotification(accountid, "block", globalAgentBlockedTitle, globalAgentBlockedMessage + (reason.length() > 0 ? "<br><br>Reason: " + reason: ""));

        mainObj.put("status", "OK");
        mainObj.put("message","Agent account successfully blocked");
        mainObj = LoadAgentProfile(mainObj, accountid);
        out.print(mainObj);

    } else if(x.equals("unblock_agent")){
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        
        ExecuteQuery("update tblsubscriber set blocked=0, blockedreason='',dateblocked=null where accountid = '"+accountid+"';");
        LogActivity(userid,"unblocked agent account " + fullname + "");   

        SendAccountStatusNotification(accountid, "unblock", globalAgentUnBlockedTitle, globalAgentUnBlockedMessage);

        mainObj.put("status", "OK");
        mainObj.put("message","Agent account successfully unblocked");
        mainObj = LoadAgentProfile(mainObj, accountid);
        out.print(mainObj);

    } else if(x.equals("delete_agent")){
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        
        ExecuteQuery("update tblsubscriber set mobilenumber='', deleted=1, datedeleted=current_timestamp, deletedby='"+userid+"' where accountid = '"+accountid+"';");
        LogActivity(userid,"delete agent account " + fullname + "");   

       SendAccountStatusNotification(accountid, "block", globalAgentBlockedTitle, globalAgentBlockedMessage + "<br><br>Reason: Account Deleted");

        mainObj.put("status", "OK");
        mainObj.put("message","Agent account successfully deleted");
        out.print(mainObj);
    
    }else if(x.equals("reset_agent_password")){
        String accountid = request.getParameter("accountid");
        String password = request.getParameter("password");

        ExecuteQuery("update tblsubscriber set accessattempt=0, accesslocklevel=0, accesslockexpiry=null, accesslockdescription='', password=AES_ENCRYPT('"+rchar(password)+"', '"+globalPassKey+"') where accountid = '"+accountid+"';");

        mainObj.put("status", "OK");
        mainObj.put("message","Password successfully changed!");
        out.print(mainObj);


    }else if(x.equals("score_ledger")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = LoadScoreLedger(mainObj, accountid, datefrom, dateto);
        mainObj.put("message", "data synchronized");
        out.print(mainObj);

    }else if(x.equals("update_api")){
        String accountid = request.getParameter("accountid");
        boolean isEnabled = Boolean.parseBoolean(request.getParameter("enabled"));
        String api_website = request.getParameter("api_website");

        ExecuteQuery("update tblsubscriber set api_enabled=" + isEnabled + ",api_website='"+api_website+"' where accountid = '"+accountid+"';");

        mainObj.put("status", "OK");
        mainObj.put("message","Api successfully updated!");
        mainObj = LoadAgentProfile(mainObj, accountid);
        out.print(mainObj);

    }else if(x.equals("save_whitelist")){
        boolean edit = Boolean.parseBoolean(request.getParameter("edit"));
        String id = request.getParameter("id");
        String accountid = request.getParameter("accountid");
        String operatorid = request.getParameter("operatorid");
        String domainname = request.getParameter("domainname");

        if(edit){
            ExecuteQuery("UPDATE tblapiwhitelist set accountid='"+accountid+"', operatorid='"+operatorid+"', domainname='"+rchar(domainname)+"' where id='"+id+"'");
            mainObj.put("message","Whitelist successfully updated!");
        }else{
            ExecuteQuery("INSERT INTO tblapiwhitelist set accountid='"+accountid+"', operatorid='"+operatorid+"', domainname='"+rchar(domainname)+"'");
            mainObj.put("message","Whitelist successfully added!");
        }

        mainObj.put("status", "OK");
        mainObj = LoadApiWhitelist(mainObj, operatorid);
        out.print(mainObj);

    }else if(x.equals("delete_whitelist")){
        String id = request.getParameter("id");
        String operatorid = request.getParameter("operatorid");

        ExecuteQuery("DELETE from tblapiwhitelist where id='"+id+"'");

        mainObj = LoadApiWhitelist(mainObj, operatorid);
        mainObj.put("status", "OK");
        mainObj.put("message","Whitelist sucessfully deleted");
        out.print(mainObj);  
    
    }else if(x.equals("create_free_account")){
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        String fc_username = request.getParameter("fc_username");
        String fc_password = request.getParameter("fc_password");

        AccountInfo info = new AccountInfo(accountid);
        FreeCreditMaster fcm = new FreeCreditMaster();

        String newid = getOperatorAccount(info.operatorid, "series_subscriber");
        String referralcode = getAccountReferralCode();
        ExecuteQuery("update tblsubscriber set hasfreeaccount=1, freeaccountid='"+newid+"' where accountid='"+accountid+"'");
        ExecuteQuery("insert into tblsubscriber set operatorid='"+info.operatorid+"', isnewaccount=1, referralcode='"+referralcode+"', accountid='"+newid+"',  fullname='"+rchar(info.fullname)+"', displayname='"+rchar(info.fullname)+"', mobilenumber='"+rchar(info.mobilenumber)+"', username=LCASE('" + fc_username + "'), password=AES_ENCRYPT('"+rchar(fc_password)+"', '"+globalPassKey+"'), dateregistered=current_timestamp, accounttype='player_non_cash', masteragent=0, isagent=0, iscashaccount=0, isfreecredit=1, agentid='" + fcm.accountid + "', masteragentid='"+fcm.accountid+"'");
        
        LogActivity(userid,"added free account name " + fc_username); 
        mainObj = LoadUpdatedAgent(mainObj, accountid);

        mainObj.put("status", "OK"); 
        mainObj.put("message", "Free account successfully created! You can now paste anywhere the details below..");
        out.print(mainObj); 
    
    }else if(x.equals("link_free_account")){
        String accountid = request.getParameter("accountid");
        String fc_accountid = request.getParameter("fc_accountid");
        String fc_fullname = request.getParameter("fc_fullname");
        String fc_username = request.getParameter("fc_username");

        AccountInfo info = new AccountInfo(accountid);
        FreeCreditMaster fcm = new FreeCreditMaster();
 
        ExecuteQuery("update tblsubscriber set hasfreeaccount=1, freeaccountid='"+fc_accountid+"' where accountid='"+accountid+"'");
         
        LogActivity(userid,"link free account " + fc_fullname + " to " + accountid); 
        mainObj = LoadUpdatedAgent(mainObj, accountid);

        mainObj.put("status", "OK"); 
        mainObj.put("message", "Free account successfully linked! You can now paste anywhere the details below..");
        out.print(mainObj); 

    }else if(x.equals("set_free_credit")){
        String appreference = request.getParameter("appreference");
        String accountid = request.getParameter("accountid");
        String trntype = request.getParameter("trntype");
 
        double amount = Double.parseDouble(request.getParameter("amount"));
        String reference = request.getParameter("reference");
 
        if(trntype.equals("BONUS")){
            reference = "Bonus Credit" + (reference.length() > 0 ? " - " + reference : "");
        }else if(trntype.equals("FREE")){
            reference = "Free Credit" + (reference.length() > 0 ? " - " + reference : "");
        }
    
        AccountInfo info = new AccountInfo(accountid);
        ExecuteSetScore(info.operatorid, sessionid, appreference, accountid, info.fullname, trntype, amount, reference, userid);
        mainObj = LoadUpdatedAgent(mainObj, accountid);
        mainObj.put("message", "Free credit successfully load to account " + info.username.toLowerCase());
        SendScoreNotification(accountid, true, amount);
    
        mainObj.put("status", "OK");
        out.print(mainObj);

    }else if(x.equals("set_socialmedia_bonus")){
        String accountid = request.getParameter("accountid");
        double amount = Double.parseDouble(request.getParameter("amount"));

        AccountInfo info = new AccountInfo(accountid);

        if(isBalanceAvailable(accountid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Account has score balance! Please clear balance to proceed");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(isTherePendingDeposit(accountid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Account has pending deposit! Please clear deposit before proceed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(isTherePendingWithdrawal(accountid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Account has pending withdrawal! Please clear withdrawal before proceed");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(info.iscashaccount && ((info.socialmedia_enabled  && info.creditbal > 0) || info.socialmedia_available)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Social media bonus is already activated");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        ExecuteQuery("UPDATE tblsubscriber set socialmedia_available=1, socialmedia_enabled=0, bonus_amount="+amount+" where accountid='"+accountid+"'");
        SendBonusNotification(accountid, "Your account has received "+String.format("%,.2f", amount) + " from social media bonus, go to promotion to claim your bonus", amount);
    
        mainObj.put("status", "OK");
        mainObj.put("message", "social media bonus successfully activated to account " + info.fullname.toLowerCase());
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
      logError("dashboard-x-agents",e.toString());
}
%>

<%!public JSONObject LoadAgents(JSONObject mainObj,String masteragentid, String keywords) {
      mainObj = DBtoJson(mainObj, "agents", sqlAgentQuery + " where deleted=0 " + (!masteragentid.isEmpty() ? " and masteragentid='"+masteragentid+"' " : "") + (!keywords.isEmpty() ? " and (fullname like '%"+keywords+"%' or accountid like '%"+keywords+"%' or username like '%"+keywords+"%')" : "") + "  order by a.fullname asc");
      return mainObj;
}
%>

<%!public JSONObject LoadAgentMaster(JSONObject mainObj,String operatorid) {
      mainObj = DBtoJson(mainObj, "master_agent", "select accountid, fullname, operatorid from tblsubscriber where masteragent=1 and operatorid='"+operatorid+"' "
                                + " and deleted=0 order by fullname asc");
      return mainObj;
}
%>

<%!public JSONObject LoadMasterAgents(JSONObject mainObj,String operatorid) {
      mainObj = DBtoJson(mainObj, "master_agent", "select accountid, fullname from tblsubscriber where masteragent=1 and operatorid='"+operatorid+"' "
                                + " and accountid not in (select betwacherid from tbloperator where operatorid='"+operatorid+"') " 
                                + " and accountid not in (select dummy_master from tbloperator where operatorid='"+operatorid+"') " 
                                + " and accountid not in (select dummy_account_1 from tbloperator where operatorid='"+operatorid+"') " 
                                + " and accountid not in (select dummy_account_2 from tbloperator where operatorid='"+operatorid+"') " 
                                + " and deleted=0 order by fullname asc");
      return mainObj;
}
%>

<%!public JSONObject LoadSelectAgent(JSONObject mainObj,String masteragentid) {
      mainObj = DBtoJson(mainObj, "select_agent", "select operatorid, accountid, fullname, commissionrate, masteragent, if(commissionrate > 0, concat(commissionrate,'%'), '-') as commission from tblsubscriber where (masteragent=1 or isagent=1) and isfreecredit=0 and masteragentid='"+masteragentid+"'  and deleted=0 order by fullname asc");
      return mainObj;
}
%>

<%!public JSONObject LoadOperatorAgent(JSONObject mainObj,String operatorid) {
      mainObj = DBtoJson(mainObj, "select_agent", "select operatorid, accountid, fullname, commissionrate, masteragent, if(commissionrate > 0, concat(commissionrate,'%'), '-') as commission from tblsubscriber where (masteragent=1 or isagent=1) and isfreecredit=0 and operatorid='"+operatorid+"'  and deleted=0 order by fullname asc");
      return mainObj;
}
%>

<%!public JSONObject LoadAgentProfile(JSONObject mainObj,String accountid) {
      mainObj = DBtoJson(mainObj, "agents", sqlAgentQuery + " where accountid='"+accountid+"' order by fullname asc");
      return mainObj;
  }
%>

<%!public JSONObject LoadApiWhitelist(JSONObject mainObj, String operatorid) {
      mainObj = DBtoJson(mainObj, "api_whitelist", "select * from tblapiwhitelist where operatorid='"+operatorid+"'");
      return mainObj;
}
%>

<%!public JSONObject LoadUpdatedAgent(JSONObject mainObj, String accountid) {
      mainObj = DBtoJson(mainObj, "agents", sqlAgentQuery + " where accountid='"+accountid+"'");
      return mainObj;
  }%>