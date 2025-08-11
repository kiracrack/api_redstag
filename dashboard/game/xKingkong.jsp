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
    String provider = "kingkong";

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
        GameSettings p = new GameSettings(provider);
        JSONObject obj = new JSONObject();

        long unixTime = System.currentTimeMillis();
    
        SortedMap<String, String> geek  = new TreeMap<>();
        String time = Long.toString(unixTime);
        geek.put("TimeStamp", time); 
        geek.put("AppID", p.api_id); 
        
        String hash = GetSignature(geek, p.api_key);

        obj.put("AppID", p.api_id);
        obj.put("Hash",  hash);
        obj.put("Timestamp", time);

        URL url = new URL(p.game_list);
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("User-Agent", "application/servlet");
        conn.addRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);
        conn.setDoInput(true);

        byte[] outputBytes = obj.toString().getBytes("UTF-8");
        OutputStream os = conn.getOutputStream();
        os.write(outputBytes);

        BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
        ExecuteQuery("UPDATE tblgameprovider set gamedata='' where provider='"+provider+"'");
        

        JSONParser parser = new JSONParser();

        String output; 
        while ((output = br.readLine()) != null) {
             ExecuteQuery("UPDATE tblgameprovider set gamedata=concat(gamedata,'"+rchar(output)+"') where provider='"+provider+"'");
        }

        GameSettings data = new GameSettings(provider);
        ExecuteQuery("DELETE from tblgamesource where provider='" + provider + "'");

        JSONObject json = (JSONObject) parser.parse(data.gamedata);
        JSONArray objContent = (JSONArray) json.get("ListGames");
        for (int i = 0; i < objContent.size(); i++) {
            JSONObject objGameChild = (JSONObject) objContent.get(i);
            ExecuteQuery("insert into tblgamesource set " 
                            + " provider='" + provider + "', " 
                            + " gamecode='" + objGameChild.get("GameCode") + "', " 
                            + " gamename='" + rchar(objGameChild.get("GameName").toString()) + "', " 
                            + " gametype='" + objGameChild.get("GameTypeName") + "', " 
                            + " aliasname='" + objGameChild.get("GameAlias") + "', " 
                            + " developer='', " 
                            + " popularity='" + objGameChild.get("Specials") + "', " 
                            + " desktop=" + objGameChild.get("SupportedPlatForms").toString().contains("Desktop") + ", " 
                            + " mobile=" + objGameChild.get("SupportedPlatForms").toString().contains("Mobile") + ", " 
                            + " priority='" + objGameChild.get("Order") + "', " 
                            + " defaultwidth='" + objGameChild.get("DefaultWidth") + "', " 
                            + " defaultheight='" + objGameChild.get("DefaultHeight") + "', " 
                            + " imageurl='https:" + objGameChild.get("Image1") + "'" 
                            + " ");
        }

        mainObj.put("status", "OK");
        mainObj.put("message", "Kingkong game list successfull updated");
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
    logError("dashboard-x-kingkong",e.toString());
}
%>
