<%@ include file="../module/db.jsp" %>
<%@ include file="../module/xLibrary.jsp" %>
<%@ include file="../module/xRecordModule.jsp" %>
<%@ include file="../module/xRecordClass.jsp" %>
<%@ include file="../module/xFirebase.jsp" %>
<%@ include file="../module/xPusher.jsp" %>
 
<%
    JSONObject mainObj = new JSONObject();
try{
    String x = Decrypt(request.getParameter("x"));
    String userid = request.getParameter("userid");
    String sessionid = request.getParameter("sessionid");

    if(x.isEmpty() || userid.isEmpty() || sessionid.isEmpty()){
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
        return;
        
    }else if(isAdminSessionExpired(userid,sessionid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalExpiredSessionMessageDashboard);
        mainObj.put("errorcode", "session");
        out.print(mainObj);
        return;
    
    }else if(isAdminAccountBlocked(userid)){
        mainObj.put("status", "ERROR");
        mainObj.put("message", globalAdminAccountBlocked);
        mainObj.put("errorcode", "blocked");
        out.print(mainObj);
        return;
    }

    if(x.equals("load_promotion")){
        String operatorid = request.getParameter("operatorid");

        mainObj.put("status", "OK");
        mainObj = load_promotion(mainObj, operatorid);
        mainObj.put("message", "Successfull Synchronized");
        out.print(mainObj);

    }else if(x.equals("set_promotion")){
        String mode = request.getParameter("mode");
        String promoid = request.getParameter("promoid");
        String operatorid = request.getParameter("operatorid");
        String sortorder = request.getParameter("sortorder");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String promocode = request.getParameter("promocode");
        String banner_url = request.getParameter("banner_url"); 
        boolean disabled = Boolean.parseBoolean(request.getParameter("disabled"));

        if(isPromotionExist(promoid, promocode)){
            mainObj.put("status", "ERROR");
            mainObj.put("message", "Promo code already exists! Please use unique one");
            out.print(mainObj);
            return;
        }

        String query = "operatorid='"+operatorid+"', "
                    + " sortorder='" + sortorder + "', " 
                    + " promocode='" + promocode + "', " 
                    + " title='" + rchar(title) + "', " 
                    + " description='" + rchar(description) + "', " 
                    + " banner_url='"+banner_url+"', "
                    + " disabled="+disabled+"";

        if (mode.equals("add")){
            ExecuteQuery("insert into tblpromotion set " + query + ", addedby='"+userid+"', datetrn=current_timestamp");
            mainObj.put("message", "Promo successfully added!");
        }else{
            ExecuteQuery("UPDATE tblpromotion set " + query + " where id='"+promoid+"'");
            mainObj.put("message", "Promo successfully updated!");
        }
        
        mainObj.put("status", "OK");
        mainObj = load_promotion(mainObj, operatorid);
        out.print(mainObj);

    }else if(x.equals("set_promo_settings")){
        String promoid = request.getParameter("promoid");
        String operatorid = request.getParameter("operatorid");
        String amount = request.getParameter("amount");
        String turnover = request.getParameter("turnover");
        String mindeposit = request.getParameter("mindeposit");
        String maxdeposit = request.getParameter("maxdeposit");
        String maxwithdraw = request.getParameter("maxwithdraw");
        String max_claim = request.getParameter("max_claim");
        String claim_limit = request.getParameter("claim_limit");

        boolean fix_amount = Boolean.parseBoolean(request.getParameter("fix_amount"));
        boolean cockfight = Boolean.parseBoolean(request.getParameter("cockfight"));
        boolean slotgame = Boolean.parseBoolean(request.getParameter("slotgame"));

        ExecuteQuery("UPDATE tblpromotion set fix_amount="+fix_amount+", amount='"+amount+"',turnover='"+turnover+"',mindeposit='"+mindeposit+"',maxdeposit='"+maxdeposit+"',maxwithdraw='"+maxwithdraw+"',max_claim='"+max_claim+"',claim_limit='"+claim_limit+"', cockfight="+cockfight+", slotgame="+slotgame+" where id='"+promoid+"'");
       
        mainObj.put("status", "OK");
        mainObj.put("message", "Promo successfully updated!");
        mainObj = load_promotion(mainObj, operatorid);
        out.print(mainObj);
    
    }else if(x.equals("delete_promotion")){
        String operatorid = request.getParameter("operatorid");
        String promoid = request.getParameter("promoid");
        
        mainObj.put("status", "ERROR");
        mainObj.put("message", "Delete promotion is temporary disabled, Please contact administrator");
        mainObj.put("errorcode", "400");
        out.print(mainObj);

        /*ExecuteQuery("DELETE FROM tblpromotion where id = '"+promoid+"';");
        mainObj.put("status", "OK");
        mainObj.put("message","Promo successfully deleted!");
        mainObj = load_promotion(mainObj, operatorid);
        out.print(mainObj);*/

     }else if(x.equals("set_popup_settings")){
        boolean popup_enabled = Boolean.parseBoolean(request.getParameter("popup_enabled"));
        String popup_banner = request.getParameter("popup_banner");
        
        ExecuteQuery("UPDATE tblgeneralsettings set popup_enabled="+popup_enabled+", popup_banner='"+popup_banner+"'");

        mainObj.put("status", "OK");
        mainObj.put("message", "Popup banner successfully save!");
        out.print(mainObj);
    
    }else if(x.equals("push_notification")){
        String promocode = request.getParameter("promocode");
        PromotionInfo promo = new PromotionInfo(promocode);

        SendBroadcastNotification(promo.title, "", promo.banner_url);

        mainObj.put("status", "OK");
        mainObj.put("message", "Promotion successfully notified all devices!");
        out.print(mainObj);

    }else{
        mainObj.put("status", "ERROR");
        mainObj.put("message","request not valid ");
        mainObj.put("errorcode", "404");
        out.print(mainObj);
    }
}catch (Exception e){
      mainObj.put("status", "ERROR");
      mainObj.put("message", e.toString());
      mainObj.put("errorcode", "400");
      out.print(mainObj);
      logError("dashboard-x-promotion",e.toString());
}
%>

<%!public boolean isPromotionExist(String id, String promocode) {
    return CountQry("tblpromotion", " id<>'"+id+"' and promocode='" + promocode + "'") > 0;
  }
 %>

 <%!public JSONObject load_promotion(JSONObject mainObj, String operatorid) {
      mainObj = DBtoJson(mainObj, "promotion", "select *, if(!fix_amount, concat(amount,'%'),'-') as 'bonus_percent', if(fix_amount, amount, 0) as 'bonus_amount', concat('X', turnover) as 'turnover2' from tblpromotion order by sortorder asc");
      return mainObj;
 }
 %>
 