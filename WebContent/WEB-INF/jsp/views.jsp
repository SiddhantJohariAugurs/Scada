<%--
    Mango - Open Source M2M - http://mango.serotoninsoftware.com
    Copyright (C) 2006-2011 Serotonin Software Technologies Inc.
    @author Matthew Lohbihler
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/.
--%>
<%@ include file="/WEB-INF/jsp/include/tech.jsp"%>
<%@ page import="com.serotonin.mango.vo.UserComment"%>

<tag:page dwr="ViewDwr"
	js="view,dygraphs/dygraph-dev,dygraph-extra,dygraphsSplineUtils,dygraphsCharts"
	css="jQuery/plugins/jquery-ui/css/south-street/jquery-ui-1.10.3.custom.min,jQuery/plugins/datetimepicker/jquery-ui-timepicker-addon,jQuery/plugins/jpicker/css/jPicker-1.1.6.min"
	jqplugins="jquery-ui/js/jquery-ui-1.10.3.custom.min,jpicker/jpicker-1.1.6.min,datetimepicker/jquery-ui-timepicker-addon">
	<link href="resources/npm/sweetalert2/dist/sweetalert2.min.css" rel="stylesheet" type="text/css">
	<link href="resources/map.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="resources/wz_jsgraphics.js"></script>
	<script type="text/javascript" src="resources/shortcut.js"></script>
	<script type="text/javascript" src="resources/customClientScripts/customView.js"></script>
	<script type="text/javascript" src="resources/npm/sweetalert2/dist/sweetalert2.min.js"></script>
	<script type="text/javascript" language="javascript" src="resources/mapStyle.js"></script> 
	
	<link rel="stylesheet" type="text/css" href="resources/select2/select2.min.css" />
	<script type="text/javascript" language="javascript" src="resources/select2/select2.min.js"></script>

	<script	src="https://maps.googleapis.com/maps/api/js?key=<fmt:message key="google.apikey" bundle="${env}"/>"></script>
	<%@ include file="/WEB-INF/jsp/include/vue/vue-app.css.jsp"%>
	<%@ include file="/WEB-INF/jsp/include/vue/vue-app.js.jsp"%>

	<style> 
		table {
			border-collapse: separate !important;
			border-spacing: 2px !important;
			padding: 3px;
		}
		.rowTable {
			background-color: #F0F0F0;
		}
		.rowTableAlt {
			background-color: #DCDCDC;
		}
	</style>
	<script type="text/javascript">
		jQuery.noConflict();
		
		shortcut.add("Ctrl+Shift+F", function() {
			toggleFullscreen();
		});
			
		var myLocation = window.location.origin + location.pathname.substr(0, location.pathname.lastIndexOf('/'));
	
		// check replace alert
		jQuery.ajax({
	        type: "GET",
	        dataType: "json",
	        url: myLocation + '/api/config/replacealert',
            success: function(data) {
            	window.alert = function(message) {
					var timeout = 6; // seconds
					swal({
						title: message,
						text: `I will close in ${timeout} seconds.`,
						timer: timeout*1000,
						showConfirmButton: true
					});
            	}
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
              // no op
            }
	    });
		
		<c:if test="${!empty currentView}">
	      mango.view.initNormalView();
	    </c:if>
	    
	    var nVer = navigator.appVersion;
	    var nAgt = navigator.userAgent;
	    var browserName  = navigator.appName;
	    var fullVersion  = parseFloat(navigator.appVersion); 
	    var majorVersion = parseInt(navigator.appVersion, 10);
	    var nameOffset, verOffset, ix;
	
	    // In Opera, the true version is after "Opera" or after "Version"
	    if ((verOffset=nAgt.indexOf("Opera")) != -1) {
			browserName = "Opera";
			fullVersion = nAgt.substring(verOffset + 6);
			if ((verOffset=nAgt.indexOf("Version")) != -1) 
				fullVersion = nAgt.substring(verOffset + 8);
	    }
	    // In MSIE, the true version is after "MSIE" in userAgent
	    else if ((verOffset=nAgt.indexOf("MSIE")) != -1) {
			browserName = "Microsoft Internet Explorer";
			fullVersion = nAgt.substring(verOffset + 5);
	    }
	    // In Chrome, the true version is after "Chrome" 
	    else if ((verOffset=nAgt.indexOf("Chrome")) != -1) {
			browserName = "Chrome";
			fullVersion = nAgt.substring(verOffset + 7);
	    }
	    // In Safari, the true version is after "Safari" or after "Version" 
	    else if ((verOffset=nAgt.indexOf("Safari")) != -1) {
			browserName = "Safari";
			fullVersion = nAgt.substring(verOffset + 7);
			if ((verOffset=nAgt.indexOf("Version")) != -1) 
				fullVersion = nAgt.substring(verOffset + 8);
	    }
	    // In Firefox, the true version is after "Firefox" 
	    else if ((verOffset=nAgt.indexOf("Firefox")) != -1) {
			browserName = "Firefox";
			fullVersion = nAgt.substring(verOffset + 8);
	    }
	    // In most other browsers, "name/version" is at the end of userAgent 
	    else if ((nameOffset=nAgt.lastIndexOf(' ') + 1) < 
	              (verOffset=nAgt.lastIndexOf('/'))) {
			browserName = nAgt.substring(nameOffset, verOffset);
			fullVersion = nAgt.substring(verOffset + 1);
			if (browserName.toLowerCase() === browserName.toUpperCase()) {
				browserName = navigator.appName;
			}
	    }
	    
	    // trim the fullVersion string at semicolon/space if present
	    if ((ix = fullVersion.indexOf(";")) != -1)
	    	fullVersion = fullVersion.substring(0, ix);
	    if ((ix = fullVersion.indexOf(" ")) != -1)
	    	fullVersion = fullVersion.substring(0, ix);
	
	    majorVersion = parseInt(fullVersion, 10);
	    
	    if (isNaN(majorVersion)) {
	    	fullVersion  = parseFloat(navigator.appVersion); 
	    	majorVersion = parseInt(navigator.appVersion, 10);
	    }
	    
	    function unshare() {
	        ViewDwr.deleteViewShare(function() {window.location = 'views.shtm';});
	    }
	    
	    function setCookie(c_name, value) {
	    	var exdate = new Date();
	    	exdate.setDate(exdate.getDate() + 365);
	    	var c_value = escape(value) + ("; expires=" + exdate.toUTCString());
	    	document.cookie = c_name + "=" + c_value;
	    }
	    
	    function getCookie(c_name) {
	    	var i, x, y, ARRcookies=document.cookie.split(";");
	    	
	    	for (i=0; i<ARRcookies.length; i++) {
	      		x = ARRcookies[i].substr(0, ARRcookies[i].indexOf("="));
	      		y = ARRcookies[i].substr(ARRcookies[i].indexOf("=") + 1);
	      		x = x.replace(/^\s+|\s+$/g, "");
	      		
	      		if (x === c_name) {
	        		return unescape(y);
	        	}
	      	}
	    }
	    
		function toggleFullscreen() {
			var check = getCookie("fullScreen")
			if (check == null || check === "" || check === "no") {
				setCookie("fullScreen", "yes")
				fullScreen();
			} else {
				setCookie("fullScreen", "no")
				normalScreen()
			}
		}
		
		function fullScreen() {
			document.getElementsByClassName("content")[0].style.padding = '0px';

			document.getElementById('mainHeader').style.display = "none";
	  	  	document.getElementById('subHeader').style.display = "none";
	  	  	document.getElementById('graphical').style.display = "none";
	  	  	document.getElementById('map').style.height = "100vh";
			jQuery('#fsOut').fadeOut(1000, function() {document.getElementById('fullscreenHint').style.display = "none"}); 	  	
		}
		
		function normalScreen() {
			document.getElementsByClassName("content")[0].style.padding = '5px';

			document.getElementById('mainHeader').style.display = "block";
	  	  	document.getElementById('subHeader').style.display = "block";
	  	  	document.getElementById('graphical').style.display = "block";
	  	  	document.getElementById('map').style.height = 'calc(100vh - 180px)';
			document.getElementById('fullscreenHint').style.display = "block";	  
			document.getElementById('fsOut').style.display = "block";	
		}
		
		function checkFullScreen() {
			var check = getCookie("fullScreen");
			if (check == null || check === "" || check === "no") {
				normalScreen();
			} else {
				fullScreen();
			}
		}
			
		function keyListen(e) {
	        var keycode = e.keyCode;
	        
	        if (keycode == '116') {
	        	e.returnValue=false;
	        	e.keyCode=false;
	        	return false;
	        };
		}
	
		function callkeydownhandler(evnt) {
	   		keyListen(evnt);
		}
	</script>

	<table class="view__table subPageHeader" id="graphical" aria-describedby="graphic view">
		<thead>
			<tr>
				<th scope="col"></th>
			</tr>
		</thead>
		<tr>
			<td class="smallTitle">
				<fmt:message key="views.title" />
				<tag:help id="graphicalViews" /></td>
			<td></td>
			<c:if test="${fn:length(views) != 0}">
				<td>
					<tag:img png="arrow_out" title="viewEdit.fullScreen"
							onclick="toggleFullscreen()" />
				</td>
			</c:if>
			<td>
				<sst:select value="${currentView.id}"
					onchange="window.location='?viewId='+ this.value;">
					<c:forEach items="${views}" var="aView">
						<sst:option value="${aView.key}">${sst:escapeLessThan(aView.value)}</sst:option>
					</c:forEach>
				</sst:select>
				<c:if test="${!empty currentView}">
					<c:choose>
						<c:when test="${owner}">
							<a href="view_edit.shtm?viewId=${currentView.id}">
								<tag:img png="icon_view_edit" title="viewEdit.editView"></tag:img>
							</a>
						</c:when>
						<c:otherwise>
						</c:otherwise>
					</c:choose>
				</c:if> 
				<a href="view_edit.shtm" onclick="localStorage.removeItem('ViewType')">
					<tag:img png="icon_view_new" title="views.newView" />
				</a>
			</td>
			<td>
				<select multiple="multiple" class="fetchGenerateLayersOptions" id="selectLayerToFilterComponent">
					<option value="1" data-defaultVal="1" selected>One</option>
					<option value="2">Two</option>
					<option value="3">Three</option>
				</select>
			</td>
		</tr>
	</table>
	<table class="view__table" aria-describedby="fullscreen" id="fullscreenHint">
		<thead>
			<tr>
				<th scope="col"></th>
			</tr>
		</thead>
		<tr>
			<td class="smallTitle" id="fsOut">
				<fmt:message key="fullScreenOut" />
			</td>
		</tr>
	</table>

	<tag:displayView view="${currentView}" emptyMessageKey="views.noViews" />
	
	<div class="viewContent">
		<div id="mapAreaOptions">
			<span></span>
		</div>

		<div id="map">
		</div>
	</div>
</tag:page>

<%@ include file="/WEB-INF/jsp/include/userComment.jsp"%>
<script type="text/javascript">
	var responseComponentData='${currentView.mapData}'; // getting backend data
</script>
<script defer type="text/javascript" language="javascript" src="resources/view-upgrade.js"></script>
<%@ include file="/WEB-INF/jsp/include/vue/vue-view.js.jsp"%>
<%@ include file="/WEB-INF/jsp/include/vue/vue-charts.js.jsp"%>
