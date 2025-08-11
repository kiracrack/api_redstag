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

    if(x.equals("load_operator")){
        mainObj.put("status", "OK");
        mainObj = LoadOperators(mainObj);
        mainObj = LoadSelectOperators(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);
    
    }else if(x.equals("select_operator")){
        mainObj.put("status", "OK");
        mainObj = LoadSelectOperators(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("set_operator_info")){
        String mode = request.getParameter("mode");
        String companyid = request.getParameter("companyid");
        String companyname = request.getParameter("companyname");
        String shortname = request.getParameter("shortname");
        String website = request.getParameter("website");
        String email = request.getParameter("email");
        String mobile = request.getParameter("mobile");
        String ownersaccountid = request.getParameter("ownersaccountid");
        String testaccountid = request.getParameter("testaccountid");
        String cs_whatsapp = request.getParameter("cs_whatsapp");
        String cs_messenger = request.getParameter("cs_messenger");
        String op_com_rate = request.getParameter("op_com_rate");
        String be_com_rate = request.getParameter("be_com_rate");
        String draw_rate = request.getParameter("draw_rate");
        String video_min_credit = request.getParameter("video_min_credit");
        String minbet = request.getParameter("minbet");
        String maxbet = request.getParameter("maxbet");
        String mintransfer = request.getParameter("mintransfer");
        String maxtransfer = request.getParameter("maxtransfer");
        String mindeposit = request.getParameter("mindeposit");
        String maxdeposit = request.getParameter("maxdeposit");
        String minwithdraw = request.getParameter("minwithdraw");
        String maxwithdraw = request.getParameter("maxwithdraw");
        boolean enablebetwatcher = Boolean.parseBoolean(request.getParameter("enablebetwatcher"));
        String betwacherid = request.getParameter("betwacherid");
        String betwatchermaxamount = request.getParameter("betwatchermaxamount");
        String betwatcherodds = request.getParameter("betwatcherodds");
        boolean betwatcherincludedummybets = Boolean.parseBoolean(request.getParameter("betwatcherincludedummybets"));
        boolean enable_agent_commission = Boolean.parseBoolean(request.getParameter("enable_agent_commission"));
        boolean actived = Boolean.parseBoolean(request.getParameter("actived"));
        boolean dummy_enable = Boolean.parseBoolean(request.getParameter("dummy_enable"));
        String dummy_master = request.getParameter("dummy_master");
        String dummy_account_1 = request.getParameter("dummy_account_1");
        String dummy_account_2 = request.getParameter("dummy_account_2");
        String dummy_am_amt_from = request.getParameter("dummy_am_amt_from");
        String dummy_am_amt_to = request.getParameter("dummy_am_amt_to");
        String dummy_am_amt_time = request.getParameter("dummy_am_amt_time");
        String dummy_pm_amt_from = request.getParameter("dummy_pm_amt_from");
        String dummy_pm_amt_to = request.getParameter("dummy_pm_amt_to");
        String dummy_pm_amt_time = request.getParameter("dummy_pm_amt_time");
        String dummy_eve_amt_from = request.getParameter("dummy_eve_amt_from");
        String dummy_eve_amt_to = request.getParameter("dummy_eve_amt_to");
        String dummy_eve_amt_time = request.getParameter("dummy_eve_amt_time");
        String dummy_mid_amt_from = request.getParameter("dummy_mid_amt_from");
        String dummy_mid_amt_to = request.getParameter("dummy_mid_amt_to");
        String dummy_mid_amt_time = request.getParameter("dummy_mid_amt_time");

        if (CountQry("tbloperator", "companyname='"+companyname+"'  and companyid<>'"+companyid+"'") > 0) {
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Operator already exists");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
        } else {
                String query = "companyname='"+rchar(companyname)+"', "
                            + " shortname='"+rchar(shortname)+"', "
                            + " website='"+rchar(website)+"', "
                            + " email='"+rchar(email)+"', "
                            + " mobile='"+rchar(mobile)+"', "
                            + " ownersaccountid='"+ownersaccountid+"', " 
                            + " testaccountid='"+testaccountid+"', " 
                            + " cs_whatsapp='"+cs_whatsapp+"', " 
                            + " cs_messenger='"+cs_messenger+"', " 
                            + " op_com_rate='"+op_com_rate+"', "
                            + " be_com_rate='"+be_com_rate+"', "
                            + " draw_rate='"+draw_rate+"', " 
                            + " video_min_credit='"+video_min_credit+"', "
                            + " minbet='"+minbet+"', "
                            + " maxbet='"+maxbet+"', "
                            + " mintransfer='"+mintransfer+"', "
                            + " maxtransfer='"+maxtransfer+"', "
                            + " mindeposit='"+mindeposit+"', " 
                            + " maxdeposit='"+maxdeposit+"', "
                            + " minwithdraw='"+minwithdraw+"', "
                            + " maxwithdraw='"+maxwithdraw+"', "
                            + " enablebetwatcher="+enablebetwatcher+", "
                            + " betwacherid='"+betwacherid+"', "
                            + " betwatchermaxamount='"+betwatchermaxamount+"', " 
                            + " betwatcherodds='"+betwatcherodds+"', " 
                            + " betwatcherincludedummybets="+betwatcherincludedummybets+", " 
                            + " enable_agent_commission="+enable_agent_commission+", "
                            + " actived="+actived+", "
                            + " dummy_enable="+dummy_enable+", "
                            + " dummy_master='"+dummy_master+"', "
                            + " dummy_account_1='"+dummy_account_1+"', "
                            + " dummy_account_2='"+dummy_account_2+"', "
                            + " dummy_am_amt_from='"+dummy_am_amt_from+"', "
                            + " dummy_am_amt_to='"+dummy_am_amt_to+"', "
                            + " dummy_am_amt_time='"+dummy_am_amt_time+"', "
                            + " dummy_pm_amt_from='"+dummy_pm_amt_from+"', "
                            + " dummy_pm_amt_to='"+dummy_pm_amt_to+"', "
                            + " dummy_pm_amt_time='"+dummy_pm_amt_time+"', "
                            + " dummy_eve_amt_from='"+dummy_eve_amt_from+"', "
                            + " dummy_eve_amt_to='"+dummy_eve_amt_to+"', "
                            + " dummy_eve_amt_time='"+dummy_eve_amt_time+"', "
                            + " dummy_mid_amt_from='"+dummy_mid_amt_from+"', "
                            + " dummy_mid_amt_to='"+dummy_mid_amt_to+"', "
                            + " dummy_mid_amt_time='"+dummy_mid_amt_time+"'";

                if (mode.equals("add")){
                    String id = getSystemSeriesID("series_operator");
                    ExecuteQuery("insert into tbloperator set companyid='"+id+"', " + query);
                    mainObj.put("message","Operator Sucessfully Added");
                    LogActivity(userid,"added operator's name " + companyname);   
                }else{
                    ExecuteQuery("UPDATE tbloperator set " + query + " where companyid='"+companyid+"'");
                    mainObj.put("message","Operator Sucessfully Updated");
                    LogActivity(userid,"update operator's " + companyname + " information");   
                }
                mainObj = LoadOperators(mainObj);
                mainObj.put("status", "OK");
                out.print(mainObj);    
                
        }
    } else if(x.equals("block_operator")){
        String companyid = request.getParameter("companyid");
        String companyname = request.getParameter("companyname");
        String reason = request.getParameter("reason");

        
        ExecuteQuery("update tbloperator set actived=0, blocked=1, blockedreason='"+rchar(reason)+"',dateblocked=current_timestamp where companyid = '"+companyid+"';");
        ExecuteQuery("update tblsubscriber set operator_blocked=1, operator_blocked_message='"+globalOperatorBlockedMessage+"' where operatorid = '"+companyid+"';");
        LogActivity(userid,"blocked operator " + companyname + "");   

        JSONObject param = new JSONObject();
        param.put("mode", "blocked");
        FirebaseOperator(companyid, globalOperatorBlockedTitle, globalOperatorBlockedMessage, param);

        mainObj.put("status", "OK");
        mainObj.put("message","Operator successfully blocked");
        mainObj = LoadOperators(mainObj);
        out.print(mainObj);

    }else if(x.equals("unblock_operator")){
        String companyid = request.getParameter("companyid");
        String companyname = request.getParameter("companyname");
        
        ExecuteQuery("update tbloperator set blocked=0, blockedreason='',dateblocked=null where companyid = '"+companyid+"';");
        ExecuteQuery("update tblsubscriber set operator_blocked=0, operator_blocked_message='' where operatorid = '"+companyid+"';");
        LogActivity(userid,"unblocked operator " + companyname + "");   

        JSONObject param = new JSONObject();
        param.put("mode", "unblocked");
        
        FirebaseOperator(companyid, globalOperatorAuthorizedTitle, globalOperatorAuthorizedMessage, param);

        mainObj.put("status", "OK");
        mainObj.put("message","Operator successfully unblocked");
        mainObj = LoadOperators(mainObj);
        out.print(mainObj);

    }else if(x.equals("load_banks")){
        mainObj.put("status", "OK");
        mainObj = LoadOperatorBank(mainObj);
        mainObj = getRemittances(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("save_bank_info")){
        boolean edit = Boolean.parseBoolean(request.getParameter("edit"));
        String id = request.getParameter("id");
        String remittanceid = request.getParameter("remittanceid");
        String operatorid = request.getParameter("operatorid");
        String accountnumber = request.getParameter("accountnumber");
        String accountname = request.getParameter("accountname");
        String qrcode = request.getParameter("qrcode");
        boolean enable = Boolean.parseBoolean(request.getParameter("enable"));

        String qrcode_url = "";
        if(qrcode.length() > 0){
            ServletContext serveapp = request.getSession().getServletContext();
            qrcode_url = AttachedPhoto(serveapp, "bank", qrcode, accountnumber);
        }

        if(edit){
            ExecuteQuery("UPDATE tblbankaccounts set isoperator=1, accountid='"+operatorid+"', remittanceid='"+remittanceid+"', accountnumber='"+accountnumber+"', accountname='"+rchar(accountname)+"', qrcode_url='"+qrcode_url+"', actived="+ enable + " where id='"+id+"'");
            mainObj.put("message","Bank account successfully updated!");
        }else{
            ExecuteQuery("INSERT INTO tblbankaccounts set isoperator=1, accountid='"+operatorid+"', remittanceid='"+remittanceid+"', accountnumber='"+accountnumber+"', accountname='"+rchar(accountname)+"', qrcode_url='"+qrcode_url+"', actived="+ enable + ", dateadded=current_timestamp");
            mainObj.put("message","Bank account successfully added!");
        }

        mainObj.put("status", "OK");
        mainObj = LoadOperatorBank(mainObj);
        out.print(mainObj);

    }else if(x.equals("delete_bank")){
        String id = request.getParameter("id");
        String accountid = request.getParameter("accountid");
        boolean isoperator = Boolean.parseBoolean(request.getParameter("isoperator"));

        ExecuteQuery("UPDATE tblbankaccounts set deleted=1,datedeleted=current_timestamp where id='"+id+"'");

        if(isoperator){
            mainObj =LoadOperatorBank(mainObj);
        }else{
            mainObj = LoadAgentBank(mainObj, accountid);;
        }
        
        mainObj.put("status", "OK");
        mainObj.put("message","Bank Account sucessfully deleted");
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