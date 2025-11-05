<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.*,java.sql.*,java.util.*,java.text.*,javax.mail.*,java.text.SimpleDateFormat,java.net.URL,java.sql.Timestamp,java.util.Date" %>
<%@ page language="java" contentType="application/json;charset=UTF-8" %>
<%@ page import="org.apache.commons.io.IOUtils"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.JSONValue"%>
<%@ page import="org.json.simple.parser.JSONParser"%>
<%@ page import="org.json.simple.parser.ParseException"%>
<%@ page import="org.apache.catalina.tribes.util.Arrays"%>
<%@ page import="org.apache.commons.lang3.RandomStringUtils"%>
<%@ page import="org.apache.commons.io.FileUtils" %>
<%@ page import="java.math.BigInteger" %>

<%@ page import="java.security.GeneralSecurityException" %>
<%@ page import="javax.crypto.Cipher" %>
<%@ page import="javax.crypto.spec.IvParameterSpec" %>
<%@ page import="javax.crypto.spec.SecretKeySpec" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.net.URLConnection" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.concurrent.TimeUnit" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.Instant" %>
<%@page pageEncoding="UTF-8"%>
 
<%@ page import="com.pusher.rest.Pusher" %>
<%@ page import="javax.mail.internet.*,javax.activation.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ page import="javax.xml.bind.DatatypeConverter" %>
<%@ page import="java.security.NoSuchAlgorithmException" %>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.util.SortedMap" %>
<%@ page import="java.util.stream.Collectors" %>

<%@ page import="connection.*" %>
<%@ include file="xSecurity.jsp" %>
<%@ include file="xFormatting.jsp" %>
<%@ include file="xDatabaseClass.jsp" %>
<%@ include file="xDatabaseUpdate.jsp" %>
<%@ include file="xDatabaseQuery.jsp" %>

<%!
public boolean globalRequiredGPS = true;
public int GlobalRecordsLimit = 50;
public String GlobalHostName = "";
public String GlobalHostDirectory = "";

public String globalFirebaseMode = "";
public String globalFirebaseDB = "";
public String globalFirebaseAuth = "";
public String globalFirebaseApi = "";
public String globalFirebaseName = "";
public String globalFirebaseToken = "";
public String globalFirebaseURL = "";

public Pusher pusher;
public String globalPusherAppID = "";
public String globalPusherAppKey = "";
public String globalPusherAppSecret = "";
public String globalPusherAppCluster = "";
public String globalPusherAppChannel = "";

public String GlobalCompanyName = "";
public String GlobalCompanyShortname = "";
public String GlobalCompanyWebsite = "";
public String GlobalCompanyEmail = "";
public String GlobalCompanyMobile = "";
public String GlobalEnvironment = "";
public String GlobalDefaultOperator = "";
public double GlobalFightCommission = 0;


public String globalMaintainanceMessage = "Server is currently undergoing maintenance. please try again later";
public String globalExpiredSessionMessage = "System detected new device login! Your session from this device will be disconnected. <br><br> If this wasn't you, or if you believe that an unauthorized person has accessed your account, please reset your password right away.";
public String globalExpiredSessionMessageDashboard = "System detected new device login! Your session from this device will be disconnected.";
public String globalAdminAccountBlocked = "Your account was blocked! Please contact admin operator";

public String globalOperatorBlockedTitle = "Operator Access Restricted";
public String globalOperatorBlockedMessage = "Your operator is temporarily restricted from using this app until further notice.";

public String globalOperatorAuthorizedTitle = "Operator Access Authorized";
public String globalOperatorAuthorizedMessage = "Your account is now authorized. Login now! place your bet and have change of big winnings.";

public String globalAgentBlockedTitle = "Account Access Blocked";
public String globalAgentBlockedMessage = "Your account was blocked! Please contact your upline immediately";

public String globalAgentUnBlockedTitle = "Account Access Unblocked";
public String globalAgentUnBlockedMessage = "Your account is now actived. Login now! place your bet and have change of big winnings.";

public String GlobalDatetrn = "";
public String GlobalDate = "";
public String GlobalTime = "";
public boolean globalExecuteUpdate = false;
public boolean globalEnableMaintainance = false;

public static final String[] HEADERS_TO_TRY = {
            "X-Forwarded-For",
            "Proxy-Client-IP",
            "WL-Proxy-Client-IP",
            "HTTP_X_FORWARDED_FOR",
            "HTTP_X_FORWARDED",
            "HTTP_X_CLUSTER_CLIENT_IP",
            "HTTP_CLIENT_IP",
            "HTTP_FORWARDED_FOR",
            "HTTP_FORWARDED",
            "HTTP_VIA",
            "REMOTE_ADDR" };
%>

<%
try{
	//ExecuteQuery("SET time_zone = '+08:00'");
	ResultSet rs = null;  
	rs =  SelectQuery("select *, DATE_FORMAT(CURRENT_TIMESTAMP, '%m/%d/%Y') as date_today, " 
					+ " DATE_FORMAT(CURRENT_TIMESTAMP, '%r') as time_today, " 
					+ " date_format(current_timestamp, '%M %d, %y %r') as datetrn from tblgeneralsettings");
	while(rs.next()){
		globalExecuteUpdate = rs.getBoolean("execute_update");
		globalEnableMaintainance = rs.getBoolean("under_maintenance");
		GlobalCompanyName = rs.getString("companyname");
		GlobalCompanyShortname = rs.getString("shortname");
		GlobalCompanyWebsite = rs.getString("website");
		GlobalCompanyEmail = rs.getString("email");
		GlobalCompanyMobile = rs.getString("mobile");
		GlobalDefaultOperator = rs.getString("defaultoperator");

		GlobalEnvironment = rs.getString("environment");
		GlobalHostDirectory = rs.getString("hostdirectory");

		GlobalFightCommission = rs.getDouble("fight_commission");
		
		globalFirebaseMode = rs.getString("firebasemode");
		globalFirebaseApi = rs.getString("firebaseapi");
		globalFirebaseDB = rs.getString("firebasedb");
		globalFirebaseAuth = rs.getString("firebaseauth");
        globalFirebaseName = rs.getString("firebasename");
        globalFirebaseToken = rs.getString("firebasetoken");
        globalFirebaseURL = "https://fcm.googleapis.com/v1/projects/"+globalFirebaseName+"/messages:send";

		globalPusherAppID = rs.getString("pusher_app_id");
		globalPusherAppKey = rs.getString("pusher_app_key");
		globalPusherAppSecret = rs.getString("pusher_app_secret");
		globalPusherAppCluster = rs.getString("pusher_app_cluster");
		globalPusherAppChannel = rs.getString("pusher_app_channel");


		GlobalDatetrn = rs.getString("datetrn");
		GlobalDate = rs.getString("date_today");
		GlobalTime = rs.getString("time_today");

		GlobalHostName = rs.getString("hostprotocol") + request.getServerName();
	}
	rs.close();

	pusher = new Pusher(globalPusherAppID, globalPusherAppKey, globalPusherAppSecret);
    pusher.setCluster(globalPusherAppCluster);
    pusher.setEncrypted(true);
	
	if(globalExecuteUpdate){
		ExecuteDatabaseUpgrade();
	}

}catch(SQLException e){
	logError("db-sql-exception", e.toString());
}catch(Exception e){
	logError("db-runtime-exception", e.toString());
	throw e;
}
%>