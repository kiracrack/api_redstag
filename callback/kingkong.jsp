<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>

<%
   JSONObject mainObj =new JSONObject();

try{

    String x = Decrypt(request.getParameter("x"));
    String appid = request.getParameter("appid");
    String hash = request.getParameter("hash");
    String timestamp = request.getParameter("timestamp");
    String userToken = request.getParameter("username");
    String provider = "kingkong";

     if(x.isEmpty() || appid.isEmpty() || hash.isEmpty()){
        mainObj = ReturnMessage(mainObj, userToken, 2, "Invalid AppID");
        out.print(mainObj);
        return;

    }else if(globalEnableMaintainance){
        mainObj = ReturnMessage(mainObj, userToken, 999, "Server under maintenance");
        out.print(mainObj);
        return;
    }

    GameSettings setting = new GameSettings(provider);
    //KingkongApiInfo info = new KingkongApiInfo(setting.api_id, setting.api_key);
    AccountTokenInfo user = new AccountTokenInfo(userToken);


    if(x.equals("authenticate-token")){
        String ip = request.getParameter("ip");
        String tokenUsername = request.getParameter("token");

        AccountTokenInfo token = new AccountTokenInfo(tokenUsername);
        LogGameRecord(x, token.accountid, token.fullname, appid,  hash, timestamp, ip, tokenUsername, "", token.creditbal, "", "", "", "", false);

        mainObj.put("Status", 0);
        mainObj.put("Username", tokenUsername);
        mainObj.put("Balance", user.creditbal);
        mainObj.put("Message", "Success");
        out.print(mainObj);

    }else if(x.equals("bet")){
        String id = request.getParameter("id");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String gamecode = request.getParameter("gamecode");
        String roundid = request.getParameter("roundid");
        
        GameProfile game = new GameProfile(gamecode, provider);
        String[] parts = id.split(":");
        if(!isRecordExisting(x, hash, user.accountid, gamecode, parts[1], roundid)){
            if(!isBalanceEnough(userToken, amount)){
                mainObj = ReturnMessage(mainObj, userToken, 100, "Insufficient fund");
                LogGameRecord(x, user.accountid, user.fullname, appid,  hash, timestamp, parts[1], userToken, gamecode, amount, roundid, "insuficient fund", "", "", false);
                out.print(mainObj);

            }else if (isRecordCancelledExist(hash, user.accountid, parts[1], gamecode, roundid)){
                mainObj = ReturnMessage(mainObj, userToken, 0, "Success");
                LogGameRecord(x, user.accountid, user.fullname, appid,  hash, timestamp, parts[1], userToken, gamecode, amount, roundid, "record cancelled exists", "", "", true);
                out.print(mainObj);
            }else{
                String transactionno = getOperatorSeriesID(user.operatorid, "series_casino_trn");
                if(amount > 0) LogLedger(user.accountid, roundid, parts[1], transactionno, game.gamename + " (bet: "+amount+")", amount, 0, user.accountid);
                mainObj = ReturnMessage(mainObj, userToken, 0, "Success");
                LogGameRecord(x, user.accountid, user.fullname, appid,  hash, timestamp, parts[1], userToken, gamecode, amount, roundid, "", "", "", false);
                out.print(mainObj);
            }
        }else{
            mainObj = ReturnMessage(mainObj, userToken, 0, "record already exists");
            out.print(mainObj);
        }
        
    }else if(x.equals("settle-bet")){
        String id = request.getParameter("id");
        double amount = Double.parseDouble(request.getParameter("amount"));
        String gamecode = request.getParameter("gamecode");
        String roundid = request.getParameter("roundid");
        String description = request.getParameter("description");
        String type = request.getParameter("type");
       
       if(isBetAlreadySettled(hash, user.accountid, gamecode, roundid)){
            mainObj = ReturnMessage(mainObj, userToken, 0,  "The Bet was settled");
            out.print(mainObj);;
            return;
        }

        if(!isRecordExisting(x, hash, user.accountid, gamecode, id, roundid)){
            GameProfile game = new GameProfile(gamecode, provider);
            String transactionno = getOperatorSeriesID(user.operatorid, "series_casino_trn");
            if(amount > 0) LogLedger(user.accountid, hash, roundid, transactionno, game.gamename + " (settled: "+amount+")", 0, amount, user.accountid);
            ExecuteResult("UPDATE tblgamelogs_kingkong set isbetsettled=1, settledamount='"+amount+"' where accountid='"+user.accountid+"' and hash='"+hash+"' and gamecode='"+gamecode+"' and roundid='"+roundid+"'");
            LogGameRecord(x, user.accountid, user.fullname, appid,  hash, timestamp, id, userToken, gamecode, amount, roundid, description, type, "", false);
            
            mainObj = ReturnMessage(mainObj, userToken, 0, "Success");
            out.print(mainObj);
        }else{
            mainObj = ReturnMessage(mainObj, userToken, 0, "record already exists");
            out.print(mainObj);
        }

    }else if(x.equals("cancel-bet")){
        String id = request.getParameter("id");
        String gamecode = request.getParameter("gamecode");
        String roundid = request.getParameter("roundid");
        String betid = request.getParameter("betid");
        
        String[] parts = betid.split(":");
        if(parts.length > 1){
            betid = parts[1];
        }

        if(isBetExists(hash, user.accountid, betid, gamecode, roundid)){
            if(!isRecordExisting(x, hash, user.accountid, gamecode, id, roundid)){
                KingkongApiBetInfo betinfo = new KingkongApiBetInfo(hash, user.accountid, betid, gamecode, roundid);
                GameProfile game = new GameProfile(gamecode, provider);
                String transactionno = getOperatorSeriesID(user.operatorid, "series_casino_trn");
                if(betinfo.amount > 0) LogLedger(user.accountid, roundid, betid, transactionno, game.gamename + " (cancelled: "+betinfo.amount+")", 0, betinfo.amount, user.accountid);
                LogGameRecord(x, user.accountid, user.fullname, appid,  hash, timestamp, betid, userToken, gamecode, betinfo.amount, roundid, "", "", id, true);
                ExecuteResult("UPDATE tblgamelogs_kingkong set isbetcancelled=1 where accountid='"+user.accountid+"' and hash='"+hash+"' and trnid='"+betid+"' and gamecode='"+gamecode+"' and roundid='"+roundid+"'");

                mainObj = ReturnMessage(mainObj, userToken, 0, "Success");
                out.print(mainObj);
            }else{
                mainObj = ReturnMessage(mainObj, userToken, 0, "record already exists");
                out.print(mainObj);
            }
        }else{
            if(!isRecordExisting(x, hash, user.accountid, gamecode, betid, roundid)){
                LogGameRecord(x, user.accountid, user.fullname, appid,  hash, timestamp, betid, userToken, gamecode, 0, roundid, "", "", betid, true);
                
                mainObj = ReturnMessage(mainObj, userToken, 0, "Success");
                out.print(mainObj);
            }else{
                mainObj = ReturnMessage(mainObj, userToken, 0, "record already exists");
                out.print(mainObj);
            }
        }
    

    }else{
        mainObj.put("status", 4);
        mainObj.put("message","Invalid parameters");
        out.print(mainObj);
    }

}catch (Exception e){
      mainObj.put("status", 4);
      mainObj.put("message", e.getMessage());
      out.print(mainObj);
      logError("app-x-callbak-kingkong",e.getMessage());
}
%>

<%!public JSONObject ReturnMessage(JSONObject mainObj, String userToken, int code, String message) {
    AccountTokenInfo user = new AccountTokenInfo(userToken);
    mainObj.put("Status", code);
    mainObj.put("Username", userToken);
    mainObj.put("Balance", user.creditbal);
    mainObj.put("Message", message);
    return mainObj;
 }%>

 <%!public boolean isBalanceEnough(String userToken, double bet_amount) {
    return CountQry("tblsubscriber", "md5(accountid)='"+userToken+"' and creditbal>="+bet_amount+"") > 0;
  }
 %>

<%!public boolean isRecordExisting(String command, String hash, String accountid, String gamecode, String trnid, String roundid) {
    return CountQry("tblgamelogs_kingkong", "command='"+command+"' and hash='"+hash+"' and accountid='"+accountid+"' and gamecode='"+gamecode+"' and  trnid='"+trnid+"' and roundid='"+roundid+"'") > 0;
  }
 %>

<%!public void LogGameRecord(String command, String accountid, String accountname,  String appid,  String hash, String timestamp, String trnid, String username, String gamecode, double amount, String roundid, String description, String trntype, String refid, boolean cancelled){
    ExecuteResult("INSERT into tblgamelogs_kingkong set command='"+command+"', accountid='"+accountid+"', accountname='"+accountname+"', appid='"+appid+"', hash='"+hash+"', timestamp='"+timestamp+"', trnid='"+trnid+"', username='"+username+"', gamecode='"+gamecode+"', amount='"+amount+"', roundid='"+roundid+"', description='"+rchar(description)+"', trntype='"+trntype+"', refid='"+refid+"', isbetcancelled="+cancelled+", datetrn=current_timestamp");
}%>
 
 <%!public boolean isBetExists(String hash, String accountid, String betid, String gamecode, String roundid) {
    return CountQry("tblgamelogs_kingkong", "command='bet' and hash='"+hash+"' and accountid='"+accountid+"' and gamecode='"+gamecode+"' and trnid='"+betid+"' and roundid='"+roundid+"'") > 0;
}
%>

<%!public boolean isBetAlreadySettled(String hash, String accountid, String gamecode, String roundid) {
    return CountQry("tblgamelogs_kingkong", "hash='"+hash+"' and accountid='"+accountid+"' and gamecode='"+gamecode+"' and roundid='"+roundid+"'  and isbetsettled=1") > 0;
}
%>


<%!public boolean isBetCancelled(String hash, String accountid, String gamecode, String roundid) {
    return CountQry("tblgamelogs_kingkong", "hash='"+hash+"' and accountid='"+accountid+"' and gamecode='"+gamecode+"' and roundid='"+roundid+"'  and isbetcancelled=1") > 0;
}
%>
 

<%!public boolean isRecordCancelledExist(String hash, String accountid, String trnid, String gamecode, String roundid) {
    return CountQry("tblgamelogs_kingkong", "command='cancel-bet' and hash='"+hash+"' and accountid='"+accountid+"' and trnid='"+trnid+"' and gamecode='"+gamecode+"' and roundid='"+roundid+"'") > 0;
}
%>