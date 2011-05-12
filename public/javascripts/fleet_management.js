var FleetManagementHandler = {
  droppables: [],
  availDroppable: null,
  lastDroppablesIndex: -1,
  lastPosition: null,

  _prepareAjaxRequest: function(obj_id, method, enroll_id, fr_id, onSuccess) {
    var targetUrl = '/fleet_race_memberships/'+(obj_id?obj_id:'');
    var params = { method: 'post', parameters: {} };
    params['parameters']['_method'] = method;
    if (enroll_id) params['parameters']['fleet_race_membership[enrollment_id]'] = enroll_id;
    if (fr_id) params['parameters']['fleet_race_membership[fleet_race_id]'] = fr_id;
    if (onSuccess) params['onSuccess'] = onSuccess;
    params['onComplete'] = function(transport) { Hobo.hideSpinner(); };
    params['onFailure'] = function(transport) { FleetManagementHandler.onFailedAjaxReq(); };
    return { targetUrl: targetUrl, params: params};
  },

  _updateDroppablesPos: function() {
    FleetManagementHandler.droppables.each(function(obj) {
      obj.y = obj.drop.element.cumulativeOffset()[1];
      obj.yEnd = obj.y + obj.drop.element.getHeight();
    });
    FleetManagementHandler.y1End = FleetManagementHandler.y1Start + FleetManagementHandler.availDroppable.element.getHeight();
  },

  onFailedAjaxReq: function() {
    $$('.content')[0].insert(
      {'top': '<div class="flash notice">Error getting response from server, page may contain invalid data. Please refresh the page to fix it!</div>'}
    );
  },

  show: function(point, element) {
    //console.log(point+','+FleetManagementHandler.lastPosition+','+FleetManagementHandler.lastDroppablesIndex);
    var drop = null;
    var obj = null;
    if (point[0] >= FleetManagementHandler.x0Start && point[0] <= FleetManagementHandler.x0End) {
      if (FleetManagementHandler.lastDroppablesIndex >= 0) {
        if (point[1] >= FleetManagementHandler.lastPosition[1]) { // new y is bigger
          for (i=FleetManagementHandler.lastDroppablesIndex; i < FleetManagementHandler.droppables.length; i++) {
            obj = FleetManagementHandler.droppables[i];
            if (obj.y <= point[1] && obj.yEnd >= point[1]) {
              drop = obj.drop;
              FleetManagementHandler.lastDroppablesIndex = i;
              break;
            }
          }
        } else { // new y is smaller
          for (i=FleetManagementHandler.lastDroppablesIndex; i > -1; i--) {
            obj = FleetManagementHandler.droppables[i];
            if (obj.y < point[1] && obj.yEnd > point[1]) {
              drop = obj.drop;
              FleetManagementHandler.lastDroppablesIndex = i;
              break;
            }
          }
        }
      } else {  // new drag
        for (i=0; i < FleetManagementHandler.droppables.length; i++) {
          obj = FleetManagementHandler.droppables[i];
          if (obj.y < point[1] && obj.yEnd > point[1]) {
            drop = obj.drop;
            FleetManagementHandler.lastDroppablesIndex = i;
            break;
          }
        }
      }
      if (drop == null) {
        FleetManagementHandler.lastDroppablesIndex = -1;
      }
    } else if (point[0] >= FleetManagementHandler.x1Start && point[0] <= FleetManagementHandler.x1End
        && point[1] >= FleetManagementHandler.y1Start && point[1] <= FleetManagementHandler.y1End) {
      drop = FleetManagementHandler.availDroppable;
      FleetManagementHandler.lastDroppablesIndex = -1;
    } else {
      FleetManagementHandler.lastDroppablesIndex = -1;
    }
    if (Droppables.last_active && Droppables.last_active != drop) {
      Droppables.deactivate(Droppables.last_active);
    }
    if (drop && drop != Droppables.last_active) {
      Droppables.activate(drop);
    }
    FleetManagementHandler.lastPosition = point;
  },

  onDrop: function(dragged, dropped, event) {
    Position.prepare();
    /*$$('.enrollments').each(function(elem) {
      console.log(elem.id+': '+elem.cumulativeOffset()+' '+elem.getHeight()+' '+elem.cumulativeScrollOffset());
    });*/
    var drag = Draggables.activeDraggable;
    drag.element.style.top = '0px';
    drag.element.style.left = '0px';
    var orig_fleet = $w(drag.element.parentNode.className)[1];
    //console.log('|'+orig_fleet+'| - |'+dropped.id+'|');
    if ($(orig_fleet) == dropped) { // on the same droppable
      return;
    }
    if ($(dropped).childElements().length == 1) {
      $(dropped).childElements()[0].style.display = 'none';
    }
    dropped.insert(drag.element.parentNode);
    drag.element.parentNode.className = 'item '+dropped.id+' editable';
    if ($(orig_fleet).childElements().length == 1) {
      $(orig_fleet).childElements()[0].style.display = 'block';
    }
    var objectId = drag.element.parentNode.id.substr(4);
    var targetId = dropped.id.substr(6);
    var data = {};
    if (dropped.id == 'available') {
      Hobo.showSpinner('Updating...');
      //console.log('unassign '+objectId);
      data = FleetManagementHandler._prepareAjaxRequest(
        objectId, 'delete', null, null,
        function(transport) {
          drag.element.parentNode.id = drag.element.id+'_null';
        }
      );
    } else if (orig_fleet == 'available') {
      Hobo.showSpinner('Updating...');
      objectId = drag.element.parentNode.id.substr(11);
      //console.log('assign '+objectId+','+targetId);
      data = FleetManagementHandler._prepareAjaxRequest(
        null, 'post', objectId, targetId,
        function(transport) {
          drag.element.parentNode.id = 'frm_'+transport.responseJSON['fleet_race_membership'].id;
        }
      );
    } else {
      Hobo.showSpinner('Updating...');
      //console.log('change assignment '+objectId+','+targetId);
      data = FleetManagementHandler._prepareAjaxRequest(
        objectId, 'put', null, targetId,
        null
      );
    }
    new Ajax.Request(data.targetUrl, data.params);
    FleetManagementHandler._updateDroppablesPos();
  },

  createDnD: function(event) {
    Droppables.show = FleetManagementHandler.show;
    Position.includeScrollOffsets = true; // make sure it works when the div is scrolled

    $$('.enrollment').each(function(elem) {
      new Draggable(elem, {
        revert: 'failed',
        onEnd: FleetManagementHandler.onEnd,
      });
    });

    $$('.enrollments').each(function(elem) {
      Droppables.add(elem.id, {
        accept: 'enrollment',
        hoverclass: 'highlight',
        onDrop: FleetManagementHandler.onDrop,
      });
    });

    Droppables.drops.each(function(droppable) {
      if ($(droppable.element) != $('available')) {
        obj = {drop: droppable};
        obj['y'] = droppable.element.cumulativeOffset()[1];
        obj['yEnd'] = obj['y']+droppable.element.getHeight();
        FleetManagementHandler.droppables.push(obj);
        //console.log(droppable.element.cumulativeOffset()[1]+': '+droppable.element.id);
      } else {
        FleetManagementHandler.availDroppable = droppable;
      }
    });

    var elem0 = $$('.enrollments')[0];
    var elem1 = $('available');
    var x0, x1, y1;
    Position.prepare();
    x0 = elem0.cumulativeOffset()[0];
    FleetManagementHandler.x0Start = x0;
    FleetManagementHandler.x0End = x0 + elem0.getWidth();
    x1 = elem1.cumulativeOffset()[0];
    FleetManagementHandler.x1Start = x1;
    FleetManagementHandler.x1End = x1 + elem1.getWidth();
    y1 = elem1.cumulativeOffset()[1];
    FleetManagementHandler.y1Start = y1
    FleetManagementHandler.y1End = y1 + elem1.getHeight();
  },
}
