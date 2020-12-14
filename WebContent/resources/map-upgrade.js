var markers = [],
removingOverlayId = '',
    removingOverlayConfirmType = 1;
// During deletion set get overlay id  & confirm type if no content generated

var renderedMap = '', mapInfoWindowContent = "map Info Window Content", stringToHTML; // map info window content generating from the libarary
var ActiveGraphicRendererId = '', ActiveGraphicRendererImgSrc = null, // global var for storing selected icon
    ResponseOfGMapOverlayData = '', // on edit store overlay data
    dwrComponentIdOfMap = '';

// Loop to Render saved components over map
function renderAllSavedMarkers(renderedMap) {
    ResponseOfGMapOverlayData.marker.forEach(function (elem, idx) {
        addMarker(elem);  
    })
}

// removing selected marker id
function removeSelectedMarkers(id) {
    markers = markers.filter(function (elem, idx) {
        if (elem.id == id) {
            markers[idx].setMap(null)
        }
        return elem.id != id
    })
};

// draggable methods
DraggableOverlay.prototype = new google.maps.OverlayView();
DraggableOverlay.prototype.onAdd = function () {
    var container = document.createElement('div'),
        that = this;

    if (this.get('content') && typeof this.get('content').nodeName !== 'undefined') {
        container.appendChild(this.get('content'));
    }
    else {
        if (typeof this.get('content') === 'string') {
            container.innerHTML = this.get('content');
        }
        else {
            return;
        }
    }
    container.style.position = 'absolute';

    google.maps.event.addDomListener(
        this.get('map').getDiv(), 'mouseleave', function () {
            google.maps.event.trigger(container, 'mouseup');
        }
    );
    google.maps.event.addDomListener(container, 'mousedown', function (e) {
        that.map.set('draggable', false);
        if (e.target.nodeName != "INPUT" && e.target.nodeName != "SELECT" && !jQuery(e.target).closest('.windowDiv').length)//stop dragging  condition
        {
            that.set('origin', e);
            this.style.cursor = 'move';
            that.moveHandler = google.maps.event.addDomListener(that.get('map').getDiv(),
                'mousemove', function (e) {
                    var origin = that.get('origin'),
                        left = origin.clientX - e.clientX,
                        top = origin.clientY - e.clientY,
                        pos = that.getProjection()
                            .fromLatLngToDivPixel(that.get('position')),
                        latLng = that.getProjection()
                            .fromDivPixelToLatLng(new google.maps.Point(pos.x - left,
                                pos.y - top));
                    that.set('origin', e);
                    that.set('position', latLng);
                    that.draw();
                });
        }
    });

    google.maps.event.addDomListener(container, 'mouseup', function () {
        if (that.map)
            that.map.set('draggable', true);
        this.style.cursor = 'default';
        google.maps.event.removeListener(that.moveHandler);
    });


    this.set('container', container)
    this.getPanes().floatPane.appendChild(container);
    google.maps.event.addDomListener(container, "click", function (e) {
        if (e.target.nodeName != "INPUT")//Avoide click event
        {
            e.preventDefault();
            e.stopPropagation();
        }
        else {
            event.stopPropagation();
        }
    })

    // This handler allows right click events on anchor tags within the popup
    var allowAnchorRightClicksHandler = function (e) {
        if (e.target.nodeName === "OBJECT" || e.target.nodeName === "EMBED") {
            e.cancelBubble = true;
            if (e.stopPropagation) {
                e.stopPropagation();
            }
        }
        google.maps.event.removeListener(that.moveHandler);
    };
    this.contextListener_ = google.maps.event.addDomListener(container, "contextmenu", allowAnchorRightClicksHandler);
}

function DraggableOverlay(map, position, content) {
    if (typeof draw === 'function') {
        this.draw = draw;
    }
    this.setValues({
        position: position, container: null,
        content: content, map: map
    });
}

DraggableOverlay.prototype.draw = function () {
    if (this.get('position') && this.get('container')) {
        var pos = this.getProjection().fromLatLngToDivPixel(this.get('position'));
        this.get('container').style.left = pos.x + 'px';
        this.get('container').style.top = pos.y + 'px';
    }
};

DraggableOverlay.prototype.onRemove = function () {
    this.get('container').parentNode.removeChild(this.get('container'));
    this.set('container', null)
};

// Render components over map on click
function addMarkerOnClick(location, id, overlayContainer) {
    var marker = new DraggableOverlay(renderedMap, location, overlayContainer);
    marker["id"] = id;
    markers.push(marker);
}

// Render saved components over map
function addMarker(location) {
    var overlayContent = document.createElement("DIV");
    overlayContent.className = "overlay";
    var mpInfoContent = location.content && location.content.length ? location.content : 'infoContent';
    var currentNode = document.querySelector('#viewContent #' + location.dwrId);

    if (currentNode) {
        currentNode.removeAttribute('dojodragsource');
        overlayContent.appendChild(currentNode);
        var pluginDelete = overlayContent.querySelector('.controlsDiv img[src="images/plugin_delete.png"]');
        var htmlDelete = overlayContent.querySelector('.controlsDiv img[src="images/html_delete.png"]');
        if (pluginDelete) {
            pluginDelete.setAttribute("overlayId", location.id);
            pluginDelete.setAttribute("data-status", 1);
        }
        if (htmlDelete) {
            htmlDelete.setAttribute("overlayId", location.id);
            htmlDelete.setAttribute("data-status", 1);
        }
    }
    else {
        overlayContent.append(mpInfoContent)
    }
    var marker = new DraggableOverlay(
        renderedMap, new google.maps.LatLng({ "lat": location.lat, "lng": location.lng }),
        overlayContent
    );
    marker["id"] = location.id;
    marker["dwrId"] = location.dwrId;
    marker["type"] = location.content;
    // Update markers array
    markers.push(marker);
}

// Removing all comp generator content & add in the current
function RemovingAllHaveContentPopupWithCurrent(currentMarkerId) {
    var overlayCompContainer = document.createElement("DIV");
    overlayCompContainer.className = "overlay__compContWraper";
    overlayCompContainer.innerHTML = document.getElementById('componentEditorsRefs').innerHTML;
    document.querySelectorAll('.overlay').forEach(function (elem, idx) {
        if (elem.querySelector('.overlay__compContWraper'))
            elem.querySelector('.overlay__compContWraper').remove();
    })
    var newId = "c" + currentMarkerId;
    document.getElementById(newId).before(overlayCompContainer)
}

// Initialize map
function initMap() {
    var initialCenter, initialZoom, initialInfoContent;
    if (ResponseOfGMapOverlayData && ResponseOfGMapOverlayData.center && ResponseOfGMapOverlayData.center.lat) {
        initialCenter = { 'lat': ResponseOfGMapOverlayData.center.lat, "lng": ResponseOfGMapOverlayData.center.lng }
    }
    else {
        initialCenter = { lat: 28, lng: 77 }
    }

    if (ResponseOfGMapOverlayData && ResponseOfGMapOverlayData.zoom) {
        initialZoom = ResponseOfGMapOverlayData.zoom;
    }
    else {
        initialZoom = 5;
    }

    renderedMap = new google.maps.Map(document.getElementById("map"), {
        zoom: initialZoom,
        center: initialCenter,
        mapTypeId: "roadmap",
        styles: mapStyle
    });

    // This event listener will call addMarker() when the map is clicked.
    renderedMap.addListener("click", (event) => {
        var overlayContainer = document.createElement("DIV");
        overlayContainer.className = "overlay";
        var dynamicId = new Date().getTime();
        var newMarker = event.latLng;
        var marker = new DraggableOverlay(renderedMap, newMarker, overlayContainer);
        marker["id"] = dynamicId;
        marker["type"] = document.getElementById('componentList').value;
        setTimeout(function () {
            addViewComponent(overlayContainer);//called the component
            setTimeout(function () {//updating events & setting attributes
                marker["dwrId"] = overlayContainer.querySelector(':scope >div').getAttribute('id');

                markers.push(marker);
                var currentOCompIdSelector = $(overlayContainer.querySelector(':scope >div').getAttribute('id') + "Content");
                var currentOCompIdGSelector = $(overlayContainer.querySelector(':scope >div').getAttribute('id') + "Graph");
                var hasChildElements = currentOCompIdSelector && currentOCompIdSelector.innerHTML;
                var hasChildGElements = currentOCompIdGSelector && currentOCompIdGSelector.innerHTML;
                var pluginDelete = overlayContainer.querySelector('.controlsDiv img[src="images/plugin_delete.png"]');
                var editDelete = overlayContainer.querySelector('.controlsDiv img[src="images/pencil.png"]');
                var htmlDelete = overlayContainer.querySelector('.controlsDiv img[src="images/html_delete.png"]');
                if (hasChildElements || hasChildGElements) {
                    if (pluginDelete) {
                        pluginDelete.setAttribute("overlayId", dynamicId);
                        pluginDelete.setAttribute("data-status", 1);
                    }
                    if (htmlDelete) {
                        htmlDelete.setAttribute("overlayId", dynamicId);
                        htmlDelete.setAttribute("data-status", 1);
                    }
                }
                else {
                    if (pluginDelete) {
                        pluginDelete.setAttribute("overlayId", dynamicId);
                        pluginDelete.setAttribute("data-status", 0);
                        console.warn('Content not generated for this component!!');
                    }
                    if (htmlDelete) {
                        htmlDelete.setAttribute("overlayId", dynamicId);
                        htmlDelete.setAttribute("data-status", 0);
                        console.warn('Content not generated for this component!!');
                    }
                }
            }, 1000)
        }, 50)
    });

    if (ResponseOfGMapOverlayData && ResponseOfGMapOverlayData.marker && ResponseOfGMapOverlayData.marker.length) {
        setTimeout(function () {
            renderAllSavedMarkers(renderedMap); // If there are saved markers
        }, 1000)
    }
}

function saveInfo() {
    if ($('googleMap').checked) { // Run if map is selected
        var allMarkerObj = {}, markerObjectsData = [], centerInfo = renderedMap.center.toJSON();
        markers.forEach(function (elem, idx) {
            var position = elem.position.toJSON();
            markerObjectsData.push({ 'lat': position.lat, 'lng': position.lng, "id": elem.id, "dwrId": elem.dwrId, "content": elem.type,"zoom":elem.zoom,"layers": elem.layers });
        });
        allMarkerObj["center"] = { 'lat': centerInfo.lat, 'lng': centerInfo.lng }
        allMarkerObj["zoom"] = renderedMap.zoom;
        allMarkerObj["marker"] = markerObjectsData;
        document.getElementById("viewMapData").value = JSON.stringify(allMarkerObj);
    }
}
//toggle visiblity of zoom & layer name on component edit popup
function toggleVisibilityOfZoomLayerOption(className){
    document.querySelectorAll('.layernameRow').forEach(function(elem){
        elem.classList.remove('hide');
        className ? elem.classList.add(className) : '';
    })
    document.querySelectorAll('.zoomRow').forEach(function(elem){
        elem.classList.remove('hide');
        className ? elem.classList.add(className) : '';
    })
}
function handleClick(myRadio) {
    currentValue = myRadio.value;
    if (myRadio.value == 'backgroundImages') {
        let bgImg = document.querySelectorAll('.backgroundImage');

        document.querySelectorAll('.backgroundImage')[0].style.display = "table-row";
        document.querySelectorAll('.backgroundImage')[1].style.display = "table-row";
        document.querySelector('#map-area .viewBackground').removeAttribute("id", "");
        document.querySelector('#viewContent .viewBackground').setAttribute("id", "viewBackground");
        document.getElementById('map-area').style.display = "none";
        document.getElementById('viewContent').style.display = "block";
        document.getElementById('mapAreaOptions').innerHTML = '';
        document.getElementById('viewBackground').style.display = "block";
        document.getElementById('sizeLabel').closest('tr').style.display = "visible";
        document.getElementById('componentGeneratorBtnInfo').className = 'img__active';
        toggleVisibilityOfZoomLayerOption("hide");
    } else {
        document.querySelectorAll('.backgroundImage')[0].style.display = "none";
        document.querySelectorAll('.backgroundImage')[1].style.display = "none";
        document.querySelector('#viewContent .viewBackground').removeAttribute("id", "");
        document.querySelector('#map-area .viewBackground').setAttribute("id", "viewBackground");
        document.getElementById('map-area').style.display = "block";
        document.getElementById('viewContent').style.display = "none";
        document.getElementById('viewBackground').style.display = "none";
        document.getElementById('sizeLabel').closest('tr').style.display = "none";
        document.getElementById('componentGeneratorBtnInfo').className = 'map__active';
        toggleVisibilityOfZoomLayerOption("");
        initMap();
    }
    resizeViewBackgroundToResolution(document.getElementById('view.resolution').value)
}
//set current zoom
function setCurrentZoom(event){
    jQuery(event.target).parent('td').find('.editorZoom').val(renderedMap.zoom);
}
//save Zoom Layers of all components
function saveZoomLayers(componentId,zoomElemId,layersElemId){
    markers && markers.forEach(function (elem, idx) {
        if(elem.dwrId === "c"+componentId){
            elem['zoom']=jQuery('#'+zoomElemId).val();
            elem['layers']=jQuery('#'+layersElemId).val();
        }
    });
}
//setting Zoom Layers of all editors
function setZoomLayersOverEditor(componentId,zoomElemId,layersElemId){
    markers && markers.forEach(function (elem, idx) {
        if(elem.dwrId === "c"+componentId){
          jQuery('#'+zoomElemId).val(elem.zoom? elem.zoom : 0);
          jQuery('#'+layersElemId).val(elem.layers? elem.layers : [jQuery('#'+layersElemId+' option[data-status="locked"]').val()]).trigger('change');
        }
    });
}
jQuery(function(){
    // dropdown multiselect Get All Layer
    if(jQuery('.fetchGenerateLayersOptions'))
        jQuery.ajax({
            type: 'GET',
            url: "/ScadaLTS/servlet/GetAllLayer",
            success: function (data) {
                var resp = JSON.parse(data);
                jQuery(".fetchGenerateLayersOptions").html('');
                if(resp  && resp["data"] && resp["data"].length){
                    resp["data"].forEach(function(elem){
                        if(elem.layerId === 1 || elem.layerId === '1'){
                            var newOpt=jQuery('<option value="'+elem.layerId+'" data-status="locked">'+elem.layerName+'</option>');
                        }
                        else
                        {
                            var newOpt=jQuery("<option value="+elem.layerId+">"+elem.layerName+"</option>");
                        }
                        jQuery(".fetchGenerateLayersOptions").append(newOpt);
                    })
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                console.warn(errorThrown.message)
            }
        });
})
jQuery(document)
.on("blur",".editorZoom",function(e){
    var newval=jQuery(this).val();
    if(isNaN(newval))
    {
        console.warn('Please enter integer.');
        jQuery(this).val(0);
        newval=0;
    }
    if(parseInt(newval))
    {
        if(newval > 22){
            jQuery(this).val(22);
            console.warn('Please enter zoom less or equal to 22.');
        }
    }
});