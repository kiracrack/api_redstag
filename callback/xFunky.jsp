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
   JSONObject mainObj = new JSONObject();

try{
    String provider = "funky";
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
        String mode = request.getParameter("mode");

        JSONParser parser = new JSONParser();
        JSONObject obj = (JSONObject) parser.parse(json.trim());
       
        if(mode.equals("/funky/Funky/User/GetBalance")){
            LogCallback(provider, "GetBalance",  obj.toString());

            String userid = getJson(obj,"playerId");
            String sessionid = getJson(obj,"sessionId");
            AccountInfo info = new AccountInfo(userid);
            if(!info.sessionid.equals(sessionid)){
                mainObj.put("errorCode", 401);
                mainObj.put("errorMessage","Player Not Login");
                out.print(mainObj);
                return;
            }

            JSONObject subObj = new JSONObject();
            subObj.put("balance", info.creditbal);

            mainObj.put("errorCode", 0);
            mainObj.put("errorMessage","Success");
            mainObj.put("data", subObj);
            out.print(mainObj);
            
        }else if(mode.equals("/funky/Funky/Bet/PlaceBet")){
            LogCallback(provider, "PlaceBet",  obj.toString());

            String sessionid = getJson(obj, "sessionId");
            GameSessionPlayerID gsp = new GameSessionPlayerID(sessionid);
            String userid = gsp.accountid;
        
            String playerIp = getJson(obj,"playerIp");

            AccountInfo info = new AccountInfo(userid);
            if(!info.sessionid.equals(sessionid)){
                mainObj.put("errorCode", 401);
                mainObj.put("errorMessage","Player Not Login");
                out.print(mainObj);
                return;
            }

            String transactionno = getOperatorSeriesID(info.operatorid,"series_casino_trn");
            JSONObject objGame = (JSONObject) obj.get("bet");
            String gamecode = getJson(objGame,"gameCode");
            String gameprovider = getJson(objGame,"gameProvider");
            String reference = getJson(objGame,"refNo");
            String voucherid = getJson(objGame,"voucherId");
            double bet = Double.parseDouble(getJson(objGame,"stake").toString());

            if(!isBalanceEnough(userid, bet)){
                mainObj.put("errorCode", 402);
                mainObj.put("errorMessage","Insufficient Balance");
                out.print(mainObj);
                return;
            }

            if(!isTransactionExists(info.operatorid, userid, provider, sessionid, gamecode, bet, 0, reference)){
                GameProfile game = new GameProfile(gamecode, provider);
                if(bet > 0) LogLedger(userid, sessionid, reference, transactionno, game.gamename + " (Bet: " + bet + ")", bet, 0, userid);

                LogTransaction(info.operatorid, userid, provider, sessionid, gamecode, bet, 0,reference, "R");
                ExecuteQuery("insert into tblgamelogs_funky set operatorid='"+info.operatorid+"',playerId='"+userid+"', sessionId='"+sessionid+"', playerIp='"+playerIp+"', gameCode='"+gamecode+"', gameName='"+rchar(game.gamename)+"', gameProvider='"+gameprovider+"', refNo='"+reference+"', stake="+bet+", winAmount=0, betStatus='R', voucherId='"+voucherid+"', effectiveStake='',freeSpinMainBet='', datetrn=current_timestamp");    
                LogGameSummary(info.operatorid, sessionid, userid, info.fullname, info.masteragentid, info.agentid, gamecode, rchar(game.gamename), reference,  bet,  0,  0);

                JSONObject subObj = new JSONObject();
                subObj.put("balance", getLatestCreditBalance(userid));

                mainObj.put("errorCode", 0);
                mainObj.put("errorMessage","Success");
                mainObj.put("data", subObj);
                out.print(mainObj);

                SendPlayerBalanceNotification(userid);
            }else{
                mainObj.put("errorCode", 404);
                mainObj.put("errorMessage","Bet Was Not Found");
                out.print(mainObj);
            }
        
        }else if(mode.equals("/funky/Funky/Bet/CheckBet")){
            LogCallback(provider, "CheckBet",  obj.toString());

            String reference = getJson(obj,"id");
            String userid = getJson(obj,"playerId");

            AccountInfo info = new AccountInfo(userid);
            if(isBetExists(info.operatorid, userid, provider, reference)){
                GameBetInfo bet = new GameBetInfo(info.operatorid, userid, provider, reference);

                JSONObject subObj = new JSONObject();
                subObj.put("stake", bet.bet_amount);
                subObj.put("winAmount", bet.win_amount );
                subObj.put("status", bet.status);
                subObj.put("statementDate", bet.datetrn);

                mainObj.put("errorCode", 0);
                mainObj.put("errorMessage","Success");
                mainObj.put("data", subObj);
                out.print(mainObj);
            }else{
                mainObj.put("errorCode", 404);
                mainObj.put("errorMessage","Bet Was Not Found");
                out.print(mainObj);
            }

        }else if(mode.equals("/funky/Funky/Bet/SettleBet")){
            LogCallback(provider, "SettleBet",  obj.toString());

            String reference = getJson(obj,"refNo");
            
            JSONObject objGame = (JSONObject) obj.get("betResultReq");
            String gamecode = getJson(objGame,"gameCode");
            String voucherid = getJson(objGame,"voucherId");
            String userid = getJson(objGame,"playerId");
            String freeSpinMainBet = getJson(objGame,"freeSpinMainBet");
            double bet_amount = Double.parseDouble(getJson(objGame,"stake").toString());
            double win_amount = Double.parseDouble(getJson(objGame,"winAmount").toString());
            double effective = Double.parseDouble(getJson(objGame,"effectiveStake").toString());

            AccountInfo info = new AccountInfo(userid);

            if(isBetExists(info.operatorid, userid, provider, reference)){
                GameBetInfo bet = new GameBetInfo(info.operatorid, userid, provider, reference);

                if(bet.settled){
                    mainObj.put("errorCode", 409);
                    mainObj.put("errorMessage","Bet Already Settled");
                    out.print(mainObj);
                    return;

                }else if(bet.status.equals("C")){
                    mainObj.put("errorCode", 410);
                    mainObj.put("errorMessage","Bet Already Cancelled");
                    out.print(mainObj);
                    return;
                }

                GameProfile game = new GameProfile(gamecode, provider);
                String transactionno = getOperatorSeriesID(info.operatorid,"series_casino_trn");
                if(win_amount > 0) LogLedger(userid, bet.sessionid, reference, transactionno, game.gamename + " (Win: " + win_amount + ")", 0, win_amount, userid);
                
                String status = "";
                if(win_amount == bet_amount){
                    status = "D";
                }else if(win_amount > bet_amount){
                    status = "W";
                }else if(bet_amount > win_amount){
                    status = "L";
                }
                
                ExecuteQuery("UPDATE tblgamelogs set win_amount="+win_amount+", `status`='"+status+"', settled=1 " +
                                    " where operatorid='"+info.operatorid+"' and accountid='"+userid+"' and provider='"+provider+"' and reference='"+reference+"'");    
                ExecuteQuery("UPDATE tblgamelogs_funky set winAmount="+win_amount+", betStatus='"+status+"', voucherId='"+voucherid+"', effectiveStake="+effective+",freeSpinMainBet='"+freeSpinMainBet+"', datesettled=current_timestamp" +
                                    " where operatorid='"+info.operatorid+"' and playerId='"+userid+"' and refNo='"+reference+"' "); 

                ExecuteQuery("UPDATE tblgamesummary set totalwin="+win_amount+", winloss=("+win_amount+"-totalbets) where operatorid='"+info.operatorid+"' and accountid='"+userid+"' and reference='"+reference+"' "); 

                JSONObject subObj = new JSONObject();
                subObj.put("refNo", reference);
                subObj.put("balance", getLatestCreditBalance(userid));
                subObj.put("playerId", userid);
                subObj.put("currency", "EN");
                subObj.put("statementDate", bet.datetrn);

                mainObj.put("errorCode", 0);
                mainObj.put("errorMessage","Success");
                mainObj.put("data", subObj);
                out.print(mainObj);

                SendPlayerBalanceNotification(userid);
            }else{
                mainObj.put("errorCode", 404);
                mainObj.put("errorMessage","Bet Was Not Found");
                out.print(mainObj);
            }
        
        }else if(mode.equals("/funky/Funky/Bet/CancelBet")){
            LogCallback(provider, "CancelBet",  obj.toString());

            String userid = getJson(obj,"playerId");
            String reference = getJson(obj,"refNo");

            AccountInfo info = new AccountInfo(userid);
            GameBetInfo bet = new GameBetInfo(info.operatorid, userid, provider, reference);
            GameProfile game = new GameProfile(bet.gamecode, provider);

            if(isBetExists(info.operatorid, userid, provider, reference)){
                if(bet.settled){
                    mainObj.put("errorCode", 409);
                    mainObj.put("errorMessage","Bet Already Settled");
                    out.print(mainObj);
                    return;
                }else if(bet.status.equals("C")){
                    mainObj.put("errorCode", 410);
                    mainObj.put("errorMessage","Bet Already Cancelled");
                    out.print(mainObj);
                    return;
                }
                 
                ExecuteQuery("UPDATE tblgamelogs set `status`='C' where operatorid='"+info.operatorid+"' and accountid='"+userid+"' and provider='"+provider+"' and sessionid='"+bet.sessionid+"' and gamecode='"+bet.gamecode+"' and reference='"+reference+"'");    
                ExecuteQuery("UPDATE tblgamelogs_funky set betStatus='C' where operatorid='"+info.operatorid+"' and playerId='"+userid+"' and sessionId='"+bet.sessionid+"' and gameCode='"+bet.gamecode+"' and refNo='"+reference+"' "); 
                ExecuteQuery("DELETE FROM tblgamesummary where operatorid='"+info.operatorid+"' and accountid='"+userid+"' and gameid='"+bet.gamecode+"' and reference='"+reference+"' "); 

                double winloss = bet.win_amount - bet.bet_amount;
                String transactionno = getOperatorSeriesID(info.operatorid,"series_casino_trn");
                if(bet.bet_amount > 0) LogLedger(userid, bet.sessionid, reference, transactionno, game.gamename + " (cancelled)", 0, bet.bet_amount, userid);
                
                JSONObject subObj = new JSONObject();
                subObj.put("refNo", reference);

                mainObj.put("errorCode", 0);
                mainObj.put("errorMessage","Success");
                mainObj.put("data", subObj);
                out.print(mainObj);

                SendPlayerBalanceNotification(userid);
            }else{
                mainObj.put("errorCode", 404);
                mainObj.put("errorMessage","Bet Was Not Found");
                out.print(mainObj);
            }

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
      logError("app-x-callback-funky",e.getMessage());
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

 <%!public boolean isBetExists(String operatorid, String accountid, String provider, String reference) {
    return CountQry("tblgamelogs", "operatorid='"+operatorid+"' and accountid='"+accountid+"' and provider='"+provider+"' and reference='"+reference+"'") > 0;
  }
 %>
 
<%!public boolean isTransactionExists(String operatorid, String accountid, String provider, String sessionid, String gamecode, double bet_amount, double win_amount, String reference) {
    return CountQry("tblgamelogs", "operatorid='"+operatorid+"' and accountid='"+accountid+"' and provider='"+provider+"' and sessionid='"+sessionid+"' and gamecode='"+gamecode+"' and bet_amount="+bet_amount+" and win_amount="+win_amount+" and reference='"+reference+"'") > 0;
  }
 %>

<%!public void LogTransaction(String operatorid, String accountid, String provider, String sessionid, String gamecode, double bet_amount, double win_amount, String reference, String status) {
     ExecuteQuery("insert into tblgamelogs set operatorid='"+operatorid+"',accountid='"+accountid+"', provider='"+provider+"', sessionid='"+sessionid+"', gamecode='"+gamecode+"', bet_amount="+bet_amount+", win_amount="+win_amount+", reference='"+reference+"', `status`='"+status+"', datetrn=current_timestamp");    
  }
 %>

 <%!public void LogGameSummary(String operatorid, String sessionid, String accountid, String fullname, String masteragentid, String agentid, String gameId, String gamename, String reference,  double bet,  double win,  double winloss) {
    ExecuteQuery("insert into tblgamesummary set operatorid='"+operatorid+"', sessionid='"+sessionid+"', provider='funky',accountid='"+accountid+"', fullname='"+rchar(fullname)+"',masteragentid='"+masteragentid+"',agentid='"+agentid+"',totalbets="+bet+", totalwin="+win+", winloss="+winloss+", gameid='"+gameId+"', gamename='"+gamename+"', reference='"+reference+"', gamedate=current_timestamp");    
  }
 %> 
 
 <%!public String getJson(JSONObject obj, String str) {
        if(obj.get(str) == null){
            return "";
        }else{
            return obj.get(str).toString();
        }
  }
%>
