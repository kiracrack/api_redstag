
<%!
    public String globalPassKey = "my.ph";
%>

<%!public String Encrypt(String text) throws Exception {
	try{
        String encrypted = new String();
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        byte[] keyBytes = new byte[16];
        byte[] b = globalPassKey.getBytes("UTF-8");
        int len = b.length;
        if (len > keyBytes.length)
            len = keyBytes.length;
        System.arraycopy(b, 0, keyBytes, 0, len);
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(keyBytes);
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec);

        byte[] results = cipher.doFinal(text.getBytes("UTF-8"));
        String base64 = Base64.getEncoder().encodeToString(results);
        encrypted = base64;
        return encrypted;

     } catch(IOException e) {
	   return "";
	}
}%>
 
 <%!public String Decrypt(String text) throws Exception {
 	try{
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding"); 
        byte[] keyBytes = new byte[16];
        byte[] b = globalPassKey.getBytes("UTF-8");
        int len = b.length;
        if (len > keyBytes.length)
            len = keyBytes.length;
        System.arraycopy(b, 0, keyBytes, 0, len);
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(keyBytes);
        cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);

        byte[] results = new byte[text.length()];

        byte[] tmp2 = Base64.getDecoder().decode(text); 
        results = cipher.doFinal(tmp2);

        return new String(results, "UTF-8");
	} catch(Exception e) {
	   return "";
	}
 }
%>

<%!public boolean isEncrypted(String text) throws Exception {
 	try{
        Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
        byte[] keyBytes = new byte[16];
        byte[] b = globalPassKey.getBytes("UTF-8");
        int len = b.length;
        if (len > keyBytes.length)
            len = keyBytes.length;
        System.arraycopy(b, 0, keyBytes, 0, len);
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
        IvParameterSpec ivSpec = new IvParameterSpec(keyBytes);
        cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec);
        byte[] results = new byte[text.length()];
        byte[] tmp2 = Base64.getDecoder().decode(text); 
        results = cipher.doFinal(tmp2);
        return true;

	} catch(Exception e) {
	   return false;
	}
 }
%>

<%!public class JwtVerification{
    public boolean valid;
    public String message;

    public JwtVerification(String token, String ipaddress, String api_file){
        JwtUtil jwtUtil = new JwtUtil();
        if(token == null){
            this.valid = false;
            this.message = globalJwtTokenInvalid; 
            logErrorToken(api_file, "blank_token", ipaddress, "null");
      
        }else if (!jwtUtil.validateToken(token)) {
            this.valid = false;
            switch(jwtUtil.error_code) {
                case "EXPIRED":
                    this.message = globalJwtTokenInvalid; 
                    logErrorToken(api_file, "expire_token", ipaddress, token);
                    break;

                case "TAMPERED":
                    this.message = globalJwtTokenInvalid; 
                    logErrorToken(api_file, "tempered_token", ipaddress, token);
                    break;

                default:
                    this.message = globalJwtTokenInvalid; 
                    logErrorToken(api_file, "invalid_token", ipaddress, token);
                    break;
            }
        }else{
            this.valid = true;
            this.message = "";
        }
    }
}%>

<%!public boolean hasMaliciousData(String api_file, HttpServletRequest request, String ipAddress) {
    for (Map.Entry<String, String[]> entry : request.getParameterMap().entrySet()) {
        String paramName = entry.getKey();
        for (String value : entry.getValue()) {
            if (isMaliciousString(value)) {
                logError(api_file, "malicious-param: ip " + ipAddress + " / " + paramName + "=" + value);
                return true;
            }
        }
    }
    return false;
}
%>

<%!public String getIpAddress(HttpServletRequest request) {
    String ipaddress = request.getParameter("ipaddress");
    return (ipaddress == null || ipaddress.isEmpty() || ipaddress.equals("null") ? getClientIp(request) : ipaddress);
}
%>

<%!public String getClientIp(HttpServletRequest request) {
    String ip = request.getHeader("X-Forwarded-For");
    if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
        ip = request.getHeader("X-Real-IP");
    }

    if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
        ip = request.getRemoteAddr();
    }

    // X-Forwarded-For may contain multiple IPs
    if (ip != null && ip.contains(",")) {
        ip = ip.split(",")[0].trim();
    }
    return ip;
}
%>

<%!public boolean isMaliciousString(String str) {
    if (str == null || str.trim().isEmpty()) {
        return false;
    }

    // allow Firebase token queries
    if (str.contains("ya29.c.c0AZ4bNp")) {
        return false;
    }

    String s = str.toLowerCase().trim();
    return s.contains("union select")
            || s.contains("sleep(")
            || s.contains("benchmark(")
            || s.contains("information_schema")
            || s.contains("mysql.db")
            || s.contains("mysql.user")
            || s.contains("load_file(")
            || s.contains("into outfile")
            || s.contains("waitfor delay")
            || s.contains("hex(cast(")
            || s.contains("xp_cmdshell")
            || s.contains("or 1=1")
            || s.contains("' or '")
            || s.contains("\" or \"")
            || s.contains("/*")
            || s.contains("*/")
            || s.contains("--") 
            || s.contains(",null,null,null")
            || s.matches("(?is).*\\binsert\\s+into\\b.*")
            || s.matches("(?is).*\\bupdate\\s+\\w+\\s+set\\b.*")
            || s.matches("(?is).*\\bdelete\\s+from\\b.*")
            || s.matches("(?is).*\\bselect\\s+.*\\bfrom\\b.*");
}
%>

<%!public JSONObject error_token_authorization(JSONObject mainObj, String message) {
    mainObj.put("status", "ERROR");
    mainObj.put("message", message);
    mainObj.put("errorcode", "session");
    return mainObj;
}%>

<%!public JSONObject error_token_controller(JSONObject mainObj, String message) {
    mainObj.put("status", "UNAUTHORIZED");
    mainObj.put("message", message);
    mainObj.put("errorcode", "session");
    return mainObj;
}%>

<%!public JSONObject error_invalid_request(JSONObject mainObj) {
    mainObj.put("status", "ERROR");
    mainObj.put("message", "bad request: request not valid");
    mainObj.put("errorcode", "400");
    return mainObj;
}%>

<%!public JSONObject error_exception(JSONObject mainObj) {
    mainObj.put("status", "ERROR");
    mainObj.put("message", "error exeception");
    mainObj.put("errorcode", "400");
    return mainObj;
}%>

<%!public JSONObject error_system_maintenance(JSONObject mainObj) {
    mainObj.put("status", "ERROR");
    mainObj.put("message", globalMaintainanceMessage);
    mainObj.put("errorcode", "maintenance");
    return mainObj;
}%>

<%!public JSONObject error_session_expired(JSONObject mainObj) {
    mainObj.put("status", "ERROR");
	mainObj.put("message", globalExpiredSessionMessage);
    mainObj.put("errorcode", "session");
    return mainObj;
}%>

<%!public JSONObject error_admin_blocked(JSONObject mainObj) {
    mainObj.put("status", "ERROR");
    mainObj.put("message", globalAdminAccountBlocked);
    mainObj.put("errorcode", "blocked");
    return mainObj;
}%>

<%!public JSONObject error_admin_session(JSONObject mainObj) {
     mainObj.put("status", "ERROR");
    mainObj.put("message", globalExpiredSessionMessageDashboard);
    mainObj.put("errorcode", "session");
    return mainObj;
}%>

<%!public JSONObject error_controller_removed(JSONObject mainObj) {
    mainObj.put("status", "BLOCKED");
    mainObj.put("message","Your controller was removed by administrator!");
    mainObj.put("errorcode", "blocked"); 
    return mainObj;
}%>

<%!public JSONObject error_controller_blocked(JSONObject mainObj) {
    mainObj.put("status", "BLOCKED");
    mainObj.put("message","Your controller was blocked by administrator!");
    mainObj.put("errorcode", "100");
    return mainObj;
}%>


<%!public JSONObject error_api_parameter(JSONObject mainObj) {
    mainObj.put("status", "BLOCKED");
    mainObj.put("message","bad request, missing parameter");
    mainObj.put("errorcode", "100");
    return mainObj;
}%>