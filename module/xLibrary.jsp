 
<%!public JSONObject DBtoJson(JSONObject mainObj, String param, String query) {
    try {
          JSONArray ja =new JSONArray();
          ResultSet rst = null;  
		  rst =  SelectQuery(query); 
          while(rst.next()){
            JSONObject obj =new JSONObject();
            ResultSetMetaData columns = rst.getMetaData();
            for (int i = 1; i < columns.getColumnCount() + 1; i++) {
                if(!columns.getColumnLabel(i).equals("password")){
                    if(columns.getColumnType(i) == -7){
                        obj.put(columns.getColumnLabel(i), rst.getBoolean(columns.getColumnLabel(i)));
                    }else if(columns.getColumnType(i) == 8){
                        obj.put(columns.getColumnLabel(i), rst.getDouble(columns.getColumnLabel(i)));
                    }else{
                        String data = rst.getString(columns.getColumnLabel(i)); if(data == null){ data = "";}
                        if(data.equals("true") || data.equals("false")){
                            obj.put(columns.getColumnLabel(i), rst.getBoolean(columns.getColumnLabel(i)));
                        }else{
                            obj.put(columns.getColumnLabel(i), rst.getString(columns.getColumnLabel(i)));
                        }
                    }
                }
            }
            ja.add(obj);
        }
        rst.close();
        mainObj.put(param, ja);
  }catch(SQLException e){
        logError("DBtoJson_sql1",e.toString());
  }catch(Exception e){
      logError("DBtoJson1",e.toString());
  }
  return mainObj;
  }
 %>

 <%!public JSONObject DBtoJson(JSONObject mainObj, String query) {
    try {
          ResultSet rst = null;  
		  rst =  SelectQuery(query);
          while(rst.next()){
            ResultSetMetaData columns = rst.getMetaData();
            for (int i = 1; i < columns.getColumnCount() + 1; i++) {
                if(columns.getColumnType(i) == -7){
                    mainObj.put(columns.getColumnLabel(i), rst.getBoolean(columns.getColumnLabel(i)));
                }else if(columns.getColumnType(i) == 8){
                    mainObj.put(columns.getColumnLabel(i), rst.getDouble(columns.getColumnLabel(i)));
                }else{
                    String data = rst.getString(columns.getColumnLabel(i)); if(data == null){ data = "";}
                    if(data.equals("true") || data.equals("false")){
                        mainObj.put(columns.getColumnLabel(i), rst.getBoolean(columns.getColumnLabel(i)));
                    }else{
                        mainObj.put(columns.getColumnLabel(i), rst.getString(columns.getColumnLabel(i)));
                    }
                }
            }
        }
        rst.close();
  }catch(SQLException e){
        logError("DBtoJson_sql2",e.toString());
  }catch(Exception e){
      logError("DBtoJson2",e.toString());
  }
  return mainObj;
  }
 %>

<%!public String AttachedPhoto(ServletContext application, String folder, String imageString, String filename) {
     String PhotoUrl = "";
    if(imageString.length() > 0) {
        String directory = application.getRealPath((GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory)+"/images/"+folder+"");
        File theDir = new File(directory);
        if (!theDir.exists()){
            theDir.mkdirs();
        }
        
        String PhotoLocation = directory + "/"+filename+".png";
        PhotoUrl = GlobalHostName + (GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory)+"/images/"+folder+"/"+filename+".png";
        byte[] data = DatatypeConverter.parseBase64Binary(imageString);
        File file= new File(PhotoLocation);
        
        try (OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(file))) {
            outputStream.write(data);
        } catch (IOException e) {
            e.printStackTrace();
            PhotoUrl = "";
        }
    }else{
         PhotoUrl = "";
    }
    return PhotoUrl;
}
%>

<%!public String AttachedReceipt(ServletContext application, String folder, String imageString, String filename) {
     String PhotoUrl = "";
    if(imageString.length() > 0) {
        String directory = application.getRealPath((GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory)+"/images/"+folder+"/" + CurrentMonth());
        File theDir = new File(directory);
        if (!theDir.exists()){
            theDir.mkdirs();
        }
        
        String PhotoLocation = directory + "/"+filename+".png";
        PhotoUrl = GlobalHostName + (GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory)+"/images/"+folder + "/" + CurrentMonth()+ "/"+filename+".png";
        byte[] data = DatatypeConverter.parseBase64Binary(imageString);
        File file= new File(PhotoLocation);
        
        try (OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(file))) {
            outputStream.write(data);
        } catch (IOException e) {
            e.printStackTrace();
            PhotoUrl = "";
        }
    }else{
         PhotoUrl = "";
    }
    return PhotoUrl;
}
%>

<%!public String AttachedImage(ServletContext application, String imageString, String filename) {
     String PhotoUrl = "";
    if(imageString.length() > 0) {
        String directory = application.getRealPath((GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory)+"/media/");
        File theDir = new File(directory);
        if (!theDir.exists()){
            theDir.mkdirs();
        }
        
        String PhotoLocation = directory + "/" + filename;
        PhotoUrl = GlobalHostName + (GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory)+"/media/"+filename;
        byte[] data = DatatypeConverter.parseBase64Binary(imageString);
        File file= new File(PhotoLocation);
        
        try (OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(file))) {
            outputStream.write(data);
        } catch (IOException e) {
            e.printStackTrace();
            PhotoUrl = "";
        }
    }else{
         PhotoUrl = "";
    }
    return PhotoUrl;
}
%>

<%!public void DeleteImage(ServletContext application, String filename) {
    String imgfile = application.getRealPath((GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory)+"/media/" + filename);
    File theFile = new File(imgfile);
    if(theFile.exists()) theFile.delete();
}
%>

<%!public String getRandomAlphaNumeric() {
    Random rnd = new Random();
    int number = rnd.nextInt(999999);
    return String.format("%06d", number);
}
%>

<%!public String RemovedStr(String htmlString){	
	 	htmlString = htmlString.replaceAll("qwertyuiopasdfghjklzxcvbnm", "");
	 	return htmlString;
}
%>

<%!public String getSystemSeriesID(String columnname) {
   	int newid = 0; 
    try{
        ResultSet rst_db = null;  
        rst_db =  SelectQuery("select "+columnname+" from tblgeneralsettings");
        while(rst_db.next()){
            newid  = rst_db.getInt(columnname)+1;
            ExecuteQuery("update tblgeneralsettings set "+columnname+"="+newid);			
        }
        rst_db.close();
    }catch(SQLException e){
		logError("getSystemSeriesID",e.toString());
	}
    return String.format("%03d", newid);
}
%>
<%!public String getSystemSeriesID(String columnname, int lenght) {
   	int newid = 0; 
    try{
        ResultSet rst_db = null;  
        rst_db =  SelectQuery("select "+columnname+" from tblgeneralsettings");
        while(rst_db.next()){
            newid  = rst_db.getInt(columnname)+1;
            ExecuteQuery("update tblgeneralsettings set "+columnname+"="+newid);			
        }
        rst_db.close();
    }catch(SQLException e){
		logError("getSystemSeriesID",e.toString());
	}
    return String.format("%0"+lenght+"d", newid);
}
%>

<%!public String getOperatorAccount(String operatorid, String columnname) {
   	int newid = 0; 
    try{
        ResultSet rst_db = null;  
        rst_db =  SelectQuery("select "+columnname+" from tbloperator where companyid='"+operatorid+"'");
        while(rst_db.next()){
                newid  = rst_db.getInt(columnname)+1;
                ExecuteQuery("update tbloperator set "+columnname+"="+newid+" where companyid='"+operatorid+"'");			
        }
        rst_db.close();
    }catch(SQLException e){
		logError("getSystemSeriesID",e.toString());
	}
    return operatorid + "-" + String.format("%05d", newid);
}
%>

<%!public String getOperatorSeriesID(String operatorid, String columnname) {
   	int newid = 0; 
    try{
        ResultSet rst_db = null;  
        rst_db =  SelectQuery("select "+columnname+" from tbloperator where companyid='"+operatorid+"'");
        while(rst_db.next()){
                newid  = rst_db.getInt(columnname)+1;
                ExecuteQuery("update tbloperator set "+columnname+"="+newid+" where companyid='"+operatorid+"'");			
        }
        rst_db.close();
    }catch(SQLException e){
		logError("getSystemSeriesID",e.toString());
	}
    return operatorid + String.format("%07d", newid);
}
%>

<%!public String getAccountReferralCode() {
   	String referralcode = "";
    for (int i = 1; i <= 10; ++i) {
        referralcode = RandomStringUtils.randomAlphabetic(2).toUpperCase()+RandomStringUtils.randomNumeric(4).toUpperCase();
        if (CountQry("tblsubscriber", "referralcode='"+referralcode+"'") == 0) break;  
    }
    return referralcode;
}
%>

<%!public boolean isVisitorsBlocked(String ipaddress) {
    return CountQry("tblwebvisitor", "ipaddress='"+ipaddress+"' and blocked=1") > 0;
  }
%>

<%!public boolean isVisitorsExists(String ipaddress) {
    return CountQry("tblwebvisitor", "ipaddress='"+ipaddress+"'") > 0;
}
%>

<%!public void LogVisitors(String ipaddress, String accountid){
    if(isVisitorsExists(ipaddress)){
        ExecuteQuery("UPDATE tblwebvisitor set counts=counts+1 " + (!accountid.isEmpty() ? ", accountid='"+accountid+"'" : "") + " where ipaddress='"+ipaddress+"'");
    }else{
        ExecuteQuery("insert into tblwebvisitor set ipaddress='"+ipaddress+"', " + (!accountid.isEmpty() ? " accountid='"+accountid+"', " : "") + " counts=counts+1");
    }
}%>

<%!public String getDirectIPAddress(HttpServletRequest request) {
    for (String header : HEADERS_TO_TRY) {
        String ip = request.getHeader(header);
        if (ip != null && ip.length() != 0 && !"unknown".equalsIgnoreCase(ip)) {
            return ip;
        }
    }

    return request.getRemoteAddr();
}
%>


<%!public void LogActivity(String userid, String details) {
    ExecuteQuery("insert into tblactivitylogs set datetrn=current_timestamp, userid='"+userid+"',details=lcase('"+rchar(details.toString())+"')");
}
%>

<%!public void LogGameStatistic(String accountid, String game_type, String gameid, String gamename, String imgurl) {
    if(CountQry("tblgamestatistics", "accountid='"+accountid+"' and game_type='"+game_type+"' and gameid='"+gameid+"'") > 0) {
        ExecuteQuery("UPDATE tblgamestatistics set play_count=play_count+1, lastdateplayed=current_timestamp,imgurl='"+imgurl+"' where accountid='"+accountid+"' and game_type='"+game_type+"' and gameid='"+gameid+"' ");
    }else{
        ExecuteQuery("insert into tblgamestatistics set accountid='"+accountid+"', game_type='"+game_type+"', gameid='"+gameid+"', gamename=lcase('"+rchar(gamename.toString())+"'), imgurl='"+imgurl+"',play_count=1, lastdateplayed=current_timestamp ");
    }
 }
 %>

<%!public boolean LogLedger(final String accountid, String sessionid, String appreference,String transactionno, String description, double debit, double credit, String trnby) {
    if(!isLogLedgerFound(accountid, sessionid, appreference, description, debit, credit, trnby)){
        LogLedgerTransaction(accountid, sessionid, appreference, description, debit, credit, trnby);
        ExecuteLogLedger(accountid, sessionid, appreference, transactionno, description, debit, credit, trnby);
    }
    return true;
}
%>

<%!public boolean LogLedgerDirect(final String accountid, String sessionid, String appreference,String transactionno, String description, double debit, double credit, String trnby) {
    ExecuteLogLedger(accountid, sessionid, appreference, transactionno, description, debit, credit, trnby);
    return true;
}
%>

<%!public void ExecuteLogLedger(String accountid, String sessionid, String appreference, String transactionno, String description, double debit, double credit, String trnby){
    try {
        ResultSet rst_db = null; double currentbal = 0; double newbal = 0;
        rst_db =  SelectQuery("select creditbal from tblsubscriber where accountid='"+accountid+"' limit 1");
        while(rst_db.next()){
                currentbal = rst_db.getDouble("creditbal");
        }
        rst_db.close();
        
        
        if(debit > 0){
            ExecuteLedger("update tblsubscriber set creditbal=ROUND(creditbal-"+debit+",2) where accountid='"+accountid+"' ");
        }

        if(credit > 0){
            ExecuteLedger("update tblsubscriber set creditbal=ROUND(creditbal+"+credit+",2) where accountid='"+accountid+"' ");
        }
        
        if(currentbal==0){
            newbal = credit - debit;
        }else{
            newbal = (currentbal + credit) - debit;
        }
        ExecuteLedger("update tblsubscriber set ledgerbal=ROUND("+newbal+",2) where accountid='"+accountid+"' ");
        ExecuteLedger("insert into tblcreditledger set accountid='"+accountid+"',sessionid='"+sessionid+"',appreference='"+appreference+"',transactionno='"+transactionno+"', description='"+rchar(description)+"',prevbal=ROUND("+currentbal+",2),debit=ROUND("+debit+",2),credit=ROUND("+credit+",2),currentbal=ROUND("+newbal+",2),datetrn=current_timestamp,trnby='"+trnby+"'");
	}catch(Exception e){
		logError("LogLedger",e.toString());
	}
}%>

<%!public void ReverseBalance(String accountid, double amount){
    if(amount > 0){
        ExecuteLedger("update tblsubscriber set creditbal=ROUND(creditbal-"+amount+",2) where accountid='"+accountid+"' ");
    }
}%>

<%!public boolean isLogLedgerFound(String accountid, String sessionid, String appreference, String description, double debit, double credit, String trnby){
    boolean recordFound = false;
    if(CountQry("tblcreditledgerlogs", "accountid='"+accountid+"' and sessionid='"+sessionid+"' and appreference='"+appreference+"' and description='"+rchar(description)+"' and debit='"+debit+"' and credit='"+credit+"' and trnby='"+trnby+"'") > 0) {
        recordFound = true;
    }
    return recordFound;
}%>

<%!public void LogLedgerTransaction(String accountid, String sessionid, String appreference, String description, double debit, double credit, String trnby){
    ExecuteResult("INSERT into tblcreditledgerlogs set accountid='"+accountid+"', sessionid='"+sessionid+"', appreference='"+appreference+"', description='"+rchar(description)+"', debit='"+debit+"', credit='"+credit+"', trnby='"+trnby+"'");
}%>


<%!public boolean LogLoginSession(String userid, String sessionid, String deviceid, String devicename, String ipaddress) {
    try {
        ExecuteQuery("update tblsubscriber set accessattempt=0, accesslocklevel=0, accesslockexpiry=null, accesslockdescription='', sessionid='"+sessionid+"',deviceid='"+deviceid+"',devicename='"+rchar(devicename)+"', lastlogindate=current_timestamp,ipaddress='"+ipaddress+"' where accountid='"+userid+"' ");
        ExecuteQuery("insert into tblloginsession set userid='"+userid+"',sessionid='"+sessionid+"',deviceid='"+deviceid+"',devicename='"+devicename+"', timein=current_timestamp");
      return true;
	}catch(Exception e){
		logError("LogLoginSession",e.toString());
		return false;
	}
}
%>

<%!public String HtmlMasterReportPage(ServletContext application, String report) {
    String reportURL = "";
    try {
            File fNew= new File(application.getRealPath((GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory) + "/report/template/"), "downline.html");
            BufferedReader br = new BufferedReader(new FileReader(fNew));
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();
                while (line != null) {
                    sb.append(line);
                    sb.append(System.lineSeparator());
                    line = br.readLine();
                }
            String htmlstring = sb.toString();
            htmlstring = htmlstring.replace("[report]", report);

            
            reportURL = GlobalHostName + (GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory)+"/report/downline1.html";
            String directory = application.getRealPath((GlobalHostDirectory.equals("")?"":"/"+GlobalHostDirectory)+"/report/downline1.html");
            File theFile = new File(directory);
            if (theFile.exists()){
                theFile.delete();
            }

            FileWriter wr = new FileWriter(new File(directory));
            wr.write(htmlstring);
            wr.close();

	}catch(Exception e){
		logError("app-x-report-downline",e.getMessage());
	}
        return reportURL;
  }
%>

<%!public void ExecuteSetScore(String operatorid, String sessionid, String appreference, String accountid, String fullname, String trntype, double amount, String reference, String userid){
    String transactionno = getOperatorSeriesID(operatorid,"series_load_credit");

    AccountInfo info = new AccountInfo(accountid);
    ExecuteQuery("insert into tblcreditloadlogs set appreference='"+appreference+"',operatorid='"+operatorid+"',transactionno='"+transactionno+"',accountid='"+accountid+"',masteragentid='"+info.masteragentid+"',agentid='"+info.agentid+"',fullname='"+rchar(fullname)+"',trntype='"+trntype+"',amount='"+amount+"',reference='"+rchar(reference)+"',datetrn=current_timestamp,trnby='"+userid+"' ");
    
    if(trntype.equals("DEDUCT")){
        String description = (reference.length() > 0 ? reference.toLowerCase() : "deduct score by operator");
        LogLedger(accountid,sessionid,appreference,transactionno,rchar(description),amount,0, userid);

    }else{
        String description = (reference.length() > 0 ? reference.toLowerCase() : "added score by operator");
        LogLedger(accountid,sessionid,appreference,transactionno,rchar(description),0,amount, userid);
    }
}%>

<%!public void ExecuteSetScoreAdmin(String operatorid, String sessionid, String appreference, String accountid, String fullname, String trntype, double amount, String reference, String userid){
    String transactionno = getOperatorSeriesID(operatorid,"series_load_credit");

    AccountInfo info = new AccountInfo(accountid);
    ExecuteQuery("insert into tblcreditloadlogs set appreference='"+appreference+"',operatorid='"+operatorid+"',transactionno='"+transactionno+"',accountid='"+accountid+"',masteragentid='"+info.masteragentid+"',agentid='"+info.agentid+"',fullname='"+rchar(fullname)+"',trntype='"+trntype+"',amount='"+amount+"',reference='"+rchar(reference)+"',datetrn=current_timestamp, dashboard=1, trnby='"+userid+"' ");
    
    if(trntype.equals("DEDUCT")){
        String description = (reference.length() > 0 ? reference.toLowerCase() : "deduct score by operator");
        LogLedger(accountid,sessionid,appreference,transactionno,rchar(description),amount,0, userid);

    }else{
        String description = (reference.length() > 0 ? reference.toLowerCase() : "added score by operator");
        LogLedger(accountid,sessionid,appreference,transactionno,rchar(description),0,amount, userid);
    }
}%>

<%!public void ClearExistingBonus(String accountid){
    AccountInfo info = new AccountInfo(accountid);
    if(info.daily_enabled) ExecuteQuery("UPDATE tblsubscriber set daily_enabled=0, daily_rate=0 where accountid='"+accountid+"'");
    if(info.rebate_enabled) ExecuteQuery("UPDATE tblsubscriber set rebate_enabled=0, bonus_amount=0, totaldeposit=0 where accountid='"+accountid+"'");
    if(info.welcome_enabled) ExecuteQuery("UPDATE tblsubscriber set welcome_enabled=0, welcome_rate=0, welcome_bonus=0, welcome_amount=0 where accountid='"+accountid+"'");
    if(info.midnight_enabled) ExecuteQuery("UPDATE tblsubscriber set midnight_enabled=0, midnight_bonus=0, midnight_amount=0 where accountid='"+accountid+"'");
    if(info.winstrike_enabled) ExecuteQuery("UPDATE tblsubscriber set winstrike_enabled=0, winstrike_selection='', winstrike_category='', winstrike_eventid='', winstrike_bonus=0 where accountid='"+accountid+"'");
    if(info.socialmedia_enabled) ExecuteQuery("UPDATE tblsubscriber set socialmedia_enabled=0, bonus_amount=0 where accountid='"+accountid+"'");
    if(info.weekly_loss_enabled) ExecuteQuery("UPDATE tblsubscriber set weekly_loss_enabled=0 where accountid='"+accountid+"'");
    if(info.custom_promo_enabled) ExecuteQuery("UPDATE tblsubscriber set custom_promo_enabled=0, custom_promo_code='',custom_promo_name='', custom_promo_turnover=0, custom_promo_maxwd=0, newdeposit=0 where accountid='"+accountid+"'");
    if(info.special_bonus_enabled) ExecuteQuery("UPDATE tblsubscriber set special_bonus_enabled=0 where accountid='"+accountid+"'");
}%>

 <%!public String CurrentMonth(){
    LocalDateTime myDateObj = LocalDateTime.now();
    DateTimeFormatter myFormatObj = DateTimeFormatter.ofPattern("yyyy-MM");
    return myDateObj.format(myFormatObj);
  }
%>

 <%!public String ReadAllLines(Reader rd) throws IOException {
    StringBuilder sb = new StringBuilder();
    int cp;
    while ((cp = rd.read()) != -1) {
      sb.append((char) cp);
    }
    return sb.toString();
  }
%>
