<%!public JSONObject LoadGameCategory(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "game_category", "select * from tblgamecategory order by priority asc");
    return mainObj;
} %>

<%!public JSONObject LoadGameFeatured(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "game_featured", "select * from tblgamefeatured order by priority asc");
    return mainObj;
} %>

<%!public JSONObject LoadGameProvider(JSONObject mainObj) {
    mainObj = DBtoJson(mainObj, "game_provider", "select * from tblgameprovider");
    return mainObj;
} %>

 <%!public JSONObject GameEnableList(JSONObject mainObj, String provider) {
    mainObj = DBtoJson(mainObj, "game_enabled_list", "select id, gameid, gamename, gametype, (select categoryname from tblgamecategory where code=a.category) as 'category', ucase(provider) as provider, imgurl1,imgurl2,imgname from tblgamelist as a where provider='"+provider+"' and isenable=1");       
    return mainObj;
 }
%>

<%!public JSONObject GameMasterList(JSONObject mainObj, String provider) {
    mainObj = DBtoJson(mainObj, "game_master_list", "select * from tblgamesource where provider='"+provider+"' and gamecode not in (select gameid from tblgamelist where isenable=1 and provider='"+provider+"')");       
    return mainObj;
 }
 %>

 <%!public JSONObject GamePopularUnfilter(JSONObject mainObj, String provider) {
    mainObj = DBtoJson(mainObj, "popular_game_unfilter", "select id, gameid, gamename, imgurl1 from tblgamelist as a where provider='"+provider+"' and isenable=1 and gameid not in (select gameid from tblgamepopular where provider='"+provider+"')");       
    return mainObj;
 }
%>

<%!public JSONObject GamePopularfiltered(JSONObject mainObj, String mode, String provider) {
    mainObj = DBtoJson(mainObj, "popular_game_filtered", "select id, gameid, gamename, imageurl from tblgamepopular where mode='"+mode+"' and provider='"+provider+"'");       
    return mainObj;
 }
%>

<%!public void EnableGamePopularity(String mode, String gameid, String provider) {
    GameProfile game = new GameProfile(gameid, provider);
    ExecuteQuery("insert into tblgamepopular set mode='"+mode+"', provider='"+provider+"', gameid='" + gameid + "', gamename='" + rchar(game.gamename) + "',imageurl='"+game.imageurl+"'");
}
%>

<%!public void RemoveGamePopularity(String id) {
    ExecuteQuery("DELETE from tblgamepopular where id='"+id+"'");
}
%>

<%!public void EnableGameFilter(String gameid, String provider) {
    GameProfile game = new GameProfile(gameid, provider);
    if(CountQry("tblgamelist", "provider='"+provider+"' and gameid='" + gameid + "'") == 0){
        ExecuteQuery("insert into tblgamelist set provider='"+provider+"', gameid='" + gameid + "', gamename='" + rchar(game.gamename) + "', gametype='" + game.gametype + "', imgurl1='" + game.imageurl + "', isenable=1 ");
    }else{
        ExecuteQuery("UPDATE tblgamelist set gamename='" + rchar(game.gamename) + "', gametype='" + game.gametype + "', imgurl1='" + game.imageurl + "', isenable=1 where provider='"+provider+"' and gameid='" + gameid + "'");
    }
}
%>

<%!public void DisableGameFilter(String id) {
    ExecuteQuery("UPDATE tblgamelist set isenable=0 where id='" + id + "'");
}
%>

<%!public void LogCallback(String provider, String command, String content) {
     ExecuteQuery("insert into tblgamecallback set provider='"+provider+"',command='"+command+"', content='"+rchar(content)+"', datetrn=current_timestamp");    
  }
 %>

 
 <%!public JSONObject LoadCasinoGameReport(JSONObject mainObj, String userid, String datefrom, String dateto) {
      mainObj = DBtoJson(mainObj, "game_report", "select date_format(gamedate, '%m/%d/%y') as 'date', gamename, sum(totalbets) as totalbets, sum(totalwin) as totalwin, sum(winloss) as winloss from tblgamesummary where accountid='"+userid+"' and date_format(gamedate, '%Y-%m-%d') between '" + datefrom + "' and '" + dateto + "' group by date_format(gamedate, '%Y-%m-%d'), gamename order by gamedate asc");
      return mainObj;
 }%>

<%!public void SendPlayerBalanceNotification(String userid) {
    JSONObject apiObjuser = new JSONObject();
    apiObjuser = api_account_creditbal(apiObjuser, userid);
    PusherPost(userid, apiObjuser);
    SendCreditBalance(userid);
}
%>

<%!public String GetSignature(SortedMap<String, String> geek, String secretKey) throws Exception {
    Set s = geek.entrySet(); 
    Iterator i = s.iterator(); 
    
    List<String> list = new ArrayList<String>();  
    while (i.hasNext()) 
    { 
        Map.Entry m = (Map.Entry)i.next(); 

        String key = ((String)m.getKey()).toLowerCase(); 
        String value = (String)m.getValue(); 

        list.add(key + "=" + value); 
    } 
    
    String raw_data = list.stream().collect(Collectors.joining("&")) + secretKey;
    
    MessageDigest md = MessageDigest.getInstance("MD5");
    byte[] rawBytes = md.digest(raw_data.getBytes("UTF-8"));
    
    return byteArrayToHex(rawBytes);
  }
%>

<%!public String byteArrayToHex(byte[] a){
    StringBuilder sb = new StringBuilder(a.length * 2);
    for(byte b: a)
        sb.append(String.format("%02x", b));
    return sb.toString();
  }
%>


<%!public String generateMD5(String inputString) throws NoSuchAlgorithmException {
    
    /*
    //First Option
    MessageDigest md = MessageDigest.getInstance("MD5");
    byte[] bytes = md.digest(stringToHash.getBytes());
    StringBuilder result = new StringBuilder();
    for (byte b : bytes) {
        result.append(String.format("%02x", b));
    }
    return result.toString(); */
      
    /*
    //Second Option
    try {
         MessageDigest md = MessageDigest.getInstance("MD5");
          byte[] inputBytes = inputString.getBytes();
            byte[] hashBytes = md.digest(inputBytes);
        StringBuilder hexString = new StringBuilder();
        for (byte b : hashBytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        String md5Hash = hexString.toString();
        return md5Hash;
    } catch (java.security.NoSuchAlgorithmException e) {
    }
    return null;
     */

    try {
        MessageDigest m = MessageDigest.getInstance("MD5");
        m.update(inputString.getBytes(), 0, inputString.length());
        BigInteger i = new BigInteger(1,m.digest());
        return String.format("%1$032x", i);         
    } catch (NoSuchAlgorithmException e) {
        e.printStackTrace();
    }
    return null;
  }
%>
