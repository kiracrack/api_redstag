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
