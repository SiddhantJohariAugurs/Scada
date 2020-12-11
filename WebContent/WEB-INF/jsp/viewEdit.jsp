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
<%@ page import="com.serotonin.mango.view.ShareUser"%>

<tag:page dwr="ViewDwr" onload="doOnload"
	js="view,dygraph-combined,dygraph-extra,dygraphsSplineUtils,dygraphsCharts"
	css="jQuery/plugins/chosen/chosen,jQuery/plugins/jpicker/css/jPicker-1.1.6.min,jQuery/plugins/jquery-ui/css/south-street/jquery-ui-1.10.3.custom.min"
	jqplugins="chosen/chosen.jquery.min,jpicker/jpicker-1.1.6.min,jquery-ui/js/jquery-ui-1.10.3.custom.min">
	<script type="text/javascript" src="resources/wz_jsgraphics.js"></script>
	<script type="text/javascript"
		src="resources/customClientScripts/customView.js"></script>
	
	<%@ include file="/WEB-INF/jsp/include/vue/vue-app.css.jsp"%>
	<%@ include file="/WEB-INF/jsp/include/vue/vue-app.js.jsp"%>
  <!-- created & added stylesheet & remove css from this file. -->
  <link href="resources/map.css" rel="stylesheet" type="text/css">
  <link href="resources/map-upgrade.css" rel="stylesheet" type="text/css">
	
	<script type="text/javascript" language="javascript" src="resources/mapStyle.js"></script> 
	<link rel="stylesheet" type="text/css" href="resources/select2/select2.min.css" />
	<script type="text/javascript" language="javascript" src="resources/select2/select2.min.js"></script>

	<script
		src="https://maps.googleapis.com/maps/api/js?key=<fmt:message key="google.apikey" bundle="${env}" />"></script>

  <script defer type="text/javascript" language="javascript" src="resources/map-upgrade.js"></script> 
  <script type="text/javascript" language="javascript">
  
    mango.view.initEditView();
    mango.share.dwr = ViewDwr;

    var newComponentPositionOffset = 0;

    function doOnload() {
      hide("sharedUsersDiv");
      <c:forEach items="${form.view.viewComponents}" var="vc">
        <c:set var="compContent"><sst:convert obj="${vc}"/></c:set>
        createViewComponent(${mango:escapeScripts(compContent)}, false, false);
      </c:forEach>
	
      ViewDwr.editInit(function (result) {
        mango.share.users = result.shareUsers;
        mango.share.writeSharedUsers(result.viewUsers);
        dwr.util.addOptions($("componentList"), result.componentTypes, "key", "value");
        settingsEditor.setPointList(result.pointList);
        compoundEditor.setPointList(result.pointList);
        MiscDwr.notifyLongPoll(mango.longPoll.pollSessionId);
      });

      if (document.getElementById("viewBackground").src.includes("spacer.gif")) {
        var viewSize = document.getElementById("view.resolution").value;
        resizeViewBackgroundToResolution(viewSize);
      } else {
        document.getElementById("sizeLabel").closest('tr').style.display = 'none';
      }
    }

    function addViewComponent(overlayContainer = '') {
      ViewDwr.addComponent($get("componentList"), function (viewComponent) {
        if ($('googleMap').checked) {
          createViewComponent(viewComponent, overlayContainer, true);
        }
        else { 
          createViewComponent(viewComponent, true, false);
        }
        MiscDwr.notifyLongPoll(mango.longPoll.pollSessionId);
      });
    }

    /**
     * @param viewComponent The component object
     * @param overlayContainer Is the google map marker div when map is true or center element when false
     * @param map Is the component being added to a map or image
     */
    function createViewComponent(viewComponent, overlayContainer, map) {
      var content, center;

      if (viewComponent.pointComponent)
        content = $("pointTemplate").cloneNode(true);
      else if (viewComponent.defName == 'imageChart')
        content = $("imageChartTemplate").cloneNode(true);
      else if (viewComponent.defName == 'enhancedImageChart')
        content = $("enhancedImageChartTemplate").cloneNode(true);
      else if (viewComponent.compoundComponent)
        content = $("compoundTemplate").cloneNode(true);
      else if (viewComponent.customComponent)
        content = $("customTemplate").cloneNode(true);
      else if (viewComponent.defName == 'calendar')
        content = $("calendarTemplate").cloneNode(true);
      else
        content = $("htmlTemplate").cloneNode(true);

      if (map) {
        var selectedView = overlayContainer;
      } else {
        center = overlayContainer;
        var selectedView = $('googleMap').checked ? $("mapAreaOptions") : $("viewContent");
      }

      configureComponentContent(content, viewComponent, selectedView, center);
      var viewId = location.search.substr(1).split("&").map(v => {return {name: v.split("=")[0], value: v.split("=")[1]}}).find(v => v.name === "viewId").value;

      if (viewComponent.defName == 'simpleCompound') {
        childContent = $("compoundChildTemplate").cloneNode(true);
        configureComponentContent(childContent, viewComponent.leadComponent, $("c" + viewComponent.id + "Content"));
      }
      else if (viewComponent.defName == 'imageChart')
        ;
      else if (viewComponent.defName == 'enhancedImageChart') {
    	
        dygraphsCharts[viewComponent.id] = new DygraphsChart(viewId, viewComponent.id, false, true, viewComponent);
      }
      else if (viewComponent.compoundComponent) {
        // Compound components only have their static content set at page load.
        $set(content.id + "Content", viewComponent.staticContent);

        // Add the child components.
        var childContent;
        for (var i = 0; i < viewComponent.childComponents.length; i++) {
          childContent = $("compoundChildTemplate").cloneNode(true);
          configureComponentContent(childContent, viewComponent.childComponents[i].viewComponent,
            $("c" + viewComponent.id + "ChildComponents"));
        }
      }

      if (viewComponent.defName !== 'calendar') {
        addDnD(content.id);
      }

      if (center)
        updateViewComponentLocation(content.id);

    }

    function configureComponentContent(content, viewComponent, parent, center) {
      content.id = "c" + viewComponent.id;
      content.viewComponentId = viewComponent.id;
      updateNodeIds(content, viewComponent.id);
      parent.appendChild(content);

      if (viewComponent.defName == "html" || viewComponent.defName == "link"
        || viewComponent.defName == "scriptButton" || viewComponent.defName == "flex"
        || viewComponent.defName == "chartComparator")
        // HTML components only get updated at page load and editing.
        updateHtmlComponentContent(content.id, viewComponent.content);

      if (center) {
        // Calculate the location for the new point. For now just put it above edit box.
        var bkgd = $("viewBackground");
        var bkgdBox = dojo.html.getMarginBox(bkgd);
        var compContentBox = dojo.html.getMarginBox(content);
        content.style.left = document.getElementById("propertiesBox").offsetWidth + 20 + newComponentPositionOffset + "px";
        content.style.top = "-135px";
        newComponentPositionOffset += 16;
      }
      else {
        content.style.left = viewComponent.x + "px";
        content.style.top = viewComponent.y + "px";
      }

      if (viewComponent.defName == "calendar") {
        var data = {};
        try {
          data = JSON.parse(viewComponent.content);
        } catch (e) {

        }
        window.initCalendar(viewComponent.id, data);
      }

      show(content);
    }

    function updateNodeIds(elem, id) {
      var i;
      for (i = 0; i < elem.attributes.length; i++) {
        if (elem.attributes[i].value && elem.attributes[i].value.indexOf("_TEMPLATE_") != -1)
          elem.attributes[i].value = elem.attributes[i].value.replace(/_TEMPLATE_/, id);
      }
      for (var i = 0; i < elem.childNodes.length; i++) {
        if (elem.childNodes[i].attributes)
          updateNodeIds(elem.childNodes[i], id);
      }
    }

    function updateHtmlComponentContent(id, content) {
      if (!content || content == "")
        $set(id + "Content", '<img src="images/html.png" alt=""/>');
      else
        $set(id + "Content", content);
    }

    function openStaticEditor(viewComponentId) {
      closeEditors();
      RemovingAllHaveContentPopupWithCurrent(viewComponentId);
      staticEditor.open(viewComponentId);
    }

    function openSettingsEditor(cid) {
      closeEditors();
      RemovingAllHaveContentPopupWithCurrent(cid);
      settingsEditor.open(cid);
    }

    function UpdateGraphicRendererImage() {
      if (ActiveGraphicRendererImgSrc)
        document.getElementById(ActiveGraphicRendererId).querySelector('img').src = ActiveGraphicRendererImgSrc;
      else {
        if (ActiveGraphicRendererId)
          document.getElementById(ActiveGraphicRendererId).querySelector('img').src = "images/icon_comp.png";
      }
    }

    function openGraphicRendererEditor(event, cid) {
      //setting selected icons
      ActiveGraphicRendererId = event.target.closest('.controlsDiv').parentNode.getAttribute("id") + "Content";
      closeEditors();
      RemovingAllHaveContentPopupWithCurrent(cid);
      graphicRendererEditor.open(cid);
    }

  	function openCompoundEditor(cid) {
  	  closeEditors();
  	  RemovingAllHaveContentPopupWithCurrent(cid);
  	  compoundEditor.open(cid);
  	}
  	
    function openCustomEditor(cid) {
      closeEditors();
      RemovingAllHaveContentPopupWithCurrent(cid);
      customEditor.open(cid);
    }

    function positionEditor(compId, editorId) {
      // Position and display the renderer editor.
      var pDim = getNodeBounds($("c" + compId));
      var editDiv = $(editorId);
      var eWidth = jQuery("#" + editorId).outerWidth(true);
      var scrollL = document.documentElement.scrollLeft;
      if (pDim.x < (screen.width - eWidth - pDim.w + scrollL - 10)) {
        editDiv.style.left = (pDim.x + pDim.w + 5) + "px";
        editDiv.style.top = (pDim.y) + "px";
      } else {
        editDiv.style.left = (pDim.x - eWidth - 5) + "px";
        editDiv.style.top = (pDim.y) + "px";
      }
    }

    function positionCustomEditor(compId, editorId) {
      // Position and display the renderer editor.
      var pDim = getNodeBounds($("c" + compId));
      var editDiv = $(editorId);
      var eWidth = jQuery("#" + editorId).outerWidth(true);
      var scrollL = document.documentElement.scrollLeft;
      editDiv.style.left = (pDim.x) + "px";
      editDiv.style.top = (pDim.y + pDim.h) + "px";
    }

    function closeEditors() {
      settingsEditor.close();
      graphicRendererEditor.close();
      staticEditor.close();
      compoundEditor.close();
      customEditor.close();
    }

    function updateViewComponentLocation(divId) {
      var div = $(divId);
      var lt = div.style.left;
      var tp = div.style.top;

      // Remove the 'px's from the positions.
      lt = lt.substring(0, lt.length - 2);
      tp = tp.substring(0, tp.length - 2);
      if (lt < 0) {
        div.style.left = 0;
        lt = 0;
      }
      if (tp < 0) {
        div.style.top = 0;
        tp = 0;
      }

      // Save the new location.
      ViewDwr.setViewComponentLocation(div.viewComponentId, lt, tp);
    }

    function addDnD(divId) {
      var div = $(divId);
      var dragSource = new dojo.dnd.HtmlDragMoveSource(div);
      dragSource.constrainTo($("viewBackground"));

      // Save the drag source in the div in case it gets deleted. See below.
      div.dragSource = dragSource;
      // Also, create a function to call on drag end to update the point view's location.
      div.onDragEnd = function () { updateViewComponentLocation(divId); };

      dojo.event.connect(dragSource, "onDragEnd", div.onDragEnd);
    }

    function deleteViewComponent(viewComponentId, overlayComp = '') {
      closeEditors();

      if (confirm('<fmt:message key="common.confirmDelete" />')) {
            ViewDwr.deleteViewComponent(viewComponentId);

      var div = $("c" + viewComponentId);
      if ($('googleMap').checked) {
        if (removingOverlayId)
          removeSelectedMarkers(removingOverlayId)
      }
      else {
        // Unregister the drag source from the DnD manager.
        if (div.dragSource) {
          div.dragSource.unregister();
        }

        // Disconnect the event handling for drag ends on this guy.
        let selectedView = $("viewContent");
        selectedView.removeChild(div);
      }
    }
    }

    function getViewComponentId(node) {
      removingOverlayId = node.getAttribute('overlayId');
      removingOverlayConfirmType = parseInt(node.getAttribute('data-status'));
      while (!(node.viewComponentId))
        node = node.parentNode;
      return node.viewComponentId;
    }

    function iconizeClicked() {
      ViewDwr.getViewComponentIds(function (ids) {
        var i, comp, content;
        if ($get("iconifyCB")) {
          mango.view.edit.iconize = true;
          for (i = 0; i < ids.length; i++) {
            comp = $("c" + ids[i]);
            content = $("c" + ids[i] + "Content");
            if (comp && !comp.savedContent)
              comp.savedContent = content.innerHTML;
            content.innerHTML = "<img src='images/plugin.png'/>";
          }
        }
        else {
          mango.view.edit.iconize = false;
          for (i = 0; i < ids.length; i++) {
            comp = $("c" + ids[i]);
            content = $("c" + ids[i] + "Content");
            if (comp && comp.savedState)
              mango.view.setContent(comp.savedState);
            else if (comp && comp.savedContent)
              content.innerHTML = comp.savedContent;
            else
              content.innerHTML = '';
            comp.savedState = null;
            comp.savedContent = null;
          }
        }
      });
    }

    function resizeViewBackground(width, height) {
      $("viewBackground").width = parseInt(width, 10);
      $("viewBackground").height = parseInt(height, 10);
    }

    function resizeViewBackgroundToResolution(size) {
      if (document.getElementById("viewBackground").src.includes("spacer.gif")) {
        switch (size) {
          case "0":
            $("viewBackground").width = 640;
            $("viewBackground").height = 480;
            break;
          case "1":
            $("viewBackground").width = 800;
            $("viewBackground").height = 600;
            break;
          case "2":
            $("viewBackground").width = 1024;
            $("viewBackground").height = 768;
            break;
          case "3":
            $("viewBackground").width = 1600;
            $("viewBackground").height = 1200;
            break;
          case "4":
            $("viewBackground").width = 1920;
            $("viewBackground").height = 1080;
            break;
          default:
            $("viewBackground").width = 1600;
            $("viewBackground").height = 1200;
        } 
      } else {
        document.getElementById("sizeLabel").closest('tr').style.display = 'none';
      }
    }

    function deleteConfirm() {
      if (document.getElementById("deleteCheckbox").checked) {
        document.getElementById("deleteButton").style.visibility = 'visible';
        setTimeout(function () {
          document.getElementById("deleteCheckbox").checked = false;
          document.getElementById("deleteButton").style.visibility = 'hidden';
        }, 3000);
      } else {
        document.getElementById("deleteButton").style.visibility = 'hidden';
      }
    }

    window.onbeforeunload = confirmExit;

    function confirmExit() {
      return false;
    }

    function validateName(event) {
      if (document.getElementById('viewNameControl').value && document.getElementById('viewNameControl').value.trim()) {
      }
      else {
        alert('Please enter view name!');
        event.preventDefault();
      }
    }

    window.onload = function () {
      var activeView = localStorage.getItem('ViewType');
      if (ResponseOfGMapOverlayData) {
        if (activeView == 'map') {
          document.getElementById('backgroundImages').closest('td').className = "map__active";
          document.getElementById('sizeLabel').closest('tr').style.display = "none";
          document.getElementById('componentGeneratorBtnInfo').className = "map__active";
          document.getElementById('layernameRow').classList.remove('hide');
          document.getElementById('zoomRow').classList.remove('hide');
        }
        $('googleMap').click();
      }
      else {
        if (activeView == 'img') {
          document.getElementById('backgroundImages').closest('td').className = "img__active";
          document.getElementById('sizeLabel').closest('tr').style.display = "visible";
          document.getElementById('componentGeneratorBtnInfo').className = "img__active";
          document.getElementById('layernameRow').classList.add('hide');
          document.getElementById('zoomRow').classList.add('hide');
        }
        $('backgroundImages').dispatchEvent(new Event('change'));
      }
    };
  </script>
	<form name="view" onsubmit="validateName(event)" class="view-edit-form"
		action="" modelAttribute="form"
		method="post" enctype="multipart/form-data">
		<table class="resetTable__fontSize">
			<tr>
				<td valign="top">
					<div id="propertiesBox" class="borderDiv marR">
						<table>
							<tr>
								<td colspan="3"><tag:img png="icon_view"
										title="viewEdit.editView" /> <span class="smallTitle">
										<fmt:message key="viewEdit.viewProperties" />
								</span> <tag:help id="editingGraphicalViews" /></td>
							</tr>

							<spring:bind path="form.view.name">
								<tr>
									<td class="formLabelRequired" width="150"><fmt:message
											key="viewEdit.name" /></td>
									<td class="formField" width="250"><input
										id="viewNameControl" type="text" name="view.name"
										value="${status.value}" /></td>
									<td class="formError">${status.errorMessage}</td>
								</tr>
							</spring:bind>
							<spring:bind path="form.view.mapData">
								<input type="hidden" name="view.mapData" id="viewMapData"
									value="" />
								<script>
                  ResponseOfGMapOverlayData = '${status.value}';
                  ResponseOfGMapOverlayData = ResponseOfGMapOverlayData ? JSON.parse(ResponseOfGMapOverlayData) : '';
                </script>
							</spring:bind>

							<spring:bind path="form.view.xid">
								<tr>
									<td class="formLabelRequired" width="150"><fmt:message
											key="common.xid" /></td>
									<td class="formField" width="250"><input type="text"
										name="view.xid" value="${status.value}" /></td>
									<td class="formError">${status.errorMessage}</td>
								</tr>
							</spring:bind>
							<tr>
								<td class="formLabelRequired" width="150">Choose view</td>
								<td><input type="radio" checked id="backgroundImages"
									onchange="handleClick(this);" name="chooseView"
									value="backgroundImages" v-model="chooseView"> <label
									for="backgroundImages">Background images</label> <br> <input
									type="radio" id="googleMap" onchange="handleClick(this);"
									name="chooseView" value="googleMap" v-model="chooseView">
									<label for="googleMap">Google Map</label></td>
								<td></td>
							</tr>
							<spring:bind path="form.backgroundImageMP">
								<tr class="backgroundImage">
									<td class="formLabelRequired"><fmt:message
											key="viewEdit.background" /></td>
									<td class="formField"><input type="file"
										name="backgroundImageMP" /></td>
									<td class="formError">${status.errorMessage}</td>
								</tr>
							</spring:bind>
							<tr class="backgroundImage">
								<td colspan="2" align="center"><input type="submit"
									name="upload" value="<fmt:message key="viewEdit.upload" />"
									onclick="window.onbeforeunload = null;" /> <input type="submit"
									name="clearImage"
									value="<fmt:message key="viewEdit.clearImage" />"
									onclick="window.onbeforeunload = null;" /></td>
								<td></td>
							</tr>

							<spring:bind path="form.view.anonymousAccess">
								<tr>
									<td class="formLabelRequired" width="150"><fmt:message
											key="viewEdit.anonymous" /></td>
									<td class="formField" width="250"><sst:select
											name="view.anonymousAccess" value="${status.value}">
											<sst:option
												value="<%=Integer.toString(ShareUser.ACCESS_NONE)%>">
												<fmt:message key="common.access.none" />
											</sst:option>
											<sst:option
												value="<%=Integer.toString(ShareUser.ACCESS_READ)%>">
												<fmt:message key="common.access.read" />
											</sst:option>
											<sst:option
												value="<%=Integer.toString(ShareUser.ACCESS_SET)%>">
												<fmt:message key="common.access.set" />
											</sst:option>
										</sst:select></td>
									<td class="formError">${status.errorMessage}</td>
								</tr>
							</spring:bind>

							<spring:bind path="form.view.resolution">
								<tr>
									<td id="sizeLabel" class="formLabelRequired" width="150">
										<fmt:message key="viedEdit.viewSize" />
									</td>
									<td class="formField" width="250"><sst:select
											id="view.resolution" name="view.resolution"
											value="${status.value}"
											onchange="resizeViewBackgroundToResolution(this.options[this.selectedIndex].value)">
											<sst:option value="<%=Integer.toString(0)%>"> 640x480</sst:option>
											<sst:option value="<%=Integer.toString(1)%>"> 800x600</sst:option>
											<sst:option value="<%=Integer.toString(2)%>"> 1024x768</sst:option>
											<sst:option value="<%=Integer.toString(3)%>"> 1600x1200</sst:option>
											<sst:option value="<%=Integer.toString(4)%>"> 1920x1080</sst:option>
										</sst:select></td>
									<td class="formError">${status.errorMessage}</td>
								</tr>
							</spring:bind>
							
							<tr>
								<td align="left" colspan="3" style="border-top: 1px lightgray solid; padding: 5px">
									<input type="submit"
									  name="save" value="<fmt:message key="common.save" />"
									  onclick="saveInfo();window.onbeforeunload = null;" />
									<input
									  type="submit" name="cancel"
									  value="<fmt:message key="common.cancel" />" />
									<label style="margin-left: 15px;" for="deleteCheckbox">
									    <fmt:message key="viewEdit.viewDelete" />
									</label>
									<input id="deleteCheckbox"
									  type="checkbox" onclick="deleteConfirm()"
									  style="padding-top: 10px; vertical-align: middle;" />
									<input id="deleteButton" type="submit" name="delete"
								      onclick="window.onbeforeunload = null; return confirm('<fmt:message key="common.confirmDelete" />')"
									  value="<fmt:message key="viewEdit.viewDeleteConfirm" />"
									  style="margin-right: 5px; visibility: hidden;" />
								</td>
							</tr>
						</table>
					</div>
				</td>
				<td valign="top">
					<div class="borderDiv" id="sharedUsersDiv">
						<tag:sharedUsers doxId="viewSharing"
							noUsersKey="share.noViewUsers" />
					</div>
				</td>
			</tr>
		</table>
		<table class="resetTable__fontSize">
			<tr>
				<td><fmt:message key="viewEdit.viewComponents" />: <select
					id="componentList"></select> <span id="componentGeneratorBtnInfo">
						<tag:img png="plugin_add" title="viewEdit.addViewComponent"
							onclick="addViewComponent()" /> <span>Click over map to
							add component to view!</span>
				</span></td>
				<td style="width: 30px;"></td>
				<td><input type="checkbox" id="iconifyCB"
					onclick="iconizeClicked();" /> <label for="iconifyCB"> <fmt:message
							key="viewEdit.iconify" /></label></td>
			</tr>
		</table>

		<table class="relative-table" class="table" width="100%">
			<tr>
				<td>
					<table class="table">
						<tr>
							<td colspan="3">
								<div id="mapAreaOptions">
									<span></span>
								</div>
								<div id="map-area">
									<div id="map">
									</div>
									<img class="viewBackground img-responsive"
										src="images/spacer.gif" alt="" style="top: 1px; left: 1px;" />
								</div>
								<div id="viewContent">
									<c:choose>
										<c:when test="${empty form.view.backgroundFilename}">
											<img id="viewBackground" class="viewBackground"
												src="images/spacer.gif" alt="" width="740" height="500"
												style="top: 1px; left: 1px;" />
										</c:when>
										<c:otherwise>
											<img id="viewBackground" class="viewBackground"
												src="${form.view.backgroundFilename}" alt=""
												style="top: 1px; left: 1px;" />
										</c:otherwise>
									</c:choose>
									<div id="componentEditorsRefs">
										<%@ include file="/WEB-INF/jsp/include/staticEditor.jsp"%>
										<%@ include file="/WEB-INF/jsp/include/settingsEditor.jsp"%>
										<%@ include file="/WEB-INF/jsp/include/graphicRendererEditor.jsp"%>
										<%@ include file="/WEB-INF/jsp/include/compoundEditor.jsp"%>
										<%@ include file="/WEB-INF/jsp/include/customEditor.jsp"%>
									</div>
								</div>
							</td>
						</tr>
					</table>

					<div id="pointTemplate"
						onmouseover="showLayer('c'+ getViewComponentId(this) +'Controls');"
						onmouseout="hideLayer('c'+ getViewComponentId(this) +'Controls');"
						style="position: absolute; left: 0px; top: 0px; display: none;">
						<div id="c_TEMPLATE_Content">
							<img src="images/icon_comp.png" alt="" />
						</div>
						<div id="c_TEMPLATE_Controls" class="controlsDiv">
							<table cellpadding="0" cellspacing="1">
								<tr
									onmouseover="showMenu('c'+ getViewComponentId(this) +'Info', 16, 0);"
									onmouseout="hideLayer('c'+ getViewComponentId(this) +'Info');">
									<td><img src="images/information.png" alt="" />
										<div id="c_TEMPLATE_Info" onmouseout="hideLayer(this);">
											<tag:img png="hourglass" title="common.gettingData" />
										</div></td>
								</tr>
								<tr>
									<td><tag:img png="plugin_edit"
											onclick="openSettingsEditor(getViewComponentId(this))"
											title="viewEdit.editPointView" /></td>
								</tr>
								<tr>
									<td><tag:img png="graphic"
											onclick="openGraphicRendererEditor(event,getViewComponentId(this))"
											title="viewEdit.editGraphicalRenderer" /></td>
								</tr>
								<tr>
									<td><tag:img png="plugin_delete"
											onclick="deleteViewComponent(getViewComponentId(this))"
											title="viewEdit.deletePointView" /></td>
								</tr>
							</table>
						</div>
						<div
							style="position: absolute; left: -16px; top: 0px; z-index: 1;">
							<div id="c_TEMPLATE_Warning" style="display: none;"
								onmouseover="showMenu('c'+ getViewComponentId(this) +'Messages', 16, 0);"
								onmouseout="hideLayer('c'+ getViewComponentId(this) +'Messages');">
								<tag:img png="warn" title="common.warning" />
								<div id="c_TEMPLATE_Messages" onmouseout="hideLayer(this);"
									class="controlContent"></div>
							</div>
						</div>
					</div>
					<div id="htmlTemplate"
						onmouseover="showLayer('c'+ getViewComponentId(this) +'Controls');"
						onmouseout="hideLayer('c'+ getViewComponentId(this) +'Controls');"
						style="position: absolute; left: 0px; top: 0px; display: none;">
						<div id="c_TEMPLATE_Content"></div>
						<div id="c_TEMPLATE_Controls" class="controlsDiv">
							<table cellpadding="0" cellspacing="1">
								<tr>
									<td><tag:img png="pencil"
											onclick="openStaticEditor(getViewComponentId(this))"
											title="viewEdit.editStaticView" /></td>
								</tr>
								<tr>
									<td><tag:img png="html_delete"
											onclick="deleteViewComponent(getViewComponentId(this))"
											title="viewEdit.deleteStaticView" /></td>
								</tr>
							</table>
						</div>
					</div>

					<div id="calendarTemplate" class="calendar"
						style="position: absolute">
						<div id="c_TEMPLATE_Content" class="calendar-content">
							<div id="c_TEMPLATE_ContentBody" class="calendar-body"></div>
						</div>
					</div>

					<div id="imageChartTemplate"
						onmouseover="showLayer('c'+ getViewComponentId(this) +'Controls');"
						onmouseout="hideLayer('c'+ getViewComponentId(this) +'Controls');"
						style="position: absolute; left: 0px; top: 0px; display: none;">
						<span id="c_TEMPLATE_Content"></span>
						<div id="c_TEMPLATE_Controls" class="controlsDiv">
							<table cellpadding="0" cellspacing="1">
								<tr>
									<td><tag:img png="plugin_edit"
											onclick="openCompoundEditor(getViewComponentId(this))"
											title="viewEdit.editPointView" /></td>
								</tr>
								<tr>
									<td><tag:img png="plugin_delete"
											onclick="deleteViewComponent(getViewComponentId(this))"
											title="viewEdit.deletePointView" /></td>
								</tr>
							</table>
						</div>
					</div>

					<div id="enhancedImageChartTemplate"
						onmouseover="showLayer('c'+ getViewComponentId(this) +'Controls');"
						onmouseout="hideLayer('c'+ getViewComponentId(this) +'Controls');"
						style="position: absolute; left: 0px; top: 0px; display: none;">
						<div id="c_TEMPLATE_Content" style="display: none;"></div>
						<div id="c_TEMPLATE_Graph" class="enhancedImageChart"></div>
						<div id="c_TEMPLATE_LegendBox" class="enhancedImageChartLegend">
							<b> <fmt:message key="graphic.enhancedImageChart.legend" /></b>
							<div id="c_TEMPLATE_Legend"></div>
						</div>
						<div id="c_TEMPLATE_Controls" class="controlsDiv">
							<table cellpadding="0" cellspacing="1">
								<tr>
									<td><tag:img png="plugin_edit"
											onclick="openCompoundEditor(getViewComponentId(this))"
											title="viewEdit.editPointView" /></td>
								</tr>
								<tr>
									<td><tag:img png="plugin_delete"
											onclick="deleteViewComponent(getViewComponentId(this))"
											title="viewEdit.deletePointView" /></td>
								</tr>
							</table>
						</div>
					</div>

					<div id="compoundTemplate"
						onmouseover="showLayer('c'+ getViewComponentId(this) +'Controls');"
						onmouseout="hideLayer('c'+ getViewComponentId(this) +'Controls');"
						style="position: absolute; left: 0px; top: 0px; display: none;">
						<span id="c_TEMPLATE_Content" class="componentPt"></span>
						<div id="c_TEMPLATE_Controls" class="controlsDiv">
							<table cellpadding="0" cellspacing="1">
								<tr
									onmouseover="showMenu('c'+ getViewComponentId(this) +'Info', 16, 0);"
									onmouseout="hideLayer('c'+ getViewComponentId(this) +'Info');">
									<td><img src="images/information.png" alt="" />
										<div id="c_TEMPLATE_Info" onmouseout="hideLayer(this);">
											<tag:img png="hourglass" title="common.gettingData" />
										</div></td>
								</tr>
								<tr>
									<td><tag:img png="plugin_edit"
											onclick="openCompoundEditor(getViewComponentId(this))"
											title="viewEdit.editPointView" /></td>
								</tr>
								<tr>
									<td><tag:img png="plugin_delete"
											onclick="deleteViewComponent(getViewComponentId(this))"
											title="viewEdit.deletePointView" /></td>
								</tr>
							</table>
						</div>

						<div id="c_TEMPLATE_ChildComponents"
							class="wirelessTempHumSensorContent"></div>
					</div>

					<div id="compoundChildTemplate"
						style="position: absolute; left: 0px; top: 0px; display: none;">
						<div id="c_TEMPLATE_Content">
							<img src="images/icon_comp.png" alt="" />
						</div>
					</div>

					<div id="customTemplate"
						onmouseover="showLayer('c'+ getViewComponentId(this) +'Controls');"
						onmouseout="hideLayer('c'+ getViewComponentId(this) +'Controls');"
						style="position: absolute; left: 0px; top: 0px; display: none;">
						<div id="c_TEMPLATE_Content"></div>
						<div id="c_TEMPLATE_Controls" class="controlsDiv">
							<table cellpadding="0" cellspacing="1">
								<tr>
									<td><tag:img png="pencil"
											onclick="openCustomEditor(getViewComponentId(this))"
											title="viewEdit.editStaticView" /></td>
								</tr>
								<tr>
									<td><tag:img png="html_delete"
											onclick="deleteViewComponent(getViewComponentId(this))"
											title="viewEdit.deleteStaticView" /></td>
								</tr>
							</table>
						</div>
					</div>
				</td>
			</tr>
		</table>
	</form>
</tag:page>