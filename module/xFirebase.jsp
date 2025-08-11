<%!public void FirebaseOperator(String operatorid, String title, String message, JSONObject param)
    {           
       try {
            URL url = new URL(globalFirebaseURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            conn.setUseCaches(false);
            conn.setDoInput(true);
            conn.setDoOutput(true);

            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + globalFirebaseToken);
            conn.setRequestProperty("Content-Type", "application/json; UTF-8");

            JSONObject msg = new JSONObject();
            JSONObject info = new JSONObject();
            info.put("topic", globalFirebaseMode+"_"+operatorid);
            
            JSONObject notif = new JSONObject();
            notif.put("title", title);
            notif.put("body", message);

            JSONObject android = new JSONObject();
            android.put("direct_boot_ok", true);

            JSONObject data = new JSONObject();
            data.put("function", "operator"); 
            data.put("title", title); 
            data.put("message", message);
            data.put("param", param);

            info.put("data", data);
            info.put("notification", notif);
            info.put("android", android);
            msg.put("message", info);

            OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream());
            wr.write(msg.toString());
            wr.flush();

            //logError("firebase", msg.toString());

            BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));

            String output;
            System.out.println("Output from Server .... \n");
            while ((output = br.readLine()) != null) {
                System.out.println(output);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
 %>

<%!public void FirebasePush(String tokenid, String mode, String title, String message, String image, String icon, JSONObject data, String popup)
    {           
       try {
            URL url = new URL(globalFirebaseURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            conn.setUseCaches(false); conn.setDoInput(true); conn.setDoOutput(true);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + globalFirebaseToken);
            conn.setRequestProperty("Content-Type", "application/json; UTF-8");

            JSONObject msg = new JSONObject();
            JSONObject info = new JSONObject();
            if(tokenid.length() > 0){
                info.put("token", tokenid);
            }else{
                info.put("topic",  globalFirebaseMode+"_global");
            }

            if(!mode.equals("session") && !mode.equals("block")){
                JSONObject notif = new JSONObject();
                notif.put("title", title);
                notif.put("body", message);
                if(image.length() > 0){
                    notif.put("image", image);
                }
                info.put("notification", notif);
            }
           

            JSONObject android = new JSONObject();
            android.put("direct_boot_ok", true);
        
            data.put("param", data.toString());
            data.put("function", "push"); 
            data.put("mode", mode); 
            data.put("title", title); 
            data.put("message", message); 
            data.put("image", image);
            data.put("date", GlobalDate);
            data.put("time", GlobalTime);
            data.put("icon", icon);
            data.put("popup", popup);
            info.put("data", data);
            
            info.put("android", android);
            msg.put("message", info);

            
            OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream());
            wr.write(msg.toString());
            wr.flush();

            //logError("firebase", msg.toString());

            BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));

            String output;
            System.out.println("Output from Server .... \n");
            while ((output = br.readLine()) != null) {
                System.out.println(output);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }%>

<%!public void FirebaseCreditUpdater(String tokenid, String accountid, String creditbal)
    {           
       try {
            URL url = new URL(globalFirebaseURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            conn.setUseCaches(false); conn.setDoInput(true); conn.setDoOutput(true);
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + globalFirebaseToken);
            conn.setRequestProperty("Content-Type", "application/json; UTF-8");
 
            JSONObject msg = new JSONObject();
            JSONObject info = new JSONObject();
            info.put("token", tokenid);

            JSONObject android = new JSONObject();
            android.put("direct_boot_ok", true);
            
            JSONObject data = new JSONObject();
            data.put("function", "credit"); 
            data.put("accountid", accountid); 
            data.put("creditbal", creditbal); 

            info.put("data", data);
            info.put("android", android);
            msg.put("message", info);
          
            OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream());
            wr.write(msg.toString());
            wr.flush();

            //logError("firebase", msg.toString());

            BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));

            String output;
            System.out.println("Output from Server .... \n");
            while ((output = br.readLine()) != null) {
                System.out.println(output);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }%> 

<%!public void SendScoreNotification(String accountid, boolean add, double amount) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("amount", (add ? String.valueOf(amount) : String.valueOf(-amount)));
    
    AccountInfo ai = new AccountInfo(accountid);
    param.put("creditbal", String.valueOf(ai.creditbal));
    String tokenid = ai.tokenid;

    String description = (add ? "You have received "+String.format("%,.2f", amount) + " credit score." : "You have deducted "+String.format("%,.2f", amount) + " from your credit score.");

    if(tokenid.length() > 0){
        FirebasePush(tokenid, "score", "Credit Score", description ,"", (add ? "score_add" : "score_deduct"), param, "TRUE");
    }

    param.put("title", "Credit Score");
    param.put("description", description);
    JSONObject apiObj = new JSONObject();
    apiObj.put("score", param);
    PusherPost(accountid, apiObj);
  }%>

<%!public void SendBonusNotification(String accountid, String description, double amount) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("amount", String.valueOf(amount));
    
    AccountInfo ai = new AccountInfo(accountid);
    param.put("creditbal", String.valueOf(ai.creditbal));
    String tokenid = ai.tokenid;

    if(tokenid.length() > 0){
        FirebasePush(tokenid, "score", "Congratulations", description ,"", "score_add", param, "TRUE");
    }

    param.put("title", "Congratulations");
    param.put("description", description);
    JSONObject apiObj = new JSONObject();
    apiObj.put("score", param);
    PusherPost(accountid, apiObj);
  }%>

<%!public void SendCreditBalance(String accountid) {
    AccountInfo ai = new AccountInfo(accountid);
    String tokenid = ai.tokenid;
    if(tokenid.length() > 0){
        FirebaseCreditUpdater(tokenid, accountid, String.valueOf(ai.creditbal));
    }
  }%>
  

<%!public void SendTransferScoreNotification(String accountid, String agentid, String sender, double amount) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("amount", String.valueOf(amount));
    AccountInfo ai = new AccountInfo(accountid);
    param.put("creditbal", String.valueOf(ai.creditbal));
    String tokenid = ai.tokenid;

    if(tokenid.length() > 0){
        SendRequestNotificationCount(agentid);
        FirebasePush(tokenid, "score", "Credit Score", "You have received "+String.format("%,.2f", amount) + " credit score from " + sender,"", "score_add", param, "TRUE");
    }

    param.put("title", "Credit Score");
    param.put("description", "You have received "+String.format("%,.2f", amount) + " credit score from " + sender);
    JSONObject apiObj = new JSONObject();
    apiObj.put("score", param);
    PusherPost(accountid, apiObj);
  }%>

<%!public void SendScoreRequestNotification(String refno, String agentid, String accountid, String accountname, double amount) {
      JSONObject param = new JSONObject();
      param.put("refno", refno);
      param.put("amount", String.valueOf(amount));
      param.put("accountid", accountid);
      param.put("accountname", accountname);
      param.put("agentid", agentid);

      String tokenid = getFirebaseToken(agentid);
      if(tokenid.length() > 0){
            SendRequestNotificationCount(agentid);
            FirebasePush(tokenid, "request_score", "Score Request", "You have new downline score request. \n\nAccount No: "+accountid+"\nAccount Name: "+accountname, "", "", param, "TRUE");
      }
  }%>

<%!public void SendAccountStatusNotification(String accountid, String status, String title, String message) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    String tokenid = getFirebaseToken(accountid);
    if(tokenid.length() > 0){
        FirebasePush(tokenid, status, title, message, "", status, param, "FALSE");
      }

    if(status.equals("block")){
        param.put("title", title);
        param.put("message", message);
        JSONObject apiObj = new JSONObject();
        apiObj.put("blocked", param);
        PusherPost(accountid, apiObj);
    }
  }%>
<%!public void SendNewLoginSessionNotification(String accountid, String appreference,  String deviceid,  String status, String title, String message) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("appreference", appreference);
    param.put("deviceid", deviceid);
    FirebasePush("", status, title, message, "", status, param, "FALSE");
  }%>

<%!public void SendUpgradeAccountNotification(String accountid, String title, String message) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    String tokenid = getFirebaseToken(accountid);
    if(tokenid.length() > 0){
        FirebasePush(tokenid, "upgrade", title, message, "", "", param, "FALSE");
      }
  }%>
<%!public void SendResultNotification(String platform, String title, String accountid, String result, String event, double amount, double payout,  boolean cancelled, String description) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("amount", String.valueOf(amount));
    param.put("payout", String.valueOf(payout));
    param.put("result", result);
    param.put("event", event);
    param.put("cancelled", String.valueOf(cancelled));

    AccountInfo ai = new AccountInfo(accountid);
    param.put("creditbal", String.valueOf(ai.creditbal));
    String tokenid = ai.tokenid;
    if(tokenid.length() > 0){
        FirebasePush(tokenid, "result", title, description, "", "", param, "TRUE");
    }

    if(platform.equals("webapi")){
        param.put("title", title);
        param.put("description", description);

        JSONObject apiObj = new JSONObject();
        apiObj.put("notification", param);
        PusherPost(accountid, apiObj);
    }
  }%>
  
<%!public void SendBroadcastNewEvent() {
    JSONObject param = new JSONObject();
    String code = QueryDirectData("code", "`tbltemplate` where mode='new_event' order by RAND()");

    MessageTemplate msg = new MessageTemplate(code);
    FirebasePush("", "event", "New Event", msg.template, msg.imageurl, "app", param, "FALSE");
  }%>

<%!public void SendBroadcastOpenEvent() {
    JSONObject param = new JSONObject();
    String code = QueryDirectData("code", "`tbltemplate` where mode='open_event' order by RAND()");

    MessageTemplate msg = new MessageTemplate(code);
    FirebasePush("", "event", "Re-opening Event", msg.template, msg.imageurl, "app", param, "FALSE");
  }%>


<%!public void SendNewDepositNotification(String refno, String agentid, String accountid, String amount) {
      JSONObject param = new JSONObject();
      param.put("accountid", accountid);
      param.put("refno", refno);
      param.put("uid", agentid);
      param.put("agentid", refno);
      param.put("downline", "true");
      param.put("creditbal", "0");

        
      AccountInfo ai = new AccountInfo(accountid);
      String tokenid = getFirebaseToken(agentid);
      if(tokenid.length() > 0){
            SendRequestNotificationCount(agentid);
            FirebasePush(tokenid, "deposit", "Good News!", "You have new downline deposit from:. \n\nAccount No: "+accountid+"\nAccount Name: "+ai.fullname+"\nAmount: "+amount, "", "", param, "TRUE");
      }
  }%>
<%!public void SendNewWithdrawalNotification(String refno, String agentid, String accountid, String amount) {
      JSONObject param = new JSONObject();
      param.put("accountid", accountid);
      param.put("refno", refno);
      param.put("uid", agentid);
      param.put("downline", "true");
      param.put("creditbal", "0");
        
      AccountInfo ai = new AccountInfo(accountid);
      String tokenid = getFirebaseToken(agentid);
      if(tokenid.length() > 0){
            SendRequestNotificationCount(agentid);
            FirebasePush(tokenid, "withdrawal", "New Withdrawal Request", "You have new downline withdrawal request from:. \n\nAccount No: "+accountid+"\nAccount Name: "+ai.fullname+"\nAmount: "+amount, "", "", param, "TRUE");
      }
  }%>
<%!public void SendBankingNotification(String refno, String accountid, String mode, String title, String message, double amount) {
    JSONObject param = new JSONObject();
    param.put("accountid", accountid);
    param.put("uid", accountid);
    param.put("refno", refno);
    param.put("downline", "false");

    AccountInfo ai = new AccountInfo(accountid);
    param.put("creditbal", String.valueOf(ai.creditbal));
    String tokenid = ai.tokenid;
    if(tokenid.length() > 0){
        FirebasePush(tokenid, mode, accountid, message, "", "", param, "TRUE");
    }

    param.put("amount", String.valueOf(amount));
    param.put("title", title);
    param.put("description", message);

    JSONObject apiObj = new JSONObject();
    apiObj.put("score", param);
    PusherPost(accountid, apiObj);
}%>

<%!public void SendNewRegistrationNotification(String refno, String agentid, String fullname, String mobilenumber, String username, String location, String photourl) {
    JSONObject param = new JSONObject();
    param.put("refno", refno);
    param.put("uid", agentid);
    param.put("fullname", fullname);
    param.put("mobilenumber", mobilenumber);
    param.put("username", username);
    param.put("location", location);
    param.put("photourl", photourl);
    param.put("message", "Good News!\n\nYou have new signup account request");

    String tokenid = getFirebaseToken(agentid);
    if(tokenid.length() > 0){
        //SendRequestNotificationCount(agentid);
        FirebasePush(tokenid, "new_account", "Good News!", "You have new signup account request. \n\nFullname: "+fullname+"\nMobile Number: "+mobilenumber, "", "", param, "TRUE");
    }
  }%>

<%!public void SendRequestNotificationCount(String accountid) {
    JSONObject param = new JSONObject();
    param.put("uid", accountid);
    param.put("request", getTotalRequestNotification(accountid).toString());
    
    String tokenid = getFirebaseToken(accountid);
    if(tokenid.length() > 0){
        FirebasePush(tokenid, "request_notification", "", "", "", "", param, "FALSE");
    }
}%>

<%!public void SendBroadcastNotification(String title, String message, String image) {
    JSONObject param = new JSONObject();
    FirebasePush("", "notification", title, message, image, "app", param, "FALSE");
  }%>