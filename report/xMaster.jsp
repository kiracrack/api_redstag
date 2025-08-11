<%@ page import="java.io.*,java.sql.*,java.util.*,java.text.*,javax.mail.*,java.text.SimpleDateFormat,java.net.URL,java.sql.Timestamp,java.util.Date" %>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.parser.JSONParser"%>
<%@ page import="org.json.simple.parser.ParseException"%>
<%@page pageEncoding="UTF-8"%>

<html>
<head></head>
<meta name="viewport" content="width=device-width, initial-scale=1" />
<script type="text/javascript" src="js/tree/jquery-1.9.1.min.js"></script>
<script type="text/javascript" src="js/tree/jquery.treetable-ajax-persist.js"></script>
<script type="text/javascript" src="js/tree/jquery.treetable-3.0.0.js"></script>
<script type="text/javascript" src="js/tree/persist-min.js"></script>
<link href="js/tree/jquery.treetable.css" media="all" rel="stylesheet" type="text/css" />
<script type="text/javascript">
$(document).ready(function(){
	$("table").agikiTreeTable({persist: true, persistStoreName: "account"});
	$("table").treetable('collapseAll');
	//$("table").treetable('expandAll');
});
</script>
<style type="text/css">
	body{
		background-color:transparent;
		font-family: "Helvetica";
		color: #6b6b6b;
	}

	table {
	  border-collapse: collapse;
	  width: 100%;
	  font-size: 3vw;
	}

	th{
		border: 1px solid #ddd;
	  	padding: 5px;
		
	}

	td{
	  	padding: 0px 3px;
	   	border: 1px solid #ddd;
	}

	/*
	tr:nth-child(even){background-color: #f2f2f2}
	tr:nth-child(odd){background-color: #ffffff}
	*/

	tr td:nth-of-type(2) {
	 text-align:center;
	}
	tr td:nth-of-type(3) {
	 text-align:right;
	}

	th:nth-of-type(1) {
	  background-color: #ff9600;
	  color: white;
	  text-align:left;
	}
	th:nth-of-type(2) {
	  background-color: #ff9600;
	  color: white;
	  text-align:center;
	}
	th:nth-of-type(3) {
	  background-color: #ff9600;
	  color: white;
	  text-align:right;
	}
</style>
<body>
	<table>
		<thead>
			<th>ACCOUNT NAME</th>
			<th>DOWNLINE</th>
			<th>SCORE</th>
			<th>WIN/LOSS</th>
		</thead>
		<tbody>
			<%
				try{
					ResultSet rst = null;  
					rst =  SelectRepo("select *, total, (select commissionrate from  tblsubscriber where accountid=a.accountid) as commissionrate, "
									+ " if(ismasteragent, (select count(*) - 1 from tblsubscriber where masteragentid=a.accountid), (select count(*) from tblsubscriber where agentid=a.accountid)) as downline " 
									+ " from tblscorereport as a where query_by='"+query_by+"'");
					while(rst.next()){
						String agentid = rst.getString("agentid");
						String accountid = rst.getString("accountid");
						String fullname = rst.getString("fullname");
						
						int downline = rst.getInt("downline");
						int commission = rst.getInt("commissionrate");
						double creditbal = rst.getDouble("creditbal");
						double winloss = rst.getDouble("total");
						boolean ismasteragent = rst.getBoolean("ismasteragent");
						
						String downline_tag = (downline > 0 ? downline + "" : "" );
						String winloss_tag = (winloss < 0 ? "<font color=red>" + FormatCurrency(String.valueOf(winloss)) + "</font>" :  (winloss > 0 ? "<font color=green>+" + FormatCurrency(String.valueOf(winloss)) + "</font>" : ""));
						String commission_tag = (commission > 0 ? "<font style='color:#ff9600'> ("+commission+"%)</font>" : "");
						if(ismasteragent){
							out.print("<tr " + (downline > 0 ? "style='background-color: #f2f2f2'" : "" )+ " data-tt-id='"+ accountid +"'><td>"+ fullname + commission_tag + "</td><td>"+downline_tag+"</td><td>"+winloss_tag+"</td></tr>");
						}else{
							out.print("<tr " + (downline > 0 ? "style='background-color: #f2f2f2'" : "" )+ " data-tt-id='"+ accountid +"' data-tt-parent-id='"+ agentid +"'><td>"+fullname + commission_tag + "</td><td>"+downline_tag+"</td><td>"+winloss_tag+"</td></tr>");
						}
					}
					rst.close();
				}catch (Exception e){
					out.print(e.getMessage());
				}
			%>
		</tbody>
	</table>
</body>
</html>

<%!public String FormatCurrency(String number) {
    double amount = Double.parseDouble(number);
    DecimalFormat formatter = new DecimalFormat("#,###.00");
    return formatter.format(amount);
  }
%>