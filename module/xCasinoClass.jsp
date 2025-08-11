<%!public class GameSettings{
    public String provider,api_id,api_key,game_list,open_game,game_cmd,domain,exiturl,gamedata,testerid;
    public boolean isdisable;
    public GameSettings(String provider){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblgameprovider where provider='"+provider+"'");
            while(rst.next()){
                this.provider = rst.getString("provider");
                this.api_id = rst.getString("api_id");
                this.api_key = rst.getString("api_key");
                this.game_list = rst.getString("game_list");
                this.open_game = rst.getString("open_game");
                this.domain = rst.getString("domain");
                this.exiturl = rst.getString("exiturl");
                this.gamedata = rst.getString("gamedata");
                this.isdisable = rst.getBoolean("isdisable");
                this.testerid = rst.getString("testerid");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-game-settings",e.toString());
        }
    }
}%>

<%!public class GameProfile{
    public String gamename,gametype,aliasname,developer,popularity,imageurl,imageurl2;
    public GameProfile(String gamecode, String provider){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblgamesource where gamecode='"+gamecode+"' and provider='"+provider+"'");
            while(rst.next()){
                this.gamename = rst.getString("gamename");
                this.gametype = rst.getString("gametype");
                this.aliasname = rst.getString("aliasname");
                this.developer = rst.getString("developer");
                this.popularity = rst.getString("popularity");
                this.imageurl = rst.getString("imageurl");
                this.imageurl2 = rst.getString("imageurl");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-game-profile",e.toString());
        }
    }
}%>

<%!public class GameInfo{
    public String gamename,imageurl;
    public GameInfo(String gameid, String provider){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select * from tblgamelist where gameid='"+gameid+"' and provider='"+provider+"'");
            while(rst.next()){
                this.gamename = rst.getString("gamename");
                this.imageurl = rst.getString("imgurl2"); 
            }
            rst.close();
        }catch(SQLException e){
            logError("class-game-info",e.toString());
        }
    }
}%>

<%!public class GameSessionPlayerID{
    public String accountid;

    public GameSessionPlayerID(String sessionid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select accountid from tblgamesession where sessionid='"+sessionid+"'");
            while(rst.next()){
                this.accountid = rst.getString("accountid");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-game-session-id",e.toString());
        }
    }
}%>


<%!public class GameBetInfo{
    public String gamecode,datetrn, status, sessionid;
    public double bet_amount, win_amount;
    public boolean settled;

    public GameBetInfo(String operatorid, String accountid, String provider, String reference){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select `status`, gamecode, sessionid, datetrn, bet_amount, win_amount, settled from tblgamelogs where operatorid='"+operatorid+"' and accountid='"+accountid+"' and provider='"+provider+"' and reference='"+reference+"'");
            while(rst.next()){
                this.gamecode = rst.getString("gamecode");
                this.status = rst.getString("status");
                this.sessionid = rst.getString("sessionid");
                this.datetrn = rst.getString("datetrn");
                this.bet_amount = rst.getDouble("bet_amount");
                this.win_amount = rst.getDouble("win_amount");
                this.settled = rst.getBoolean("settled");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-game-bet-info",e.toString());
        }
    }
}%>


<%!public class KingkongApiInfo{
    public String timestamp, hash;
    public KingkongApiInfo(String appID, String secretKey){
        try{
            long unixTime = System.currentTimeMillis();
            
            SortedMap<String, String> geek  = new TreeMap<>();
            String time = Long.toString(unixTime);
            geek.put("TimeStamp", time); 
            geek.put("AppID", appID); 
            
            String hash = GetSignature(geek, secretKey);
            
            this.timestamp = time;
            this.hash = hash;
            
        }catch(Exception e){
            logError("class-kingkong-api-info",e.toString());
        }
    }
}%>

<%!public class KingkongApiBetInfo{
    public double amount;
    public KingkongApiBetInfo(String hash, String accountid, String betid, String gamecode, String roundid){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select amount from tblgamelogs_kingkong where command='bet' and accountid='"+accountid+"' and hash='"+hash+"' and trnid='"+betid+"' and gamecode='"+gamecode+"' and roundid='"+roundid+"'");
            while(rst.next()){
                this.amount = rst.getDouble("amount");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-kingkon-bet-info",e.toString());
        }
    }
}%>

<%!public class AccountTokenInfo{
    public String accountid, username, fullname, operatorid;
    public double creditbal;
    public AccountTokenInfo(String token){
        try{
            ResultSet rst = null; 
            rst =  SelectQuery("select accountid, username, fullname, operatorid, creditbal from tblsubscriber as a where md5(accountid)='"+token+"'");
            while(rst.next()){
                this.accountid = rst.getString("accountid");
                this.username = rst.getString("username");
                this.fullname = rst.getString("fullname");
                this.operatorid = rst.getString("operatorid");
                this.creditbal = rst.getDouble("creditbal");
            }
            rst.close();
        }catch(SQLException e){
            logError("class-token-info",e.toString());
        }
    }
}%>

