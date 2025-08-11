<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xWinlossSabong.jsp" %>
<%@ include file="../module/xWinlossCasino.jsp" %>
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
 
    if(x.equals("win_loss_cockfight")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        
        if(getDifferenceDays(datefrom, dateto) >= 7) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Winloss query by date report for more than 7 days is not allowed! please select date for a week only");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        AccountInfo account = new AccountInfo(accountid);
        if(compute_sabong_agent(userid, (account.isagent || account.masteragent ? accountid : account.agentid), datefrom, dateto, "- ")){
            mainObj.put("status", "OK");
            mainObj.put("isagent", String.valueOf(account.isagent));
            mainObj.put("commissionrate", account.commissionrate);
            mainObj.put("accountid", accountid);
            mainObj = DisplayWinLossSabongAgent(mainObj, userid);
            mainObj.put("message", "data synchronized");
            out.print(mainObj); 
        }
    
    } else if(x.equals("win_loss_casino")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        
        if(getDifferenceDays(datefrom, dateto) >= 7) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Winloss query by date report for more than 7 days is not allowed! please select date for a week only");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        AccountInfo account = new AccountInfo(accountid);
        if(compute_casino_agent(userid, (account.isagent || account.masteragent ? accountid : account.agentid), datefrom, dateto, "- ")){
            mainObj.put("status", "OK");
            mainObj.put("isagent", String.valueOf(account.isagent));
            mainObj.put("commissionrate", account.commissionrate);
            mainObj.put("accountid", accountid);
            mainObj = DisplayWinLossCasinoAgent(mainObj, userid);
            mainObj.put("message", "data synchronized");
            out.print(mainObj); 
        }
    
    } else if(x.equals("commission_cockfight")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");   
        String dateto = request.getParameter("dateto");
        
        if(getDifferenceDays(datefrom, dateto) >= 7) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Commission query by date report for more than 7 days is not allowed! please select date for a week only");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        AccountInfo account = new AccountInfo(accountid);
        if(compute_sabong_agent(userid, accountid, datefrom, dateto, "- ")){
            mainObj.put("status", "OK");
            mainObj.put("commissionrate", account.commissionrate);
            mainObj = DisplayWinLossSabongCommission(mainObj, userid);
            mainObj.put("message", "data synchronized");
            out.print(mainObj); 

        }
    } else if(x.equals("commission_casino")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");   
        String dateto = request.getParameter("dateto");
        
        if(getDifferenceDays(datefrom, dateto) >= 7) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Commission query by date report for more than 7 days is not allowed! please select date for a week only");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        AccountInfo account = new AccountInfo(accountid);
        if(compute_casino_agent(userid, accountid, datefrom, dateto, "- ")){
            mainObj.put("status", "OK");
            mainObj.put("commissionrate", account.commissionrate);
            mainObj = DisplayWinLossCasinoCommission(mainObj, userid);
            mainObj.put("message", "data synchronized");
            out.print(mainObj); 
        }

    }else if(x.equals("downline_cockfight")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        
        if(getDifferenceDays(datefrom, dateto) >= 7) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Downline query by date report for more than 7 days is not allowed! please select date for a week only");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        AccountInfo account = new AccountInfo(accountid);
        if(compute_sabong_agent(userid, (account.isagent || account.masteragent ? accountid : account.agentid), datefrom, dateto, "- ")){
            mainObj.put("status", "OK");
            mainObj.put("isagent", String.valueOf(account.isagent));
            mainObj = DisplayDownlineSabongReport(mainObj, userid);
            mainObj.put("message", "data synchronized");
            out.print(mainObj);
        }
    
    }else if(x.equals("downline_casino")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        
        if(getDifferenceDays(datefrom, dateto) >= 7) {
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Downline query by date report for more than 7 days is not allowed! please select date for a week only");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }
        
        AccountInfo account = new AccountInfo(accountid);
        if(compute_casino_agent(userid, (account.isagent || account.masteragent ? accountid : account.agentid), datefrom, dateto, "- ")){
            mainObj.put("status", "OK");
            mainObj.put("isagent", String.valueOf(account.isagent));
            mainObj = DisplayDownlineCasinoReport(mainObj, userid);
            mainObj.put("message", "data synchronized");
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
      logError("app-x-report",e.getMessage());
}
%>
 
