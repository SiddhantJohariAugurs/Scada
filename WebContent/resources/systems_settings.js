//generate Select Option
function generateLayerInfoTableRows(dataArr) {
    jQuery("#allLayers .reset__table tbody").html('');
    var totalL = dataArr.length;
    for (var i = 0; i < dataArr.length; i++) {
        var data = dataArr[i];
        if(data.layerId == 1){
            var newTr = jQuery('<tr><td>' + data.layerName + '</td><td>' + data.layerDescrption + '</td>\
                  <td>\
                    <img class="editLayerDetail" data-id="'+ data.layerId + '" data-name="' + data.layerName + '" data-description="' + data.layerDescrption + '" src="images/pencil.png" alt="Edit" title="Edit layer" data-toggle="custom__modal" data-target="editLayer"  border="0" width="20"> \
                  </td></tr>'
            );
        }
        else{
            var newTr = jQuery('<tr><td>' + data.layerName + '</td><td>' + data.layerDescrption + '</td>\
                  <td>\
                    <img class="editLayerDetail" data-id="'+ data.layerId + '" data-name="' + data.layerName + '" data-description="' + data.layerDescrption + '" src="images/pencil.png" alt="Edit" title="Edit layer" data-toggle="custom__modal" data-target="editLayer"  border="0" width="20"> \
                    <svg class="deleteLayerDetail" data-id="'+ data.layerId + '"  height="30px" viewBox="-40 0 427 427.00131" width="30"><title>Delete layer</title><path d="m232.398438 154.703125c-5.523438 0-10 4.476563-10 10v189c0 5.519531 4.476562 10 10 10 5.523437 0 10-4.480469 10-10v-189c0-5.523437-4.476563-10-10-10zm0 0"/><path d="m114.398438 154.703125c-5.523438 0-10 4.476563-10 10v189c0 5.519531 4.476562 10 10 10 5.523437 0 10-4.480469 10-10v-189c0-5.523437-4.476563-10-10-10zm0 0"/><path d="m28.398438 127.121094v246.378906c0 14.5625 5.339843 28.238281 14.667968 38.050781 9.285156 9.839844 22.207032 15.425781 35.730469 15.449219h189.203125c13.527344-.023438 26.449219-5.609375 35.730469-15.449219 9.328125-9.8125 14.667969-23.488281 14.667969-38.050781v-246.378906c18.542968-4.921875 30.558593-22.835938 28.078124-41.863282-2.484374-19.023437-18.691406-33.253906-37.878906-33.257812h-51.199218v-12.5c.058593-10.511719-4.097657-20.605469-11.539063-28.03125-7.441406-7.421875-17.550781-11.5546875-28.0625-11.46875h-88.796875c-10.511719-.0859375-20.621094 4.046875-28.0625 11.46875-7.441406 7.425781-11.597656 17.519531-11.539062 28.03125v12.5h-51.199219c-19.1875.003906-35.394531 14.234375-37.878907 33.257812-2.480468 19.027344 9.535157 36.941407 28.078126 41.863282zm239.601562 279.878906h-189.203125c-17.097656 0-30.398437-14.6875-30.398437-33.5v-245.5h250v245.5c0 18.8125-13.300782 33.5-30.398438 33.5zm-158.601562-367.5c-.066407-5.207031 1.980468-10.21875 5.675781-13.894531 3.691406-3.675781 8.714843-5.695313 13.925781-5.605469h88.796875c5.210937-.089844 10.234375 1.929688 13.925781 5.605469 3.695313 3.671875 5.742188 8.6875 5.675782 13.894531v12.5h-128zm-71.199219 32.5h270.398437c9.941406 0 18 8.058594 18 18s-8.058594 18-18 18h-270.398437c-9.941407 0-18-8.058594-18-18s8.058593-18 18-18zm0 0"/><path d="m173.398438 154.703125c-5.523438 0-10 4.476563-10 10v189c0 5.519531 4.476562 10 10 10 5.523437 0 10-4.480469 10-10v-189c0-5.523437-4.476563-10-10-10zm0 0"/></svg>\
                  </td></tr>'
            );
        }
        newTr.find('.editLayerDetail').on('click', function () {
            setupEditedLayerValues(jQuery(this));
        })
        newTr.find('.deleteLayerDetail').on('click', function () {
            deleteSelectedLayerInfo(jQuery(this));
        })
        jQuery("#allLayers .reset__table tbody").append(newTr);
    }
    if (document.querySelectorAll('#allLayers .reset__table tbody [data-toggle="custom__modal"]')) {
        var allModals = document.querySelectorAll('#allLayers .reset__table tbody [data-toggle="custom__modal"]');
        modalPoupInit(allModals);
    }
}
//init function to toggle modal popup
function modalPoupInit(allModals) {
    allModals.forEach(function (node) {
        node.addEventListener("click", function (event) {
            if (document.querySelector('.custom__modal.show')) {
                document.querySelector('.custom__modal.show').style.display = "none";
                document.querySelector('.custom__modal.show').classList.remove("show");
            }
            var targetModal = document.getElementById(event.target.getAttribute("data-target"));
            targetModal.classList.add("show");
            targetModal.style.display = "block";
            targetModal.querySelector(".close").onclick = function () {
                targetModal.style.display = "none";
            }
        })
    })
}
setTimeout(function () {
    var allModals = document.querySelectorAll('[data-toggle="custom__modal"]');
    modalPoupInit(allModals);
}, 300)
//close popup out side click
window.onclick = function (event) {
    if (event.target.classList.contains("custom__modal")) {
        var modalTargeted = document.querySelector('.custom__modal.show');
        modalTargeted.style.display = "none";
        modalTargeted.classList.remove('show');
    }
}
//submit/add new layer info
function submitNewLayer() {
    var LayerType = document.getElementById('LayerName').value;
    var LayerId = document.getElementById('LayerDesc').value;
    if (LayerType && LayerId) {
        jQuery.ajax({
            type: 'POST',
            contentType: "application/json",
            dataType: 'json',
            url: "/ScadaLTS/servlet/AddLayer",
            data: JSON.stringify({ "layerName": LayerType, "layerDescription": LayerId }),
            success: function (msg) {
                alert(msg.success);
                getAllLayersInfo();
                document.querySelector('.custom__modal.show').click();
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("Problem creating layer:" + errorThrown.message);
            }
        });
    }
    else {
        alert('Name & description both are required!')
    }
}
//submit/add new layer info
function getAllLayersInfo() {
    jQuery.ajax({
        type: 'GET',
        url: "/ScadaLTS/servlet/GetAllLayer",
        success: function (data) {
            var resp = JSON.parse(data);
            generateLayerInfoTableRows(resp["data"]);
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            console.warn(errorThrown.message)
        }
    });
}
setTimeout(function () {
    getAllLayersInfo();
}, 500)
//submit edited layer info
function submitEditedLayer() {
    var LayerId = document.getElementById('EditedLayerId').value;
    var LayerType = document.getElementById('EditedLayerName').value;
    var LayerDesc = document.getElementById('EditedLayerDesc').value;
    if (LayerType && LayerDesc) {
        jQuery.ajax({
            type: 'POST',
            contentType: "application/json",
            dataType: 'json',
            url: "/ScadaLTS/servlet/UpdateLayer",
            data: JSON.stringify({ "layerId": LayerId, "layerName": LayerType, "layerDescription": LayerDesc }),
            success: function (msg) {
                alert(msg.success);
                getAllLayersInfo();
                document.querySelector('.custom__modal.show').click();
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                alert("Problem editing layer:" + errorThrown.message);
            }
        });
    }
    else {
        alert('Name & description both are required!')
    }
}
//setup editing layer info
function setupEditedLayerValues($this) {
    document.getElementById('EditedLayerId').value = $this.data('id');
    document.getElementById('EditedLayerName').value = $this.data('name');
    document.getElementById('EditedLayerDesc').value = $this.data('description');
}
//Delete clicked layer info
function deleteSelectedLayerInfo($this) {
    jQuery.ajax({
        type: 'POST',
        contentType: "application/json",
        dataType: 'json',
        url: "/ScadaLTS/servlet/DeleteLayer",
        data: JSON.stringify({ "layerId": $this.data('id') }),
        success: function (msg) {
            alert(msg.success);
            $this.closest('tr').remove();
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
            alert("Problem creating layer:" + errorThrown.message);
        }
    });
}