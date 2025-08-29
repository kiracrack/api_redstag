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
    
    if(x.equals("arena")){ 
        mainObj.put("status", "OK");
        mainObj = getActiveArena(mainObj);
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 

    }else if(x.equals("event_info")){
        String eventid = request.getParameter("eventid");

        AccountInfo info = new AccountInfo(userid);
        if(info.custom_promo_enabled){
            PromotionInfo promo = new PromotionInfo(info.custom_promo_code);
            if(!promo.cockfight){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Your current promo is not allowed to play cockfight");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }

        mainObj.put("status", "OK");
        mainObj = getAccountInformation(mainObj, userid);
        mainObj = getEventInfo(mainObj, eventid);
        mainObj.put("message","request returned valid");
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
      logError("app-x-event",e.getMessage());
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