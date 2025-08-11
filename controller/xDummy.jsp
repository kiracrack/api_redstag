<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xGameModule.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String deviceid = request.getParameter("deviceid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || deviceid.isEmpty() || sessionid.isEmpty()){
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
        return;

    }else if(isControllerRemoved(deviceid)){
        mainObj.put("status", "BLOCKED");
        mainObj.put("message","Your controller was removed by administrator!");
        mainObj.put("errorcode", "100");
        out.print(mainObj);
        return;

    }else if(isControllerBlocked(deviceid)){
        mainObj.put("status", "BLOCKED");
        mainObj.put("message","Your controller was blocked by administrator!");
        mainObj.put("errorcode", "100");
        out.print(mainObj);
        return;
    }

    if(x.equals("dummy_post_bet")){ 
        String eventid = request.getParameter("eventid");
        String operatorid = request.getParameter("operatorid");
        String accountid = request.getParameter("accountid");
        String dummy_id = request.getParameter("dummy_id");
        String dummy_name = request.getParameter("dummy_name");
        String bet_choice = request.getParameter("bet_choice");
        String bet_amount = request.getParameter("bet_amount");
        String appreference = request.getParameter("appreference");

        EventInfo event = new EventInfo(eventid, false);
        String fightkey = event.fightkey;
        
        if(CountQry("tblevent", "eventid='"+eventid+"' and (current_status='closed' or current_status='result')") > 0 ){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Current fight is already closed!");
            out.print(mainObj);
            return;
            
        }else if(CountQry("tblevent", "eventid='"+eventid+"' and current_status='standby'") > 0 ){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Current fight is not yet open!");
            out.print(mainObj);
            return;

        }else if(CountQry("tblevent", "eventid='"+eventid+"' and current_status='cancelled'") > 0 ){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Current fight is cancelled!");
            out.print(mainObj);
            return;

        }

        ExecutePostBet("android", eventid, sessionid, appreference, operatorid, accountid, bet_choice , Double.parseDouble(bet_amount), "",false, true, false, dummy_id, dummy_name);

        mainObj.put("status", "OK");
        mainObj = CurrentBetSummary(mainObj, fightkey, operatorid);
        mainObj.put("message","request returned valid");
        out.print(mainObj);

        if(operatorid.equals(GlobalDefaultOperator)){
            JSONObject apiObj = new JSONObject();
            apiObj.put("plasada", GlobalFightCommission);
            apiObj = api_current_fight_summary(apiObj, fightkey, operatorid);
            PusherPost(eventid, apiObj);
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
      logError("controller-x-dummy",e.getMessage());
}
%>