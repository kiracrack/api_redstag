<%-- select command executor --%>
<%!public ResultSet SelectQuery(String command) {
    Random rand = new Random();
    int method1 =  rand.nextInt(10 - 1) + 1;
	int method2 =  rand.nextInt(10 - 1) + 1;

	 if(method1 % 2 == 0){
		if(method2 % 2 == 0){
			return SelectQuery1(command);
		}else{
			return SelectQuery2(command);
		}
	 }else{
		if(method2 % 2 == 0){
			return SelectQuery3(command);
		}else{
			return SelectQuery4(command);
		}
	 }
 }
 %>

<%!public ResultSet SelectQuery1(String command) {
    ResultSet i = null;
    try {
		redstag_query class_select_conn1 = new redstag_query();
		class_select_conn1.disconnect();
		Statement select_stat1 = null; if(select_stat1 != null) select_stat1.close();
		Connection select_conn1 = null;
		ResultSet select_res1 = null;
		select_conn1 = class_select_conn1.connect();
        select_stat1 = select_conn1.createStatement();
      	select_res1 =  select_stat1.executeQuery(command);
		i = select_res1;
	}catch(SQLException e){
		logError("select1-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		logError("select1-runtime-exception", e.toString() + "("+command+")");
		throw e;
	}
	return i;
 }
 %>

<%!public ResultSet SelectQuery2(String command) {
    ResultSet i = null;
    try {
		redstag_query class_select_conn2 = new redstag_query();
		class_select_conn2.disconnect();
		Statement select_stat2 = null; if(select_stat2 != null) select_stat2.close();
		Connection select_conn2 = null;
		ResultSet select_res2 = null;
		select_conn2 = class_select_conn2.connect();
        select_stat2 = select_conn2.createStatement();
      	select_res2 =  select_stat2.executeQuery(command);
		i = select_res2;
	}catch(SQLException e){
		logError("select2-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		logError("select2-runtime-exception", e.toString() + "("+command+")");
		throw e;
	}
	return i;
 }
 %>

<%!public ResultSet SelectQuery3(String command) {
    ResultSet i = null;
    try {
		redstag_query class_select_conn3 = new redstag_query();
		class_select_conn3.disconnect();
		Statement select_stat3 = null; if(select_stat3 != null) select_stat3.close();
		Connection select_conn3 = null;
		ResultSet select_res3 = null;
		select_conn3 = class_select_conn3.connect();
        select_stat3 = select_conn3.createStatement();
      	select_res3 =  select_stat3.executeQuery(command);
		i = select_res3;
	}catch(SQLException e){
		logError("select3-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		logError("select3-runtime-exception", e.toString() + "("+command+")");
		throw e;
	}
	return i;
 }
 %>

<%!public ResultSet SelectQuery4(String command) {
    ResultSet i = null;
    try {
		redstag_query class_select_conn4 = new redstag_query();
		class_select_conn4.disconnect();
		Statement select_stat4 = null; if(select_stat4 != null) select_stat4.close();
		Connection select_conn4 = null;
		ResultSet select_res4 = null;
		select_conn4 = class_select_conn4.connect();
        select_stat4 = select_conn4.createStatement();
      	select_res4 =  select_stat4.executeQuery(command);
		i = select_res4;
	}catch(SQLException e){
		logError("select4-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		logError("select4-runtime-exception", e.toString() + "("+command+")");
		throw e;
	}
	return i;
 }
 %>
<%-- endregion --%>

<%-- select command executor 2 --%>
<%!public ResultSet QuerySelect(String command) {
    Random rand = new Random();
    int method1 =  rand.nextInt(10 - 1) + 1;
	int method2 =  rand.nextInt(10 - 1) + 1;

	 if(method1 % 2 == 0){
		if(method2 % 2 == 0){
			return QuerySelect1(command);
		}else{
			return QuerySelect2(command);
		}
	 }else{
		if(method2 % 2 == 0){
			return QuerySelect3(command);
		}else{
			return QuerySelect4(command);
		}
	 }
 }
 %>

<%!public ResultSet QuerySelect1(String command) {
    ResultSet i = null;
    try {
		redstag_query select_class_conn1 = new redstag_query();
		select_class_conn1.disconnect();
		Statement stat_select1 = null; if(stat_select1 != null) stat_select1.close();
		Connection conn_select1 = null;
		ResultSet res_select1 = null;
		conn_select1 = select_class_conn1.connect();
        stat_select1 = conn_select1.createStatement();
      	res_select1 =  stat_select1.executeQuery(command);
		i = res_select1;
	}catch(SQLException e){
		logError("select1-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		logError("select1-runtime-exception", e.toString() + "("+command+")");
		throw e;
	}
	return i;
 }
 %>

<%!public ResultSet QuerySelect2(String command) {
    ResultSet i = null;
    try {
		redstag_query select_class_conn2 = new redstag_query();
		select_class_conn2.disconnect();
		Statement stat_select2 = null; if(stat_select2 != null) stat_select2.close();
		Connection conn_select2 = null;
		ResultSet res_select2 = null;
		conn_select2 = select_class_conn2.connect();
        stat_select2 = conn_select2.createStatement();
      	res_select2 =  stat_select2.executeQuery(command);
		i = res_select2;
	}catch(SQLException e){
		logError("select2-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		logError("select2-runtime-exception", e.toString() + "("+command+")");
		throw e;
	}
	return i;
 }
 %>

<%!public ResultSet QuerySelect3(String command) {
    ResultSet i = null;
    try {
		redstag_query select_class_conn3 = new redstag_query();
		select_class_conn3.disconnect();
		Statement stat_select3 = null; if(stat_select3 != null) stat_select3.close();
		Connection conn_select3 = null;
		ResultSet res_select3 = null;
		conn_select3 = select_class_conn3.connect();
        stat_select3 = conn_select3.createStatement();
      	res_select3 =  stat_select3.executeQuery(command);
		i = res_select3;
	}catch(SQLException e){
		logError("select3-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		logError("select3-runtime-exception", e.toString() + "("+command+")");
		throw e;
	}
	return i;
 }
 %>

<%!public ResultSet QuerySelect4(String command) {
    ResultSet i = null;
    try {
		redstag_query select_class_conn4 = new redstag_query();
		select_class_conn4.disconnect();
		Statement stat_select4 = null; if(stat_select4 != null) stat_select4.close();
		Connection conn_select4 = null;
		ResultSet res_select4 = null;
		conn_select4 = select_class_conn4.connect();
        stat_select4 = conn_select4.createStatement();
      	res_select4 =  stat_select4.executeQuery(command);
		i = res_select4;
	}catch(SQLException e){
		logError("select4-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		logError("select4-runtime-exception", e.toString() + "("+command+")");
		throw e;
	}
	return i;
 }
 %>


<%-- endregion --%>

<%-- execute random --%>
<%!public void ExecuteRandom(String command, Connection conn,  Statement stmt) {
    try {
		redstag_execute db = new redstag_execute();
		db.disconnect();
		conn = db.connect();
		stmt = conn.createStatement();
		stmt.executeUpdate(command);
	}catch(SQLException e){
		logError("ExecuteRandom", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteReport(command);
		logError("ExecuteRandom", e.toString() + "("+command+")");
	}
 }
 %>
<%-- endregion --%>

<%-- normal command executor --%>
<%!public void ExecuteQuery(String command) {
    Random rand = new Random();
    int method1 =  rand.nextInt(10 - 1) + 1;
	int method2 =  rand.nextInt(10 - 1) + 1;

	 if(method1 % 2 == 0){
		if(method2 % 2 == 0){
			ExecuteQuery1(command);
		}else{
			ExecuteQuery2(command);
		}
	 }else{
		if(method2 % 2 == 0){
			ExecuteQuery3(command);
		}else{
			ExecuteQuery4(command);
		}
	 }
 }
 %>

<%!public void ExecuteQuery1(String command) {
    try {
		redstag_execute class_query_conn1 = new redstag_execute();
		class_query_conn1.disconnect();
		Statement query_stat1 = null;
		Connection query_conn1 = null;
		query_conn1 = class_query_conn1.connect();
		query_stat1 = query_conn1.createStatement();
		query_stat1.executeUpdate(command);
	}catch(SQLException e){
		logError("normal1-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteQuery(command);
		logError("normal1-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>
<%!public void ExecuteQuery2(String command) {
    try {
		redstag_execute class_query_conn2 = new redstag_execute();
		class_query_conn2.disconnect();
		Statement query_stat2 = null;
		Connection query_conn2 = null;
		query_conn2 = class_query_conn2.connect();
		query_stat2 = query_conn2.createStatement();
		query_stat2.executeUpdate(command);
	}catch(SQLException e){
		logError("normal2-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteQuery(command);
		logError("normal2-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>
<%!public void ExecuteQuery3(String command) {
    try {
		redstag_execute class_query_conn3 = new redstag_execute();
		class_query_conn3.disconnect();
		Statement query_stat3 = null;
		Connection query_conn3 = null;
		query_conn3 = class_query_conn3.connect();
		query_stat3 = query_conn3.createStatement();
		query_stat3.executeUpdate(command);
	}catch(SQLException e){
		logError("normal3-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteQuery(command);
		logError("normal3-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>
<%!public void ExecuteQuery4(String command) {
    try {
		redstag_execute class_query_conn4 = new redstag_execute();
		class_query_conn4.disconnect();
		Statement query_stat4 = null;
		Connection query_conn4 = null;
		query_conn4 = class_query_conn4.connect();
		query_stat4 = query_conn4.createStatement();
		query_stat4.executeUpdate(command);
	}catch(SQLException e){
		logError("normal4-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteQuery(command);
		logError("normal4-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>
<%-- endregion --%>

<%-- dummy command executor --%>
<%!public void ExecuteDummy(String command) {
    Random rand = new Random();
    int method1 =  rand.nextInt(10 - 1) + 1;
	int method2 =  rand.nextInt(10 - 1) + 1;

	 if(method1 % 2 == 0){
		if(method2 % 2 == 0){
			ExecuteDummy1(command);
		}else{
			ExecuteDummy2(command);
		}
	 }else{
		if(method2 % 2 == 0){
			ExecuteDummy3(command);
		}else{
			ExecuteDummy4(command);
		}
	 }
 }
 %>
<%!public void ExecuteDummy1(String command) {
    try {
		redstag_dummy class_dummy_conn1 = new redstag_dummy();
		class_dummy_conn1.disconnect();
		Statement dummy_stat1 = null;
		Connection dummy_conn1 = null;
		dummy_conn1 = class_dummy_conn1.connect();
		dummy_stat1 = dummy_conn1.createStatement();
		dummy_stat1.executeUpdate(command);
	}catch(SQLException e){
		logError("dummy1-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteDummy(command);
		logError("dummy1-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteDummy2(String command) {
    try {
		redstag_dummy class_dummy_conn2 = new redstag_dummy();
		class_dummy_conn2.disconnect();
		Statement dummy_stat2 = null;
		Connection dummy_conn2 = null;
		dummy_conn2 = class_dummy_conn2.connect();
		dummy_stat2 = dummy_conn2.createStatement();
		dummy_stat2.executeUpdate(command);
	}catch(SQLException e){
		logError("dummy2-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteDummy(command);
		logError("dummy2-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteDummy3(String command) {
    try {
		redstag_dummy class_dummy_conn3 = new redstag_dummy();
		class_dummy_conn3.disconnect();
		Statement dummy_stat3 = null;
		Connection dummy_conn3 = null;
		dummy_conn3 = class_dummy_conn3.connect();
		dummy_stat3 = dummy_conn3.createStatement();
		dummy_stat3.executeUpdate(command);
	}catch(SQLException e){
		logError("dummy3-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteDummy(command);
		logError("dummy3-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteDummy4(String command) {
    try {
		redstag_dummy class_dummy_conn4 = new redstag_dummy();
		class_dummy_conn4.disconnect();
		Statement dummy_stat4 = null;
		Connection dummy_conn4 = null;
		dummy_conn4 = class_dummy_conn4.connect();
		dummy_stat4 = dummy_conn4.createStatement();
		dummy_stat4.executeUpdate(command);
	}catch(SQLException e){
		logError("dummy4-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteDummy(command);
		logError("dummy4-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%-- endregion --%>

<%-- bet command executor --%>
<%!public void ExecuteBet(String command) {
    Random rand = new Random();
    int method1 =  rand.nextInt(10 - 1) + 1;
	int method2 =  rand.nextInt(10 - 1) + 1;

	 if(method1 % 2 == 0){
		if(method2 % 2 == 0){
			ExecuteBet1(command);
		}else{
			ExecuteBet2(command);
		}
	 }else{
		if(method2 % 2 == 0){
			ExecuteBet3(command);
		}else{
			ExecuteBet4(command);
		}
	 }
 }
 %>
<%!public void ExecuteBet1(String command) {
    try {
		redstag_bet class_bet_conn1 = new redstag_bet();
		class_bet_conn1.disconnect();
		Statement bet_stat1 = null;
		Connection bet_conn1 = null;
		bet_conn1 = class_bet_conn1.connect();
		bet_stat1 = bet_conn1.createStatement();
		bet_stat1.executeUpdate(command);
	}catch(SQLException e){
		logError("bet1-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteBet(command);
		logError("bet1-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteBet2(String command) {
    try {
		redstag_bet class_bet_conn2 = new redstag_bet();
		class_bet_conn2.disconnect();
		Statement bet_stat2 = null;
		Connection bet_conn2 = null;
		bet_conn2 = class_bet_conn2.connect();
		bet_stat2 = bet_conn2.createStatement();
		bet_stat2.executeUpdate(command);
	}catch(SQLException e){
		logError("bet2-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteBet(command);
		logError("bet2-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteBet3(String command) {
    try {
		redstag_bet class_bet_conn3 = new redstag_bet();
		class_bet_conn3.disconnect();
		Statement bet_stat3 = null;
		Connection bet_conn3 = null;
		bet_conn3 = class_bet_conn3.connect();
		bet_stat3 = bet_conn3.createStatement();
		bet_stat3.executeUpdate(command);
	}catch(SQLException e){
		logError("bet3-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteBet(command);
		logError("bet3-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteBet4(String command) {
    try {
		redstag_bet class_bet_conn4 = new redstag_bet();
		class_bet_conn4.disconnect();
		Statement bet_stat4 = null;
		Connection bet_conn4 = null;
		bet_conn4 = class_bet_conn4.connect();
		bet_stat4 = bet_conn4.createStatement();
		bet_stat4.executeUpdate(command);
	}catch(SQLException e){
		logError("bet4-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteBet(command);
		logError("bet4-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%-- endregion --%>

<%-- result command executor --%>
<%!public void ExecuteResult(String command) {
    Random rand = new Random();
    int method1 =  rand.nextInt(10 - 1) + 1;
	int method2 =  rand.nextInt(10 - 1) + 1;

	 if(method1 % 2 == 0){
		if(method2 % 2 == 0){
			ExecuteResult1(command);
		}else{
			ExecuteResult2(command);
		}
	 }else{
		if(method2 % 2 == 0){
			ExecuteResult3(command);
		}else{
			ExecuteResult4(command);
		}
	 }
 }
 %>
<%!public void ExecuteResult1(String command) {
    try {
		redstag_result class_Result_conn1 = new redstag_result();
		class_Result_conn1.disconnect();
		Statement Result_stat1 = null;
		Connection Result_conn1 = null;
		Result_conn1 = class_Result_conn1.connect();
		Result_stat1 = Result_conn1.createStatement();
		Result_stat1.executeUpdate(command);
	}catch(SQLException e){
		logError("Result1-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteResult(command);
		logError("Result1-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteResult2(String command) {
    try {
		redstag_result class_Result_conn2 = new redstag_result();
		class_Result_conn2.disconnect();
		Statement Result_stat2 = null;
		Connection Result_conn2 = null;
		Result_conn2 = class_Result_conn2.connect();
		Result_stat2 = Result_conn2.createStatement();
		Result_stat2.executeUpdate(command);
	}catch(SQLException e){
		logError("Result2-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteResult(command);
		logError("Result2-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteResult3(String command) {
    try {
		redstag_result class_Result_conn3 = new redstag_result();
		class_Result_conn3.disconnect();
		Statement Result_stat3 = null;
		Connection Result_conn3 = null;
		Result_conn3 = class_Result_conn3.connect();
		Result_stat3 = Result_conn3.createStatement();
		Result_stat3.executeUpdate(command);
	}catch(SQLException e){
		logError("Result3-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteResult(command);
		logError("Result3-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteResult4(String command) {
    try {
		redstag_result class_Result_conn4 = new redstag_result();
		class_Result_conn4.disconnect();
		Statement Result_stat4 = null;
		Connection Result_conn4 = null;
		Result_conn4 = class_Result_conn4.connect();
		Result_stat4 = Result_conn4.createStatement();
		Result_stat4.executeUpdate(command);
	}catch(SQLException e){
		logError("Result4-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteResult(command);
		logError("Result4-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%-- endregion --%>

<%-- ledger command executor --%>
<%!public void ExecuteLedger(String command) {
    Random rand = new Random();
    int method1 =  rand.nextInt(10 - 1) + 1;
	int method2 =  rand.nextInt(10 - 1) + 1;

	 if(method1 % 2 == 0){
		if(method2 % 2 == 0){
			ExecuteLedger1(command);
		}else{
			ExecuteLedger2(command);
		}
	 }else{
		if(method2 % 2 == 0){
			ExecuteLedger3(command);
		}else{
			ExecuteLedger4(command);
		}
	 }
 }
 %>
<%!public void ExecuteLedger1(String command) {
    try {
		redstag_ledger class_Ledger_conn1 = new redstag_ledger();
		class_Ledger_conn1.disconnect();
		Statement Ledger_stat1 = null;
		Connection Ledger_conn1 = null;
		Ledger_conn1 = class_Ledger_conn1.connect();
		Ledger_stat1 = Ledger_conn1.createStatement();
		Ledger_stat1.executeUpdate(command);
	}catch(SQLException e){
		logError("Ledger1-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteLedger(command);
		logError("Ledger1-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteLedger2(String command) {
    try {
		redstag_ledger class_Ledger_conn2 = new redstag_ledger();
		class_Ledger_conn2.disconnect();
		Statement Ledger_stat2 = null;
		Connection Ledger_conn2 = null;
		Ledger_conn2 = class_Ledger_conn2.connect();
		Ledger_stat2 = Ledger_conn2.createStatement();
		Ledger_stat2.executeUpdate(command);
	}catch(SQLException e){
		logError("Ledger2-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteLedger(command);
		logError("Ledger2-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteLedger3(String command) {
    try {
		redstag_ledger class_Ledger_conn3 = new redstag_ledger();
		class_Ledger_conn3.disconnect();
		Statement Ledger_stat3 = null;
		Connection Ledger_conn3 = null;
		Ledger_conn3 = class_Ledger_conn3.connect();
		Ledger_stat3 = Ledger_conn3.createStatement();
		Ledger_stat3.executeUpdate(command);
	}catch(SQLException e){
		logError("Ledger3-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteLedger(command);
		logError("Ledger3-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteLedger4(String command) {
    try {
		redstag_ledger class_Ledger_conn4 = new redstag_ledger();
		class_Ledger_conn4.disconnect();
		Statement Ledger_stat4 = null;
		Connection Ledger_conn4 = null;
		Ledger_conn4 = class_Ledger_conn4.connect();
		Ledger_stat4 = Ledger_conn4.createStatement();
		Ledger_stat4.executeUpdate(command);
	}catch(SQLException e){
		logError("Ledger4-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteLedger(command);
		logError("Ledger4-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%-- endregion --%>

<%-- report command executor --%>
<%!public void ExecuteReport(String command) {
    Random rand = new Random();
    int method1 =  rand.nextInt(10 - 1) + 1;
	int method2 =  rand.nextInt(10 - 1) + 1;

	 if(method1 % 2 == 0){
		if(method2 % 2 == 0){
			ExecuteReport1(command);
		}else{
			ExecuteReport2(command);
		}
	 }else{
		if(method2 % 2 == 0){
			ExecuteReport3(command);
		}else{
			ExecuteReport4(command);
		}
	 }
 }
 %>

<%!public void ExecuteReport1(String command) {
    try {
		redstag_report class_Report_conn1 = new redstag_report();
		class_Report_conn1.disconnect();
		Statement Report_stat1 = null;
		Connection Report_conn1 = null;
		Report_conn1 = class_Report_conn1.connect();
		Report_stat1 = Report_conn1.createStatement();
		Report_stat1.executeUpdate(command);
	}catch(SQLException e){
		logError("report1-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteReport(command);
		logError("report1-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteReport2(String command) {
    try {
		redstag_report class_Report_conn2 = new redstag_report();
		class_Report_conn2.disconnect();
		Statement Report_stat2 = null;
		Connection Report_conn2 = null;
		Report_conn2 = class_Report_conn2.connect();
		Report_stat2 = Report_conn2.createStatement();
		Report_stat2.executeUpdate(command);
	}catch(SQLException e){
		logError("report2-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteReport(command);
		logError("report2-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteReport3(String command) {
    try {
		redstag_report class_Report_conn3 = new redstag_report();
		class_Report_conn3.disconnect();
		Statement Report_stat3 = null;
		Connection Report_conn3 = null;
		Report_conn3 = class_Report_conn3.connect();
		Report_stat3 = Report_conn3.createStatement();
		Report_stat3.executeUpdate(command);
	}catch(SQLException e){
		logError("report3-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteReport(command);
		logError("report3-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>

<%!public void ExecuteReport4(String command) {
    try {
		redstag_report class_Report_conn4 = new redstag_report();
		class_Report_conn4.disconnect();
		Statement Report_stat4 = null;
		Connection Report_conn4 = null;
		Report_conn4 = class_Report_conn4.connect();
		Report_stat4 = Report_conn4.createStatement();
		Report_stat4.executeUpdate(command);
	}catch(SQLException e){
		logError("report4-sql-exception", e.toString() + "("+command+")");
	}catch(Exception e){
		ExecuteReport(command);
		logError("report4-executor-exception", e.toString() + "("+command+")");
	}
 }
 %>
  
 
<%-- endregion --%>

<%!public void logError(String module, String message) {
    try {
		redstag_error class_error_conn = new redstag_error();
		class_error_conn.disconnect();
		Statement stat_error = null;
		Connection conn_error = null;
		conn_error = class_error_conn.connect();
		stat_error = conn_error.createStatement();
		stat_error.executeUpdate("insert into tblerrorlogs set module='"+module+"',message='"+rchar(message.toString())+"', datetrn=current_timestamp");
	}catch(Exception e){
		System.out.print(e);
	}
 }
 %>

<%!public int CountRecord(String tbl){
   	int cnt = 0;
    try {
		ResultSet rst_db = null;  
		rst_db =  SelectQuery("select count(*) as cnt from " + tbl);
		while(rst_db.next()){
			cnt = rst_db.getInt("cnt");			
		}rst_db.close();
	}catch(SQLException e){
		logError("CountRecord",e.toString());
	}
    return cnt;
 }
 %>

<%!public int CountQry(String tbl, String cond) {
	int cnt = 0;
	try {
		ResultSet rst_db = null;  
		rst_db =  SelectQuery("select count(*) as cnt from " + tbl + " where " + cond);
		while(rst_db.next()){
			cnt = rst_db.getInt("cnt");			
		}rst_db.close();
	}catch(SQLException e){
		logError("sql-count-query",e.toString());
	}
	return cnt;
	}
 %>

<%!public int DistinctCount(String tbl, String fieldname, String cond) {
   	int cnt = 0;
    try {
		ResultSet rs = null;
		rs =  SelectQuery("select count(distinct "+fieldname+") as cnt from " + tbl + cond);
		while(rs.next()){
			cnt = rs.getInt("cnt");			
		}rs.close();
	}catch(SQLException e){
		logError("sql-distinct-count-query",e.toString());
	}
    return cnt;
	}
 %>

<%!public String QueryDirectData(String columnname, String tbl) {
   	String val = "0";
    try {
		ResultSet rs = null;
		rs =  SelectQuery("select "+columnname+" from " + tbl);
		while(rs.next()){
			val = rs.getString(columnname);			
		}rs.close();
	}catch(SQLException e){
		logError("sql-query-direct-data",e.toString());
	}
    return val;
	}
 %>


<%!public String QuerySingleData(String columnqry, String columnname, String tbl) {
   	String val = "";
    try {
		ResultSet rst_db = null;  
		rst_db =  SelectQuery("select "+columnqry+" as "+columnname+" from " + tbl);
		while(rst_db.next()){
				val = rst_db.getString(columnname);			
		}rst_db.close();
		
	}catch(SQLException e){
		logError("sql-query-single-data",e.toString());
	}
    return val;
  }
 %>

<%!public String rchar(String str){ 
    str = str.replace("'", "''");
	str = str.replace("\\", "\\\\");
    return str;
	}
 %>
