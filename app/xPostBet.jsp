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
try{

    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");
    String appreference = request.getParameter("appreference");

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

    if(x.equals("post_bet")){
        String eventid = request.getParameter("eventid");
        String display_name = request.getParameter("display_name");
        String bet_choice =  request.getParameter("bet_choice");
        double bet_amount =  Double.parseDouble(request.getParameter("bet_amount"));
        String ws_selection =  request.getParameter("ws_selection");
        String platform =  request.getParameter("platform"); if(platform == null) platform = "android";
        
        EventInfo event = new EventInfo(eventid, false);
        String eventkey =  event.eventkey;
        String fightkey =  event.fightkey;
        String fightnumber = event.fightnumber;
        String postingdate = event.postingdate; 

        AccountInfo info = new AccountInfo(userid);
        String operatorid =  info.operatorid;
        String masteragentid =  info.masteragentid;
        String agentid =  info.agentid;
        
        OperatorInfo op = new OperatorInfo(operatorid);
        boolean test = (op.testaccountid.equals(masteragentid) ? true : false);

        if(info.iscashaccount && info.rebate_enabled){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "You have entered on rebate bonus account mode. Sabong is not available");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        if(CountQry("tblevent", "eventid='"+eventid+"' and fightkey='"+fightkey+"'") == 0 ){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Current fight is already changed! Please refresh you app");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(CountQry("tblevent", "eventid='"+eventid+"' and current_status='closed'") > 0 ){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Current fight #"+fightnumber+" is already closed!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(CountQry("tblevent", "eventid='"+eventid+"' and current_status='result'") > 0 ){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Current fight #"+fightnumber+" is already closed!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

         }else if(CountQry("tblevent", "eventid='"+eventid+"' and current_status='standby'") > 0 ){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Current fight #"+fightnumber+" is not yet open!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        
        }else if(CountQry("tblevent", "eventid='"+eventid+"' and current_status='cancelled'") > 0 ){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Current fight #"+fightnumber+" is cancelled!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal>="+bet_amount+"") == 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Your score balance is insufficient!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(op.minbet > 0 && bet_amount < op.minbet){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Minimum bet per fight is "+op.minbet+"!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(op.maxbet > 0 && MaxBet(userid, fightkey, bet_amount, op.maxbet)){
            mainObj.put("status", "ERROR");
            mainObj.put("message","You have reach a maximum limit bet per fight!");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        if(!ws_selection.isEmpty()){
            WinStrikeBonus ws = new WinStrikeBonus(ws_selection);
            String bonuscode = eventid + "-" + ws_selection;
            if(info.winstrike_available){
                mainObj.put("status", "ERROR");
                mainObj.put("message","You have available winstrike bonus! Please claim first before avail another winstrike");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;

            }else if(bet_amount < ws.min_bet){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Minimum bet is "+String.valueOf(ws.min_bet)+"!");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
           
           }else if(isBonusExists(userid, bonuscode)){
                mainObj.put("status", "ERROR");
                mainObj.put("message","Win strike bonus for " + ws_selection + " is not available");
                mainObj.put("errorcode", "100");
                out.print(mainObj);
                return;
        
            }
        }

        String description = display_name + " post bet " + bet_choice + " on event " + eventid;

        if(!isLogLedgerFound(userid, sessionid, appreference, description, bet_amount, 0, userid)){
            LogLedgerTransaction(userid, sessionid, appreference, description, bet_amount, 0, userid);
            ExecutePostBet(platform, eventid, sessionid, appreference, operatorid, userid, bet_choice, bet_amount, ws_selection, false, false, test, userid, display_name);
        }

        String creditbal = getLatestCreditBalance(userid);

        mainObj.put("status", "OK");
        mainObj.put("creditbal", creditbal);
        mainObj.put("amount", bet_amount);
        mainObj = FetchMyBet(mainObj, userid, fightkey);
        mainObj = CurrentBetSummary(mainObj, fightkey, operatorid);
        mainObj.put("message", "Your bet successfully posted!");
        out.print(mainObj);

        JSONObject apiObj = new JSONObject();
        apiObj.put("plasada", GlobalFightCommission);
        apiObj = api_current_fight_summary(apiObj, fightkey, operatorid);
        PusherPost(eventid, apiObj);

        if(platform.equals("webapi")){
            JSONObject apiObjuser = new JSONObject();
            apiObjuser = api_current_fight_bet(apiObjuser, userid, fightkey);
            apiObjuser = api_account_creditbal(apiObjuser, userid);
            PusherPost(userid, apiObjuser);
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
      logError("app-x-postbet",e.getMessage());
}
%>

<%!public boolean MaxBet(String userid, String fightkey, double addBet, double maxbet) {
    double totalBet = Double.parseDouble(QuerySingleData("ifnull(sum(bet_amount),0)","totalbet", "tblfightbets where accountid='" + userid + "' and fightkey='"+fightkey+"'")); 
    if((totalBet+addBet) > maxbet){
        return true;
    }else{
        return false;
    }
  }
 %>