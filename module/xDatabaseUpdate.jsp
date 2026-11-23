<%!public void ExecuteDatabaseUpgrade() {
    try {
        String updateVersion = "";
         
    }catch(Exception e){
        logError("ExecuteDatabaseUpgrade",e.toString());
    }
}
%>

<%!public void ExecuteUpdateDB(String nVersions, String strQuery) {
    ExecuteQuery(strQuery);
    ExecuteQuery("insert into tblupdatelogs set databaseversion='" + nVersions + "',dateupdate=current_timestamp,appliedquery='" + rchar(strQuery) + "'");
}
%>