<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.zuora.hosted.lite.util.HPMHelper" %>
<%@ page import="java.util.Map" %>
<%
	Map params = (Map)request.getAttribute("params");
	Map prepopulateFields = (Map)request.getAttribute("prepopulateFields");
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<link href="css/hpm2samplecode.css" rel="stylesheet" type="text/css" />
<title>Inline, Button In.</title>
<script type="text/javascript" src='<%=HPMHelper.getJsPath()%>'></script>
<script type="text/javascript">
//HPM parameters and passthroughs
var params = {};

//Set parammeters and passthroughs
<%	
	for(Object key : params.keySet()) {
%>
params["<%=(String)key%>"]="<%=(String)params.get(key)%>";		
<%
	}
%>

//Pre-populate fields
var prepopulateFields = {};

//Set pre-populate fields
<%		
	for(Object key : prepopulateFields.keySet()) {
%>
prepopulateFields["<%=(String)key%>"]="<%=(String)prepopulateFields.get(key)%>";		
<%
	}
%>

function forwardCallbackURL(response) {
	var callbackUrl = "callback?";
	for(id in response) {
		callbackUrl = callbackUrl+id+"="+encodeURIComponent(response[id])+"&";		
	}
	window.location.replace(callbackUrl);
} 

var callback = function (response) {
    if(response.responseFrom == "Response_From_Submit_Page") {
    	if(response.success) {
        	// Submitting hosted page succeeds. Business logic code may be added here. Simply forward to the callback url in sample code.
        	forwardCallbackURL(response);
        } else {
            // Submitting hosted page fails. Error handling code should be added here. Simply forward to the callback url in sample code.
            forwardCallbackURL(response);
        }
    } else {
    	// Requesting hosted page fails. Error handling code should be added here. Simply forward to the callback url in sample code.
    	forwardCallbackURL(response);
    }
};

function showPage() {
	document.getElementById("showPage").disabled = true;
	
	Z.render(params,prepopulateFields,callback);
}
</script>
</head>
<body>
	<div class="firstTitle"><font size="5" style="margin-left: 90px; height: 80px;">Inline, Submit Button Inside Hosted Page.</font></div>
	<div class="item"><button id="showPage" onclick="showPage()" style="margin-left: 150px; height: 24px; width: 120px;">Open Hosted Page</button><button onclick='window.location.replace("Homepage.jsp")' style="margin-left: 20px; width: 140px; height: 24px;">Back To Homepage</button></div>
	<div class="title"><div id="zuora_payment"></div></div>
</body>
</html>