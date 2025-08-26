<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || userid.isEmpty() || (sessionid.isEmpty() && !isAllowedMultiSession(userid))){
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

    }else if(isSessionExpired(userid,sessionid)){
		mainObj.put("status", "ERROR");
		mainObj.put("message", globalExpiredSessionMessage);
        mainObj.put("errorcode", "session");
		out.print(mainObj);
        return;
    }

    
    if(x.equals("infinity")){
        GameSettings game = new GameSettings("infinity");
        String gameid = request.getParameter("gameid");
        
        if(game.isdisable && !game.testerid.equals(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Game provider is currently under maintenance! Please try again later");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        AccountInfo info = new AccountInfo(userid);
        OperatorInfo op = new OperatorInfo(info.operatorid);
        boolean test = (op.testaccountid.equals(info.masteragentid) ? true : false);

        JSONObject obj = new JSONObject();
        obj.put("cmd",  "openGame");
        obj.put("hall",  game.api_id);
        obj.put("key",  game.api_key);
        obj.put("domain",  game.domain);
        obj.put("exitUrl",  game.exiturl);
        obj.put("language", "en");
        obj.put("login", userid);
        obj.put("gameId", gameid);
        obj.put("cdnUrl",  "");
        obj.put("demo",  (test ? "1" : "0"));
        
        URL url = new URL(game.open_game + "openGame/");
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
        
       
        String status = json.get("status").toString();
        String error = json.get("error").toString();

        if(status.equals("success")){
            JSONObject objContent = (JSONObject) json.get("content");
            content.add(objContent);

            for (int i = 0; i < content.size(); i++) {
                JSONObject objContentChild = (JSONObject) content.get(i);
                JSONObject objGame = (JSONObject) objContentChild.get("game");

                String gamesessionid = UUID.randomUUID().toString().replace("-","");
                
                CreateGameSession(gamesessionid, userid, sessionid, gameid, "infinity", objGame.get("url").toString());

                GameInfo gameInfo = new GameInfo(gameid, "infinity");
                LogGameStatistic(userid, "infinity", gameid, gameInfo.gamename, gameInfo.imageurl);
                
                mainObj.put("status", "OK");
                mainObj.put("sessionid", gamesessionid);
                mainObj.put("message", "response valid");
                out.print(mainObj);
            }
        }else if(error.equals("games_not_activ")){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "This game is not available for demo account. Please use real account");
            mainObj.put("errorcode", "400");
            out.print(mainObj);

        }else{
            mainObj.put("status", "ERROR");
            mainObj.put("message", json.get("error").toString());
            mainObj.put("errorcode", "400");
            out.print(mainObj);
        }

    }else if(x.equals("funky")){
        AccountInfo info = new AccountInfo(userid);
        GameSettings funky = new GameSettings("funky");
        String gameid = request.getParameter("gameid");

        OperatorInfo op = new OperatorInfo(info.operatorid);
        boolean test = (op.testaccountid.equals(info.masteragentid) ? true : false);

         if(funky.isdisable && !funky.testerid.equals(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Game provider is currently under maintenance! Please try again later");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }
        
        JSONObject obj = new JSONObject();
        obj.put("gameCode",  gameid);
        obj.put("userName",  info.username);
        obj.put("playerId",  userid);
        obj.put("currency",  "MYR");
        obj.put("language", "EN");
        obj.put("playerIp", info.ipaddress);
        obj.put("sessionId", sessionid);
        obj.put("redirectUrl", funky.exiturl);
        obj.put("isTestAccount", test);
        
        URL url = new URL(funky.open_game);
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.addRequestProperty("Content-Type", "Content-Type: application/x-www-form-urlencoded");
        conn.setRequestProperty("User-Agent", funky.api_id);
        conn.setRequestProperty("Authentication", funky.api_key);
        conn.setRequestProperty("X-Request-ID", UUID.randomUUID().toString());

        conn.setDoOutput(true);
        conn.setDoInput(true);

        byte[] outputBytes = obj.toString().getBytes("UTF-8");
        OutputStream os = conn.getOutputStream();
        os.write(outputBytes);

        BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));

        JSONParser parser = new JSONParser();
        JSONObject json = (JSONObject) parser.parse(br.readLine());

        LogCallback(x, "OpenGame",  json.toString());

        if(json.get("errorCode").toString().equals("0")){
            JSONObject objOpenGame = (JSONObject) json.get("data");
     
            String gamesession = UUID.randomUUID().toString().replace("-","");
            String gameurl = objOpenGame.get("gameUrl").toString() + "?token=" + objOpenGame.get("token").toString();
            CreateGameSession(gamesession, userid, sessionid, gameid, "funky", gameurl);

            GameInfo gameInfo = new GameInfo(gameid, "funky");
            LogGameStatistic(userid, "funky", gameid, gameInfo.gamename, gameInfo.imageurl);

            mainObj.put("status", "OK");
            mainObj.put("sessionid", gamesession);
            mainObj.put("message", "response valid");
            out.print(mainObj);
            
        }else{
            mainObj.put("status", "ERROR");
            mainObj.put("message", json.get("errorMessage").toString());
            mainObj.put("errorcode", "400");
            out.print(mainObj);
        }
    
    }else if(x.equals("gamitech")){
        String gameid = request.getParameter("gameid");

        URL url = new URL("https://api.gamitech.net/Api/Register.php");
        Map<String,Object> params = new LinkedHashMap<>();
        params.put("SecrtKey", "VeQVCTXEOUdhNZFi");
        params.put("userId", userid);

        StringBuilder postData = new StringBuilder();
        for (Map.Entry<String,Object> param : params.entrySet()) {
            if (postData.length() != 0) postData.append('&');
            postData.append(URLEncoder.encode(param.getKey(), "UTF-8"));
            postData.append('=');
            postData.append(URLEncoder.encode(String.valueOf(param.getValue()), "UTF-8"));
        }
        byte[] postDataBytes = postData.toString().getBytes("UTF-8");

        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setRequestProperty("Content-Length", String.valueOf(postDataBytes.length));
        conn.setDoOutput(true);
        conn.getOutputStream().write(postDataBytes);

        BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
        JSONParser parser = new JSONParser();
        JSONObject json = (JSONObject) parser.parse(br.readLine());
        
        logError("app-x-game", json.toString());
        
        if(json.get("status").toString().equals("100") || json.get("status").toString().equals("403")){
            String gamesession = UUID.randomUUID().toString().replace("-","");
            String gameurl = "https://www.gamitech.net/LoginGame3.php?game="+gameid+"&cm=redstagapp&id=" + userid;
            CreateGameSession(gamesession, userid, sessionid, gameid, "gamitech", gameurl);

            mainObj.put("status", "OK");
            mainObj.put("sessionid", gamesession);
            mainObj.put("message", "response valid");
            out.print(mainObj);

        }else{
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Error game api response");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
        }

       
    }else if(x.equals("kissH5")){
        AccountInfo info = new AccountInfo(userid);
        GameSettings game = new GameSettings("kissH5");
        String gameid = request.getParameter("gameid");

        OperatorInfo op = new OperatorInfo(info.operatorid);
        boolean test = (op.testaccountid.equals(info.masteragentid) ? true : false);

        if(game.isdisable && !game.testerid.equals(userid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Game provider is currently under maintenance! Please try again later");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        String authcode = game.api_id;
        String secretKey = game.api_key;
        long time = Instant.now().getEpochSecond();
        String sign=generateMD5((authcode+userid+time+secretKey).toLowerCase());

        logError("app-x-game", sign);

        Map<String,Object> params = new LinkedHashMap<>();
        params.put("userName", userid);
        params.put("gamePlatformID", gameid);
        params.put("gameID", gameid);
        params.put("officialUrl", game.exiturl);
        params.put("lang", "en-US");
        params.put("time", time);
        params.put("authcode", authcode);
        params.put("sign", sign);

        /*StringBuilder postData = new StringBuilder();
        for (Map.Entry<String,Object> param : params.entrySet()) {
            if (postData.length() != 0) postData.append('&');
            postData.append(URLEncoder.encode(param.getKey(), "UTF-8"));
            postData.append('=');
            postData.append(URLEncoder.encode(String.valueOf(param.getValue()), "UTF-8"));
        }
        //byte[] postDataBytes = postData.toString().getBytes("UTF-8");
        */

        String request_game =  game.open_game + "?&userName=" + userid + "&time=" + time + "&authcode=" + authcode + "&sign=" + sign;
        
        logError("app-x-game", request_game);

        URL url = new URL(request_game);
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.addRequestProperty("Content-Type", "Content-Type: application/x-www-form-urlencoded");

        conn.setDoOutput(true);
        conn.setDoInput(true);
        //conn.getOutputStream().write(postDataBytes);

        BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
        JSONParser parser = new JSONParser();
        JSONObject json = (JSONObject) parser.parse(br.readLine());
        
        logError("app-x-game", json.toString());

        if(json.get("success").toString().equals("true")){
            /*JSONObject objOpenGame = (JSONObject) json.get("data");
     
            String gamesession = UUID.randomUUID().toString().replace("-","");
            String gameurl = objOpenGame.get("gameUrl").toString() + "?token=" + objOpenGame.get("token").toString();
            CreateGameSession(gamesession, userid, sessionid, gameid, "funky", gameurl);

            GameInfo gameInfo = new GameInfo(gameid, "funky");
            LogGameStatistic(userid, "funky", gameid, gameInfo.gamename, gameInfo.imageurl);

            mainObj.put("status", "OK");
            mainObj.put("sessionid", gamesession);
            mainObj.put("message", "response valid");
            out.print(mainObj);*/
            
        }else{
            mainObj.put("status", "ERROR");
            mainObj.put("message", json.get("msg").toString());
            mainObj.put("errorcode", "400");
            out.print(mainObj);
        }

        //LogCallback(x, "OpenGame",  json.toString());


    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "400");
        out.print(mainObj);
    }

}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("app-x-game",e.getMessage());
}
%>

<%!public void CreateGameSession(String gamesession, String accountid, String sessionid, String gameid, String provider, String gameurl){
    ExecuteResult("DELETE FROM tblgamesession where accountid='"+accountid+"'");
    ExecuteResult("INSERT into tblgamesession set gamesession='"+gamesession+"', accountid='"+accountid+"', sessionid='"+sessionid+"', gameid='"+gameid+"', provider='"+provider+"', gameurl='"+gameurl+"'");
}%>
