<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
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
      
    if(x.equals("load_arena")){
        mainObj.put("status", "OK");
        mainObj = LoadArena(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("set_arena_info")){
        String mode = request.getParameter("mode");
        String arenaid = request.getParameter("arenaid");
        String arenaname = request.getParameter("arenaname");
        String main_banner_url = request.getParameter("main_banner_url");
        String vertical_banner = request.getParameter("vertical_banner");
        String vertical_banner_name = request.getParameter("vertical_banner_name");
        boolean active = Boolean.parseBoolean(request.getParameter("active"));
        boolean opposite_bet = Boolean.parseBoolean(request.getParameter("opposite_bet"));
        String vertical_banner_url = "";

    
        if(vertical_banner.length() > 10){
            vertical_banner_name = (vertical_banner_name.length() > 0 ? vertical_banner_name : UUID.randomUUID().toString());
            ServletContext serveapp = request.getSession().getServletContext();
            vertical_banner_url = AttachedPhoto(serveapp, "arena", vertical_banner, vertical_banner_name);
        }
    
        if (mode.equals("add")){
            ExecuteQuery("insert into tblarena set arenaname='" +rchar(arenaname)+ "', active=" + active + ", opposite_bet=" + opposite_bet + ", main_banner_url='"+main_banner_url+"' " + (vertical_banner.length() > 0 ? ", vertical_banner_name='"+vertical_banner_name+"', vertical_banner_url='"+vertical_banner_url+"' " : ""));
            mainObj.put("message", " Arena successfully added!");
        }else{
            ExecuteQuery("UPDATE tblarena set arenaname='" +rchar(arenaname)+ "', active=" + active + ", opposite_bet=" + opposite_bet + ", main_banner_url='"+main_banner_url+"' " + (vertical_banner.length() > 0 ? ", vertical_banner_name='"+vertical_banner_name+"', vertical_banner_url='"+vertical_banner_url+"' " : "") + " where arenaid='"+arenaid+"'");
            mainObj.put("message", "Arena successfully updated!");
        }

        mainObj.put("status", "OK");
        mainObj = LoadArena(mainObj);
        out.print(mainObj);

    }else if(x.equals("delete_arena")){
        String arenaid = request.getParameter("arenaid");
        
        ExecuteQuery("DELETE FROM tblarena where arenaid = '"+arenaid+"';");

        mainObj.put("status", "OK");
        mainObj.put("message","Arena successfully deleted!");
        mainObj = LoadArena(mainObj);
        out.print(mainObj);

    }else if(x.equals("load_event")){
        String arenaid = request.getParameter("arenaid");
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj.put("status", "OK");
        mainObj = LoadEvents(mainObj, arenaid, datefrom, dateto);
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
      logError("dashboard-x-events",e.toString());
}
%>

<%!public JSONObject LoadEvents(JSONObject mainObj, String arenaid, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "event", sqlEventQuery + " where arenaid='"+arenaid+"' and event_date between '"+datefrom+"' and '"+dateto+"' order by event_date asc");
    return mainObj;
} %>