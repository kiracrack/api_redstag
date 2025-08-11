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
    String provider = "funky";

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
                            + " aliasname='" + rchar(objContentChild.get("dashboardGameName").toString()) + "', " 
                            + " developer='" + objContentChild.get("gameProvider") + "', " 
                            + " popularity='" + (Boolean.parseBoolean(objContentChild.get("onLobby").toString()) ? "featured" : "") + "', " 
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

