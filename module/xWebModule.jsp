<%!public JSONObject api_account_info(JSONObject mainObj,  String userid, boolean login) {
   AccountInfo info = new AccountInfo(userid);
   JSONObject obj = new JSONObject();
   obj.put("accountid", userid);
   obj.put("operatorid", info.operatorid);
   obj.put("masteragentid", info.masteragentid);
   obj.put("sessionid", info.sessionid);
   obj.put("fullname", info.fullname);
   obj.put("username", info.username);
   obj.put("mobilenumber", info.mobilenumber);
   obj.put("creditbal", info.creditbal);
   obj.put("agentname", info.agentname);
   obj.put("commissionrate", info.commissionrate);
   obj.put("blocked", info.blocked);
   obj.put("blockedreason", info.blockedreason);
   obj.put("video_min_credit", info.videomincredit);
   obj.put("minbet", info.minbet);
   obj.put("maxbet", info.maxbet);
   obj.put("imageurl", info.imageurl);
   obj.put("datelogin", info.date_now);
   obj.put("timelogin", info.time_now);
   obj.put("totalonline", info.totalonline);
   obj.put("isagent", info.isagent);
   obj.put("isnewaccount", info.isnewaccount);
   obj.put("masteragent", info.masteragent);
   obj.put("referralcode", info.referralcode);
   obj.put("iscashaccount", info.iscashaccount);
   obj.put("isonlineagent", info.isonlineagent);
   obj.put("date_registered", info.date_registered);
   obj.put("rebate_available", info.rebate_available);
   obj.put("rebate_enabled", info.rebate_enabled);
   obj.put("weekly_loss_enabled", info.weekly_loss_enabled);
   obj.put("special_bonus_enabled", info.special_bonus_enabled);
   obj.put("telco_enabled", info.telco_enabled);
   
   obj.put("api_enabled", info.api_enabled);
   obj.put("api_player", info.api_player);
   obj.put("api_website", info.api_website);

   obj.put("midnight_available", info.midnight_available);
   obj.put("midnight_enabled", info.midnight_enabled);
   obj.put("midnight_bonus", info.midnight_bonus);
   obj.put("midnight_amount", info.midnight_amount);

   obj.put("newdeposit", info.newdeposit);
   obj.put("totaldeposit", info.totaldeposit);
   obj.put("creditbal", info.creditbal);
   obj.put("telco_enabled", info.telco_enabled);
   obj.put("welcome_enabled", info.welcome_enabled);
   obj.put("welcome_rate", info.welcome_rate);
   obj.put("welcome_bonus", info.welcome_bonus);
   obj.put("daily_enabled", info.daily_enabled);
   obj.put("daily_rate", info.daily_rate);
   obj.put("socialmedia_available", info.socialmedia_available);
   obj.put("socialmedia_enabled", info.socialmedia_enabled);
   obj.put("socialmedia_bonus", info.bonus_amount);

   obj.put("winstrike_selection", info.winstrike_selection);
   obj.put("winstrike_available", info.winstrike_available);
   obj.put("winstrike_category", info.winstrike_category);
   obj.put("winstrike_enabled", info.winstrike_enabled);
   obj.put("winstrike_eventid", info.winstrike_eventid);
   obj.put("winstrike_bonus", info.winstrike_bonus);
   obj.put("winstrike_type", info.winstrike_type);

   obj.put("custom_promo_enabled", info.custom_promo_enabled);
   obj.put("custom_promo_code", info.custom_promo_code);
   obj.put("custom_promo_name", info.custom_promo_name);
   obj.put("custom_promo_maxwd", info.custom_promo_maxwd);
   PromotionInfo promo = new PromotionInfo(info.custom_promo_code);
   obj.put("custom_promo_slotgame", promo.slotgame || false);
   obj.put("custom_promo_cockfight", promo.cockfight || false);

   if(login){
      obj.put("firebasemode", globalFirebaseMode);
      obj.put("firebasedb", globalFirebaseDB);
      obj.put("firebaseauth", globalFirebaseAuth);

      obj.put("pusherappid", globalPusherAppID);
      obj.put("pusherappkey", globalPusherAppKey);
      obj.put("pusherappsecret", globalPusherAppSecret);
      obj.put("pusherappcluster", globalPusherAppCluster);
      obj.put("pusherappchannel", globalPusherAppChannel);
   }

   JSONArray objarray =new JSONArray();
   objarray.add(obj);
    
   mainObj.put("profile", objarray);
   return mainObj;
  }
 %>

 <%!public JSONObject api_referral_summary(JSONObject mainObj,  String userid) {
   JSONObject obj = new JSONObject();

   ReferralInfo ref = new ReferralInfo(userid);
   obj.put("referral_account", ref.totalaccount);

   DateWeekly dw = new DateWeekly();

   /*weekly referral bonus 15RM */
   ReferralBonus bonus_prev = new ReferralBonus(userid, dw.prev_week_from, dw.prev_week_to);
   ReferralBonus bonus_curr = new ReferralBonus(userid, dw.current_week_from, dw.current_week_to);

   if(bonus_prev.amount > 0 && !isBonusExists(userid, "WRB-" + dw.prev_week_code)){
      obj.put("referral_bonus", bonus_prev.amount);
      obj.put("referral_bonus_available", true);
   }else{
      obj.put("referral_bonus", bonus_curr.amount);
      obj.put("referral_bonus_available", false);
   }

   /*weekly referral commission */
   DownlineWinlossCockfight wls_prev = new DownlineWinlossCockfight(userid, dw.prev_week_from, dw.prev_week_to);
   DownlineWinlossCasino wlc_prev = new DownlineWinlossCasino(userid, dw.prev_week_from, dw.prev_week_to);
   double totalPrevWinloss = wls_prev.winloss + wlc_prev.winloss;
   double prevCommission = (totalPrevWinloss < 0 ? -totalPrevWinloss * 0.05 : 0);
   if(prevCommission > 3388) prevCommission = 3388;
   if(prevCommission > 0 && !isBonusExists(userid, "WRC-" + dw.prev_week_code)){
      obj.put("referral_commission", prevCommission);
      obj.put("referral_commission_available", true);
      
   }else{
      DownlineWinlossCockfight wls_current = new DownlineWinlossCockfight(userid, dw.current_week_from, dw.current_week_to);
      DownlineWinlossCasino wlc_current = new DownlineWinlossCasino(userid, dw.current_week_from, dw.current_week_to);
      double totalCurrentWinloss = wls_current.winloss + wlc_current.winloss;
      double currentCommission = (totalCurrentWinloss < 0 ? -totalCurrentWinloss * 0.05 : 0);

      if(currentCommission > 3388) currentCommission = 3388;
      obj.put("referral_commission", currentCommission);
      obj.put("referral_commission_available", false);
   }
   
   JSONArray objarray =new JSONArray();
   objarray.add(obj);
   mainObj.put("referral", objarray);
   return mainObj;
  }
 %>

 
 <%!public JSONObject api_weekly_rebate_winloss(JSONObject mainObj,  String userid) {
   JSONObject obj = new JSONObject();

   DateWeekly dw = new DateWeekly();

   PlayerTotalDeposit dep_prev = new PlayerTotalDeposit(userid, dw.prev_week_from, dw.prev_week_to);
   PlayerWinlossCockfight wls_prev = new PlayerWinlossCockfight(userid, dw.prev_week_from, dw.prev_week_to);
   PlayerWinlossCasino wlc_prev = new PlayerWinlossCasino(userid, dw.prev_week_from, dw.prev_week_to);
   double totalPrevWinloss = wls_prev.winloss + wlc_prev.winloss;
   double prevRebate = (totalPrevWinloss < 0 ? -totalPrevWinloss * 0.05 : 0);
   if(prevRebate > 1688) prevRebate = 1688;

   if(dep_prev.totaldeposit >= 688 && prevRebate > 0 && !isBonusExists(userid, "WRW-" + dw.prev_week_code)){
      obj.put("cockfight", (wls_prev.winloss < 0 ? -wls_prev.winloss : 0));
      obj.put("casino", (wlc_prev.winloss < 0 ? -wlc_prev.winloss : 0));
      obj.put("total", (totalPrevWinloss < 0 ? -totalPrevWinloss : 0));
      obj.put("rebate", prevRebate);
      obj.put("deposit", dep_prev.totaldeposit);
      obj.put("available", true);
      
   }else{
      PlayerTotalDeposit dep_current = new PlayerTotalDeposit(userid, dw.current_week_from, dw.current_week_to);
      PlayerWinlossCockfight wls_current = new PlayerWinlossCockfight(userid, dw.current_week_from, dw.current_week_to);
      PlayerWinlossCasino wlc_current = new PlayerWinlossCasino(userid, dw.current_week_from, dw.current_week_to);
      double totalCurrentWinloss = wls_current.winloss + wlc_current.winloss;
      double currRebate = (totalCurrentWinloss < 0 ? -totalCurrentWinloss * 0.05 : 0);
      if(currRebate > 1688) currRebate = 1688;

      obj.put("cockfight", (wls_current.winloss < 0 ? -wls_current.winloss : 0));
      obj.put("casino", (wlc_current.winloss < 0 ? -wlc_current.winloss : 0));
      obj.put("total", (totalCurrentWinloss < 0 ? -totalCurrentWinloss : 0));
      obj.put("rebate", currRebate);
      obj.put("deposit", dep_current.totaldeposit);
      obj.put("available", false);
   }
   
   JSONArray objarray = new JSONArray();
   objarray.add(obj);
   mainObj.put("weekly_winloss", objarray);
   return mainObj;
  }
 %>

 <%!public JSONObject api_popup_banner(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "settings", "select popup_enabled, popup_banner from tblgeneralsettings");
    return mainObj;
  }
 %>

 <%!public JSONObject api_game_statistic(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "game_statistic", "select imgurl, gameid, game_type, play_count, if(game_type='cockfight', ifnull((select eventid from tblevent where arenaid=a.gameid and event_active=1),''),'') as eventid from tblgamestatistics as a where accountid='"+userid+"' order by play_count desc limit 5");
    return mainObj;
  }
 %>

 <%!public JSONObject api_account_creditbal(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "creditbal", "select creditbal from tblsubscriber as a where accountid='"+userid+"'");
    return mainObj;
  }
 %>

 <%!public JSONObject api_casino_games(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "game_list", "select a.id, a.gameid, a.gamename, a.provider, b.isnewgame, a.category, IF(IFNULL(a.imgurl2, '') = '',a.imgurl1,a.imgurl2) as imageurl from tblgamelist as a inner join tblgamesource as b on a.gameid=b.gamecode where isenable=1 and category in (select code from tblgamecategory) and a.provider in (select provider from tblgameprovider where active=1) order by rand() ;");            
    return mainObj;
 }
 %>

<%!public JSONObject api_casino_featured(JSONObject mainObj, String masteragentid) {
    mainObj = DBtoJson(mainObj, "game_featured", "select title, imgurl, linkurl from tblgamefeatured where id in (select bannerid from tblbannerfilter where modetype='game_featured' " + (masteragentid.length() > 0 ? "and masteragentid='"+masteragentid+"'" : "") + ") order by priority asc");       
    return mainObj;
 }
 %>

 <%!public JSONObject api_casino_category(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "game_category", "select if(_default,'ALL',code) as code, categoryname, imgurl from tblgamecategory order by priority asc");       
    return mainObj;
 }
 %>

 <%!public JSONObject api_casino_popular(JSONObject mainObj, String mode) {
    mainObj = DBtoJson(mainObj, "game_" + mode, "SELECT a.gameid,a.gamename, isnewgame, a.provider,IF(IFNULL((select imgurl2 from tblgamelist where gameid=a.gameid), '') = '', a.imageurl, (select imgurl2 from tblgamelist where gameid=a.gameid)) as imageurl FROM tblgamepopular as a inner join tblgamesource as b on a.gameid=b.gamecode where `mode`='"+mode+"' and a.provider in (select provider from tblgameprovider where active=1) order by rand() limit 6");       
    return mainObj;
 }
 %>

<%!public JSONObject api_active_arena(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "game_arena", "select *, ifnull((select eventid from tblevent where arenaid=a.arenaid and event_active=1),'') as eventid from tblarena as a where active=1");
    return mainObj;
  }
 %>

<%!public JSONObject api_event_info(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "event", "select eventid, event_standby, fight_result, total_win_meron, total_win_wala, total_draw, total_cancelled, current_status,fightnumber, (select vertical_banner_url from tblarena where arenaid=a.arenaid) as vertical_banner, (select opposite_bet from tblarena where arenaid=a.arenaid) as opposite_bet, (select if(disabled,'false','true') from tblpromotion where promocode='promo_win_strike') as winstrike_enabled from tblevent as a where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

 <%!public JSONObject api_fight_number(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "fightnumber", "select fightnumber from tblevent where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

<%!public JSONObject api_event_notice(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "notice", "select event_title,event_reminders_warning,event_reminders_message from tblevent where eventid='"+eventid+"'");
    return mainObj;
  }
%>

<%!public JSONObject api_event_video(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "video", "SELECT a.event_standby as standby, a.live_mode as mode, b.source_url as stream_url, b.player_type as stream_player, b.web_available, b.web_url, b.web_player FROM tblevent a right join tblvideosource b on a.live_sourceid=b.id where eventid='"+eventid+"'");
    return mainObj;
  }
%>

<%!public JSONObject api_result_info(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "result", "select result as r, if(result='C','X',fightnumber) as rd from tblfightresult where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

<%!public JSONObject api_current_fight_bet(JSONObject mainObj, String accountid, String fightkey) {
    mainObj = DBtoJson(mainObj, "bet", "SELECT eventid,(select arenaname from tblarena where arenaid=a.arenaid) as arena,concat(fightnumber, if(length(ws_selection) > 0,concat(' (',ws_selection,')',''),'')) as fightnumber,transactionno,bet_choice,bet_amount FROM tblfightbets as a where accountid='"+accountid+"' and fightkey='"+fightkey+"';");
    mainObj = DBtoJson(mainObj, "bet_total", "SELECT  bet_choice, sum(bet_amount) as total_bet FROM tblfightbets as a where accountid='"+accountid+"' and fightkey='"+fightkey+"' group by bet_choice;");
    return mainObj;
  }
 %>
 
 <%!public JSONObject api_current_event_bet(JSONObject mainObj, String accountid, String eventid) {
    mainObj = DBtoJson(mainObj, "current_event_bet", "SELECT fightnumber, bet_choice, result,  bet_amount, round(odd,3) as odd, round(if(cancelled,0,if(win,win_amount, if(result='D', 0, -lose_amount) )),2) as win_loss FROM tblfightbets2 as a where accountid='"+accountid+"' and eventid='"+eventid+"' order by id desc limit 5;");
    return mainObj;
  }
 %>

<%!public JSONObject api_credit_load_logs(JSONObject mainObj, String accountid, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "credit_logs", "SELECT  *, date_format(datetrn, '%m/%d/%y') as 'date', result, date_format(datetrn, '%r') as 'time' FROM tblcreditloadlogs as a where accountid='"+accountid+"' and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "';");
    return mainObj;
  }
 %>
 
<%!public JSONObject api_operator_bank(JSONObject mainObj,  String operatorid ) {
    mainObj = DBtoJson(mainObj, "operator_bank", "select *, (select logourl from tblremittance where code=a.remittanceid) as logourl, " 
                        + " (select remittancename from tblremittance where code=a.remittanceid) as bankname, " 
                        + " (select isbank from tblremittance where code=a.remittanceid) as isbank "
                        + " from tblbankaccounts as a where accountid='"+operatorid+"' and isoperator and actived=1 and deleted=0 order by accountid asc");
    return mainObj;
 }
 %>

<%!public JSONObject api_account_list(JSONObject mainObj,String userid, boolean isagent) {
    mainObj = DBtoJson(mainObj, "accounts", "select accountid,fullname,username,mobilenumber,creditbal,commissionrate,iscashaccount,photourl,photoupdated,isagent,agentid,blocked,lastlogindate,current_timestamp from tblsubscriber as a where (agentid='"+userid+"' or agentid in (select accountid from tblsubscriber where agentid='"+userid+"' and iscashaccount=1)) and isagent=" + isagent + " and deleted=0 order by fullname asc");
    return mainObj;
}
%>

<%!public JSONObject api_deposit_list(JSONObject mainObj,String userid) {
    mainObj = DBtoJson(mainObj, "deposit", sqlDepositQuery + " where accountid='" + userid + "' order by id desc");
    return mainObj;
 }
 %>

<%!public JSONObject api_withdrawal_list(JSONObject mainObj,String userid) {
    mainObj = DBtoJson(mainObj, "withdrawal", sqlWithdrawalQuery + " where accountid='" + userid + "' order by id desc");
    return mainObj;
 }
 %>

<%!public JSONObject api_rebate_promo(JSONObject mainObj, String userid) {
    mainObj = DBtoJson(mainObj, "rebate_promo", "select rebate_enabled, if(bonus_date=current_date || bonus_date = (current_date - INTERVAL 1 DAY), totaldeposit, 0) as totaldeposit, if((totaldeposit * 0.08) > 1688, 1688, (totaldeposit * 0.08) ) as bonus,  bonus_date, if(totaldeposit >= 150 and (rebate_enabled=0 or creditbal < 1) and bonus_date = (current_date - INTERVAL 1 DAY), 'true', 'false') as rebate_available from tblsubscriber as a where accountid='"+userid+"'");
    return mainObj;
 }
 %>

<%!public JSONObject api_turnover_promo(JSONObject mainObj, String userid) {
    mainObj = DBtoJson(mainObj, "turnover_promo", sqlDailyTurnoverQuery(userid));
    return mainObj;
 }
 %>

<%!public JSONObject api_custom_promo(JSONObject mainObj, String userid) {
    mainObj = DBtoJson(mainObj, "custom_promo", sqlCustomPromoQuery(userid));
    return mainObj;
 }
 %>

<%!public JSONObject api_winstrike_promo(JSONObject mainObj, String userid, String eventid, String category) {
    mainObj = DBtoJson(mainObj, "winstrike_promo", sqlWinstrikeQuery(userid, eventid, category));
    return mainObj;
 }
 %>
 
<%!public JSONObject api_promotion_list(JSONObject mainObj, String operatorid) {
    mainObj = DBtoJson(mainObj, "promotion", "select * from (select title, promocode, description, banner_url, if(build_in, 'true', 'false') as build_in from tblpromotion where disabled=0 and build_in=0 " +(operatorid.length() > 0 ? " and operatorid='"+operatorid+"' " : "")+ " order by sortorder asc) as a UNION ALL "
                                           + "select * from (select title, promocode, description, banner_url, if(build_in, 'true', 'false') as build_in from tblpromotion where disabled=0 and build_in=1 " +(operatorid.length() > 0 ? " and operatorid='"+operatorid+"' " : "")+ " order by sortorder asc) as b");
    return mainObj;
 }
 %>

<%!public JSONObject api_promotion_status(JSONObject mainObj, String operatorid) {
    mainObj = DBtoJson(mainObj, "promotion", "select promocode, disabled from tblpromotion " +(operatorid.length() > 0 ? " where operatorid='"+operatorid+"'" : "")+ " order by sortorder asc");
    return mainObj;
 }
 %>

 <%!public JSONObject api_score_request(JSONObject mainObj, String accountid) {
    mainObj = DBtoJson(mainObj, "score_request", sqlScoreRequestQuery + " where userid='"+accountid+"' order by id desc");
    return mainObj;
 }
 %>
 
<%!public JSONObject api_current_fight_summary(JSONObject mainObj, String fightkey, String operatorid) {
    mainObj = DBtoJson(mainObj, "summary", "SELECT  "
                            + " count(if(bet_choice='M',1,null)) as countMeron, "
                            + " count(if(bet_choice='D',1,null)) as countDraw, "
                            + " count(if(bet_choice='W',1,null)) as countWala, "
                            + " sum(if(bet_choice='M',bet_amount,0)) as totalMeron, "
                            + " sum(if(bet_choice='D',bet_amount,0)) as totalDraw, "
                            + " sum(if(bet_choice='W',bet_amount,0)) as totalWala "
                            + " FROM tblfightbets where fightkey='"+fightkey+"' and operatorid='"+operatorid+"'");
    return mainObj;
 }
 %>