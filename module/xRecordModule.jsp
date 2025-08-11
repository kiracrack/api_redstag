
<%!public JSONObject getGeneralSettings(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "settings", "select * from tblgeneralsettings");
    return mainObj;
  }
 %>

<%!public ArrayList getActiveOperator() {
    ArrayList<String> list = new ArrayList<String>();
    try{
        ResultSet rst = null; 
        rst =  SelectQuery("select companyid from tbloperator where actived=1");
        while(rst.next()){
            list.add(rst.getString("companyid"));
        }
        rst.close();
    }catch(SQLException e){
        logError("getActiveOperator",e.toString());
    }
    return list;}
 %>

<%!public JSONObject getAccountInformation(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "profile", "select *,IF(birthdate IS NULL,'0',YEAR(CURDATE()) -YEAR(birthdate)) AS age, " 
                    + " ifnull(date_format(birthdate,'%Y-%m-%d'), '') as datebirth, ifnull(emailaddress,'') as email, " 
                    + " date_format(current_timestamp,'%Y-%m-%d') as datelogin, date_format(current_timestamp,'%r') as timelogin, " 
                    + " ifnull((select fullname from tblsubscriber as x where x.accountid=a.agentid limit 1),'') as agentname, "
                    + " ifnull((select commissionrate from tblsubscriber as x where x.accountid=a.agentid limit 1),'0') as agentcommission, "
                    + " if(creditbal + ifnull((select sum(bet_amount) FROM tblfightbets as a where accountid=a.accountid),0) >= (select video_min_credit from tbloperator where companyid=a.operatorid),'true', 'false') as isvideoallowed, "
                    + " ifnull((select deposit_instruction from tblsubscriber as x where x.accountid=a.agentid limit 1),'') as agentdepositinstruction, "
                    + " (select count(*) from tblcreditrequest where confirmed=0 and cancelled=0 and agentid=a.accountid) as count_score_request, "
                    + " (select count(*) from tbldeposits where confirmed=0 and cancelled=0 and agentid=a.accountid) as count_deposit_request, "
                    + " (select count(*) from tblwithdrawal where confirmed=0 and cancelled=0 and agentid=a.accountid) as count_withdrawal_request, "
                    + " if(masteragentid = (select ownersaccountid from tbloperator where companyid=a.operatorid), 'true', 'false') as isonlineagent, "
                    + " ifnull(photourl,'') as imageurl "
                    + " from tblsubscriber as a where accountid='"+userid+"'");
    
    mainObj = getBankAccounts(mainObj, userid);
    mainObj = getTotalRequestNotification(mainObj, userid);
    mainObj = DBtoJson(mainObj, "operator", "select * from tbloperator where companyid='" +  getOperatorid(userid) + "'");
    return mainObj;
  }
 %>

<%!public JSONObject getBankAccounts(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "bank_account", "select * from (select *, "
                    + " (select remittancename from tblremittance where code=a.remittanceid) as remittancename, "
                    + " (select logourl from tblremittance where code=a.remittanceid) as logourl, "
                    + " (select if(isbank,'true','false') from tblremittance where code=a.remittanceid) as isbank "
                    + " from tblbankaccounts as a where accountid='"+userid+"' and actived=1 and deleted=0) as x order by remittancename asc");
    return mainObj;
 }
 %>

<%!public JSONObject getTotalRequestNotification(String userid) {
    JSONObject mainObj = new JSONObject();
    mainObj = DBtoJson(mainObj, "select (select count(*) from tblcreditrequest where confirmed=0 and cancelled=0 and agentid=a.accountid) as count_score_request, "
                    + " (select count(*) from tblregistration where approved=0 and deleted=0 and agentid=a.accountid) as count_new_account, "
                    + " (select count(*) from tbldeposits where confirmed=0 and cancelled=0 and (agentid=a.accountid or agentid in (select accountid from tblsubscriber where agentid='"+userid+"' and iscashaccount=1))) as count_deposit_request, "
                    + " (select count(*) from tblwithdrawal where confirmed=0 and cancelled=0 and (agentid=a.accountid or agentid in (select accountid from tblsubscriber where agentid='"+userid+"' and iscashaccount=1))) as count_withdrawal_request "
                    + " from tblsubscriber as a where accountid='"+userid+"'");
    return mainObj;
 }
 %>

<%!public JSONObject getTotalRequestNotification(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "request", "select (select count(*) from tblcreditrequest where confirmed=0 and cancelled=0 and agentid=a.accountid) as count_score_request, "
                    + " (select count(*) from tblregistration where approved=0 and deleted=0 and agentid=a.accountid) as count_new_account, "
                    + " (select count(*) from tbldeposits where confirmed=0 and cancelled=0 and (agentid=a.accountid or agentid in (select accountid from tblsubscriber where agentid='"+userid+"' and iscashaccount=1))) as count_deposit_request, "
                    + " (select count(*) from tblwithdrawal where confirmed=0 and cancelled=0 and (agentid=a.accountid or agentid in (select accountid from tblsubscriber where agentid='"+userid+"' and iscashaccount=1))) as count_withdrawal_request "
                    + " from tblsubscriber as a where accountid='"+userid+"'");
    return mainObj;
 }
 %>


<%!public JSONObject getActiveArena(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "arena", "select *, ifnull((select eventid from tblevent where arenaid=a.arenaid and event_active=1),'') as eventid from tblarena as a where active=1");
    return mainObj;
  }
 %>
 
<%!public JSONObject getEventInfo(JSONObject mainObj, String eventid) {
    mainObj = DBtoJson(mainObj, "event", "select *, concat(eventid, '-', event_key) as eventkey, (select if(disabled,'false','true') from tblpromotion where promocode='promo_win_strike') as winstrike_enabled from tblevent where eventid='"+eventid+"'");
    mainObj = DBtoJson(mainObj, "result", "select id, eventid, fightnumber, result, if(result='C','X',fightnumber) as resultdisplay, case when result='W' then 'wala' when result='M' then 'meron' when result='D' then 'draw' when result='C' then 'cancelled' end as 'resultkey' from tblfightresult where eventid='"+eventid+"'");
    return mainObj;
  }
 %>

<%!public JSONObject getDummyAccount(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "dummy_names", "select * from tbldummyname ORDER BY RAND()");
    mainObj = DBtoJson(mainObj, "dummy_settings", "select * from tbldummysettings");
    mainObj = DBtoJson(mainObj, "dummy_player", "select * from tbloperator where actived=1 and dummy_enable=1");
    return mainObj;
  }
 %>


<%!public JSONObject getRegistrationAccount(JSONObject mainObj,  String mobilenumber, String pincode) {
    mainObj = DBtoJson(mainObj, "select fullname, mobilenumber  from tblregistration where mobilenumber='"+mobilenumber+"' and pinnumber=AES_ENCRYPT('"+pincode.replace("'","")+"', '"+globalPassKey+"')");
    return mainObj;
  }
 %>

<%!public JSONObject getAndroidUpdate(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "select apkupdateurl from tblversioncontrol");
    return mainObj;
 }
 %>

<%!public JSONObject getControllerUpdate(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "select controllerupdateurl from tblversioncontrol");
    return mainObj;
 }
 %>

<%!public JSONObject getRemittances(JSONObject mainObj, String operatorid) {
    mainObj = DBtoJson(mainObj, "remittance", "select * from tblremittance where operatorid='"+operatorid+"' and isbank=1 order by remittancename asc");
    return mainObj;
 }
 %>
<%!public JSONObject getRemittances(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "remittance", "select * from tblremittance where isbank=1 order by remittancename asc");
    return mainObj;
 }
 %>

<%!public JSONObject getDashboardUpdate(JSONObject mainObj, String dversion) {
    mainObj = DBtoJson(mainObj, "select *,dashboardupdateurl as downloadurl, date_format(str_to_date(dashboardversion, '%Y.%m.%d'), '%Y-%m-%d') as 'version' " 
                    + " from tblversioncontrol where date_format(str_to_date(dashboardversion, '%Y.%m.%d'), '%Y-%m-%d') > '" + dversion + "'");
    return mainObj;
  }
 %>

<%!public JSONObject getAdminProfile(JSONObject mainObj,  String userid) {
    mainObj = DBtoJson(mainObj, "profile", "select *, (select betwacherid from tbloperator where companyid=a.operatorid) as betwacherid, "
                        + " (select ownersaccountid from tbloperator where companyid=a.operatorid) as ownersaccountid, "
                        + " (select dummy_master from tbloperator where companyid=a.operatorid) as dummy_master, "
                        + " date_format(current_timestamp, '%M %d, %Y %r') as datelogin from tbladminaccounts as a where id='"+userid+"'");
    return mainObj;
}
%>

<%!public JSONObject LoadOperators(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "operators", "select *, case when actived=1 then 'Active' else 'In-Active' end as status, "
                            + " case when enablebetwatcher=1 then 'YES' else 'NO' end as bet_watcher, " 
                            + " (select fullname from tblsubscriber where accountid=a.ownersaccountid) as owner_account, "
                            + " (select fullname from tblsubscriber where accountid=a.betwacherid) as bet_watcher_account, "
                            + " (select count(*) from tblsubscriber where operatorid=a.companyid and masteragent=1) as totalmasteragent, "
                            + " (select count(*) from tblsubscriber where operatorid=a.companyid and masteragent=0 and isagent=1) as totalagent, "
                            + " (select count(*) from tblsubscriber where operatorid=a.companyid and masteragent=0 and isagent=0) as totalplayer, " 
                            + " if(enable_agent_commission,'YES', 'NO') as enable_commission "
                            + " from tbloperator as a order by companyname asc");

    mainObj = LoadOperatorBank(mainObj);               
    return mainObj;
 }
 %>

<%!public JSONObject LoadSelectOperators(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "select_operator", "select companyid, companyname from tbloperator order by companyname asc");       
    return mainObj;
 }
 %>

<%!public JSONObject LoadOperatorBank(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "operator_bank", "select *, (select logourl from tblremittance where code=a.remittanceid) as logourl, "
                                + " (select remittancename from tblremittance where code=a.remittanceid) as bankname, "
                                + " (select isbank from tblremittance where code=a.remittanceid) as isbank, if(actived, 'Active','Disabled') as status "
                                + " from tblbankaccounts as a where isoperator=1 and deleted=0");
      return mainObj;
 }
 %>
 

 <%!public JSONObject LoadTelcoList(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "telco_list", "select * from tblremittance as a where isbank=0 and deleted=0");
      return mainObj;
 }
 %>

<%!public JSONObject LoadAgentBank(JSONObject mainObj, String agentid) {
    mainObj = DBtoJson(mainObj, "operator_bank", "select *, (select logourl from tblremittance where code=a.remittanceid) as logourl, " 
                        + " (select remittancename from tblremittance where code=a.remittanceid) as bankname, " 
                        + " (select isbank from tblremittance where code=a.remittanceid) as isbank, if(actived, 'Active','Disabled') as status "
                        + " from tblbankaccounts as a where accountid='"+agentid+"' and actived=1 and deleted=0  order by accountid asc");
    return mainObj;
 }
 %>

<%!public JSONObject QueryDeposit(JSONObject mainObj,String refno) {
      mainObj = DBtoJson(mainObj, "deposit", sqlDepositQuery + " where refno='"+refno+"'");
      return mainObj;
 }
 %>

<%!public JSONObject LoadDepositUpline(JSONObject mainObj,String userid,String search, Integer pgno) {
      mainObj = DBtoJson(mainObj, "deposit", sqlDepositQuery + " where accountid='" + userid + "' " + search + " order by id desc limit " + Integer.toString(pgno));
      return mainObj;
 }
 %>

<%!public JSONObject LoadDepositDownline(JSONObject mainObj,String agentid,String search, Integer pgno) {
      mainObj = DBtoJson(mainObj, "deposit", sqlDepositQuery + " where (agentid='"+agentid+"' or agentid in (select accountid from tblsubscriber where agentid='"+agentid+"' and iscashaccount=1)) " + search + " order by id desc limit " + Integer.toString(pgno));
      return mainObj;
 }
 %>

<%!public JSONObject QueryWithdrawal(JSONObject mainObj,String refno) {
      mainObj = DBtoJson(mainObj, "withdrawal", sqlWithdrawalQuery + " where refno='"+refno+"'");
      return mainObj;
 }
 %>
<%!public JSONObject LoadWithdrawalUpline(JSONObject mainObj,String userid,String search, Integer pgno) {
      mainObj = DBtoJson(mainObj, "withdrawal", sqlWithdrawalQuery + " where accountid='" + userid + "' " + search + " order by id desc limit " + Integer.toString(pgno));
      return mainObj;
 }
 %>
<%!public JSONObject LoadWithdrawalDownline(JSONObject mainObj,String agentid,String search, Integer pgno) {
      mainObj = DBtoJson(mainObj, "withdrawal", sqlWithdrawalQuery + " where (agentid='"+agentid+"' or agentid in (select accountid from tblsubscriber where agentid='"+agentid+"' and iscashaccount=1)) " + search + " order by id desc limit " + Integer.toString(pgno));
      return mainObj;
 }
 %>

<%!public JSONObject LoadScoreRequest(JSONObject mainObj, String accountid, boolean customer, String search, Integer pgno) {
    mainObj = DBtoJson(mainObj, "score_request", sqlScoreRequestQuery + " where confirmed=0 and cancelled=0 and " + (customer ? " agentid='"+accountid+"' " : " userid='"+accountid+"' ") + search + " order by id desc limit " + Integer.toString(pgno));
    return mainObj;
 }
 %>
<%!public JSONObject LoadNewAccount(JSONObject mainObj, String accountid, String search, Integer pgno) {
    mainObj = DBtoJson(mainObj, "new_account", sqlNewAccountQuery + " where agentid='"+accountid+"' and approved=0 and deleted=0 " + search + " order by id desc limit " + Integer.toString(pgno));
    return mainObj;
 }
 %>

<%!public JSONObject LoadAnnouncement(JSONObject mainObj, String operatorid) {
      mainObj = DBtoJson(mainObj, "announcement", "select *, date_format(datetrn,'%Y-%m-%d') as 'date', date_format(datetrn,'%r') as 'time' from tblannouncement order by sortorder asc");
      return mainObj;
 }
 %>

 <%!public JSONObject LoadSpecialBonus(JSONObject mainObj) {
      mainObj = DBtoJson(mainObj, "special_bonus", "select * from tblspecialbonus where deleted=0");
      return mainObj;
 }
 %>

<%!public boolean isPromotionEnabled(String promocode) {
    return CountQry("tblpromotion", "promocode='" + promocode + "' and disabled=0") > 0;
  }
 %>
 
 <%!public String getAccountid(String mobilenumber) {
    return QueryDirectData("accountid","tblsubscriber where mobilenumber='"+mobilenumber+"'");
 }
 %>

<%!public String getAccountid(String username, String password) {
    return QueryDirectData("accountid","tblsubscriber where username='"+username+"' and password=AES_ENCRYPT('"+password.replace("'","")+"', '"+globalPassKey+"')");
 }
 %>

<%!public String getOperatorid(String userid) {
   return QueryDirectData("operatorid", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

<%!public boolean isSessionExpired(String userid, String sessionid) {
    return CountQry("tblsubscriber", "accountid='" + userid + "' and sessionid='"+sessionid+"'") == 0;
  }
 %>

 <%!public boolean isAllowedMultiSession(String userid) {
    return CountQry("tblmultisession", "accountid='" + userid + "'") > 0;
  }
 %>

<%!public boolean isAdminSessionExpired(String userid, String sessionid) {
    return CountQry("tbladminaccounts", "id='" + userid + "' and sessionid='"+sessionid+"'") == 0;
  }
 %>

<%!public boolean isAdminAccountBlocked(String userid) {
    return CountQry("tbladminaccounts", "(id='" + userid + "' or username='" + rchar(userid) + "') and blocked=1") > 0;
  }
 %>

<%!public String getMasterAgentid(String userid) {
   return QueryDirectData("masteragentid", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

<%!public String getAccountName(String userid) {
   return QueryDirectData("displayname", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

 <%!public String getFullname(String userid) {
   return QueryDirectData("fullname", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

 <%!public String getAgentID(String userid) {
   return QueryDirectData("agentid", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

<%!public String getFirebaseToken(String userid) {
   return QueryDirectData("tokenid", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

<%!public String getLatestCreditBalance(String userid) {
   return QueryDirectData("creditbal", "tblsubscriber where accountid='"+userid+"'");
 }
 %>

<%!public boolean isBalanceAvailable(String userid) {
   return CountQry("tblsubscriber", "accountid='"+userid+"' and creditbal > 1 ") > 0;
 }
 %>

<%!public boolean isProfileConfirmed(String userid) {
    return CountQry("tblsubscriber","accountid='"+userid+"' and confirmed=1") > 0;
 }
 %>

<%!public boolean isControllerRemoved(String deviceid) {
    return CountQry("tblcontroller", "deviceid='"+deviceid+"'") == 0;
 }
 %>

<%!public boolean isControllerBlocked(String deviceid) {
    return CountQry("tblcontroller", "deviceid='"+deviceid+"' and blocked=1") > 0;
 }
 %>

 <%!public boolean isBankAccountExist(String userid) {
    return CountQry("tblbankaccounts", "accountid='"+userid+"' and deleted=0") > 0;
  }
%>

 <%!public boolean isTherePendingDeposit(String userid) {
    return CountQry("tbldeposits", "accountid='"+userid+"' and confirmed=0 and cancelled=0") > 0;
  }
%>

<%!public boolean isDepositAlreadyConfirmed(String userid, String refno) {
    return CountQry("tbldeposits", "accountid='"+userid+"' and refno='"+refno+"' and confirmed=1 and cancelled=0") > 0;
  }
%>

<%!public boolean isTherePendingWithdrawal(String userid) {
    return CountQry("tblwithdrawal", "accountid='"+userid+"' and confirmed=0 and cancelled=0") > 0;
  }
%>

<%!public boolean isBonusExists(String userid, String bonuscode) {
    return CountQry("tblbonus", "accountid='"+userid+"' and bonuscode='"+bonuscode+"'") > 0;
 }
 %>

 <%!public boolean isBonusExistsByDate(String userid, String bonuscode, String bonusdate) {
    return CountQry("tblbonus", "accountid='"+userid+"' and bonuscode='"+bonuscode+"' and bonusdate='"+bonusdate+"'") > 0;
 }
 %>
 
 <%!public boolean isBonusExistsByReference(String userid, String bonuscode, String appreference) {
    return CountQry("tblbonus", "accountid='"+userid+"' and bonuscode='"+bonuscode+"' and appreference='"+appreference+"'") > 0;
 }
 %>

 <%!public boolean isRebateIsValid(String userid) {
    return CountQry("tblsubscriber", "accountid='"+userid+"' and rebate_claim_date >= current_date and rebate_enabled=0 and totaldeposit > 0") > 0;
 }
 %>

<%!public boolean isMasterAgentDisplayOperatorBank(String masteragentid) {
    return CountQry("tblsubscriber", "accountid='"+masteragentid+"' and displayoperatorbank=1") > 0;
  }
%>

<%!public boolean isAgentDisplayOperatorBank(String agentid) {
    return CountQry("tblsubscriber", "accountid='"+agentid+"' and displayoperatorbank=1") > 0;
  }
%>

<%!public int CountWinstrike(String category, String accountid, String eventid) {
    return CountQry("tblfightwinstrike", "category='"+category+"' and accountid='" + accountid + "' and eventid='"+eventid+"' and (result<>'C' and result<>'D')");
  }
 %>

<%!public JSONObject LoadArena(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "arena", "select * from tblarena");       
    return mainObj;
 }
 %>