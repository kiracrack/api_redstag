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
    JSONObject apiObj = new JSONObject();
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

    PushFirebaseUsers(GlobalDefaultOperator, false);

    if(x.equals("event_info")){ 
        String eventid = request.getParameter("eventid");

        mainObj.put("status", "OK");
        mainObj = getEventInfo(mainObj, eventid);
        mainObj = CurrentEventSummary(mainObj, eventid);
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 
    
    }else if(x.equals("arena")){ 
        mainObj.put("status", "OK");
        mainObj = getActiveArena(mainObj);
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 

    }else if(x.equals("video_source")){ 
        mainObj.put("status", "OK");
        mainObj = LoadVideoSource(mainObj);
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 

    }else if(x.equals("message_template")){ 
        mainObj.put("status", "OK");
        mainObj = LoadMessageTemplate(mainObj);
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 

    }else if(x.equals("announcement")){ 
        mainObj.put("status", "OK");
        mainObj = LoadAnnouncementController(mainObj);
        mainObj.put("message", "data synchronized");
        out.print(mainObj); 
    
    }else if(x.equals("timer_settings")){ 
        String arenaid = request.getParameter("arenaid");
        String lastcall = request.getParameter("lastcall");
        String closed = request.getParameter("closed");
        boolean auto_lastcall = Boolean.parseBoolean(request.getParameter("auto_lastcall"));
        boolean auto_closed = Boolean.parseBoolean(request.getParameter("auto_closed"));
        
        ExecuteQuery("update tblarena set auto_lastcall="+auto_lastcall+", timer_lastcall='"+lastcall+"', auto_closed="+auto_closed+", timer_closed='"+closed+"' where arenaid='"+arenaid+"'");
        mainObj.put("status", "OK");
        mainObj = getActiveArena(mainObj);
        mainObj.put("message", "Settings successfully saved!");
        out.print(mainObj);

    }else if(x.equals("push_notification")){ 
        String aid = request.getParameter("aid");
        AnnouncementInfo promo = new AnnouncementInfo(aid);

        SendBroadcastNotification(promo.title, promo.push_message, promo.banner_url);

        mainObj.put("status", "OK");
        mainObj.put("message", "Announcement successfully notified all devices!");
        out.print(mainObj);


    }else if(x.equals("activate_video")){ 
        String eventid = request.getParameter("eventid");
        String mode = request.getParameter("mode");
        String sourceid = request.getParameter("sourceid");
        String sourcename = request.getParameter("sourcename");
        String val = request.getParameter("val");
        String query = "";

        VideoInfo video = new VideoInfo(sourceid);

        if(mode.equals("YOUTUBE")){
            query = " live_youtube_id='"+  val +"'";
        }else{
            query = " live_stream_title='"+video.source_name+"', live_stream_url='"+  video.source_url +"' ";
        }

        ExecuteQuery("update tblevent set live_sourceid='"+sourceid+"', live_mode='"+mode+"', "+query+" where eventid='"+eventid+"'");
       
        mainObj.put("status", "OK");
        mainObj.put("live_title", sourcename);
        mainObj.put("live_val", val);
        mainObj.put("live_mode", mode);
        mainObj.put("message", (mode.equals("YOUTUBE") ? "Youtube" : "Live stream") + " successfully activated!");
        out.print(mainObj);

        apiObj = api_event_video(apiObj, eventid);
        PusherPost(eventid, apiObj);

    }else if(x.equals("update_video_title")){ 
        String eventid = request.getParameter("eventid");
        String title = request.getParameter("title");

        ExecuteQuery("update tblevent set event_title='"+rchar(title)+"' where eventid='"+eventid+"'");
       
        mainObj.put("status", "OK");
        mainObj.put("video_title", title);
        mainObj.put("message", "Video title successfully changed!");
        out.print(mainObj);

        apiObj = api_event_notice(apiObj, eventid);
        PusherPost(eventid, apiObj);
    
    }else if(x.equals("update_reminders")){ 
        String eventid = request.getParameter("eventid");
        String warning_reminder = request.getParameter("warning_reminder");
        String message_reminder = request.getParameter("message_reminder");

        ExecuteQuery("update tblevent set event_reminders_message='"+rchar(message_reminder)+"', event_reminders_warning='"+rchar(warning_reminder)+"' where eventid='"+eventid+"'");
       
        mainObj.put("status", "OK");
        mainObj.put("warning_reminder", warning_reminder);
        mainObj.put("message_reminder", message_reminder);
        mainObj.put("message", "Reminder successfully changed!");
        out.print(mainObj);

        apiObj = api_event_notice(apiObj, eventid);
        PusherPost(eventid, apiObj);
    
    }else if(x.equals("change_fight")){ 
        String eventid = request.getParameter("eventid");
        String FightNumber = request.getParameter("current_fight");

        EventInfo event = new EventInfo(eventid, false);

        if(event.status.equals("standby")){
            String newFightkey = eventid+"-"+FightNumber+"-"+UUID.randomUUID().toString();
            ExecuteQuery("update tblevent set fightkey='"+newFightkey+"',fightnumber='"+FightNumber+"' where eventid='"+eventid+"'");
            mainObj.put("fightkey", newFightkey);
        }else{
            ExecuteQuery("update tblevent set fightnumber='"+FightNumber+"' where eventid='"+eventid+"'");
            ExecuteQuery("UPDATE tblfightbets set fightnumber='"+FightNumber+"' where fightkey='"+event.fightkey+"'"); 
            mainObj.put("fightkey", event.fightkey);
        }

        mainObj.put("status", "OK");
        mainObj.put("fightnumber", FightNumber);
        mainObj.put("message", "Fight number successfully changed!");
        out.print(mainObj);

        apiObj = api_fight_number(apiObj, eventid);
        PusherPost(eventid, apiObj);

    }else if(x.equals("pause_video")){ 
        String eventid = request.getParameter("eventid");
        String message = request.getParameter("message");

        ExecuteQuery("update tblevent set event_standby=1,event_standby_message='"+rchar(message)+"' where eventid='"+eventid+"'");
       
        mainObj.put("status", "OK");
        mainObj.put("video_state", String.valueOf(true));
        mainObj.put("message", "Video successfully standby!");
        out.print(mainObj);

        apiObj = api_event_video(apiObj, eventid);
        PusherPost(eventid, apiObj);

     }else if(x.equals("resume_video")){ 
        String eventid = request.getParameter("eventid");

        ExecuteQuery("update tblevent set event_standby=0 where eventid='"+eventid+"'");
       
        mainObj.put("status", "OK");
        mainObj.put("video_state", String.valueOf(false));
        mainObj.put("message", "Video successfully resume!");
        out.print(mainObj);

        apiObj = api_event_video(apiObj, eventid);
        PusherPost(eventid, apiObj);

    }else if(x.equals("change_event_state")){ 
        String eventid = request.getParameter("eventid");
        boolean event_state = Boolean.parseBoolean(request.getParameter("event_state"));

        ExecuteQuery("update tblevent set event_closed="+event_state+ (event_state ? ", event_date_closed=current_timestamp " : "") + " where eventid='"+eventid+"'");

        if(!event_state) SendBroadcastOpenEvent();
       
        mainObj.put("status", "OK");
        mainObj.put("event_state", String.valueOf(event_state));
        mainObj.put("message", "Event successfully "+(event_state? "closed" : "open")+"!");
        out.print(mainObj);

        apiObj = api_event_info(apiObj, eventid);
        PusherPost(eventid, apiObj);

    }else if(x.equals("new_event")){ 
        String arenaid = request.getParameter("arenaid");
        String eventid = request.getParameter("eventid");
        String current_fight = request.getParameter("current_fight");

        String new_eventid = getSystemSeriesID("series_event");
        String newEventkey = UUID.randomUUID().toString();
        String newFightkey = UUID.randomUUID().toString();

        String event_title =""; 
        String live_mode = "";
        String live_stream_title = "";
        String live_stream_url = "";
        String live_youtube_id = "";
        String live_sourceid = "";
        String event_standby_message = "";
        String event_reminders_warning = "";

        if(!eventid.isEmpty()){
            EventInfo event = new EventInfo(eventid, false);
            event_title = event.event_title;
            live_mode = event.live_mode;
            live_stream_title = event.live_stream_title;
            live_stream_url = event.live_stream_url;
            live_youtube_id = event.live_youtube_id;
            live_sourceid = event.live_sourceid;
            event_standby_message = event.event_standby_message;
            event_reminders_warning = event.event_reminders_warning;
        }
    
        ExecuteQuery("UPDATE tblevent set event_active=0,event_closed=1,event_date_closed=current_timestamp where arenaid='"+arenaid+"' and event_active=1");
        ExecuteQuery("insert into tblevent set arenaid='"+arenaid+"', "
                        + " eventid='"+new_eventid+"', "
                        + " event_key='"+newEventkey+"', "
                        + " event_title='"+rchar(event_title)+"', "
                        + " fightnumber='"+current_fight+"', "
                        + " fightkey='"+new_eventid+"-"+current_fight+"-"+newFightkey+"', "
                        + " event_date=current_date, " 
                        + " live_mode='"+rchar(live_mode)+"', "
                        + " live_stream_title='"+rchar(live_stream_title)+"', "
                        + " live_stream_url='"+rchar(live_stream_url)+"', "
                        + " live_youtube_id='"+rchar(live_youtube_id)+"', "
                        + " live_sourceid='"+rchar(live_sourceid)+"', "
                        + " event_standby_message='"+rchar(event_standby_message)+"', "
                        + " event_reminders_warning='"+rchar(event_reminders_warning)+"', "
                        + " event_active=1 ");
        
        ExecuteQuery("INSERT into tblfightlogs2 (accountid,sessionid,arenaid,eventid,fightkey,description,amount) select accountid,sessionid,arenaid,eventid,fightkey,description,amount from tblfightlogs where arenaid='"+arenaid+"';");
        ExecuteQuery("DELETE from tblfightlogs where arenaid='"+arenaid+"'");

        SendBroadcastNewEvent();

        mainObj.put("status", "OK");
        mainObj = getEventInfo(mainObj, new_eventid);
        mainObj = getActiveArena(mainObj);
        mainObj = getGeneralSettings(mainObj);
        mainObj = getDummyAccount(mainObj);
        mainObj.put("message", "Event successfully created!");
        out.print(mainObj);

        apiObj = api_event_info(apiObj, new_eventid);
        PusherPost(new_eventid, apiObj);

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
      logError("controller-x-event",e.toString());
}
%>

<%!public JSONObject LoadVideoSource(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "video",  "select * from tblvideosource where source_working=1 and deleted=0");
      return mainObj;
 }
 %>

<%!public JSONObject LoadMessageTemplate(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "template",  "select * from tbltemplate");
      return mainObj;
 }
 %>

 
<%!public JSONObject LoadAnnouncementController(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "announcement", "select *,  "
                            + " date_format(datetrn,'%Y-%m-%d') as 'date', " 
                            + " date_format(datetrn,'%r') as 'time' from tblannouncement where visible=1 order by sortorder asc");
      return mainObj;
 }
 %>