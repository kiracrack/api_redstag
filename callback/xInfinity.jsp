<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>

<%
   JSONObject mainObj =new JSONObject();

try{
    String provider = "infinity";
    String x = Decrypt(request.getParameter("x"));

    if(globalEnableMaintainance){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalMaintainanceMessage);
        mainObj.put("errorcode", "maintenance");
        out.print(mainObj);
        return;
    }

    if(x.equals("callback")){
        String json = request.getParameter("json");
 
        JSONParser parser = new JSONParser();
        JSONObject obj = (JSONObject) parser.parse(json.trim());
        String cmd = obj.get("cmd").toString();
        String userid = obj.get("login").toString();
        String hall = obj.get("hall").toString();
        String key = obj.get("key").toString();

        AccountInfo info = new AccountInfo(userid);

        if(!isUserExist(userid)){
            mainObj.put("status", "fail");
            mainObj.put("error","user_not_found");
            out.print(mainObj);
            return;
        }

        if(cmd.equals("getBalance")){
            LogCallback(provider, "getBalance",  obj.toString());

            mainObj.put("status", "success");
            mainObj.put("error","");
            mainObj.put("balance", info.creditbal);
            mainObj.put("currency", "MYR");
            out.print(mainObj);

        }else if(cmd.equals("writeBet")){
            LogCallback(provider, "writeBet",  obj.toString());

            String sessionId = obj.get("sessionId").toString();
            double bet = Double.parseDouble(obj.get("bet").toString());
            double win = Double.parseDouble(obj.get("win").toString());
            double winLose = Double.parseDouble(obj.get("winLose").toString());
            String tradeId = obj.get("tradeId").toString();
            String betInfo = obj.get("betInfo").toString();
            String gameId = obj.get("gameId").toString();
            String matrix = obj.get("matrix").toString();
            String datetrn = obj.get("date").toString();
            String WinLines = obj.get("WinLines").toString();
            
            if(!isBalanceEnough(userid, bet)){
                mainObj.put("status", "fail");
                mainObj.put("error","fail_balance");
                out.print(mainObj);
                return;
            }

            if(!isTransactionExists(info.operatorid, userid, provider, sessionId, gameId, bet, win, tradeId)){
                String transactionno = getOperatorSeriesID(info.operatorid,"series_casino_trn");
                double amount = win - bet;

                GameProfile game = new GameProfile(gameId, provider);
                if(amount != 0){
                    if(amount < 0) LogLedger(userid, sessionId, tradeId, transactionno, game.gamename + " (Bet: " + bet + " Win: "+win+")",-amount, 0, userid);
                    if(amount > 0) LogLedger(userid, sessionId, tradeId, transactionno, game.gamename + " (Win: "+win+")", 0, amount, userid);
                  
                }
                LogTransaction(info.operatorid, userid, provider, sessionId, gameId, bet, win, tradeId, "OK");
                ExecuteQuery("insert into tblgamelogs_infinity set operatorid='"+info.operatorid+"', login='"+userid+"', hall='"+hall+"', `key`='"+key+"', sessionId='"+sessionId+"', bet="+bet+", win="+win+", winLose="+winLose+", tradeId='"+tradeId+"', betInfo='"+betInfo+"', gameId='"+gameId+"', gamename='"+game.gamename+"', matrix='"+matrix+"', gamedate='"+datetrn+"', datetrn=current_timestamp, WinLines='"+WinLines+"', transactionno='"+transactionno+"'");
                LogGameSummary(info.operatorid, sessionId, userid, info.fullname, info.masteragentid, info.agentid, gameId, game.gamename, tradeId, bet, win, winLose);

                mainObj.put("operationId", transactionno);
            }else{
                mainObj.put("operationId", getTransactionNo(sessionId, bet, win, tradeId, betInfo, gameId, matrix));
            }

            mainObj.put("status", "success");
            mainObj.put("error","");
            mainObj.put("login",userid);
            mainObj.put("balance", getLatestCreditBalance(userid));
            mainObj.put("currency", "MYR");
           
            out.print(mainObj);

            SendPlayerBalanceNotification(userid);
            return;

        }else{
            mainObj.put("status", "fail");
            mainObj.put("error","command_not_found");
            out.print(mainObj);
            return;
        }
        
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
      logError("app-x-callback-infinity",e.getMessage());
}
%>

<%!public boolean isUserExist(String userid) {
    return CountQry("tblsubscriber", "accountid='"+userid+"' and blocked=0 and deleted=0 ") > 0;
  }
 %>
 
 <%!public boolean isBalanceEnough(String userid, double bet_amount) {
    return CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal>="+bet_amount+"") > 0;
  }
 %>
 
<%!public boolean isTransactionExists(String operatorid, String accountid, String provider, String sessionid, String gamecode, double bet_amount, double win_amount, String reference) {
    return CountQry("tblgamelogs", "operatorid='"+operatorid+"' and accountid='"+accountid+"' and provider='"+provider+"' and sessionid='"+sessionid+"' and gamecode='"+gamecode+"' and bet_amount="+bet_amount+" and win_amount="+win_amount+" and reference='"+reference+"'") > 0;
  }
 %>

<%!public void LogTransaction(String operatorid, String accountid, String provider, String sessionid, String gamecode, double bet_amount, double win_amount, String reference, String status) {
     ExecuteQuery("insert into tblgamelogs set operatorid='"+operatorid+"',accountid='"+accountid+"', provider='"+provider+"', sessionid='"+sessionid+"', gamecode='"+gamecode+"', bet_amount="+bet_amount+", win_amount="+win_amount+", reference='"+reference+"', `status`='"+status+"', settled=1, datetrn=current_timestamp");    
  }
 %>
 
 <%!public String getTransactionNo(String sessionId, double bet, double win, String tradeId, String betInfo, String gameId, String matrix) {
    return QuerySingleData("transactionno", "transactionno", "tblgamelogs_infinity where sessionId='"+sessionId+"' and bet="+bet+" and bet="+win+" and tradeId='"+tradeId+"' and betInfo='"+betInfo+"' and gameId='"+gameId+"' and matrix='"+matrix+"'");
  }
%>

 <%!public void LogGameSummary(String operatorid, String sessionid, String accountid, String fullname, String masteragentid, String agentid, String gameId, String gamename, String reference,  double bet,  double win,  double winloss) {
    ExecuteQuery("insert into tblgamesummary set operatorid='"+operatorid+"', sessionid='"+sessionid+"', provider='infinity',accountid='"+accountid+"', fullname='"+rchar(fullname)+"',masteragentid='"+masteragentid+"',agentid='"+agentid+"',totalbets="+bet+", totalwin="+win+", winloss="+winloss+", gameid='"+gameId+"', gamename='"+gamename+"', reference='"+reference+"', gamedate=current_timestamp");    
  }
 %> 


 