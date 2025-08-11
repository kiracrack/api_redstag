<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>

<%
   JSONObject mainObj =new JSONObject();
try{

    String x = Decrypt(request.getParameter("x"));
    String sessionid = request.getParameter("sessionid");

    if(x.equals("open_game")){
        if(!isSessionAvailable(sessionid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Game session expired");
            out.print(mainObj);
            return;
        }

        mainObj.put("status", "OK");
        mainObj = LoadGameSession(mainObj, sessionid);
        mainObj.put("message", "response valid");
        out.print(mainObj);
    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
    }

}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("app-x-play",e.getMessage());
}
%>
 
<%!public boolean isSessionAvailable(String sessionid) {
    return CountQry("tblgamesession", "gamesession='"+sessionid+"'") > 0;
  }
%>

<%!public JSONObject LoadGameSession(JSONObject mainObj, String sessionid) {
    mainObj = DBtoJson(mainObj, "select gameurl from tblgamesession where gamesession='"+sessionid+"'");
    return mainObj;
 }
 %>