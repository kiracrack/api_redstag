<%@ include file="../../module/db.jsp" %>
<%@ include file="../../module/xLibrary.jsp" %>
<%@ include file="../../module/xRecordModule.jsp" %>
<%@ include file="../../module/xRecordClass.jsp" %>
<%@ include file="../../module/xCasinoModule.jsp" %>
<%@ include file="../../module/xCasinoClass.jsp" %>
<%@ include file="../../module/xWebModule.jsp" %>
<%@ include file="../../module/xPusher.jsp" %>
<%@ include file="../../module/xFirebase.jsp" %>
 
<%
    JSONObject mainObj = new JSONObject();
    JSONObject apiObj = new JSONObject();
    String provider = "infinity";

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

    if(x.equals("re_update_game_list")){
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
    mainObj.put("errorcode", "200");
    out.print(mainObj);
    logError("dashboard-x-infinity",e.toString());
}
%>

