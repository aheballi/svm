/////////////////////////////////////////////////////////////////////
//
// helpinfo.js - definition of Help information used 
//               throughout the InstallShield Help Library
//
// Copyright © 2002-2004 InstallShield Software Corporation
//
/////////////////////////////////////////////////////////////////////
//
// Use the appropriate value for HELPNETPRODUCTCAT
//
// 2     AdminStudio
// 4     DemoShield
// 6     InstallShield Developer
// 38	 Expo Walkthrough
// 7     InstallShield Express
// 8     InstallShield MultiPlatform
// 9     InstallShield Professional
// 13    PackageForTheWeb
// 27    InstallShield Update Service
// 33    RedBend vBuild
// 50    InstallShield DevStudio
// 58    InstallShield X

var HELPNETPRODUCTCAT = "58";

// Enter the current version of the product

var HELPNETPRODUCTVER = "10.5";


var HELPINFO_PRODUCT = "InstallShield";
var HELPINFO_VERSION = "10.5";
var HELPINFO_DATE    = "October 2004";



// MSDN: the toLocaleDateString method requires JScript 5.5 or later.
// JScript 5.5 is implemented in IE 5.5 and later, and Windows Me and later.


var releasedate = HELPINFO_DATE;
dateObj = new Date(document.lastModified)
var datetimestamp=dateObj.toLocaleString(document.lastModified);
//	var datestamp=dateObj.toLocaleDateString(document.lastModified);
//	var timestamp=dateObj.toLocaleTimeString(document.lastModified);
var leading="Topic Last Updated: "
//	var modstamp = leading + datestamp + ' ' + timestamp;


// Comment the following line out if you're compiling a .chm file.
// var modstamp = leading + datetimestamp;

// Comment the following line out if you're compiling for HelpNet.
var modstamp = "Topic Last Updated: 8 June 2005";	
	
var URL_FEEDBACK_PART1 = "http://www.installshield.com/feedback/forms/feedback.asp?category=prod&first_sub_cat=58&second_sub_cat=7&version=";
var URL_FEEDBACK_PART2 = "&form_url=Online%20Help:%20";

function FeedMe() {
    var s = new String(window.location.href);
    var lIndex = s.lastIndexOf("/");
    var sFile = s.substr(lIndex + 1);
    
    var sURL = (URL_FEEDBACK_PART1 + HELPINFO_VERSION + URL_FEEDBACK_PART2);
    sURL += sFile;
    
    window.open(sURL);
    
    return false;
}	

function AfxGetApp() {
    var oObjMgr = new ActiveXObject("ISProxy.Proxy");
	oObjMgr.ISCreateObject(document, "Isobjmgr.dll", "{DE5FBA5D-8AB0-4a53-B620-F2065702D228}");
    return oObjMgr.pApp;
}

function AfxGetNav() {
    var oApp = AfxGetApp();
    return oApp.GetNav();
}

function GotoView(sView) {
    var oNav = AfxGetNav();
    oNav.GoToNode(sView);
    
    var oApp = AfxGetApp();
    oApp.FocusToIDE();
    
    return false;
}