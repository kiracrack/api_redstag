
<%!public JSONObject getPlayeinfoApi(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "data", "select accountid, creditbal as score, fullname as accountname, date_format(lastlogindate,'%Y-%m-%d') as datelogin, date_format(lastlogindate,'%r') as timelogin, " 
                    + " date_format(dateregistered,'%Y-%m-%d') as datecreated, date_format(dateregistered,'%r') as timecreated, "
                    + " blocked, date_format(dateblocked,'%Y-%m-%d') as dateblocked, date_format(dateblocked,'%r') as timeblocked "
                    + " from tblsubscriber as a where accountid='"+userid+"'");
    return mainObj;
  }
 %>

<%!public boolean isApiKeyValid(String key) {
    if(CountQry("tblsubscriber", "MD5(concat(accountid, '"+globalPassKey+"'))='"+key+"' and api_enabled=1") > 0){
        return true;
    }else{
        return false;
    }
  }
 %>

<%!public boolean isInWhiteList(String key, String domain) {
    if(CountQry("tblapiwhitelist", "MD5(concat(accountid, '"+globalPassKey+"'))='"+key+"' and domainname='" + domain + "'") > 0){
        return true;
    }else{
        ExecuteQuery("insert into tblapideniedaccess set apikey='"+key+"', domain='"+domain+"', datelogs=current_timestamp");
        return false;
    }
  }
%>

<%!public boolean isUserExists(String key, String userid) {
    if(CountQry("tblsubscriber", "MD5(concat(agentid, '"+globalPassKey+"'))='"+key+"' and api_userid=MD5(concat('"+userid+"', '"+globalPassKey+"')) and api_player=1") > 0){
        return true;
    }else{
        return false;
    }
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

<%!public void CreateNewAccount(String key, String userid) {
    OperatorInfoApi op = new OperatorInfoApi(key);
    String newid = getOperatorAccount(op.operatorid, "series_subscriber");
    String referralcode = getAccountReferralCode();
    ExecuteQuery("insert into tblsubscriber set operatorid='"+op.operatorid+"', "
                + " accountid='"+newid+"', "
                + " fullname=ucase('"+newid+"'), "
                + " displayname=ucase('"+newid+"'), " 
                + " username=LCASE('" + newid + "'), "
                + " password=AES_ENCRYPT('"+userid+"', '"+globalPassKey+"'), "
                + " dateregistered=current_timestamp, "
                + " accounttype='player_cash', isagent=0, "
                + " agentid='"+op.agentid+"', "
                + " masteragentid='"+op.masteragentid+"', "
                + " api_userid=MD5(concat('"+userid+"', '"+globalPassKey+"')), "
                + " api_identifier='"+userid+"', "
                + " api_player=1," 
                + " referralcode='"+referralcode+"', " 
                + " iscashaccount=1, isnewaccount=1");

    ExecuteQuery("insert into tblpasswordhistory set userid='"+newid+"', password=AES_ENCRYPT('"+userid+"', '"+globalPassKey+"'),changedate=current_timestamp");
  }
 %>

 <%!public class OperatorInfoApi{
    public String operatorid, masteragentid, agentid, api_website;
    public double commissionrate;
    public OperatorInfoApi(String key){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select accountid, masteragentid, operatorid, commissionrate, api_website from tblsubscriber as a where MD5(concat(accountid, '"+globalPassKey+"'))='"+key+"'");
            while(rst.next()){
                this.operatorid = rst.getString("operatorid");  
                this.masteragentid = rst.getString("masteragentid");  
                this.agentid = rst.getString("accountid");  
                this.commissionrate = rst.getDouble("commissionrate");
                this.api_website = rst.getString("api_website");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-api-operator-info",e.toString());
        }
    }
}%>

<%!public class PlayerInfoApi{
    public String accountid, operatorid, sessionid, fullname;
    public double creditbal;
    public PlayerInfoApi(String key, String userid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select accountid, fullname, operatorid, sessionid, creditbal from tblsubscriber as a where MD5(concat(agentid, '"+globalPassKey+"'))='"+key+"' and api_userid=MD5(concat('"+userid+"', '"+globalPassKey+"')) and api_player=1");
            while(rst.next()){
                this.operatorid = rst.getString("operatorid");  
                this.accountid = rst.getString("accountid");
                this.fullname = rst.getString("fullname");
                this.sessionid = rst.getString("sessionid");
                this.creditbal = rst.getDouble("creditbal");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-api-player-info",e.toString());
        }
    }
}%>

<%!public class PlayerWinlossApi{
    public double winloss;
    public PlayerWinlossApi(String userid, String datefrom, String dateto){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select ROUND(sum(win_amount) - sum(lose_amount),2) as winloss from tblfightbets2 as a where accountid='"+userid+"'  and cancelled=0 and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "'");
            while(rst.next()){
                this.winloss = rst.getDouble("winloss");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-api-win-loss",e.toString());
        }
    }
}%>

<%!public class OperatorWinlossApi{
    public double winloss;
    public OperatorWinlossApi(String agentid, String datefrom, String dateto){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select ROUND(sum(win_amount) - sum(lose_amount),2) as winloss from tblfightbets2 as a where agentid='"+agentid+"'  and cancelled=0 and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "'");
            while(rst.next()){
                this.winloss = rst.getDouble("winloss");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-api-win-loss",e.toString());
        }
    }
}%>