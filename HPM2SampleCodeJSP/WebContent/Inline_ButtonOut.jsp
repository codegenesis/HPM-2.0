<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.zuora.hosted.lite.util.HPMHelper" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.io.FileInputStream" %>
<%
	Map<String, String> params = new HashMap<String, String>();
	params.put("style", "inline");
	params.put("submitEnabled", "false");
	params.put("locale", request.getParameter("locale"));
	params.put("retainValues", "true");
	params.put("signatureType", "advanced");
 	params.put("field_passthrough1", "100");
 	params.put("field_passthrough2", "100");
 	//params.put("field_passthrough3", "100");
 	params.put("field_passthrough4", "100");
 	params.put("field_passthrough5", "100");
	
	Properties prepopulateFields = new Properties();
	prepopulateFields.load(new FileInputStream(request.getServletContext().getRealPath("WEB-INF") + "/data/prepopulate.properties"));
	
	try{
		HPMHelper.prepareParamsAndFields(request.getParameter("pageName"), params, (Map)prepopulateFields);		
	}catch(Exception e) {
		// TODO: Error handling code should be added here.
		
		throw e;
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<link href="css/hpm2samplecode.css" rel="stylesheet" type="text/css" />
<title>Inline, Button Out.</title>
<script type="text/javascript" src='<%=HPMHelper.getJsPath()%>'></script>
<script type="text/javascript">
var jsVersion = "<%=HPMHelper.getJsVersion()%>";

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

var callback = function (response) {
    if(!response.success) {
    	// Requesting hosted page failed. Error handling code should be added here. Simply forward to the callback url in sample code.
    	var callbackUrl = "Callback.jsp?";
    	for(id in response) {
    		callbackUrl = callbackUrl+id+"="+encodeURIComponent(response[id])+"&";		
    	}
    	window.location.replace(callbackUrl);
    }
};

var clientErrorMessageCallback = function(key, code, message) {
	// Overwrite error messages generated by client-side validation. 	
	var errorMessage = message;
	
	switch(key) {
		case "creditCardNumber":
			if(code == '001') {
				errorMessage = 'Card number required. Please input firstly.';
			}else if(code == '002') {
				errorMessage = 'Number does not match credit card. Please try again.';
			}
			break;
		case "cardSecurityCode":
			break;
		case "creditCardExpirationYear":
			break;
		case "creditCardExpirationMonth":
			break;			
	}
	
	Z.sendErrorMessageToHpm(key, errorMessage);	
	
	return;
};

function showPage() {
	document.getElementById("showPage").disabled = true;
	
	var zuoraDiv = document.getElementById('zuora_payment');
	zuoraDiv.innerHTML="";
	
	if(jsVersion == "1.0.0" || jsVersion == "1.1.0") {
		// Zuora javascript of version 1.0.0 and 1.1.0 only supports Z.render. 
		Z.render(params,prepopulateFields,callback);
	} else {
		// Zuora javascript of version 1.2.0 and later supports Z.renderWithErrorHandler.
		Z.renderWithErrorHandler(params,prepopulateFields,callback,clientErrorMessageCallback);			
	}
	
	// Display the submit button.
	document.getElementById("submit").style.display = "inline";
}

function submitPage() {
	document.getElementById('errorMessage').innerHTML='';
	Z.submit();	
	return false;
}

function submitSucceed() {
	// Submitting hosted page succeeded, disable the submit button.
	document.getElementById("submitButton").disabled = true;
}

var parameterArray = {};

var serverErrorMessageCallback = function() {
	// Overwrite field error messages generated by server-side validation.	
	var existErrorField = false;
	for(key in parameterArray) {
		var keySplit = key.split("_");
		if(keySplit.length == 2 && keySplit[0] == "errorField") {
			var errorMessage = parameterArray[key];
			switch(keySplit[1]) {
				case "creditCardNumber":
					errorMessage = 'Please input correct credit card number.';					
					break;
				case "cardSecurityCode":
					break;
				case "creditCardExpirationYear":
					break;
				case "creditCardExpirationMonth":
					break;
				case "creditCardType":
					break;	
			}
			
			Z.sendErrorMessageToHpm(keySplit[1], errorMessage);					
			existErrorField = true;
		}
	}
	
	// Overwrite general error messages generated by server-side validation.
	if(!existErrorField) {
		Z.sendErrorMessageToHpm("error", "Validation failed on server side, Please check your input firstly.");
	}
};

function submitFail(callbackQueryString) {
	var zuoraDiv = document.getElementById('zuora_payment');
	zuoraDiv.innerHTML="";
	
	var parameterString = callbackQueryString.split("&");
	parameterArray = {};
	for (i=0; j=parameterString[i]; i++){ 
		parameterArray[j.substring(0,j.indexOf("="))] = j.substring(j.indexOf("=")+1,j.length); 
	}
	
	// Submitting hosted page failed, reload hosted page with retained values and display error message.
	if(jsVersion == "1.0.0" || jsVersion == "1.1.0") {
		
		// Remove PCI prepopulate fields from params.
		delete params.field_creditCardNumber;
		delete params.field_creditCardExpirationYear;
		delete params.field_creditCardExpirationMonth;
		delete params.field_cardSecurityCode;
		
		Z.render(params,null,callback);		
		document.getElementById("errorMessage").innerHTML="Hosted Page failed to submit. The reason is: " + decodeURIComponent(parameterArray["errorMessage"]);		
	} else {
		Z.renderWithErrorHandler(params,null,callback,clientErrorMessageCallback);		
		Z.runAfterRender(serverErrorMessageCallback);		
	}
}
</script>
</head>
<body>
	<div class="firstTitle"><font size="5" style="margin-left: 90px; height: 80px;">Inline, Submit Button Outside Hosted Page.</font></div>
	<div class="item"><button id="showPage" onclick="showPage()" style="margin-left: 150px; height: 24px; width: 120px;">Open Hosted Page</button><button onclick='window.location.replace("Homepage.jsp")'  style="margin-left: 20px; width: 140px; height: 24px;">Back To Homepage</button></div>
	<div class="item"><font id="errorMessage" size="3" color="red"></font></div>
	<div class="title"><div id="zuora_payment"></div></div>
	<div class="item"><div id="submit" style="display:none"><button id="submitButton" onclick="submitPage();return false;" style="margin-left: 270px; width: 66px; height: 24px; margin-top: 10px;">Submit</button></div></div>
</body>
</html>