<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xWebModule.jsp" %>
<%@ include file="../module/xGameModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xCasinoClass.jsp" %>
<%@ include file="../module/xCasinoModule.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>

<%
   JSONObject mainObj = new JSONObject();
try{
    long unixTimestamp = Instant.now().getEpochSecond();
    out.print(unixTimestamp);
    //out.print(generateMD5Hash("GameLogin", CurrentDateTime(), "mg5redstagMYR", "TTR4D8P2MGL79OUG", ""));

}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
     
}
%>
 
<%!public String generateMD5Hash(String functionName, String formattedDate, String operatorId, String secretKey, String playerId) throws NoSuchAlgorithmException {
    String stringToHash = functionName + formattedDate + operatorId + secretKey + playerId;
    MessageDigest md = MessageDigest.getInstance("MD5");
    byte[] bytes = md.digest(stringToHash.getBytes());
    StringBuilder result = new StringBuilder();
    for (byte b : bytes) {
        result.append(String.format("%02x", b));
    }
    return result.toString();
  }
%>
