
<%!public boolean compute_casino_master(String query_by, String operatorid, String datefrom, String dateto, String space) {
    try {
        int sort = 1;
        ResultSet rst = null; Connection conn = null; Statement stmt = null;
        ExecuteReport("DELETE FROM `tblscorereport` where query_by='"+query_by+"'");
        rst = SelectQuery(sqlWinlossCasinoDetails(datefrom, dateto, "a.masteragent=1 and a.accountid in (select accountid from tblwinlossfilter) and a.operatorid='"+operatorid+"'"));
        while(rst.next()){
            ExecuteRandom("insert into tblscorereport set "
                            + " report='casino', "
                            + " query_by='"+query_by+"', "
                            + " accountid='"+rst.getString("accountid")+"', "
                            + " masteragentid='"+ rst.getString("accountid") +"', "
                            + " agentid='"+rst.getString("agentid")+"', "
                            + " baseagent='"+rst.getString("accountid")+"', "
                            + " level='"+ 0 +"', "
                            + " fullname='"+rchar(rst.getString("fullname"))+"', "
                            + " total='"+rst.getString("total")+"', "
                            + " isagent='"+rst.getString("isagent")+"', " 
                            + " ismasteragent=1, " 
                            + " sort="+sort+"", conn, stmt);

            if(CountQry("tblsubscriber", "agentid='"+rst.getString("accountid")+"'") > 0){
                 ResultSet rst_m = null; Connection conn_m = null; Statement stmt_m = null;
                 compute_casino_downline(true, rst_m, conn_m, stmt_m, 1, query_by, rst.getString("accountid"), rst.getString("accountid"), datefrom, dateto, space, space, sort);
            }
           
        }
        rst.close();

    }catch(SQLException e){
        logError("x-compute-casino-master",e.toString());
        return false;
    }catch(Exception e){
        logError("x-compute-casino-master",e.toString());
        return false;
    }
    return true;
 }%>
 
<%!public boolean compute_casino_agent(String query_by, String agentid, String datefrom, String dateto, String space) {
    try{
        int sort = 1;
        ResultSet rst = null;  Connection conn = null;  Statement stmt = null;
        ExecuteReport("DELETE FROM `tblscorereport` where query_by='"+query_by+"'");
        rst = SelectQuery(sqlWinlossCasinoDetails(datefrom, dateto, "a.accountid='"+agentid+"'"));
        while(rst.next()){
            ExecuteRandom("insert into tblscorereport set "
                            + " report='casino', "
                            + " query_by='"+query_by+"', "
                            + " accountid='"+rst.getString("accountid")+"', "
                            + " masteragentid='"+ rst.getString("masteragentid") +"', "
                            + " agentid='"+rst.getString("agentid")+"', "
                            + " baseagent='"+rst.getString("accountid")+"', "
                            + " level='"+ 0 +"', "
                            + " fullname='"+rchar(rst.getString("fullname"))+"', "
                            + " total='"+rst.getString("total")+"', "
                            + " creditbal='"+rst.getString("creditbal")+"', "
                            + " ismasteragent='"+rst.getString("masteragent")+"', " 
                            + " isagent='"+rst.getString("isagent")+"', "
                            + " sort="+sort+"", conn, stmt);
            if(CountQry("tblsubscriber", "agentid='"+rst.getString("accountid")+"'") > 0){
                ResultSet rst_a = null; Connection conn_a = null; Statement stmt_a = null;
                compute_casino_downline(false, rst_a, conn_a, stmt_a, 0, query_by, rst.getString("accountid"), rst.getString("accountid"), datefrom, dateto, space, space, sort);
            }
        }
        rst.close();
    }catch(SQLException e){
        logError("x-compute-casino-agent",e.toString());
        return false;
    }catch(Exception e){
        logError("x-compute-casino-agent",e.toString());
        return false;
    }
    return true;
 }%>
    
<%!public void compute_casino_downline(boolean isMasterReport, ResultSet rst, Connection conn, Statement stmt, int level, String query_by, String agentid, String baseagent, String datefrom, String dateto, String space, String space_char, int sort) {
     try {
        space += space_char;
        level = level + 1;
        rst = null; conn = null; stmt = null;
        rst = SelectQuery(sqlWinlossCasinoDetails(datefrom, dateto, "a.agentid='"+agentid+"'"));
        while(rst.next()){
            sort = sort + 1;
            if(isMasterReport){
                baseagent = (level==2 ? rst.getString("accountid") : baseagent);
            }else{
                baseagent = (level==1 ? rst.getString("accountid") : baseagent);
            }
            
            ExecuteRandom("insert into tblscorereport set "
                            + " report='casino', "
                            + " query_by='"+query_by+"', "
                            + " accountid='"+rst.getString("accountid")+"', "
                            + " masteragentid='"+ rst.getString("masteragentid") +"', "
                            + " agentid='"+ agentid +"', "
                            + " baseagent='"+ baseagent +"', "
                            + " level='"+ level +"', "
                            + " fullname='"+ space + rchar(rst.getString("fullname"))+"', "
                            + " total='"+rst.getString("total")+"', "
                            + " creditbal='"+rst.getString("creditbal")+"', "
                            + " ismasteragent='"+rst.getString("masteragent")+"', " 
                            + " isagent='"+rst.getString("isagent")+"', "
                            + " sort="+sort+"", conn, stmt);

                 if(CountQry("tblsubscriber", "agentid='"+rst.getString("accountid")+"'") > 0){
                     ResultSet rst_x = null; Connection conn_x = null; Statement stmt_x = null;
                     compute_casino_downline(isMasterReport, rst_x, conn_x, stmt_x, level, query_by, rst.getString("accountid"), baseagent, datefrom, dateto, space, space_char, sort);
                 }
        }
        rst.close();
    }catch(SQLException e){
        logError("x-compute-casino-downline",e.toString());
    }catch(Exception e){
        logError("x-compute-casino-downline",e.toString());
    }
 }%>

<%!public JSONObject DisplayWinLossCasinoMaster(JSONObject mainObj, String datefrom, String dateto) {
    try {
        JSONArray ja =new JSONArray();
        ResultSet rst = null;  
        rst =  SelectQuery("select *,if(!online, if(total < 0,round(total*0.11,2), total), total) as  winloss from (select masteragentid, (select fullname from tblsubscriber where accountid=a.masteragentid) as masteragentname, sum(winloss) as total, if(masteragentid='101-00019',true,false) as online from "
                                + " tblgamesummary as a where masteragentid in (select accountid from tblwinlossfilter) and date_format(gamedate,'%Y-%m-%d') between '"+datefrom+"' and '"+dateto+"' group by masteragentid) as x");
        while(rst.next()){
            JSONObject obj =new JSONObject();
            obj.put("accountid", rst.getString("masteragentid"));
            obj.put("fullname", rst.getString("masteragentname"));
            obj.put("total", rst.getString("total"));
            obj.put("win_loss", rst.getString("winloss"));
            obj.put("isagent", true);
            ja.add(obj);
        }
        rst.close();
        mainObj.put("winloss_report", ja);
    }catch(SQLException e){
        logError("x-report-master-win-loss",e.toString());
    }catch(Exception e){
        logError("x-report-master-win-loss",e.toString());
    }
    return mainObj;}%>

<%!public JSONObject DisplayWinLossCasinoAgent(JSONObject mainObj, String query_by) {
    try {
        JSONArray ja =new JSONArray();
        ResultSet rst = null;  
        rst =  SelectQuery("select *,if(dl_rate=0,concat(ul_rate,'%'),concat(dl_rate,'%')) as comrate, if(ismasteragent, if(total < 0,round(total*0.11,2), 0) ,if(dl_rate>0 and total < 0,round(total-(total*(dl_rate)/100),2), total))  as 'win_loss', if(dl_rate>0 and total < 0,-round((total*(dl_rate/100)),2), 0) as 'commission', if(total < 0,-round((total*((if(ul_rate=0,dl_rate, if(dl_rate=0, ul_rate, ul_rate-dl_rate)  ))/100)),2), 0) as 'earning' "
                            + " from (SELECT baseagent as accountid, fullname, isagent, ismasteragent, round(sum(total),2) as total, ifnull((select commissionrate from tblsubscriber where accountid=a.agentid),0) as ul_rate, ifnull((select commissionrate from tblsubscriber where accountid=a.accountid),0) as dl_rate FROM `tblscorereport` as a where query_by='"+query_by+"' and report='casino' group by baseagent order by sort asc) as x;");
        while(rst.next()){
            if(rst.getBoolean("ismasteragent") || rst.getBoolean("isagent") || rst.getDouble("total") != 0){
                JSONObject obj =new JSONObject();
                obj.put("accountid", rst.getString("accountid"));
                obj.put("fullname", rst.getString("fullname"));
                obj.put("total", rst.getString("total"));
                obj.put("com_rate", rst.getString("comrate"));
                obj.put("win_loss", rst.getString("win_loss"));
                obj.put("commission", rst.getString("commission"));
                obj.put("earning", rst.getString("earning"));
                obj.put("isagent", rst.getBoolean("isagent"));
                ja.add(obj);
            }
        }
        rst.close();
        mainObj.put("winloss_report", ja);
    }catch(SQLException e){
        logError("x-report-agent-win-loss",e.toString());
    }catch(Exception e){
        logError("x-report-agent-win-loss",e.toString());
    }
    return mainObj;}%>

<%!public JSONObject DisplayWinLossCasinoCommission(JSONObject mainObj, String query_by) {
    try {
        JSONArray ja =new JSONArray();
        ResultSet rst = null;  
        rst =  SelectQuery("select *, if(dl_rate=0,'-',concat(dl_rate,'%')) as comrate, total as 'win_loss' "
                            + " from (SELECT baseagent as accountid, fullname, isagent, ismasteragent, round(total,2) as total, ifnull((select commissionrate from tblsubscriber where accountid=a.agentid),0) as ul_rate, "
                            + " ifnull((select commissionrate from tblsubscriber where accountid=a.accountid),0) as dl_rate FROM `tblscorereport` as a where query_by='"+query_by+"' and report='casino' order by sort asc) as x;");
        while(rst.next()){
            JSONObject obj =new JSONObject();
            obj.put("accountid", rst.getString("accountid"));
            obj.put("fullname", rst.getString("fullname"));
            obj.put("total", rst.getString("total"));
            obj.put("com_rate", rst.getString("comrate"));
            obj.put("win_loss", (rst.getDouble("win_loss") > 0 ? "0.00" : rst.getString("win_loss")));
            obj.put("isagent", rst.getBoolean("isagent"));
            ja.add(obj);
        }
        rst.close();
        mainObj.put("commission_report", ja);
    }catch(SQLException e){
        logError("x-report-agent-win-loss",e.toString());
    }catch(Exception e){
        logError("x-report-agent-win-loss",e.toString());
    }
    return mainObj;}%>


<%!public JSONObject DisplayDownlineCasinoReport(JSONObject mainObj, String query_by) {
    try {
        JSONArray ja =new JSONArray();
        ResultSet rst = null;  
        rst =  SelectQuery("SELECT accountid, fullname, round(total,2) as total, creditbal, isagent FROM `tblscorereport` as a where query_by='"+query_by+"' and report='casino' ");
        while(rst.next()){
            JSONObject obj =new JSONObject();
            obj.put("accountid", rst.getString("accountid"));
            obj.put("fullname", rst.getString("fullname"));
            obj.put("total", rst.getString("total"));
            obj.put("creditbal", rst.getString("creditbal"));
            obj.put("isagent", rst.getBoolean("isagent"));
            ja.add(obj);
        }
        rst.close();
        mainObj.put("downline_report", ja);
    }catch(SQLException e){
        logError("x-report-agent-casino-downline",e.toString());
    }catch(Exception e){
        logError("DisplayDownlineReport",e.toString());
    }
    return mainObj;}%>
