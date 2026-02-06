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
    
    if(x.equals("update_game_list")){
        String provider = request.getParameter("provider");

        if(provider.equals("funky")) mainObj = UpdateGameFunky(mainObj, provider);
        if(provider.equals("infinity")) mainObj = UpdateGameInfinity(mainObj, provider);
        if(provider.equals("kissH5")) mainObj = UpdateGame918KissH5(mainObj, provider);

        out.print(mainObj);

    }else if(x.equals("load_game_list")){
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
 

        if (mode.equals("add")){
            ExecuteQuery("insert into tblgamecategory set categoryname='" +rchar(categoryname)+ "', imgurl='"+imgurl+"', priority=" + priority + "");
            mainObj.put("message", "Category successfully added!");
        }else{
            ExecuteQuery("update tblgamecategory set categoryname='" +rchar(categoryname)+ "', imgurl='"+imgurl+"', priority=" + priority + " where code='"+code+"'");
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
        String companyname = request.getParameter("companyname");
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
            ExecuteQuery("insert into tblgameprovider set provider='" +provider+ "', companyname='" +rchar(companyname)+ "', api_id='" + api_id + "', api_key='" + api_key + "', game_list='" + game_list + "', open_game='" + open_game + "', domain='"+ domain +"', exiturl='" + exiturl + "',isdisable="+isdisable+",testerid='"+testerid+"', active="+active+"");
            mainObj.put("message", "Provider successfully added!");
        }else{
            ExecuteQuery("update tblgameprovider set provider='" + provider+ "', companyname='" +rchar(companyname)+ "', api_id='" + api_id + "', api_key='" + api_key + "', game_list='" + game_list + "', open_game='" + open_game + "', domain='"+ domain +"', exiturl='" + exiturl + "', isdisable="+isdisable+",testerid='"+testerid+"', active="+active+" where id='"+id+"'");
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

    }else if(x.equals("set_game_info")){
        String id = request.getParameter("id");
        String gameid = request.getParameter("gameid");
        String provider = request.getParameter("provider");
        String gamename = request.getParameter("gamename");
        boolean isnewgame = Boolean.parseBoolean(request.getParameter("isnewgame"));
        boolean isenable = Boolean.parseBoolean(request.getParameter("isenable"));
    
        ExecuteQuery("UPDATE tblgamelist set gamename='"+rchar(gamename)+"', isnewgame="+isnewgame+", isenable="+isenable+" where id='"+id+"'");
        ExecuteQuery("UPDATE tblgamesource set isnewgame="+isnewgame+" where provider=lcase('"+provider+"') and gamecode='"+gameid+"'");
        mainObj.put("message", "Game info successfully updated!");

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

<%!public JSONObject UpdateGameFunky(JSONObject mainObj, String provider) {
    try{
        GameSettings funky = new GameSettings(provider);
        JSONObject obj = new JSONObject();
        obj.put("gameType",  "0");
        obj.put("language", "EN");
        
        String requestid = UUID.randomUUID().toString();

        URL url = new URL(funky.game_list);
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.addRequestProperty("Content-Type", "Content-Type: application/x-www-form-urlencoded");
        conn.setRequestProperty("User-Agent", funky.api_id);
        conn.setRequestProperty("Authentication", funky.api_key);
        conn.setRequestProperty("X-Request-ID", requestid);

        conn.setDoOutput(true);
        conn.setDoInput(true);

        byte[] outputBytes = obj.toString().getBytes("UTF-8");
        OutputStream os = conn.getOutputStream();
        os.write(outputBytes);

        BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));

        JSONParser parser = new JSONParser();
        JSONObject json = (JSONObject) parser.parse(br.readLine());

        JSONArray objGameList = (JSONArray) json.get("gameList");
        ExecuteQuery("DELETE from tblgamesource where provider='" + provider + "'");
        for (int i = 0; i < objGameList.size(); i++) {
            JSONObject objContentChild = (JSONObject) objGameList.get(i);


                ExecuteQuery("insert into tblgamesource set " 
                            + " provider='" + provider + "', " 
                            + " gamecode='" + objContentChild.get("gameCode") + "', " 
                            + " gamename='" + rchar(objContentChild.get("gameName").toString()) + "', " 
                            + " gametype='" + objContentChild.get("gameType") + "', " 
                            + " aliasname='" + rchar(objContentChild.get("gameName").toString()) + "', " 
                            + " developer='" + objContentChild.get("gameProvider") + "', " 
                            + " popularity='', " 
                            + " isnewgame=" + Boolean.parseBoolean(objContentChild.get("isNewGame").toString()) + ", " 
                            + " desktop=" + objContentChild.get("supportedOrientation").toString().contains("Landscape") + ", " 
                            + " mobile=" + objContentChild.get("supportedOrientation").toString().contains("Portrait")  + ", " 
                            + " priority='0', " 
                            + " defaultwidth='" + objContentChild.get("suggestedViewWidth") + "', " 
                            + " defaultheight='" + objContentChild.get("suggestedViewHeight") + "', " 
                            + " imageurl='https://funkyofficial-cdn.funkytest.com/game/en/" + objContentChild.get("gameCode") + ".png'," 
                            + " demourl='" + objContentChild.get("demoGameUrl") + "'" 
                            + " ");
        }
        
        mainObj.put("status", "OK");
        mainObj.put("message", "Game list successfull updated");
        return mainObj;
    }catch (Exception e){
        mainObj.put("status", "ERROR");
        mainObj.put("message", e.toString());
        mainObj.put("errorcode", "200");
        return mainObj;
    }
 }%>

<%!public JSONObject UpdateGameInfinity(JSONObject mainObj, String provider) {
    try{
        GameSettings infi = new GameSettings(provider);
        JSONObject obj = new JSONObject();
        obj.put("cmd",  "gamesList");
        obj.put("hall",  infi.api_id);
        obj.put("key",  infi.api_key);
        obj.put("cdnUrl",  "");
        
        URL url = new URL(infi.game_list);
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("User-Agent", "application/servlet");
        conn.addRequestProperty("Content-Type", "Content-Type: application/x-www-form-urlencoded");
        conn.setDoOutput(true);
        conn.setDoInput(true);

        byte[] outputBytes = obj.toString().getBytes("UTF-8");
        OutputStream os = conn.getOutputStream();
        os.write(outputBytes);

        BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));

        JSONParser parser = new JSONParser();
        JSONArray content = new JSONArray();
        JSONObject json = (JSONObject) parser.parse(br.readLine());

        JSONObject objContent = (JSONObject) json.get("content");
        content.add(objContent);

        for (int i = 0; i < content.size(); i++) {
            JSONObject objContentChild = (JSONObject) content.get(i);
            
            /*
            ExecuteQuery("DELETE FROM tblgamelables;");
            JSONArray objGameLabels = (JSONArray) objContentChild.get("gameLabels");
            for (int v = 0; v < objGameLabels.size(); v++) {
                ExecuteQuery("insert into tblgamelables set description='" +rchar(objGameLabels.get(v).toString())+ "'");
            }

            ExecuteQuery("DELETE FROM tblgametitles;");
            JSONArray objGameTitles = (JSONArray) objContentChild.get("gameTitles");
            for (int y = 0; y < objGameTitles.size(); y++) {
                ExecuteQuery("insert into tblgametitles set description='" +rchar(objGameTitles.get(y).toString())+ "'");
            }
            */

            ExecuteQuery("DELETE from tblgamesource where provider='" + provider + "'");

            JSONArray objGameList = (JSONArray) objContentChild.get("gameList");
            for (int z = 0; z < objGameList.size(); z++) {
                JSONObject objGameListChild = (JSONObject) objGameList.get(z);

                ExecuteQuery("insert into tblgamesource set " 
                            + " provider='" + provider + "', " 
                            + " gamecode='" + objGameListChild.get("id") + "', " 
                            + " gamename='" + rchar(objGameListChild.get("name").toString()) + "', " 
                            + " gametype='" + objGameListChild.get("categories") + "', " 
                            + " aliasname='" + objGameListChild.get("system_name2") + "', " 
                            + " developer='" + objGameListChild.get("title") + "', " 
                            + " popularity='" + objGameListChild.get("menu") + "', " 
                            + " isnewgame=" + objGameListChild.get("menu").toString().contains("new") + ", " 
                            + " desktop=" + (Integer.parseInt(objGameListChild.get("device").toString()) == 0 || Integer.parseInt(objGameListChild.get("device").toString()) == 2) + ", " 
                            + " mobile=" + (Integer.parseInt(objGameListChild.get("device").toString()) == 1)  + ", " 
                            + " priority='0', " 
                            + " defaultwidth='0', " 
                            + " defaultheight='0', " 
                            + " imageurl='" + objGameListChild.get("img") + "'" 
                            + " ");
            }
        }
        
        mainObj.put("status", "OK");
        mainObj.put("message", "Game list successfull updated");
        return mainObj;
    }catch (Exception e){
        mainObj.put("status", "ERROR");
        mainObj.put("message", e.toString());
        mainObj.put("errorcode", "200");
        return mainObj;
    }
 }%>

<%!public JSONObject UpdateGame918KissH5(JSONObject mainObj, String provider) {
    try{
        GameSettings kiss = new GameSettings(provider);

        URL url = new URL(kiss.game_list);
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.connect();

        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String str_aray = ReadAllLines(br); 
        
        Object parsedData = JSONValue.parse(str_aray);
        JSONArray jsonArray = (JSONArray) parsedData;

        ExecuteQuery("DELETE from tblgamesource where provider='" + provider + "'");
        for (int i = 0; i < jsonArray.size(); i++) {
            JSONObject objContentChild = (JSONObject) jsonArray.get(i);
                ExecuteQuery("insert into tblgamesource set " 
                            + " provider='" + provider + "', " 
                            + " gamecode='" + objContentChild.get("gameid") + "', " 
                            + " gamename='" + rchar(objContentChild.get("gamename").toString()) + "', " 
                            + " gametype='Slot', " 
                            + " aliasname='" + rchar(objContentChild.get("gamename").toString()) + "', " 
                            + " developer='', " 
                            + " popularity='', " 
                            + " isnewgame=0, " 
                            + " desktop=1, " 
                            + " mobile=0, " 
                            + " priority='0', " 
                            + " defaultwidth='0', " 
                            + " defaultheight='0', " 
                            + " imageurl='"+objContentChild.get("imageurl").toString()+"'," 
                            + " demourl=''" 
                            + " ");
        }

        mainObj.put("status", "OK");
        mainObj.put("message", "Game list successfull updated");
        return mainObj;
    }catch (Exception e){
        mainObj.put("status", "ERROR");
        mainObj.put("message", e.toString());
        mainObj.put("errorcode", "200");
        return mainObj;
    }
 }%>