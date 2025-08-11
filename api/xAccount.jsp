<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xApiModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>


<%
   JSONObject mainObj = new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String key = request.getParameter("key");
    String userid = request.getParameter("userid");
    String referer = request.getParameter("referer");
    String ipaddress = request.getParameter("ipaddress");

    if(x.isEmpty() || key.isEmpty() || userid.isEmpty() || referer.isEmpty()){
        mainObj.put("status", "ERROR");
        mainObj.put("message","forbidden");
        mainObj.put("errorcode", "403");
        out.print(mainObj);
        return;
    }else if(!isApiKeyValid(key)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", "api request forbidden");
        mainObj.put("errorcode", "403");
        out.print(mainObj);
        return;
        
    }else if(!isInWhiteList(key, referer)){
        
        DeniedAddress(key, referer);
        mainObj.put("status", "ERROR");
        mainObj.put("message", "header x-requested is not allowed");
        mainObj.put("errorcode", "405");
        out.print(mainObj);

        return;
    }else if(isContainSpecialChar(userid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", "user id invalid format");
        mainObj.put("errorcode", "400");
        out.print(mainObj);
        return;
    }else if(globalEnableMaintainance){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalMaintainanceMessage);
        mainObj.put("errorcode", "400");
        out.print(mainObj);
        return;
    }

    if(!isUserExists(key, userid)) CreateNewAccount(key, userid);

    PlayerInfoApi info = new PlayerInfoApi(key, userid);

    if(x.equals("api_login")){
        String nickname = request.getParameter("nickname");
        if(nickname.length() > 0 && isContainSpecialChar(nickname)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "nickname is invalid format! strickly alpha numeric only");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }else if(isBlocked(info.accountid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "account access blocked");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        OperatorInfoApi op = new OperatorInfoApi(key);
        ExecuteQuery("UPDATE tblsubscriber set fullname=ucase('"+nickname+"'), displayname=ucase('"+nickname+"'), api_website='" + op.api_website + "' where accountid='"+info.accountid+"'");

        String sessionid = UUID.randomUUID().toString();
        if(LogLoginSession(info.accountid, sessionid, "", "", ipaddress)){
            mainObj.put("status", "OK");
            mainObj = api_account_info(mainObj, info.accountid, true);
            mainObj.put("message","login succeeded");
            out.print(mainObj);
        }

    }else if(x.equals("account-info")){
        mainObj.put("status", "OK");
        mainObj = getPlayeinfoApi(mainObj, info.accountid);
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("score-balance")){
        AccountBalance b = new AccountBalance(info.accountid);
        mainObj.put("status", "OK");
        mainObj.put("balance", b.creditbal);
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("account-block")){
        ExecuteQuery("update tblsubscriber set blocked=1, blockedreason='',dateblocked=current_timestamp where accountid = '"+info.accountid+"';");
        mainObj.put("status", "OK");
        mainObj.put("message", "account successfully blocked");
        out.print(mainObj);

    }else if(x.equals("account-unblock")){
        ExecuteQuery("update tblsubscriber set blocked=0, blockedreason='',dateblocked=null where accountid = '"+info.accountid+"';");
        mainObj.put("status", "OK");
        mainObj.put("message", "account successfully unblocked");
        out.print(mainObj);

    }else if(x.equals("score-add")){
        String reference = request.getParameter("reference");
        double amount = Double.parseDouble(request.getParameter("amount"));
        
        if(amount <= 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "please enter positive amount to add");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        } 

        String transactionno = getOperatorSeriesID(info.operatorid,"series_credit_transfer");
        ExecuteSetScore(info.operatorid, info.sessionid, reference, info.accountid, info.fullname, "ADD", amount, "WALLET CASH-IN", info.accountid);
        
        AccountBalance b = new AccountBalance(info.accountid);
        mainObj.put("status", "OK");
        mainObj.put("method", "add");
        mainObj.put("added_amount", amount);
        mainObj.put("new_balance", b.creditbal);
        mainObj.put("message", "score successfully added to account " + info.fullname.toLowerCase());
        out.print(mainObj);

    }else if(x.equals("score-remove")){
        String reference = request.getParameter("reference");
        double amount = Double.parseDouble(request.getParameter("amount"));
        
        if(amount <= 0){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "please enter positive amount to deduct");
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;

        }else if(amount > info.creditbal ){
            AccountBalance b = new AccountBalance(info.accountid);
            mainObj.put("status", "ERROR");
            mainObj.put("message", "insufficient score balance");
            mainObj.put("requested", amount);
            mainObj.put("balance", info.creditbal);
            mainObj.put("errorcode", "400");
            out.print(mainObj);
            return;
        }

        String description = "WALLET CASH-OUT";
        String transactionno = getOperatorSeriesID(info.operatorid,"series_credit_transfer");
        ExecuteSetScore(info.operatorid, info.sessionid, reference, info.accountid, info.fullname, "DEDUCT", amount, description, info.accountid);
        
        AccountBalance b = new AccountBalance(info.accountid);
        mainObj.put("status", "OK");
        mainObj.put("method", "remove");
        mainObj.put("deducted_amount", amount);
        mainObj.put("new_balance", b.creditbal);
        mainObj.put("message", "score successfully removed from account " + info.fullname.toLowerCase());
        out.print(mainObj);

    }else if(x.equals("score-record")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = api_score_record(mainObj, info.accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("score-ledger")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = api_score_ledger(mainObj, info.accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("game-record")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        mainObj = api_bets_report(mainObj, info.accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else if(x.equals("win-loss-record")){
        String datefrom = request.getParameter("datefrom");
        String dateto = request.getParameter("dateto");

        PlayerWinlossCockfightApi cockfight = new PlayerWinlossCockfightApi(info.accountid, datefrom, dateto);
        mainObj = api_win_loss_report(mainObj, info.accountid, datefrom, dateto);
        mainObj.put("status", "OK");
        mainObj.put("winloss", cockfight.winloss);
        mainObj.put("message","query succeeded");
        out.print(mainObj);

    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","bad request, method not valid");
        mainObj.put("errorcode", "400");
        out.print(mainObj);
    }

}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", "bad request, missing parameter");
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("api-x-account",e.getMessage());
}
%>

<%!public boolean isBlocked(String userid) {
    boolean blocked = false;
    if(CountQry("tblsubscriber", "accountid='"+userid+"' and  blocked=1") > 0){
        blocked = true;
    }
    return blocked;
  }
%>

<%!public void DeniedAddress(String key, String referer) {
    ExecuteQuery("insert into tblapideniedaccess set apikey='"+key+"', domain='"+referer+"',datelogs=current_timestamp");
  }
%>

<%!public JSONObject api_score_record(JSONObject mainObj, String userid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "data", "select id, transactionno, date_format(datetrn, '%Y-%m-%d') as 'date', date_format(datetrn, '%r') as 'time', trntype, amount from tblcreditloadlogs where accountid='"+userid+"'  and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by id asc ");
      return mainObj;
 }
 %>

<%!public JSONObject api_score_ledger(JSONObject mainObj, String userid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "data", "select id, transactionno, date_format(datetrn, '%Y-%m-%d') as 'date', date_format(datetrn, '%r') as 'time', description, if(debit>0, -debit, credit) as amount, currentbal as balance from tblcreditledger where accountid='"+userid+"'  and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by id asc ");
      return mainObj;
 }
 %>

 <%!public JSONObject api_bets_report(JSONObject mainObj, String userid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "data", "select id, transactionno, date_format(datetrn, '%Y-%m-%d') as 'date', result, date_format(datetrn, '%r') as 'time', fightnumber, bet_amount, "
            + " eventid, if(bet_choice='M','Meron',if(bet_choice='W','Wala', 'Draw')) as bet_choice, odd,  winloss from " 
            + " (SELECT id, transactionno, fightnumber, bet_amount, datetrn, eventid, bet_choice, odd, if(cancelled,'Cancelled', if(result='M','Meron',if(result='W','Wala', 'Draw'))) as result, if(win,payback_total, 0) as win_bonus, if(!win,payback_total, 0) as payback_bonus, winloss "
            + " FROM tblfightbets2 where accountid='"+userid+"') as x where date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by id asc");
      return mainObj;
 }%>

<%!public JSONObject api_win_loss_report(JSONObject mainObj, String accountid, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "win_loss_report", "SELECT sessionid, transactionno, description, betinfo, amount, winloss, date_format(datetrn, '%m/%d/%y') as 'date', date_format(datetrn, '%r') as 'time' FROM tblcredittransaction as a where accountid='"+accountid+"' and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "';");
    return mainObj;
  }
 %>