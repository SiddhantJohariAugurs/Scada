
// var responseComponentData='${currentView.mapData}', // getting backend data
var mapInfoWindowContent = "Info Window content!!",
    markers = [], renderedMap = '';
responseComponentData = responseComponentData ? JSON.parse(responseComponentData) : responseComponentData;

// draggable methods
DraggableOverlay.prototype = new google.maps.OverlayView();

DraggableOverlay.prototype.onAdd = function () {
    var container = document.createElement('div'),
        that = this;

    if (this.get('content') && typeof this.get('content').nodeName !== 'undefined') {
        container.appendChild(this.get('content'));
    } else {
        if (this.get('content') && typeof this.get('content') === 'string') {
            container.innerHTML = this.get('content');
        } else {
            return;
        }
    }
    container.style.position = 'absolute';

    this.set('container', container)
    this.getPanes().floatPane.appendChild(container);
}

function DraggableOverlay(map, position, content) {
    if (typeof draw === 'function') {
        this.draw = draw;
    }
    this.setValues({ position: position, container: null, content: content, map: map });
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

window.onload = function () {
    checkFullScreen();
    localStorage.removeItem("ViewType");
    if (responseComponentData) {
        document.querySelector('#viewBackground').style.display = "none";
        document.querySelector('.viewContent').appendChild(document.querySelector('#viewContent img'));
        initMap(responseComponentData);
        localStorage.setItem("ViewType", "map");
    } else {
        document.querySelector('#map').style.display = "none";
        localStorage.setItem("ViewType", "img");
    }
}

// iniialize map
function initMap() {
    var initialCenter, initialZoom, initialInfoContent;
    if (responseComponentData && responseComponentData.center && responseComponentData.center.lat) {
        initialCenter = { 'lat': responseComponentData.center.lat, "lng": responseComponentData.center.lng }
    } else {
        initialCenter = { lat: 28, lng: 77 }
    }

    if (responseComponentData && responseComponentData.zoom) {
        initialZoom = responseComponentData.zoom;
    } else {
        initialZoom = 5;
    }

    renderedMap = new google.maps.Map(document.getElementById("map"), {
        zoom: initialZoom,
        center: initialCenter,
        mapTypeId: "roadmap",
        styles: mapStyle
    });
    compareCurrentZoomWithCompZoom(initialZoom);//setup with initial zoom
    renderedMap.addListener("zoom_changed", () => {
        compareCurrentZoomWithCompZoom(renderedMap.getZoom());
    });
    if (responseComponentData && responseComponentData.marker && responseComponentData.marker.length) {
        setTimeout(function () {
            renderAllSavedMarkers(renderedMap);
        }, 500) // if there are saved markers
    }
}

// looping throught all markers
function renderAllSavedMarkers(renderedMap) {
    var newNode, mpInfoContent;
    responseComponentData.marker.forEach(function (elem, idx) {
        var currentNode = document.querySelector('#viewContent #' + elem.dwrId);
        var setOverlayContent = document.createElement("DIV");
        setOverlayContent.className = "overlay";

        if (currentNode) {
            currentNode.className = elem.content;
            currentNode.style.position = "";
            setOverlayContent.appendChild(currentNode);
            var Img=document.createElement('IMG');
            Img.src="images/plugin.png";
            Img.className="viewCompIcon";
            setOverlayContent.appendChild(Img);
        } else {
            setOverlayContent.innerHTML = elem.content;
        }

        addMarker(elem, setOverlayContent);
    })
}

// add maker from save info
function addMarker(location, mpInfoContent) {
    var marker = new DraggableOverlay(
        renderedMap,
        new google.maps.LatLng({ "lat": location.lat, "lng": location.lng }),
        mpInfoContent
    );
    marker["id"] = location.id;
    markers.push(marker);
}
function compareCurrentZoomWithCompZoom(currentZoom){
    responseComponentData.marker.forEach(function (elem, idx) {
        var $comp = jQuery('#'+elem.dwrId);
        if(elem.zoom){//no operation with 0 or null zoom
            if(currentZoom > elem.zoom){
                $comp.hide();
                $comp.closest(".overlay").find('.viewCompIcon').show();
            }
            else{
                $comp.show();
                $comp.closest(".overlay").find('.viewCompIcon').hide();
            }
        }
    })
}
function compareCurrentLayersWithCompLAyers(currentLayers){
    responseComponentData.marker.forEach(function (elem, idx) {
        if(elem && elem.layers)
        {
            var $comp = jQuery('#'+elem.dwrId).closest('.overlay');
            var savedLayers  = elem.layers;
            currentLayers=currentLayers? currentLayers : [];
            var matched = currentLayers.filter(function(obj) { 
                return savedLayers.indexOf(obj) !== -1; 
            });
            if(matched.length){
                $comp.removeClass('hideLayer');
            }
            else{
                $comp.addClass('hideLayer');
            }
        }
    })
}
jQuery(function () {
    // dropdown multiselect Get All Layer
    if (jQuery('.fetchGenerateLayersOptions'))
        jQuery.ajax({
            type: 'GET',
            url: "/ScadaLTS/servlet/GetAllLayer",
            success: function (data) {
                var resp = JSON.parse(data);
                jQuery(".fetchGenerateLayersOptions").html('');
                if (resp && resp["data"] && resp["data"].length) {
                    resp["data"].forEach(function (elem) {
                            if(elem.layerId === 1 || elem.layerId === '1'){
                                var newOpt=jQuery("<option value="+elem.layerId+" selected data-defaultVal="+elem.layerId+">"+elem.layerName+"</option>");
                            }
                            else
                            {
                                var newOpt=jQuery("<option value="+elem.layerId+">"+elem.layerName+"</option>");
                            }
                        jQuery(".fetchGenerateLayersOptions").append(newOpt);
                    })
                    jQuery('#selectLayerToFilterComponent').select2(
                        {
                            placeholder: "Select layers",
                        })
                        .on('select2:unselect', function(e){
                            var latVals=jQuery('#selectLayerToFilterComponent').val();
                            if(!latVals){
                            jQuery('#selectLayerToFilterComponent').val(
                                [jQuery('#selectLayerToFilterComponent option[data-defaultval]').val()]
                                ).trigger('change');
                            }
                        });
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {        
                console.warn(errorThrown.message)
            }
        });
})
jQuery(document)
    .on("change", '#selectLayerToFilterComponent', function () {
        //handle layer change
        compareCurrentLayersWithCompLAyers(jQuery(this).select2("val"))
    });