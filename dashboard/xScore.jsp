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
    
    if(x.equals("load_score")){
        String operatorid = request.getParameter("operatorid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        boolean admin = Boolean.parseBoolean(request.getParameter("admin"));
        boolean system = Boolean.parseBoolean(request.getParameter("system"));

        mainObj.put("status", "OK");
        mainObj = LoadScore(mainObj,operatorid, datefrom, dateto, admin, system);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("set_score")){
        String operatorid = request.getParameter("operatorid");
        String appreference = request.getParameter("appreference");
        String accountid = request.getParameter("accountid");
        String fullname = request.getParameter("fullname");
        String trntype = request.getParameter("trntype");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String reference = request.getParameter("reference");

        if(CountQry("tblsubscriber", "accountid='"+accountid+"'") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Account number not found");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        ExecuteSetScoreAdmin(operatorid, sessionid, appreference, accountid, fullname, trntype, amount, reference, userid);

        if(trntype.equals("ADD")){
            mainObj.put("message", "Score successfully added to account " + fullname.toLowerCase());
            SendScoreNotification(accountid, true, amount);
        }else{
            mainObj.put("message", "Score successfully deduct from account " + fullname.toLowerCase());
            SendScoreNotification(accountid, false, amount);
        }

        mainObj.put("status", "OK");
        mainObj = LoadScore(mainObj, operatorid);
        mainObj = LoadUpdatedAgent(mainObj, accountid);
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
    logError("dashboard-x-score",e.toString());
}
%>

<%!public JSONObject LoadScore(JSONObject mainObj, String operatorid, String datefrom, String dateto, boolean admin, boolean system) {
    String filter = "";
    if(admin && system){
        filter = "";
    }else if(admin && !system){    
        filter = " and dashboard=1 ";

    }else if(!admin && system){    
        filter = " and dashboard=0 ";
    }
    mainObj = DBtoJson(mainObj, "score", "select *, "
                        + " (select fullname from tblsubscriber where accountid=a.accountid) as 'accountname', " 
                        + " (select fullname from tblsubscriber where accountid=a.masteragentid) as 'masteragent', " 
                        + " (select fullname from tblsubscriber where accountid=a.agentid) as 'agent', " 
                        + " if(dashboard, (select fullname from tbladminaccounts where id=a.trnby), (select fullname from tblsubscriber where accountid=a.trnby)) as 'transby', " 
                        + " if(trntype='DEDUCT',-amount,amount) as score from tblcreditloadlogs as a where operatorid='"+operatorid+"' and date_format(datetrn,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' " + filter + " order by datetrn asc");
    return mainObj;
  }%>

<%!public JSONObject LoadScore(JSONObject mainObj, String operatorid) {
      mainObj = DBtoJson(mainObj, "score", "select *, "
                            + " (select fullname from tblsubscriber where accountid=a.accountid) as 'accountname', " 
                            + " (select fullname from tblsubscriber where accountid=a.masteragentid) as 'masteragent', " 
                            + " (select fullname from tblsubscriber where accountid=a.agentid) as 'agent', " 
                            + " if(trntype='DEDUCT',-amount,amount) as score from tblcreditloadlogs as a where operatorid='"+operatorid+"' and date_format(datetrn,'%Y-%m-%d')=current_date order by datetrn asc");
      return mainObj;
  }%>

<%!public JSONObject LoadUpdatedAgent(JSONObject mainObj, String accountid) {
      mainObj = DBtoJson(mainObj, "agents", sqlAgentQuery + " where accountid='"+accountid+"'");
      return mainObj;
  }%>