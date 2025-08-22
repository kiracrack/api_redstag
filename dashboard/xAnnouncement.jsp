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

    if(x.equals("load_announcement")){
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = LoadAnnouncement(mainObj, operatorid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("set_announcement_info")){
        String mode = request.getParameter("mode");
        String id = request.getParameter("id");
        String operatorid = request.getParameter("operatorid");
        String sortorder = request.getParameter("sortorder");
        String title = request.getParameter("title");
        String push_message = request.getParameter("push_message");
        String img_filename = request.getParameter("img_filename");
        String img_banner = request.getParameter("img_banner");
        boolean visible = Boolean.parseBoolean(request.getParameter("visible"));
        boolean push = Boolean.parseBoolean(request.getParameter("push"));
        String banner_url = "";

        if(img_banner.length() > 0){
            img_filename = (img_filename.length() > 0 ? img_filename : UUID.randomUUID().toString());
            ServletContext serveapp = request.getSession().getServletContext();
            banner_url = AttachedPhoto(serveapp, "announcement", img_banner, img_filename);
        }
        
        String query = "operatorid='"+operatorid+"', "
                    + " sortorder='" + sortorder + "', " 
                    + " title='" + rchar(title) + "', " 
                    + " push_message='" + rchar(push_message) + "', " 
                    + " visible="+visible+" ";

        if (mode.equals("add")){
            ExecuteQuery("insert into tblannouncement set " + query + (img_banner.length() > 0 ? ", filename='"+img_filename+"', banner_url='"+banner_url+"' " : "") + ", addedby='"+userid+"' , datetrn=current_timestamp");
            mainObj.put("message", "Announcement successfully added!");
        }else{
            ExecuteQuery("UPDATE tblannouncement set " + query + (img_banner.length() > 0 ? ", filename='"+img_filename+"', banner_url='"+banner_url+"' " : "") +  " where id='"+id+"'");
            mainObj.put("message",  "Announcement successfully updated!");
        }
        
        if(push){
            SendBroadcastNotification(title, push_message, banner_url);
        }

        mainObj.put("status", "OK");
        mainObj = LoadAnnouncement(mainObj, operatorid);
        out.print(mainObj);
     
    }else if(x.equals("delete_announcement")){
        String operatorid = request.getParameter("operatorid");
        String id = request.getParameter("id");
        
        ExecuteQuery("DELETE FROM tblannouncement where id = '"+id+"';");

        mainObj.put("status", "OK");
        mainObj.put("message","Announcement successfully deleted!");
        mainObj = LoadAnnouncement(mainObj, operatorid);
        out.print(mainObj);

    }else if(x.equals("push_notification")){
        String id = request.getParameter("id");
        AnnouncementInfo promo = new AnnouncementInfo(id);

        SendBroadcastNotification(promo.title, promo.push_message, promo.banner_url);

        mainObj.put("status", "OK");
        mainObj.put("message", "Announcement successfully notified all devices!");
        out.print(mainObj);


    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid ");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
    }
}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("dashboard-x-announcement",e.toString());
}
%>
 