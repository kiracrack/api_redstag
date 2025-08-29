<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    boolean guest = Boolean.parseBoolean(request.getParameter("guest"));

    if(x.isEmpty()){
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

    }else if(!guest){
        String sessionid = request.getParameter("sessionid");
        if(isSessionExpired(userid,sessionid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", globalExpiredSessionMessage);
            mainObj.put("errorcode", "session");
            out.print(mainObj);
            return;
        }
    }
    
    if(!guest) mainObj = api_account_info(mainObj, userid, false);

    if(x.equals("home")){
        if(!guest){
            AccountInfo info = new AccountInfo(userid);
            if(info.isonlineagent){
                 mainObj = api_popup_banner(mainObj);
            }
            mainObj = api_casino_featured(mainObj, info.masteragentid);
        }else{
            mainObj = api_casino_featured(mainObj, "");
        }
       
        mainObj = api_active_arena(mainObj);
        mainObj = api_casino_games(mainObj);
        mainObj = api_casino_category(mainObj);
        mainObj = api_casino_popular(mainObj, "most_played");
        mainObj = api_casino_popular(mainObj, "top_rated");
        
        mainObj.put("status", "OK");
        mainObj.put("message", "response valid");
        out.print(mainObj);

    }else if(x.equals("profile")){
        mainObj.put("status", "OK");
        AccountInfo info = new AccountInfo(userid);
        if(info.isonlineagent && !info.masteragent){
            mainObj = api_referral_summary(mainObj, userid);
            mainObj = api_game_statistic(mainObj, userid);
        }
        mainObj = getBankAccounts(mainObj, userid);
        mainObj.put("message", "response valid");
        out.print(mainObj);
        
    }else if(x.equals("event")){
        String eventid = request.getParameter("eventid");
        EventInfo event = new EventInfo(eventid, false);
        AccountInfo info = new AccountInfo(userid);
        ArenaInfo arena = new ArenaInfo(event.arenaid);

        if(info.custom_promo_enabled){
            PromotionInfo promo = new PromotionInfo(info.custom_promo_code);
            if(!promo.cockfight){
                mainObj.put("status", "ERROR");
                mainObj.put("message", "Your current promo is not allowed to play cockfight");
                mainObj.put("errorcode", "400");
                out.print(mainObj);
                return;
            }
        }else if(info.rebate_enabled){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Your account is not allowed to play sabong!");
            mainObj.put("errorcode", "session");
            out.print(mainObj);
            return;
        }

        mainObj.put("plasada", GlobalFightCommission);
        mainObj.put("opposite_bet", arena.opposite_bet);
        mainObj = api_event_info(mainObj, eventid);
        mainObj = api_event_notice(mainObj, eventid);
        mainObj = api_event_video(mainObj, eventid);
        mainObj = api_result_info(mainObj, eventid);
        mainObj = api_current_event_bet(mainObj, userid, eventid);
        mainObj = api_current_fight_bet(mainObj, userid, event.fightkey);
        mainObj = api_current_fight_summary(mainObj, event.fightkey, info.operatorid);

        LogGameStatistic(userid, "cockfight", event.arenaid, arena.arenaname, arena.main_banner_url);

        mainObj.put("status", "OK");
        mainObj.put("message", "response valid");
        out.print(mainObj);

    }else if(x.equals("current_event_bet")){
        String eventid = request.getParameter("eventid");
        
        mainObj = api_current_event_bet(mainObj, userid, eventid);
        mainObj.put("status", "OK");
        mainObj.put("message", "response valid");
        out.print(mainObj);

    }else if(x.equals("games")){
        mainObj.put("status", "OK");
         if(!guest){
            AccountInfo info = new AccountInfo(userid);
            mainObj = api_casino_featured(mainObj, info.masteragentid);
        }else{
            mainObj = api_casino_featured(mainObj, "");
        }

        mainObj = api_active_arena(mainObj);
        mainObj = api_casino_category(mainObj);
        mainObj = api_casino_games(mainObj);
        mainObj.put("message", "response valid");
        out.print(mainObj);

    }else if(x.equals("credit_logs")){
        String accountid = request.getParameter("accountid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");
        
        mainObj = api_credit_load_logs(mainObj, accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message", "response valid");
        out.print(mainObj);

    }else if(x.equals("users_online")){
        AccountInfo info = new AccountInfo(userid);
        PushFirebaseUsers(info.operatorid, false);

    }else if(x.equals("agent")){ 
        mainObj = api_account_list(mainObj, userid, true);
        mainObj.put("status", "OK");
        mainObj.put("account_type", x);
        mainObj.put("message","Result synchronized");
        out.print(mainObj);
    
    }else if(x.equals("player") || x.equals("referred")){
        mainObj = api_account_list(mainObj, userid, false);
        mainObj.put("status", "OK");
        mainObj.put("account_type", x);
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("deposit")){
        mainObj = api_deposit_list(mainObj, userid);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("withdrawal")){
        mainObj = api_withdrawal_list(mainObj, userid);
        mainObj.put("status", "OK");
        mainObj.put("message","Result synchronized");
        out.print(mainObj);

    }else if(x.equals("promo")){
        if(!guest){
            AccountInfo info = new AccountInfo(userid);
            mainObj = api_rebate_promo(mainObj, userid);
            mainObj = api_turnover_promo(mainObj, userid);
            mainObj = api_weekly_rebate_winloss(mainObj, userid);
            mainObj = api_custom_promo(mainObj, userid);
            mainObj = api_winstrike_promo(mainObj, userid, info.winstrike_eventid, info.winstrike_category);
            mainObj = api_promotion_list(mainObj, info.operatorid);
        }else{
             mainObj = api_promotion_list(mainObj, "");
        }
        
        mainObj.put("status", "OK");
        mainObj.put("message","request returned valid");
        out.print(mainObj);

    }else if(x.equals("score_request")){
        mainObj = api_score_request(mainObj, userid);
        mainObj.put("status", "OK");
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
      logError("app-x-webapp",e.getMessage());
}
%>

