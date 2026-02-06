<%!public void SendOTP(String appreference, String mobilenumber, String otpcode, String message){          
    try {
        Thread smsTread = new Thread(new SmsTask(appreference, mobilenumber, otpcode, message));
        smsTread.start();
    } catch (Exception e) {
        e.printStackTrace();
    }
}
 %>

<%!public class SmsTask implements Runnable {
    private String appreference, mobilenumber, otpcode, message;

    public SmsTask(String appreference, String mobilenumber, String otpcode, String message) {
        this.appreference = appreference;
        this.mobilenumber = mobilenumber;
        this.otpcode = otpcode;
        this.message = message;
    }
    public void run() {
        SendQueue(appreference, mobilenumber, otpcode, message);
    }
 }
 %>

 

<%!public void SendQueue(String appreference, String mobilenumber, String otpcode, String message){          
    try {
        URL url = new URL("https://redstagarena.com/sms.php");
        Map<String,Object> params = new LinkedHashMap<>();
        params.put("api_key", "462_cgK9xSn13WIuIX1oDK_kPPcQCd");
        params.put("api_secret", "ASchfEmbr33n__qZRIIVsezW_kfIoq");
        params.put("to", mobilenumber);
        params.put("text", "RedStag: " + message);

        StringBuilder postData = new StringBuilder();
        for (Map.Entry<String,Object> param : params.entrySet()) {
            if (postData.length() != 0) postData.append('&');
            postData.append(URLEncoder.encode(param.getKey(), "UTF-8"));
            postData.append('=');
            postData.append(URLEncoder.encode(String.valueOf(param.getValue()), "UTF-8"));
        }
        byte[] postDataBytes = postData.toString().getBytes("UTF-8");

        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setRequestProperty("Accept", "application/json");
        conn.setDoOutput(true);
        conn.getOutputStream().write(postDataBytes);

        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String str_aray = ReadAllLines(br); 
        ExecuteQuery("update tblotp set server_response='"+rchar(str_aray)+"' where otpcode='"+otpcode+"' and appreference='"+appreference+"'");
        
    } catch (Exception e) {
        e.printStackTrace();
        ExecuteQuery("update tblotp set server_response='"+ e.getMessage() +"' where otpcode='"+otpcode+"' and appreference='"+appreference+"'");
        logError("app-x-error",e.getMessage());
    }
}
%>


<%!public void SendQueueMY(String appreference, String mobilenumber, String otpcode, String message){          
    try {
        URL url = new URL("https://sms.360.my/gw/bulk360/v3_0/send.php");
        Map<String,Object> params = new LinkedHashMap<>();
        params.put("user", "QnXe0LGexr");
        params.put("pass", "JRvlvuVouLlJ8GjfrYL4ENezLqcZi5d3coxFvPq9");
        params.put("from", "Redstag");
        params.put("to", mobilenumber);
        params.put("text", "RedStag: " + message);

        StringBuilder postData = new StringBuilder();
        for (Map.Entry<String,Object> param : params.entrySet()) {
            if (postData.length() != 0) postData.append('&');
            postData.append(URLEncoder.encode(param.getKey(), "UTF-8"));
            postData.append('=');
            postData.append(URLEncoder.encode(String.valueOf(param.getValue()), "UTF-8"));
        }
        byte[] postDataBytes = postData.toString().getBytes("UTF-8");

        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setRequestProperty("Content-Length", String.valueOf(postDataBytes.length));
        conn.setDoOutput(true);
        conn.getOutputStream().write(postDataBytes);

        BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
        
        String output;
        while ((output = br.readLine()) != null) {
            ExecuteQuery("update tblotp set server_response='"+rchar(output)+"' where otpcode='"+otpcode+"' and appreference='"+appreference+"'");
        }
    } catch (Exception e) {
        e.printStackTrace();
        ExecuteQuery("update tblotp set server_response='"+ e.getMessage() +"' where otpcode='"+otpcode+"' and appreference='"+appreference+"'");
        logError("app-x-error",e.getMessage());
    }
}
%>