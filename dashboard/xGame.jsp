<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>


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
    
    if(x.equals("load_game_list")){
        String provider = request.getParameter("provider");

        mainObj.put("status", "OK");
        mainObj = GameEnableList(mainObj, provider);
        mainObj = LoadGameCategory(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("game_category")){
        mainObj.put("status", "OK");
        mainObj = LoadGameCategory(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("set_game_category")){
        String mode = request.getParameter("mode");
        String code = request.getParameter("code");
        String categoryname = request.getParameter("category");
        String imgname = request.getParameter("imgname");
        String imgurl = request.getParameter("imgurl");
        String priority = request.getParameter("priority");

        String imgname_url = "";

        if(imgurl.length() > 10){
            imgname = (imgname.length() > 0 ? imgname : UUID.randomUUID().toString());
            ServletContext serveapp = request.getSession().getServletContext();
            imgname_url = AttachedPhoto(serveapp, "category", imgurl, imgname);
        }else{
            imgname_url = "";
        }

        if (mode.equals("add")){
            ExecuteQuery("insert into tblgamecategory set categoryname='" +rchar(categoryname)+ "', imgname='"+imgname+"', imgurl='"+imgname_url+"', priority=" + priority + "");
            mainObj.put("message", "Category successfully added!");
        }else{
            ExecuteQuery("update tblgamecategory set categoryname='" +rchar(categoryname)+ "', imgname='"+imgname+"', imgurl='"+imgname_url+"', priority=" + priority + " where code='"+code+"'");
            mainObj.put("message", "Category successfully updated!");
        }

        mainObj.put("status", "OK");
        mainObj = LoadGameCategory(mainObj);
        out.print(mainObj);

    }else if(x.equals("delete_game_category")){
        String code = request.getParameter("code");

        ExecuteQuery("DELETE from tblgamecategory where code='"+code+"'");

        mainObj.put("status", "OK");
        mainObj = LoadGameCategory(mainObj);
        mainObj.put("message", "Category successfully deleted");
        out.print(mainObj);

    }else if(x.equals("game_featured")){
        mainObj.put("status", "OK");
        mainObj = LoadGameFeatured(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);
    
    }else if(x.equals("set_game_featured")){
        String id = request.getParameter("id");
        String mode = request.getParameter("mode");
        String title = request.getParameter("title");
        String imgname = request.getParameter("imgname");
        String imgurl = request.getParameter("imgurl");
        String linkurl = request.getParameter("linkurl");
        String priority = request.getParameter("priority");
        String imgname_url = "";

        if(imgurl.length() > 10){
            imgname = (imgname.length() > 0 ? imgname : UUID.randomUUID().toString());
            ServletContext serveapp = request.getSession().getServletContext();
            imgname_url = AttachedPhoto(serveapp, "featured", imgurl, imgname);
        }else{
            imgname_url = "";
        }

        if (mode.equals("add")){
            ExecuteQuery("insert into tblgamefeatured set title='" +rchar(title)+ "', imgname='"+imgname+"', imgurl='"+imgname_url+"', linkurl='"+linkurl+"', priority=" + priority + "");
            mainObj.put("message", "Featured banner successfully added!");
        }else{
            ExecuteQuery("update tblgamefeatured set title='" +rchar(title)+ "', imgname='"+imgname+"', imgurl='"+imgname_url+"', linkurl='"+linkurl+"', priority=" + priority + " where id='"+id+"'");
            mainObj.put("message", "Featured banner successfully added!");
        }

        mainObj.put("status", "OK");
        mainObj = LoadGameFeatured(mainObj);
        out.print(mainObj);

    }else if(x.equals("delete_game_featured")){
        String id = request.getParameter("id");

        ExecuteQuery("DELETE from tblgamefeatured where id='"+id+"'");

        mainObj.put("status", "OK");
        mainObj = LoadGameFeatured(mainObj);
        mainObj.put("message", "Featured banner successfully deleted");
        out.print(mainObj);
    
    }else if(x.equals("load_provider")){
        mainObj.put("status", "OK");
        mainObj = LoadGameProvider(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);
 
    }else if(x.equals("set_game_provider")){
        String mode = request.getParameter("mode");
        String id = request.getParameter("id");
        String provider = request.getParameter("provider");
        String api_id = request.getParameter("api_id");
        String api_key = request.getParameter("api_key");
        String game_list = request.getParameter("game_list");
        String open_game = request.getParameter("open_game");
        String domain = request.getParameter("domain");
        String exiturl = request.getParameter("exiturl");
        String testerid = request.getParameter("testerid");
        boolean isdisable = Boolean.parseBoolean(request.getParameter("isdisable"));
        boolean active = Boolean.parseBoolean(request.getParameter("active"));


        if (mode.equals("add")){
            ExecuteQuery("insert into tblgameprovider set provider='" +rchar(provider)+ "', api_id='" + api_id + "', api_key='" + api_key + "', game_list='" + game_list + "', open_game='" + open_game + "', domain='"+ domain +"', exiturl='" + exiturl + "',isdisable="+isdisable+",testerid='"+testerid+"', active="+active+"");
            mainObj.put("message", "Provider successfully added!");
        }else{
            ExecuteQuery("update tblgameprovider set provider='" +rchar(provider)+ "', api_id='" + api_id + "', api_key='" + api_key + "', game_list='" + game_list + "', open_game='" + open_game + "', domain='"+ domain +"', exiturl='" + exiturl + "', isdisable="+isdisable+",testerid='"+testerid+"', active="+active+" where id='"+id+"'");
            mainObj.put("message", "Provider successfully updated!");
        }

        mainObj.put("status", "OK");
        mainObj = LoadGameProvider(mainObj);
        out.print(mainObj);

    }else if(x.equals("delete_game_provider")){
        String id = request.getParameter("id");

        ExecuteQuery("DELETE from tblgameprovider where id='"+id+"'");

        mainObj.put("status", "OK");
        mainObj = LoadGameProvider(mainObj);
        mainObj.put("message", "Provider successfully deleted");
        out.print(mainObj);
    
    }else if(x.equals("set_game_image")){
        String id = request.getParameter("id");
        String provider = request.getParameter("provider");
        String imgname = request.getParameter("imgname");
        String imgurl2 = request.getParameter("imgurl2");
        String imgname_url = ""; 

        if(imgurl2.length() > 10){
            imgname = (imgname.length() > 0 ? imgname : UUID.randomUUID().toString());
            ServletContext serveapp = request.getSession().getServletContext();
            imgname_url = AttachedPhoto(serveapp, "game", imgurl2, imgname);
        }else{
            imgname_url = "";
        }
    
        ExecuteQuery("UPDATE tblgamelist set imgname='"+imgname+"', imgurl2='"+imgname_url+"' where id='"+id+"'");
        mainObj.put("message", "Game image successfully updated!");

        mainObj.put("status", "OK");
        mainObj = GameEnableList(mainObj, provider);
        out.print(mainObj);

    }else if(x.equals("update_game_category")){
        String ids = request.getParameter("id");
        String code = request.getParameter("code");
        String provider = request.getParameter("provider");
 
        String[] arr = ids.split(",");
        if(arr.length > 1){
            for (String id : arr) {
                ExecuteQuery("UPDATE tblgamelist set category='"+code+"' where id='"+id+"'");
            }
        }else{
            ExecuteQuery("UPDATE tblgamelist set category='"+code+"' where id='"+ids+"'");
        }

        mainObj.put("status", "OK");
        mainObj = GameEnableList(mainObj, provider);
        mainObj.put("message", "Category for selected game successfully updated!");
        out.print(mainObj);
    
    }else if(x.equals("load_game_filter")){
        String provider = request.getParameter("provider");
        
        mainObj.put("status", "OK");
        mainObj = GameMasterList(mainObj, provider);
        mainObj = GameEnableList(mainObj, provider);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("enable_game")){
        String games = request.getParameter("gameid");
        String provider = request.getParameter("provider");
        
        String[] arr = games.split(",");
        if(arr.length > 1){
            for (String gameid : arr) {
                EnableGameFilter(gameid, provider);
            }
        }else{
            EnableGameFilter(games, provider);
        }

        mainObj.put("status", "OK");
        mainObj = GameMasterList(mainObj, provider);
        mainObj = GameEnableList(mainObj, provider);
        mainObj.put("message", "command accepted");
        out.print(mainObj);

    }else if(x.equals("disable_game")){
        String ids = request.getParameter("id");
        String provider = request.getParameter("provider");

        String[] arr = ids.split(",");
        if(arr.length > 1){
            for (String id : arr) {
                DisableGameFilter(id);
            }
        }else{
            DisableGameFilter(ids);
        }

        mainObj.put("status", "OK");
        mainObj = GameMasterList(mainObj, provider);
        mainObj = GameEnableList(mainObj, provider);
        mainObj.put("message", "Selected game successfully disable!");
        out.print(mainObj);

    }else if(x.equals("load_popular_game")){
        String mode = request.getParameter("mode");
        String provider = request.getParameter("provider");
        
        mainObj.put("status", "OK");
        mainObj = GamePopularUnfilter(mainObj, provider);
        mainObj = GamePopularfiltered(mainObj, mode, provider);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("enable_popular_game")){
        String mode = request.getParameter("mode");
        String games = request.getParameter("gameid");
        String provider = request.getParameter("provider");
        
        String[] arr = games.split(",");
        if(arr.length > 1){
            for (String gameid : arr) {
                EnableGamePopularity(mode, gameid, provider);
            }
        }else{
            EnableGamePopularity(mode, games, provider);
        }

        mainObj.put("status", "OK");
        mainObj = GamePopularUnfilter(mainObj, provider);
        mainObj = GamePopularfiltered(mainObj, mode, provider);
        mainObj.put("message", "command accepted");
        out.print(mainObj);
    
    }else if(x.equals("remove_popular_game")){
        String mode = request.getParameter("mode");
        String ids = request.getParameter("id");
        String provider = request.getParameter("provider");

        String[] arr = ids.split(",");
        if(arr.length > 1){
            for (String id : arr) {
                RemoveGamePopularity(id);
            }
        }else{
            RemoveGamePopularity(ids);
        }

        mainObj.put("status", "OK");
        mainObj = GamePopularUnfilter(mainObj, provider);
        mainObj = GamePopularfiltered(mainObj, mode, provider);
        mainObj.put("message", "command accepted");
        out.print(mainObj);

    
    }else if(x.equals("load_featured_filter")){
        String operatorid = request.getParameter("operatorid");
        String masteragentid = request.getParameter("masteragentid");

        mainObj.put("status", "OK");
        mainObj = DisableList(mainObj, "game_featured", operatorid, masteragentid);
        mainObj = EnableList(mainObj, "game_featured", operatorid, masteragentid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("enable_banner")){
        String operatorid = request.getParameter("operatorid");
        String masteragentid = request.getParameter("masteragentid");
        String bannerid = request.getParameter("bannerid");
         
        String[] arr = bannerid.split(",");
        if(arr.length > 1){
            for (String id : arr) {
                EnableBanner("game_featured", operatorid, id, masteragentid);
            }
        }else{
            EnableBanner("game_featured", operatorid, bannerid, masteragentid);
        }

        mainObj.put("status", "OK");
        mainObj.put("message", "command accepted");
        out.print(mainObj);

    }else if(x.equals("disable_banner")){
        String bannerid = request.getParameter("bannerid");
        
        String[] arr = bannerid.split(",");
        if(arr.length > 1){
            for (String id : arr) {
                DisableBanner(id);
            }
        }else{
            DisableBanner(bannerid);
        }
        mainObj.put("status", "OK");
        mainObj.put("message", "command accepted");
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
      logError("dashboard-x-games",e.toString());
}
%>

<%!public JSONObject DisableList(JSONObject mainObj, String modetype, String operatorid, String masteragentid) {
      mainObj = DBtoJson(mainObj, "disable_list", "select id, title from tblgamefeatured where id not in (select bannerid from tblbannerfilter where modetype='"+modetype+"' and operatorid='"+operatorid+"' and masteragentid='"+masteragentid+"')");
      return mainObj;
}
%>

<%!public JSONObject EnableList(JSONObject mainObj, String modetype, String operatorid, String masteragentid) {
      mainObj = DBtoJson(mainObj, "enabled_list", "select id, bannername from tblbannerfilter where modetype='"+modetype+"' and operatorid='"+operatorid+"' and masteragentid='"+masteragentid+"'");
      return mainObj;
}
%>

 <%!public void EnableBanner(String modetype, String operatorid, String bannerid, String masteragentid) {
    if(CountQry("tblbannerfilter", "modetype='"+modetype+"' and operatorid='"+operatorid+"' and bannerid='"+bannerid+"' and masteragentid='"+masteragentid+"'") == 0){
        String bannername = QueryDirectData("title", "tblgamefeatured where id='"+bannerid+"'");
        ExecuteQuery("insert into tblbannerfilter set modetype='"+modetype+"', operatorid='"+operatorid+"', bannerid='" + bannerid + "', bannername='" + rchar(bannername) + "', masteragentid='" + masteragentid + "' ");
    }
}
%>

<%!public void DisableBanner(String id) {
    ExecuteQuery("DELETE from tblbannerfilter where id='"+id+"'");
}
%>


