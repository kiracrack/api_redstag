<%!
public String sqlAgentQuery = "select operatorid, accountid, username, fullname, accounttype, agentid, isagent, masteragentid, displayname, mobilenumber, "
        + " creditbal, commissionrate, displayoperatorbank, lastlogindate, photoupdated, blocked, iscashaccount, photourl, referralcode, isfreecredit, hasfreeaccount, freeaccountid, "
        + " if(accounttype='master', 'Master', if(accounttype='agent', 'Agent', if(accounttype='player_cash', 'Cash', 'Non-Cash'))) as 'accountype', " 
        + " case when blocked=1 then 'Blocked' else 'Active' end as status, " 
        + " if(commissionrate=0, '-', concat(commissionrate,'%')) as commission, "  
        + " ifnull(date_format(dateregistered, '%M %d, %Y'),'') as 'date_registered', "
        + " ifnull(date_format(lastlogindate, '%M %d, %Y'),'Not yet login this account') as 'date_login', "
        + " ifnull(date_format(lastlogindate, '%r'),'') as 'time_login', "
        + " ifnull((select fullname from tblsubscriber as x where x.accountid=a.masteragentid and x.masteragent=1 limit 1 ),'MASTER') as masteragentname, "  
        + " ifnull((select fullname from tblsubscriber as x where x.accountid=a.agentid limit 1),'MASTER') as agentname, "
        + " current_timestamp, api_enabled, MD5(concat(accountid, 'my.ph')) as apikey "  
        + " from tblsubscriber as a ";

public String sqlAccountQuery = "select a.operatorid, a.accountid, username, fullname, codename, address, emailaddress, accounttype, a.agentid, masteragent, isagent, a.masteragentid, displayname, mobilenumber, "
        + " creditbal, commissionrate, displayoperatorbank, lastlogindate, photoupdated, blocked, iscashaccount, photourl, "
        + " if(accounttype='master', 'Master', if(accounttype='agent', 'Agent', if(accounttype='player_cash', 'Cash', 'Non-Cash'))) as 'accountype', " 
        + " case when blocked=1 then 'Blocked' else 'Active' end as status, " 
        + " if(commissionrate=0, '-', concat(commissionrate,'%')) as commission, "  
        + " ifnull(date_format(birthdate, '%M %d, %Y'),'') as 'birthdate', "
        + " ifnull(date_format(dateregistered, '%M %d, %Y'),'') as 'date_registered', "
        + " ifnull(date_format(lastlogindate, '%M %d, %Y'),'Not yet login this account') as 'date_login', "
        + " ifnull(date_format(lastlogindate, '%r'),'') as 'time_login', "
        + " ifnull((select fullname from tblsubscriber as x where x.accountid=a.masteragentid),'MASTER') as masteragentname, "  
        + " ifnull((select fullname from tblsubscriber as x where x.accountid=a.agentid),'MASTER') as agentname, "
        + " ifnull(sum(if(cancelled,0,win_amount)),0) - ifnull(sum(if(cancelled,0,lose_amount)),0) as win_lose, "
        + " current_timestamp "  
        + " from tblsubscriber as a left join tblfightbets2 as b on a.accountid=b.accountid and "
        + " date_format(datetrn, '%Y-%m-%d') = current_date and dummy=0 and banker=0 and cancelled=0 ";

public String sqlEventQuery = "select *, (select arenaname from tblarena where arenaid=a.arenaid) as arena, " 
        + " case when event_active=1 then 'ACTIVE' when event_cancelled=1 then 'CANCELLED' when event_closed=1 then 'CLOSED' else 'DRAFT' end as status, "
        + " if(live_mode='YOUTUBE', live_youtube_id,live_stream_url) as live_url from tblevent as a ";

public String sqlDepositQuery = "select *, date_format(date_deposit, '%M %d, %Y') as 'trn_date', date_format(time_deposit, '%r') as 'trn_time',  "
                + " date_format(dateconfirm, '%M %d, %Y') as 'confirmed_date', date_format(dateconfirm, '%r') as 'confirmed_time', "
                + " date_format(datecancelled, '%M %d, %Y') as 'cancelled_date', date_format(datecancelled, '%r') as 'cancelled_time', "
                + " ifnull((select accountnumber from tblbankaccounts where id=a.bankid),'') as accountno, "
                + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                + " (select fullname from tblsubscriber where accountid=a.agentid) as agentname, "
                + " (select remittancename from tblremittance where code=a.remittanceid) as remittancename, " 
                + " (select if(isbank,'true','false') from tblremittance where code=a.remittanceid) as isbank, "
                + " (select logourl from tblremittance where code=a.remittanceid) as logourl, "
                + " (select photourl from tblsubscriber where accountid=a.accountid) as photourl " 
                + " from tbldeposits as a ";
                
public String sqlWithdrawalQuery = "select *, date_format(datetrn, '%M %d, %Y') as 'trn_date', date_format(datetrn, '%r') as 'trn_time',  "
                + " date_format(dateconfirm, '%M %d, %Y') as 'confirmed_date', date_format(dateconfirm, '%r') as 'confirmed_time', "
                + " date_format(datecancelled, '%M %d, %Y') as 'cancelled_date', date_format(datecancelled, '%r') as 'cancelled_time', "
                + " (select fullname from tblsubscriber where accountid=a.accountid) as fullname, "
                + " (select fullname from tblsubscriber where accountid=a.agentid) as agentname, "
                + " (select remittancename from tblremittance where code=a.remittanceid) as remittancename, " 
                + " (select logourl from tblremittance where code=a.remittanceid) as logourl, "
                + " (select photourl from tblsubscriber where accountid=a.accountid) as photourl " 
                + " from tblwithdrawal as a ";

public String sqlScoreRequestQuery = "select *, date_format(daterequest, '%M %d, %Y') as 'trn_date', date_format(daterequest, '%r') as 'trn_time',  "
                + " date_format(dateconfirmed, '%M %d, %Y') as 'confirmed_date', date_format(dateconfirmed, '%r') as 'confirmed_time', "
                + " date_format(datecancelled, '%M %d, %Y') as 'cancelled_date', date_format(datecancelled, '%r') as 'cancelled_time', "
                + " (select fullname from tblsubscriber where accountid=a.userid) as fullname, "
                + " (select photourl from tblsubscriber where accountid=a.userid) as photourl " 
                + " from tblcreditrequest as a ";

public String sqlNewAccountQuery = "select *, date_format(dateregister, '%M %d, %Y') as 'trn_date', date_format(dateregister, '%r') as 'trn_time' " 
                + " from tblregistration as a ";

%>

<%!public String sqlWinlossSabongDetails(String datefrom, String dateto, String condition){	
        return "select accountid, agentid, creditbal, isagent, masteragent, masteragentid, fullname, total, downline "
            + " from (SELECT a.agentid, a.creditbal, a.isagent,a.masteragentid, a.masteragent, a.accountid, a.fullname,  "
            + " sum(ifnull(if(cancelled,0,win_amount),0))-sum(ifnull(if(cancelled,0,lose_amount),0)) as total, (select count(*) from tblsubscriber as d where d.agentid=a.accountid) as downline "
            + " FROM tblsubscriber as a left join tblfightbets2 as b on a.accountid=b.accountid and "
            + " date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' and dummy=0 and banker=0 and cancelled=0 where "+condition+" group by accountid) as x " 
            + " where if(isagent or masteragent or downline > 0, total is not null , total<>0) order by accountid asc";
}
%>

<%!public String sqlWinlossCasinoDetails(String datefrom, String dateto, String condition){	
        return "select accountid, agentid, creditbal, isagent, masteragent, masteragentid, fullname, total, downline "
            + " from (SELECT a.agentid, a.creditbal, a.isagent,a.masteragentid, a.masteragent, a.accountid, a.fullname,  "
            + " ifnull(sum(winloss),0) as total, (select count(*) from tblsubscriber as d where d.agentid=a.accountid) as downline " 
            + " FROM tblsubscriber as a left join tblgamesummary as b on a.accountid=b.accountid and "
            + " date_format(gamedate, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' where "+condition+" group by accountid) as x " 
            + " where if(isagent or masteragent or downline > 0, total is not null , total<>0) order by accountid asc";
}
%>

<%!public String sqlDailyTurnoverQuery(String userid){	
        return "select cockfight,casino,(cockfight+casino) as total, ifnull( "
             + " case when (cockfight+casino) >=25000 and (cockfight+casino) < 50000 then 168 "
             + " when (cockfight+casino) >=50000 and (cockfight+casino) < 100000 then 388 "
             + " when (cockfight+casino) >=100000 and (cockfight+casino) < 200000 then 888 "
             + " when (cockfight+casino) >= 200000 then 1888 end,0) as bonus, current_date, "
             + " (select count(*) from tblbonus where accountid=x.accountid and bonuscode='turnover' and bonusdate=current_date) as claimed "
             + " from (select accountid, "
             + " (SELECT ifnull(sum(if(cancelled,0,bet_amount)),0) FROM `tblfightbets2` where accountid=a.accountid and date_format(datetrn, '%Y-%m-%d')=current_date)  as cockfight, "
             + " (select ifnull(sum(totalbets),0) from tblgamesummary where accountid=a.accountid and date_format(gamedate, '%Y-%m-%d')=current_date) as casino from tblsubscriber as a where accountid='"+userid+"') as x"; 
}
%>

<%!public String sqlWinstrikeQuery(String userid, String eventid, String category){	
        return "SELECT *,(select arenaname from tblarena where arenaid=a.arenaid) as arena from tblfightwinstrike as a where accountid='"+userid+"' and eventid='"+eventid+"' and category='"+category+"'";
}
%>

<%!public String sqlCustomPromoQuery(String userid){	
        return "SELECT a.promocode, a.title, count(b.id) as promocount FROM `tblpromotion` as a left join tblbonus as b on a.promocode=b.bonuscode and b.accountid='" + userid + "' and "
                + " case when maxclaimed='yearly' then date_format(bonusdate,'%Y')=date_format(current_date,'%Y') "
                + " when maxclaimed='monthly' then date_format(bonusdate,'%Y-%m')=date_format(current_date,'%Y-%m') "
                + " when maxclaimed='weekly' then WEEK(bonusdate, 1) > WEEK(CURDATE() - INTERVAL 1 WEEK, 1) "
                + " when maxclaimed='daily' then date_format(bonusdate,'%Y-%m-%d')=date_format(current_date,'%Y-%m-%d') end where a.build_in=0 and a.disabled=0 group by promocode;";
}
%>