<%!public void PusherPost(String event, JSONObject apiObj){          
    try {
        Thread pusherTread = new Thread(new PusherTask(event, apiObj));
        pusherTread.start();
    } catch (Exception e) {
        e.printStackTrace();
    }
}
%>

<%!public class PusherTask implements Runnable {
    private String event;
    private JSONObject apiObj;

    public PusherTask(String event, JSONObject apiObj) {
        this.event = event;
        this.apiObj = apiObj;
    }
    public void run() {
        PusherTrigger(event, apiObj);
    }
 }
 %>

<%!public void PusherTrigger(String event, JSONObject apiObj){          
    try {
        pusher.trigger(globalPusherAppChannel, Encrypt(event), apiObj);
    } catch (Exception e) {
        e.printStackTrace();
    }
}
%>

<%!public void PushFirebaseUsers(String operatorid, boolean login){          
    try {
        Thread firebaseTread = new Thread(new FirebaseUsersTask(operatorid, login));
        firebaseTread.start();
    } catch (Exception e) {
        e.printStackTrace();
    }
}
%>

<%!public class FirebaseUsersTask implements Runnable {
    private String operatorid;
    private boolean login;

    public FirebaseUsersTask(String operatorid, boolean login) {
        this.operatorid = operatorid;
        this.login = login;
    }

    public void run() {
        FetchFirebaseUsers(operatorid, login);
    }
 }
 %>


<%!public void FetchFirebaseUsers(String operatorid, boolean login){          
    try {
        URL url = new URL(globalFirebaseDB + globalFirebaseMode + "/users.json");
        HttpURLConnection conn = (HttpURLConnection)url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        String output;
        BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
        while ((output = br.readLine()) != null) {
            org.json.JSONObject res = new org.json.JSONObject(output);
            org.json.JSONObject dummy = res.getJSONObject("dummy");
            org.json.JSONObject operator = res.getJSONObject(operatorid);
            
            int totalDummy = 0;
            org.json.JSONObject objdmy = new org.json.JSONObject(dummy.toString());
            Iterator<String> keyDmy = objdmy.keys();
            while(keyDmy.hasNext()) {
                String key = keyDmy.next();
                org.json.JSONObject entry = objdmy.getJSONObject(key);
                if(entry.getString("status").equals("online")){
                    totalDummy++;
                }
            }

            int totalUsers = 0;
            org.json.JSONObject objopr = new org.json.JSONObject(operator.toString());
            Iterator<String> keyopr = objopr.keys();
            while(keyopr.hasNext()) {
                String key = keyopr.next();
                org.json.JSONObject entry = objopr.getJSONObject(key);
                if(entry.getString("status").equals("online")){
                    totalUsers++;
                }
            }
            int totalonline = totalDummy + totalUsers + (login ? 1 : 0);
            ExecuteQuery("update tbloperator set totalonline='"+ totalonline +"' where companyid='"+operatorid+"'");
 
            JSONObject apiObj = new JSONObject();
            apiObj.put("users", totalonline);
            PusherPost("global", apiObj);
        }
       
    } catch (Exception e) {
        e.printStackTrace();
        //logError("app-x-firebase",e.getMessage());
    }
}
%>