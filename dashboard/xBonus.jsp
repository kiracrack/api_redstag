<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
 
<%
    String api_file = "dashboard-x-bonus";
    JSONObject mainObj = new JSONObject();

try{

    String ipaddress = getIpAddress(request);
    if (hasMaliciousData(api_file, request, ipaddress)) {
        out.print(error_invalid_request(mainObj));
        return;
    }

    String token = null;
    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

    String authHeader = request.getHeader("Authorization");
    if (authHeader != null  && authHeader.startsWith("Bearer ")) {
        token = authHeader.substring(7);
    }

    if(x.isEmpty() || userid.isEmpty() || sessionid.isEmpty()){
        out.print(error_invalid_request(mainObj));
        return;
        
    }else if(isAdminSessionExpired(userid,sessionid)){
        out.print(error_admin_session(mainObj));
        return;
        
    }else if(isAdminAccountBlocked(userid)){
        out.print(error_admin_blocked(mainObj));
        return;
    }

    if(x.equals("load_special_bonus")){
        mainObj.put("status", "OK");
        mainObj = LoadSpecialBonus(mainObj);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);


    }else if(x.equals("set_special_bonus")){
        String accountid = request.getParameter("accountid");
        String bonus_type = request.getParameter("bonus_type").toLowerCase();
        double bonus_amount = Double.parseDouble(request.getParameter("bonus_amount"));
        String appreference = request.getParameter("appreference");

        if(isBalanceAvailable(accountid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message","Bonus cannot be process! Make sure there is no balance on account");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(isTherePendingDeposit(accountid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Bonus cannot be process due to pending deposit on account");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;

        }else if(isTherePendingWithdrawal(accountid)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Bonus cannot be process due to pending withdrawal on account");
            mainObj.put("errorcode", "100");
            out.print(mainObj);
            return;
        }

        AccountInfo info = new AccountInfo(accountid);
        ExecuteQuery("INSERT INTO tblbonus set accountid='"+accountid+"', operatorid='"+info.operatorid+"', appreference='"+appreference+"', bonus_type='" + bonus_type + "', bonuscode='" + bonus_type.replace(" ", "_") + "', bonusdate=current_date, amount="+bonus_amount+", dateclaimed=current_timestamp");
        ExecuteQuery("UPDATE tblsubscriber set special_bonus_enabled=1 where accountid='"+accountid+"'");

        ExecuteSetScore(info.operatorid, sessionid, appreference, accountid, info.fullname, "ADD", bonus_amount, bonus_type, accountid);
        SendBonusNotification(accountid, "You have received "+String.format("%,.2f", bonus_amount) + " from " + bonus_type, bonus_amount);

        mainObj.put("status", "OK"); 
        mainObj.put("message", "You have successfully send " +bonus_type+ "!");
        out.print(mainObj);

    }else{
        out.print(error_invalid_request(mainObj));
    }
}catch (Exception e){
    out.print(error_invalid_request(mainObj));
    logError(api_file, e.getMessage());
}
%>
 