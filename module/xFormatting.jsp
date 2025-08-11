<%!public String ConvertDateFormat(String datevalue, String frmformat, String toformat) {
    String selectedDate = "";
    try {
         SimpleDateFormat fromFormat = new SimpleDateFormat(frmformat);
         SimpleDateFormat dbFormat = new SimpleDateFormat(toformat);
         selectedDate =  dbFormat.format(fromFormat.parse(datevalue));
  }catch(Exception e){
    System.out.println(e);
  } 
      return selectedDate;
  }
%>

<%!public long getDifferenceDays(String datefrom, String dateto) {
    long diff = 0;
    try {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
        Date firstDate = sdf.parse(datefrom);
        Date secondDate = sdf.parse(dateto);

        long diffInMillies = Math.abs(secondDate.getTime() - firstDate.getTime());
        diff = TimeUnit.DAYS.convert(diffInMillies, TimeUnit.MILLISECONDS);
    }catch(Exception e){
        System.out.println(e);
    } 
    return diff;
}
%>


<%!public String QuoteValue(String str) {
    return str.replace("\"","");
  }
%>

<%!public String FormatCurrency(String number) {
    double amount = Double.parseDouble(number);
    DecimalFormat formatter = new DecimalFormat("#,###.00");
    return formatter.format(amount);
  }
%>

<%!public String FormatNumber(String number) {
    double amount = Double.parseDouble(number);
    DecimalFormat formatter = new DecimalFormat("#,###");
    return formatter.format(amount);
  }
%>

<%!public double Val(double amount) {
    DecimalFormat formatter = new DecimalFormat("0.00");
    return Double.parseDouble(formatter.format(amount));
  }
%>

<%!public String ProperCase(String fullname) {
    String ProperCaseName = "";  
    String[] name = fullname.split(" ");
    if(name.length > 1){
        String partName = "";
        for (String part : name) {
            partName = part.toLowerCase();
            partName = partName.substring(0, 1).toUpperCase() + partName.substring(1) + " ";
            ProperCaseName += partName;
        }
        ProperCaseName = ProperCaseName.substring(0, ProperCaseName.length() - 1);
    }else{
        ProperCaseName = fullname.toLowerCase();
        ProperCaseName = ProperCaseName.substring(0, 1).toUpperCase() + ProperCaseName.substring(1);
    }
    return ProperCaseName;  
}  
%>

<%!public String FirstName(String fullname) {
    String first_name = "";  
    String[] name = fullname.split(" ");
    if(name.length > 1){
        for (String part : name) {
            first_name = part.toLowerCase();
            break;
        }
    }else{
        first_name = fullname.toLowerCase();
    }
    return first_name;  
}  
%>

<%!public String uFirstName(String fullname) {
    String first_name = "";  
    String[] name = fullname.split(" ");
    if(name.length > 1){
        for (String part : name) {
            first_name = part.toUpperCase();
            break;
        }
    }else{
        first_name = fullname.toUpperCase();
    }
    return first_name;  
}  
%>

<%!public String charRemoveAt(String str, int p) {  
    return str.substring(0, p) + str.substring(p + 1);  
}  
%>

<%!public String CC(String str){ 
    str = str.replace(",", ""); 
    return str;
}
%>

<%!public String RemoveSpecialChar(String str){ 
    str = str.replace("'", "");
	str = str.replace("\\", "");
    return str;
}
%>


<%!public String RandomBetPercentage(){ 
    Random rand = new Random();
    return String.valueOf(rand.nextInt((98 - 80) + 1) + 80);
}
%>

<%!public String RandomBetBalancer(){ 
    Random rand = new Random();
    return String.valueOf(rand.nextInt((60 - 30) + 1) + 30);
}
%>

<%!public String MaskStringAsterisk(String str){ 
    if(!str.isEmpty()){
        return "*****" + (str.length() <= 5 ? "" : str.substring(5));
    }else{
        return "";
    }
}
%>
 