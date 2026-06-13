<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xScoreReport.jsp" %>
<%@ include file="../module/xWinlossSabong.jsp" %>
<%@ include file="../module/xWinlossCasino.jsp" %>
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

    if(x.equals("winloss_sabong")){
        String operatorid = request.getParameter("operatorid");
        String agentid = request.getParameter("agentid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        
        if(agentid.length() > 0){
            compute_sabong_agent(userid, agentid, datefrom, dateto, "- ");
            mainObj = DisplayWinLossSabongAgent(mainObj, userid);
        }else{
            //compute_sabong_master(userid, operatorid, datefrom, dateto, "- ");
            mainObj = DisplayWinLossSabongMaster(mainObj, datefrom, dateto);
        }
    
        mainObj.put("status", "OK");
        mainObj.put("message", "data synchronized");
        out.print(mainObj);

    }else if(x.equals("winloss_casino")){
        String operatorid = request.getParameter("operatorid");
        String agentid = request.getParameter("agentid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        
         if(agentid.length() > 0){
            compute_casino_agent(userid, agentid, datefrom, dateto, "- ");
            mainObj = DisplayWinLossCasinoAgent(mainObj, userid);
        }else{
            //compute_casino_master(userid, operatorid, datefrom, dateto, "- ");
            mainObj = DisplayWinLossCasinoMaster(mainObj, datefrom, dateto);
        }
    
        mainObj.put("status", "OK");
        mainObj.put("message", "data synchronized");
        out.print(mainObj);
    
    }else if(x.equals("betting_sabong_report")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = LoadSabongBetsReport(mainObj, accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message", "data synchronized");
        out.print(mainObj);
    
    }else if(x.equals("betting_casino_report")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = LoadCasinoBetsReport(mainObj, accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message", "data synchronized");
        out.print(mainObj);
     
    }else if(x.equals("agent_downline_report")){
        String agentid = request.getParameter("agentid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        
        if(compute_sabong_agent(userid, agentid, datefrom, dateto, "- ")){
            mainObj.put("status", "OK");
            mainObj = DisplayDownlineSabongReport(mainObj, userid);
            mainObj.put("message", "data synchronized");
            out.print(mainObj);
        }

    }else if(x.equals("load_winloss_filter")){
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = MasterList(mainObj, operatorid);
        mainObj = EnableList(mainObj, operatorid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("enable_master_agent")){
        String operatorid = request.getParameter("operatorid");
        String accountid = request.getParameter("accountid");
        
        String[] arr = accountid.split(",");
        if(arr.length > 1){
            for (String id : arr) {
                EnableMasterAgent(operatorid, id);
            }
        }else{
            EnableMasterAgent(operatorid, accountid);
        }

        mainObj.put("status", "OK");
        mainObj.put("message", "command accepted");
        out.print(mainObj);

    }else if(x.equals("disable_master_agent")){
        String accountid = request.getParameter("accountid");

        String[] arr = accountid.split(",");
        if(arr.length > 1){
            for (String id : arr) {
                DisableMasterAgent(id);
            }
        }else{
            DisableMasterAgent(accountid);
        }
        mainObj.put("status", "OK");
        mainObj.put("message", "Selected game successfully disable!");
        out.print(mainObj);


    }else if(x.equals("general_report")){
        String operatorid = request.getParameter("operatorid");
        boolean include_casino = Boolean.parseBoolean(request.getParameter("include_casino"));
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        GeneralSummaryOnline rpt = new GeneralSummaryOnline(operatorid, include_casino, datefrom, dateto);
        String sabong = FormatCurrency(String.valueOf(-rpt.sabong));
        String casino = FormatCurrency(String.valueOf(-rpt.casino));
        
       
        JSONArray objarray = new JSONArray();
        objarray.add(CreateObj("Total Sabong", String.valueOf((rpt.sabong == 0 ? "0.00" : sabong)), false, ""));
        if(include_casino) objarray.add(CreateObj("Total Casino", String.valueOf((rpt.casino == 0 ? "0.00" : casino)), false, ""));
        
        double total_profit = (-rpt.sabong) + (-rpt.casino);
        String profit = FormatCurrency(String.valueOf(total_profit));
        objarray.add(CreateObj("Total Winloss", String.valueOf((total_profit == 0 ? "0.00" : profit)), true, "#daf2d0"));
        objarray.add(CreateObj(" ", "", false, ""));
        
        String deposit = FormatCurrency(String.valueOf(rpt.deposit));
        String withdraw = FormatCurrency(String.valueOf(rpt.withdraw));

        String app_transfer = FormatCurrency(String.valueOf(rpt.app_transfer));
        String app_remove = FormatCurrency(String.valueOf(rpt.app_remove));

        String admin_transfer = FormatCurrency(String.valueOf(rpt.admin_transfer));
        String admin_remove = FormatCurrency(String.valueOf(rpt.admin_remove));

        String regular_bonus = FormatCurrency(String.valueOf(rpt.regular_bonus));
        String bonus_withdraw = FormatCurrency(String.valueOf(-rpt.bonus_withdraw));
        String bonus_return = FormatCurrency(String.valueOf(rpt.bonus_return));
        String forfeited_bonus = FormatCurrency(String.valueOf(rpt.forfeited_bonus));

        objarray.add(CreateObj("Total Deposit", String.valueOf((rpt.deposit == 0 ? "0.00" : deposit)), false, ""));
        objarray.add(CreateObj("Manual Score Transfer (onlineagent)", String.valueOf((rpt.app_transfer == 0 ? "0.00" : app_transfer)), false, ""));
        objarray.add(CreateObj("Manual Score Transfer (dashboard)", String.valueOf((rpt.admin_transfer == 0 ? "0.00" : admin_transfer)), false, ""));
        objarray.add(CreateObj("Regular Bonus Claimed", String.valueOf((rpt.regular_bonus == 0 ? "0.00" : regular_bonus)), false, ""));
        
        double total_in = rpt.deposit + rpt.app_transfer + rpt.admin_transfer + rpt.regular_bonus;
        objarray.add(CreateObj("TOTAL CREDIT-IN", String.valueOf((total_in == 0 ? "0.00" : FormatCurrency(String.valueOf(total_in)))), true, "#daf2d0"));
        objarray.add(CreateObj(" ", "", false, ""));

        objarray.add(CreateObj("Total Withdraw", String.valueOf((rpt.withdraw == 0 ? "0.00" : withdraw)), false, ""));
        objarray.add(CreateObj("Manual Score Remove (onlineagent)", String.valueOf((rpt.app_remove == 0 ? "0.00" : app_remove)), false, ""));
        objarray.add(CreateObj("Manual Score Remove (dashboard)", String.valueOf((rpt.admin_remove == 0 ? "0.00" : admin_remove)), false, ""));
        objarray.add(CreateObj("OFFSET (Custom Bonus Withdraw)", String.valueOf((rpt.bonus_withdraw == 0 ? "0.00" : bonus_withdraw)), false, ""));

        double total_out = rpt.withdraw + rpt.app_remove + rpt.admin_remove + (-rpt.bonus_withdraw);
        objarray.add(CreateObj("TOTAL CREDIT-OUT", String.valueOf((total_out == 0 ? "0.00" :  FormatCurrency(String.valueOf(total_out)))), true, "#daf2d0"));
        objarray.add(CreateObj(" ", "", false, ""));

        double total_in_out = total_in - total_out;
        objarray.add(CreateObj("TOTAL CREDIT-IN Less CREDIT-OUT", String.valueOf((total_in_out == 0 ? "0.00" :  FormatCurrency(String.valueOf(total_in_out)))), true, "#daf2d0"));
        double winloss_variance = total_profit - total_in_out;
        objarray.add(CreateObj("WINLOSS VARIANCE", String.valueOf((winloss_variance == 0 ? "0.00" :  FormatCurrency(String.valueOf(winloss_variance)))), true, "#daf2d0"));

        /*
        objarray.add(CreateObj("Returned Bonus", (rpt.bonus_return == 0 ? "0.00" : bonus_return), false, ""));
        objarray.add(CreateObj("Forfeited Bonus", (rpt.forfeited_bonus == 0 ? "0.00" : forfeited_bonus), false, ""));*/
        
        mainObj.put("status", "OK");
        mainObj.put("general_report", objarray);        
        mainObj.put("message", "Successfull Synchronized");
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
    logError("dashboard-x-report",e.toString());
}
%> 

<%!public JSONObject MasterList(JSONObject mainObj, String operatorid) {
      mainObj = DBtoJson(mainObj, "master_list", "select accountid, fullname from tblsubscriber where masteragent=1 and deleted=0 and accountid not in (select accountid from tblwinlossfilter where operatorid='"+operatorid+"') and operatorid='"+operatorid+"'");
      return mainObj;
}
%>

<%!public JSONObject EnableList(JSONObject mainObj, String operatorid) {
      mainObj = DBtoJson(mainObj, "enabled_list", "select accountid, accountname from tblwinlossfilter where operatorid='"+operatorid+"'");
      return mainObj;
}
%>

 <%!public void EnableMasterAgent(String operatorid, String accountid) {
    if(CountQry("tblwinlossfilter", "accountid='" + accountid + "'") == 0){
        String accountname = getFullname(accountid);
        ExecuteQuery("insert into tblwinlossfilter set operatorid='"+operatorid+"',accountid='" + accountid + "', accountname='" + rchar(accountname) + "' ");
    }
}
%>

<%!public void DisableMasterAgent(String accountid) {
    ExecuteQuery("DELETE from tblwinlossfilter where accountid='" + accountid + "'");
}
%>
