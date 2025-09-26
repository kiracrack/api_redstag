<%!public class AccountSession{
    public String accountid;
    public AccountSession(String sessionid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select accountid from tblsubscriber as a where sessionid='"+sessionid+"' and api_player=1");
            while(rst.next()){
                this.accountid = rst.getString("accountid");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-api-player-session",e.toString());
        }
    }
}%>
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
    public String accountid, agentid, operatorid, agentname, sessionid, fullname;
    public double creditbal;
    public PlayerInfoApi(String key, String userid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select accountid, fullname, agentid, operatorid, sessionid, creditbal, (select fullname from tblsubscriber as x where x.accountid=a.agentid) as agentname from tblsubscriber as a where MD5(concat(agentid, '"+globalPassKey+"'))='"+key+"' and api_userid=MD5(concat('"+userid+"', '"+globalPassKey+"')) and api_player=1");
            while(rst.next()){
                this.operatorid = rst.getString("operatorid");  
                this.agentid = rst.getString("agentid");  
                this.agentname = rst.getString("agentname");
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

 <%!public JSONObject api_admin_dashboard(JSONObject mainObj,  String agentid) {
        JSONObject obj = new JSONObject();
        DateWeekly dw = new DateWeekly();

        OperatorWinlossApi currentWinloss = new OperatorWinlossApi(agentid, dw.current_week_from, dw.current_week_to);
        OperatorWinlossApi previousWinLoss = new OperatorWinlossApi(agentid, dw.prev_week_from, dw.prev_week_to);
 
        OperatorCashTransactionLogs cashTrn = new OperatorCashTransactionLogs(agentid, dw.current_week_from, dw.current_week_to);
        String month_from = ConvertDateFormat(dw.current_week_from,"yyyy-MM-dd", "MMMM");
        String month_to = ConvertDateFormat(dw.current_week_to,"yyyy-MM-dd", "MMMM");

        String current_week = "";
        if(!month_from.equals(month_to)) {
            current_week = ConvertDateFormat(dw.current_week_from,"yyyy-MM-dd", "MMMM dd") + " - " + ConvertDateFormat(dw.current_week_to,"yyyy-MM-dd", "MMMM dd, yyyy");
        }else{
            current_week = ConvertDateFormat(dw.current_week_from,"yyyy-MM-dd", "MMMM dd") + " - " + ConvertDateFormat(dw.current_week_to,"yyyy-MM-dd", "dd, yyyy");
        }
        
        obj.put("current_week", current_week);
        obj.put("winloss_current", currentWinloss.winloss);
        obj.put("winloss_lastweek", previousWinLoss.winloss);
        
        obj.put("total_cash_in", cashTrn.total_cash_in);
        obj.put("count_cash_in", cashTrn.count_cash_in);
        obj.put("total_cash_out", cashTrn.total_cash_out);
        obj.put("count_cash_out", cashTrn.count_cash_out);

        JSONArray objarray =new JSONArray();
        objarray.add(obj);
        
        mainObj.put("dashboard", objarray);
        return mainObj;
  }
 %>

 <%!public class OperatorCashTransactionLogs{
    public double total_cash_in, total_cash_out;
    public int count_cash_in, count_cash_out;
    public OperatorCashTransactionLogs(String agentid, String datefrom, String dateto){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("SELECT ifnull(sum(if(trntype='ADD',amount,0)),0) as total_in, ifnull(sum(if(trntype='ADD',1,0)),0) as count_in, ifnull(sum(if(trntype='DEDUCT',amount,0)),0) as total_out, ifnull(sum(if(trntype='DEDUCT',1,0)),0) as count_out  FROM `tblcreditloadlogs` where agentid='"+agentid+"' and date_format(datetrn, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "'");
            while(rst.next()){
                this.total_cash_in = rst.getDouble("total_in");  
                this.count_cash_in = rst.getInt("count_in");  
                this.total_cash_out = rst.getDouble("total_out");  
                this.count_cash_out = rst.getInt("count_out");  
            }
            rst.close();
        }catch(SQLException e){
            logError("class-operator-api-cash-transaction",e.toString());
        }
    }
}%>
 