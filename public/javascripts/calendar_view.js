var CalendarViewHandler = {
  isDragging: false,
  onDroppables: false,
  lastDraggable: null,
  lastDraggableLastPost: [],
  droppables: [],
  draggables: [],
  rowTimeslot: [],
  modal: null,
  objectToUndo: null,
  can_create: false,

  // --- Helpers --------------------------------------------------------------

  _decodeTime: function(id) {
    var dateEnc = id.substr(3);
    var dateDec = [];
    dateDec['year'] = dateEnc.substr(0,4);
    dateDec['month'] = dateEnc.substr(4,2);
    dateDec['day'] = dateEnc.substr(6,2);
    dateDec['hour'] = dateEnc.substr(8,2);
    dateDec['minute'] = dateEnc.substr(10,2);
    return dateDec;
  },

  openModal: function() {
    if (CalendarViewHandler.modal == null) {
      CalendarViewHandler.modal = new Control.Modal($('newform'), {
        overlayOpacity: 0.75,
        className: 'modal',
        fade: true,
      });
    }
    CalendarViewHandler.modal.open();
  },

  closeModal: function() {
    if (CalendarViewHandler.modal != null) {
      CalendarViewHandler.modal.close();
    }
  },

  _fleetAdded: function(drag) {
    drag.element.style.position = 'absolute';
    drag.options.onStart = CalendarViewHandler.onStartInCalendar;
    drag.options.onEnd = CalendarViewHandler.onEndInCalendar;
    drag.options.revert = false;
    drag.options.ghosting = false;
    drag._isScrollChild = true;
    $('overlays').insert(drag.element);
  },

  _resetFleetPos: function(drag) {
    drag.element.style.position = 'relative';
    drag.options.onStart = CalendarViewHandler.onStart;
    drag.options.onEnd = CalendarViewHandler.onEnd;
    drag.options.revert = true;
    drag.options.scroll = false;
    drag.options.ghosting = true;
    drag.delta[0] = 0;//drag.element.offsetLeft;
    drag.delta[1] = 0;//drag.element.offsetTop;
    $('fleetscontainer').insert(drag.element);
  },

  _revertElement: function(drag) {
    var delta = CalendarViewHandler.lastDraggableLastPost;
    var d = drag.currentDelta();
    drag.options.reverteffect(drag.element, d[1]-delta[1], d[0]-delta[0]);
  },

  _prepareForUpdate: function(elem, droppedId) {
    var objectId = elem.id.substr(5);
    CalendarViewHandler._setUndo({'id': objectId, 'info': elem.className});
    var dateDec = CalendarViewHandler._decodeTime(droppedId); 
    var result = {};
    var params = {'_method': 'put'};
    var prefix;
    if (elem.hasClassName('fleet')) {
      result['targetUrl'] = '/fleet_races/'+objectId;
      prefix = 'fleet_race';
    } else {
      result['targetUrl'] = '/calendar_entries/'+objectId;
      prefix = 'calendar_entry';
    }
    params[prefix+'[scheduled_time_event][year]'] = dateDec['year'];
    params[prefix+'[scheduled_time_event][month]'] = dateDec['month'];
    params[prefix+'[scheduled_time_event][day]'] = dateDec['day'];
    params[prefix+'[scheduled_time_event][hour]'] = dateDec['hour'];
    params[prefix+'[scheduled_time_event][minute]'] = dateDec['minute'];
    result['params'] = params;
    return result;
  },

  _prepareForm: function(dateDec) {
    $$('.scheduled-time-event-view select').each(function(elem){elem.style.display='none';});
    $$('.scheduled-time-event-view input').each(function(elem){elem.style.display='none';});
    $$('.scheduled-time-event-view a').each(function(elem){elem.style.display='none';});
    $('calendar_entry_scheduled_time_event').value =
        dateDec['year']+'-'+dateDec['month']+'-'+dateDec['day']+' '+
        dateDec['hour']+':'+dateDec['minute']+':00';
    var scheduledTimeText = dateDec['year']+'-'+dateDec['month']+'-'+dateDec['day']+' '+dateDec['hour']+':'+dateDec['minute'];
    if ($('scheduled-time-event-text')) {
      $('scheduled-time-event-text').innerHTML = scheduledTimeText;
    } else {
      $$('.scheduled-time-event-view')[0].insert("<span id='scheduled-time-event-text'>"+scheduledTimeText+"</span>");
    }
  },

  _reFlowElemsInBox: function(boxId) {
    var elem = $(boxId);
    var boxTop;
    if (elem.offsetParent.id.length == 0) {
      boxTop = elem.offsetTop + elem.offsetParent.offsetTop;
    } else {
      boxTop = elem.offsetTop;
    }
    var newTop = 0;
    $$('.'+boxId).each(function(elem) {
      elem.style.top = (boxTop+newTop)+'px';
      newTop += 20;
    });
  },

  _recalculateRowHeight: function(rowId) {
    var maxEntries = 1;
    var entriesCount = 0;
    $$('.row_'+rowId).each(function(elem) {
      entriesCount = $$('.'+elem.id).length; 
      if (entriesCount > maxEntries) {
        maxEntries = entriesCount;
      }
    });
    $$('.row_'+rowId).each(function(elem) {
      elem.style.height = (maxEntries*20-1)+'px';
    });
    return maxEntries;
  },

  _setUndo: function(objectToUndo) {
    if (objectToUndo == null) {
      CalendarViewHandler.objectToUndo = null;
      $('undo_link').style.display = 'none';
    } else {
      CalendarViewHandler.objectToUndo = objectToUndo;
      $('undo_link').style.display = 'block';
    }
  },

  _resizeCalendarView: function() {
    var e = window, a = 'inner';
    if (!('innerHeight' in window)) {
      a = 'client';
      e = document.documentElement || document.body;
    }
    var viewportHeight = e[a+'Height'];
    var elem = $('contentcontainer');
    var elemHeight = (viewportHeight - elem.cumulativeOffset()[1]-35);
    elem.style.height = elemHeight+'px';
    if ($('fleetscontainer')) {
      $('fleetscontainer').style.height = elemHeight+'px';
    }
  },

  // --- setup stuff ----------------------------------------------------------

  scrollViewTo8AM: function() {
    var elem8AM = $$('.cell_224')[0];
    var boxTop;
    if (elem8AM.offsetParent.id.length ==0) {
      boxTop = elem8AM.offsetTop + elem8AM.offsetParent.offsetTop;
    } else {
      boxTop = elem8AM.offsetTop;
    }
    $('contentcontainer').scrollTop = boxTop;
  },

  createDnD: function(event, isAjax) {
    Droppables.show = CalendarViewHandler.show;
    Position.includeScrollOffsets = true; // make sure it works when the div is scrolled
    var drag;

    // draggables for calendar entries
    $$('.entry').each(function(elem) {
      drag = new Draggable(elem, {
        revert: false,//'failure',
        scroll: 'contentcontainer',
        onStart: CalendarViewHandler.onStartInCalendar,
        onEnd: CalendarViewHandler.onEndInCalendar,
      });
      CalendarViewHandler.draggables[elem.id] = drag;
      Event.observe(elem.childElements()[0], 'mouseup', CalendarViewHandler.editEntry);
    });

    // droppables
    $$('.calendar_droppables').each(function(elem) {
      Droppables.add(elem.id, {
        quiet: true,
        hoverclass: 'highlight',
        accept: ['entry','fleet'],
        onDrop: CalendarViewHandler.onDrop
      });
      Event.observe(elem, 'click', CalendarViewHandler.createEntry);
    });
    Droppables.drops.each(function(droppable) {
      var classId = $w(droppable.element.className)[1];
      CalendarViewHandler.droppables[classId] = droppable;
    });

    // draggables for fleets
    $$('.fleet').each(function(elem) {
      if (elem.parentNode.id == 'overlays') {
        drag = new Draggable(elem, {
          revert: false,//'failure',
          scroll: 'contentcontainer',
          onStart:  CalendarViewHandler.onStartInCalendar,
          onEnd: CalendarViewHandler.onEndInCalendar,
        });
        CalendarViewHandler.draggables[elem.id] = drag;
      } else {
        if (!isAjax) {
          drag = new Draggable(elem, {
            revert: 'true',
            scroll: 'contentcontainer',
            ghosting: true,
            onStart:  CalendarViewHandler.onStart,
            onEnd: CalendarViewHandler.onEnd,
          });
          CalendarViewHandler.draggables[elem.id] = drag;
        }
      }
    });

    if (!isAjax) {
    // row position
      var index = 0;
      while (index < 671) {
        for (i=0; i<4; i++) {
          var cellClass = '.cell_'+(index+i);
          CalendarViewHandler.rowTimeslot.push($$(cellClass)[0]);
        }
        index += 28;
      }
    }
  },

  adjustCalendarView: function(event) {
    var newWidth = $('tableheader').getWidth()-$('tablecontent').getWidth()-1;
    $('scrollpad').style.width = newWidth+'px';
    //console.log('adjustCalendarView '+$('scrollpad').style.width+','+$('tableheader').getWidth()+','+$('tablecontent').getWidth()+','+newWidth);
    var firstContentRow = $('tablecontent').childElements()[0].childElements()[0];
    for (var i=0; i<8; i++) {
      var cellWidth = $('headerrow').childElements()[i].getWidth();
      if (i > 0) {
        cellWidth = cellWidth - 1;
      }
      firstContentRow.childElements()[i].style.width = cellWidth+'px';
    }

    var boxId;
    $$('.entry').each(function(elem) {
      boxId = $w(elem.className)[1];
      $(boxId).addClassName('has_entries');
      if (elem.scrollHeight > elem.clientHeight || elem.scrollWidth > elem.clientWidth) {
        Event.observe(elem, 'mouseover', CalendarViewHandler.expandEntry);
        Event.observe(elem, 'mouseout', CalendarViewHandler.restoreEntryWidth);
      }
    });
    $$('.fleet').each(function(elem) {
      if (elem.parentNode.id == 'overlays') {
        boxId = $w(elem.className)[1];
        $(boxId).addClassName('has_entries');
      }
      if (elem.scrollHeight > elem.clientHeight || elem.scrollWidth > elem.clientWidth) {
        Event.observe(elem, 'mouseover', CalendarViewHandler.expandEntry);
        Event.observe(elem, 'mouseout', CalendarViewHandler.restoreEntryWidth);
      }
    });

    //reflowCalendarView();
    CalendarViewHandler._resizeCalendarView();
  },


  // --- Scriptaculous patch --------------------------------------------------

  show: function(point, element) {
    var drop = null;
    Position.prepare();
    var cso0 = $$('.cell_0')[0].cumulativeScrollOffset();
    var co0 = $$('.cell_0')[0].cumulativeOffset();
    var co671 = $$('.cell_671')[0].cumulativeOffset();
    var xCoord = point[0]-co0[0]+cso0[0];
    var yCoord = point[1]-co0[1]+(cso0[1]-Position.deltaY); 
    var cellX = Math.floor(xCoord/115); 
    var cellY = Math.floor(yCoord/20);
    if (xCoord < 0 || xCoord > 115*6+110 || yCoord <0 || yCoord > (co671[1]-co0[1]+20)) {
      // not on droppables..
    } else {
      if (cellY >= 96) cellY = 95; // this is possible when timeslot height is adjusted
      var cellrowco = CalendarViewHandler.rowTimeslot[cellY].cumulativeOffset();
      var cellrowy = cellrowco[1]-co0[1];
      while (cellrowy > yCoord) {
        cellY--;
        cellrowco = CalendarViewHandler.rowTimeslot[cellY].cumulativeOffset();
        cellrowy = cellrowco[1]-co0[1];
      }
      var cellClassId = 'cell_'+(Math.floor(cellY/4)*28 + cellY%4 + (cellX*4));
      drop = CalendarViewHandler.droppables[cellClassId]; 
    }
    if (Droppables.last_active && Droppables.last_active != drop) {
      Droppables.deactivate(Droppables.last_active);
    }
    if (drop && drop != Droppables.last_active) {
      Droppables.activate(drop);
    }
  },


  // --- AJAX Handler ---------------------------------------------------------

  onSuccessDelete: function(drag) {
    var elemClassNames = $w(drag.element.className);
    if (elemClassNames[0] == 'fleet') {
      CalendarViewHandler._resetFleetPos(drag);
    } else {
      // clean up
      elem = drag.element;
      drag.destroy();
      elem.remove();
    }
    drag.element.className = elemClassNames[0];

    var oldBoxId = elemClassNames[1];
    var oldRowId = elemClassNames[2].substr(6);
    var oldBoxNewEntryCount = $$('.'+oldBoxId).length;
    if (oldBoxNewEntryCount > 0) {
      CalendarViewHandler._recalculateRowHeight(oldRowId);
      $$('.has_entries').each(function(elem) {
        var boxId = elem.id;
        CalendarViewHandler._reFlowElemsInBox(boxId);
      });
    } else {
      $(oldBoxId).removeClassName('has_entries');
    }
  },

  onSuccessUpdate: function(drag, dropped) {
    drag.element.style.left = $(dropped).offsetLeft+'px';
    drag.element.style.top = $(dropped).offsetTop+'px';
    drag.delta[0] = $(dropped).offsetLeft;
    drag.delta[1] = $(dropped).offsetTop;
    var elemClassNames = $w(drag.element.className);
    drag.element.className = elemClassNames[0]+' '+dropped.id+' in'+$w(dropped.className)[2];
    $(dropped).addClassName('has_entries');
    var reflowOldBox = false;
    if (drag.element.hasClassName('fleet') && drag.element.parentNode.id != 'overlays') {
      CalendarViewHandler._setUndo(null);
      CalendarViewHandler._fleetAdded(drag);
    } else {
      var oldBoxId = elemClassNames[1];
      var oldRowId = elemClassNames[2].substr(6);
      var oldBoxNewEntryCount = $$('.'+oldBoxId).length;
      if (oldBoxNewEntryCount > 0) {
        CalendarViewHandler._recalculateRowHeight(oldRowId);
        reflowOldBox = true;
      } else {
        $(oldBoxId).removeClassName('has_entries');
      }
    }

    var reflowNewRow = false;
    var newBoxContent = $$('.'+dropped.id);
    if (newBoxContent.length > 1) {
      var lastElemForBox = newBoxContent[newBoxContent.length-1];
      lastElemForBox.insert({'after': drag.element});
      reflowNewRow = true;
      var rowId = dropped.id.substr(11);
      CalendarViewHandler._recalculateRowHeight(rowId);
      CalendarViewHandler._reFlowElemsInBox(dropped.id);
    }

    if (reflowNewRow || reflowOldBox) {
      $$('.has_entries').each(function(elem) {
        var boxId = elem.id;
        CalendarViewHandler._reFlowElemsInBox(boxId);
      });
    }
  },

  onFailedAjaxReq: function(msg) {
    if (msg.responseText) {
      msg = msg.responseText;
    } else {
      msg = 'Error getting response from server, page may contain invalid data. Please refresh the page to fix it!';
    }
    $$('.content')[0].insert(
      {'top': '<div class="flash error-messages">'+msg+'</div>'}
    );
    $$('.flash')[0].fade({delay: 5.0, duration: 2.0});
  },

  // --- DnD Handler ----------------------------------------------------------

  onStart: function(drag, event) {
    CalendarViewHandler.isDragging = true;
    var elem = drag.element;
    elem.style.zIndex = 1000;
    if (elem.parentNode.id == 'fleetscontainer') {
      $('fleetscontainer').getElementsBySelector('#'+elem.id)[0].style.visibility = 'hidden';
    }
  },

  onEnd: function(drag, event) {
    CalendarViewHandler.isDragging = false;
    $('contentcontainer').scrollLeft = 0;
  },

  onStartInCalendar: function(drag, event) {
    CalendarViewHandler.onStart(drag, event);
    CalendarViewHandler.lastDraggableLastPost = drag.currentDelta();
  },

  onEndInCalendar: function(drag, event) {
    CalendarViewHandler.onEnd(drag, event);
    CalendarViewHandler.lastDraggable = drag;
    if (!CalendarViewHandler.onDroppables) {
      if (confirm('Are you sure you want to delete/unschedule '+drag.element.childElements()[0].innerHTML)) {
        objectId = drag.element.id.substr(5);
        var targetUrl = '';
        var params = null;
        if (drag.element.hasClassName('fleet')) {
          targetUrl = '/fleet_races/'+objectId;
          params = {
            '_method': 'put',
            'fleet_race[scheduled_time_event]': null,
          };
        } else {
          targetUrl = '/calendar_entries/'+objectId;
          params = {'_method': 'delete'};
        }
        Hobo.showSpinner('Deleting...');
        CalendarViewHandler._setUndo(null);
        new Ajax.Request(targetUrl, {
          method: 'post',
          parameters: params,
          //onSuccess: function(transport) { CalendarViewHandler.onSuccessDelete(drag); },
          onFailure: function(transport) { CalendarViewHandler.onFailedAjaxReq(transport); },
          onComplete: function(transport) { Hobo.hideSpinner(); },
        });
        CalendarViewHandler.onSuccessDelete(drag);

      } else {
        CalendarViewHandler._revertElement(drag);
      }
    } else {
      drag.options.revert = false;
    }
    CalendarViewHandler.onDroppables = false;
  },

  onDrop: function(dragged, dropped, event) {
    CalendarViewHandler.isDragging = false;
    CalendarViewHandler.onDroppables = true;
    var drag = Draggables.activeDraggable; // dragged is just the element, we need the draggable object!
    if (drag.element.hasClassName(dropped.id)) { // dropped on the same box
      CalendarViewHandler._revertElement(drag);
      return;
    }

    var updateData = CalendarViewHandler._prepareForUpdate(drag.element, dropped.id);
    Hobo.showSpinner('Updating...');
    new Ajax.Request(updateData.targetUrl, {
      method: 'post',
      parameters: updateData.params,
      //onSuccess: function(transport) { CalendarViewHandler.onSuccessUpdate(drag, dropped); },
      onFailure: function(transport) { CalendarViewHandler.onFailedAjaxReq(transport); },
      onComplete: function(transport) { Hobo.hideSpinner(); },
    });
    CalendarViewHandler.onSuccessUpdate(drag, dropped);

  }, 

  createEntry: function(event) {
    $('calendar-entry-form').action = window.location.pathname;
    $('calendar_entry_name').value = '';
    if ($('_method')) {
      $('_method').value = 'POST';
    }
    var dateDec = CalendarViewHandler._decodeTime(event.currentTarget.id);
    CalendarViewHandler._prepareForm(dateDec);
    CalendarViewHandler.openModal();
  },

  editEntry: function(event) {
    if (CalendarViewHandler.isDragging) {
      return;
    }
    var elem = event.currentTarget.parentNode;
    $('entry-elem-id').value = elem.id;
    var dateDec = CalendarViewHandler._decodeTime($w(elem.className)[1]);
    CalendarViewHandler._prepareForm(dateDec);
    $('calendar-entry-form').action = '/calendar_entries/'+elem.id.substr(5);
    $('calendar_entry_name').value = event.currentTarget.innerHTML;
    if ($('_method')) {
      $('_method').value = 'PUT';
    } else {
      $('page_path').insert({'after': "<input type='hidden' id='_method' name='_method' value='PUT'>"});
    }
    $$('.scheduled-time-event-view select').each(function(elem){elem.style.display='none';});
    CalendarViewHandler.openModal();
  },

  onSubmit: function(event) {
    CalendarViewHandler.closeModal();
    Hobo.showSpinner('Saving...');
    var succesId = '';
    if ($('_method') && $('_method').value == 'PUT') {
      successId = 'scheduled-time-event-text';  // update
    } else {
      successId = 'overlays';  // create
    }
    CalendarViewHandler._setUndo(null);
    new Ajax.Updater({ success: successId}, $('calendar-entry-form').action+'?'+$('params').value, {
      asynchronous: true,
      evalScripts: true,
      parameters: Form.serialize($('calendar-entry-form')),
      onFailure: function(transport) {
        CalendarViewHandler.onFailedAjaxReq(transport);
      },
      onSuccess: function(transport) {
        if ($('_method') && $('_method').value == 'PUT') {  // update
          var elem = $($('entry-elem-id').value);
          elem.childElements()[0].innerHTML = $('calendar_entry_name').value;
          if (elem.scrollHeight > elem.clientHeight || elem.scrollWidth > elem.clientWidth) {
            Event.observe(elem, 'mouseover', CalendarViewHandler.expandEntry);
            Event.observe(elem, 'mouseout', CalendarViewHandler.restoreEntryWidth);
          }
        }
      },
      onComplete: function(transport) { Hobo.hideSpinner(); },
    });
    event.stop();
  },

  expandEntry: function(event) {
    if (CalendarViewHandler.isDragging) {
      return;
    }
    var elem = (event.currentTarget) ? event.currentTarget : event.srcElement;
    elem.style.zIndex=100;
    while (elem.scrollHeight > elem.clientHeight || elem.scrollWidth > elem.clientWidth) {
      elem.style.width = (elem.clientWidth+10)+'px';
    }
  },

  restoreEntryWidth: function(event) {
    if (CalendarViewHandler.isDragging) {
      return;
    }
    var elem = (event.currentTarget) ? event.currentTarget : event.srcElement;
    elem.style.width='113px';
    elem.style.zIndex=0;
  },

  undoLastUpdate: function(event) {
    var objectId = CalendarViewHandler.objectToUndo.id;
    var classNames = $w(CalendarViewHandler.objectToUndo.info);
    var drag = CalendarViewHandler.draggables[classNames[0]+objectId];
    var dropped = $(classNames[1]);

    var updateData = CalendarViewHandler._prepareForUpdate(drag.element, dropped.id);
    Hobo.showSpinner('Undoing...');
    new Ajax.Request(updateData.targetUrl, {
      method: 'post',
      parameters: updateData.params,
      //onSuccess: function(transport) { CalendarViewHandler.onSuccessUpdate(drag, dropped); },
      onFailure: function(transport) { CalendarViewHandler.onFailedAjaxReq(transport); },
      onComplete: function(transport) { Hobo.hideSpinner(); },
    });
    CalendarViewHandler.onSuccessUpdate(drag, dropped);
    CalendarViewHandler._setUndo(null);
  },

  onLoad: function(event) {
    CalendarViewHandler.adjustCalendarView();
    CalendarViewHandler.scrollViewTo8AM();
    if (CalendarViewHandler.can_create) {
      CalendarViewHandler.createDnD(event, false);

      // post-load
      Event.observe('calendar-entry-form', 'submit', CalendarViewHandler.onSubmit);
      Event.observe('cancel-button', 'click', CalendarViewHandler.closeModal);
    }

    // post-load
    Event.observe('course_area_id', 'change', function(event) { $('page-form').submit(); });
    $('change_course_area').style.display = 'none';

    Event.observe('undo_link','click', CalendarViewHandler.undoLastUpdate);
  }
}
