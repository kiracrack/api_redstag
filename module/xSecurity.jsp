
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