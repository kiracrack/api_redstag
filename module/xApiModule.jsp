
<%!public JSONObject getPlayeinfoApi(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "data", "select accountid, creditbal as score, fullname as accountname, date_format(lastlogindate,'%Y-%m-%d') as datelogin, date_format(lastlogindate,'%r') as timelogin, " 
                    + " date_format(dateregistered,'%Y-%m-%d') as datecreated, date_format(dateregistered,'%r') as timecreated, "
                    + " blocked, date_format(dateblocked,'%Y-%m-%d') as dateblocked, date_format(dateblocked,'%r') as timeblocked "
                    + " from tblsubscriber as a where accountid='"+userid+"'");
    return mainObj;
  }
 %>

<%!public JSONObject api_winloss_report(JSONObject mainObj, String agentid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "winloss_report", "select * from (SELECT accountid, (select fullname from tblsubscriber where accountid=a.accountid) as fullname, group_concat(distinct(select arenaname from tblarena where arenaid=a.arenaid)) as arenaname, "
            + " (select api_identifier from tblsubscriber where accountid=a.accountid) as api_id, (select creditbal from tblsubscriber where accountid=a.accountid) as creditbal, ROUND(sum(win_amount) - sum(lose_amount),2) as winloss "
            + " FROM tblfightbets2 as a where agentid='"+agentid+"' and cancelled=0 and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' group by accountid) as x order by winloss asc");
      return mainObj;
 }%>

<%!public JSONObject api_cash_transaction_report(JSONObject mainObj, String trntype, String agentid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "cash_transaction", "SELECT accountid, fullname, transactionno, (select api_identifier from tblsubscriber where accountid=a.accountid) as identifier, date_format(datetrn, '%m/%d/%y') as 'date', date_format(datetrn, '%r') as 'time', amount from `tblcreditloadlogs` as a where agentid='"+agentid+"' and trntype='"+trntype+"' and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by datetrn asc");
      return mainObj;
 }%>

<%!public JSONObject api_score_report(JSONObject mainObj, String agentid, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "score_report", "SELECT  *,accountid, (select api_identifier from tblsubscriber where accountid=a.accountid) as api_id, (select fullname from tblsubscriber where accountid=a.accountid) as fullname, date_format(datetrn, '%m/%d/%y') as 'date', date_format(datetrn, '%r') as 'time' FROM tblcredittransaction as a where agentid='"+agentid+"' and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "';");
    return mainObj;
  }
 %>

<%!public JSONObject api_player_accounts(JSONObject mainObj, String agentid, String datefrom, String dateto) {
    mainObj = DBtoJson(mainObj, "player_accounts", "SELECT  accountid, fullname, creditbal, api_identifier as 'api_id', ipaddress, blocked,dateblocked,  dateregistered, lastlogindate FROM tblsubscriber as a where agentid='"+agentid+"' and date_format(dateregistered, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "';");
    return mainObj;
  }
 %>

<%!public JSONObject api_player_bets(JSONObject mainObj, String agentid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "player_bets", "select accountid, (select api_identifier from tblsubscriber where accountid=x.accountid) as api_id, (select fullname from tblsubscriber where accountid=x.accountid) as fullname, date_format(datetrn, '%Y-%m-%d') as 'date', result, date_format(datetrn, '%r') as 'time', fightnumber, transactionno, bet_amount, "
            + "  eventid, arena, if(bet_choice='M','Meron',if(bet_choice='W','Wala', 'Draw')) as bet_choice, odd,  winloss from " 
            + " (SELECT accountid, fightnumber, transactionno, bet_amount, datetrn, eventid, (select arenaname from tblarena where arenaid=a.arenaid) as arena, bet_choice, odd, if(result='','Cancelled', if(result='M','Meron',if(result='W','Wala', 'Draw'))) as result, " 
            + "  ROUND(win_amount - lose_amount,2) as winloss "
            + " FROM tblfightbets2 as a where agentid='"+agentid+"') as x where date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' order by datetrn asc");
      return mainObj;
 }%>

<%!public boolean isApiKeyValid(String key) {
    return CountQry("tblsubscriber", "MD5(concat(accountid, '"+globalPassKey+"'))='"+key+"' and api_enabled=1") > 0;
  }
 %>

 <%!public boolean isSessionValid(String sessionid) {
    return CountQry("tblsubscriber", "sessionid='"+sessionid+"' and api_player=1") > 0;
  }
 %>

<%!public boolean isInWhiteList(String key, String domain) {
    return CountQry("tblapiwhitelist", "MD5(concat(accountid, '"+globalPassKey+"'))='"+key+"' and domainname='" + domain + "'") > 0;
  }
%>

<%!public boolean isUserExists(String key, String userid) {
    return CountQry("tblsubscriber", "MD5(concat(agentid, '"+globalPassKey+"'))='"+key+"' and api_userid=MD5(concat('"+userid+"', '"+globalPassKey+"')) and api_player=1") > 0;
  }
%>

<%!public boolean isContainSpecialChar(String s) {
    if (s == null || s.trim().isEmpty()) {
         return false;
     }
     Pattern p = Pattern.compile("[^A-Za-z0-9]");
     Matcher m = p.matcher(s);
     return m.find();
  }
%>


<%!public void DeniedAddress(String key, String referer) {
    ExecuteQuery("insert into tblapideniedaccess set apikey='"+key+"', domain='"+referer+"',datelogs=current_timestamp");
  }
%>
 
<%!public void CreateNewAccount(String key, String userid) {
    OperatorInfoApi op = new OperatorInfoApi(key);
    String newid = getOperatorAccount(op.operatorid, "series_subscriber");

    ExecuteQuery("insert into tblsubscriber set operatorid='"+op.operatorid+"', "
                + " accountid='"+newid+"', "
                + " fullname=ucase('"+userid+"'), "
                + " displayname=ucase('"+userid+"'), " 
                + " username=LCASE('" + userid + "'), "
                + " password=AES_ENCRYPT('"+userid+"', '"+globalPassKey+"'), "
                + " dateregistered=current_timestamp, "
                + " accounttype='player_non_cash', isagent=0, "
                + " agentid='"+op.agentid+"', "
                + " masteragentid='"+op.masteragentid+"', "
                + " api_userid=MD5(concat('"+userid+"', '"+globalPassKey+"')), "
                + " api_identifier='"+userid+"', "
                + " api_player=1," 
                + " iscashaccount=0");

    ExecuteQuery("insert into tblpasswordhistory set userid='"+newid+"', password=AES_ENCRYPT('"+userid+"', '"+globalPassKey+"'),changedate=current_timestamp");
  }
 %>

<%!public void ExecuteLogTransaction(String accountid, String agentid, String sessionid, String appreference, String transactionno, String description, double amount){
    if(!isTransactionFound(accountid, sessionid, appreference, transactionno, description, amount)) 
    ExecuteLedger("insert into tblcredittransaction set accountid='"+accountid+"', agentid='"+agentid+"', sessionid='"+sessionid+"',appreference='"+appreference+"',transactionno='"+transactionno+"',description='"+rchar(description)+"', amount='"+amount+"', datetrn=current_timestamp");
}%>

<%!public boolean isTransactionFound(String accountid, String sessionid, String appreference, String transactionno, String description, double amount){
    return CountQry("tblcredittransaction", "accountid='"+accountid+"' and sessionid='"+sessionid+"' and appreference='"+appreference+"' and transactionno='"+transactionno+"' and description='"+rchar(description)+"' and amount='"+amount+"'") > 0;
}%>