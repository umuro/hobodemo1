
function adjustCalendarView(event) {
  $('scrollpad').style.width = $('tableheader').getWidth()-$('tablecontent').getWidth()-1+'px';
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
      if (elem.scrollHeight > elem.clientHeight || elem.scrollWidth > elem.clientWidth) {
        Event.observe(elem, 'mouseover', CalendarViewHandler.expandEntry);
        Event.observe(elem, 'mouseout', CalendarViewHandler.restoreEntryWidth);
      }
    }
  });

  //reflowCalendarView();
  resizeCalendarView();
}

function resizeCalendarView() {
  var e = window, a = 'inner';
  if (!('innerHeight' in window)) {
    a = 'client';
    e = document.documentElement || document.body;
  }
  var viewportHeight = e[a+'Height'];
  var elem = $('contentcontainer');
  var elemHeight = (viewportHeight - elem.cumulativeOffset()[1]-35);
  elem.style.height = elemHeight+'px';
}

function reflowCalendarView() {
  var recalculatedRows = [];
  $$('.has_entries').each(function(elem) {
    var rowId = $w(elem.className)[2].substr(4);
    if (recalculatedRows[rowId] == undefined) {
      CalendarViewHandler._recalculateRowHeight(rowId);
      recalculatedRows[rowId] = true;
    }
  });
  $$('.has_entries').each(function(elem) {
    var boxId = elem.id;
    CalendarViewHandler._reFlowElemsInBox(boxId);
  });
}

var CalendarViewHandler = {
  isDragging: false,
  onDroppables: false,
  lastDraggable: null,
  lastDraggableLastPost: [],
  droppables: [],
  rowTimeslot: [],
  modal: null, 

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
        fade: true  
      });
    }
    CalendarViewHandler.modal.open();
  },

  closeModal: function() {
    if (CalendarViewHandler.modal != null) {
      CalendarViewHandler.modal.close();
    }
  },

  _resetFleetPos: function(drag) {
    drag.element.style.position = 'relative';
    drag.element.style.top= '0px';
    drag.element.style.left = '0px';
    drag.options.onStart = null;
    drag.options.onEnd = null;
    drag.options.revert = true;
    drag.options.scroll = false;
    drag.delta[0] = 0;
    drag.delta[1] = 0;
    $('fleetscontainer').insert(drag.element);
    resizeCalendarView();
  },

  _revertElement: function(drag) {
    var delta = CalendarViewHandler.lastDraggableLastPost;
    var d = drag.currentDelta();
    drag.options.reverteffect(drag.element, d[1]-delta[1], d[0]-delta[0]);
  },

  _prepareForUpdate: function(elem, droppedId) {
    var objectId = elem.id.substr(5);
    var dateDec = CalendarViewHandler._decodeTime(droppedId); 
    var result;
    if (elem.hasClassName('fleet')) {
      result = {
        targetUrl: '/fleet_races/'+objectId,
        params:  {
          '_method': 'put',
          'fleet_race[scheduled_time][year]': dateDec['year'],
          'fleet_race[scheduled_time][month]': dateDec['month'],
          'fleet_race[scheduled_time][day]': dateDec['day'],
          'fleet_race[scheduled_time][hour]': dateDec['hour'],
          'fleet_race[scheduled_time][minute]': dateDec['minute']
        },
      };
    } else {
      result = {
        targetUrl: '/calendar_entries/'+objectId,
        params:  {
          '_method': 'put',
          'calendar_entry[scheduled_time][year]': dateDec['year'],
          'calendar_entry[scheduled_time][month]': dateDec['month'],
          'calendar_entry[scheduled_time][day]': dateDec['day'],
          'calendar_entry[scheduled_time][hour]': dateDec['hour'],
          'calendar_entry[scheduled_time][minute]': dateDec['minute']
        },
      };
    }
    return result;
  },

  _reFlowElemsInBox: function(boxId) {
    var elem = $(boxId);
    var boxTop;
    if (elem.offsetParent.id.length == 0) {
      var boxTop = elem.offsetTop + elem.offsetParent.offsetTop;
    } else {
      var boxTop = elem.offsetTop;
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

  _fleetAdded: function(drag) {
    drag.options.onStart = CalendarViewHandler.onStart; 
    drag.options.onEnd = CalendarViewHandler.onEnd; 
    drag.options.revert = false;
    drag.options.scroll = $('contentcontainer');
    drag._isScrollChild = true;
    drag.element.style.position = 'absolute';
    $('overlays').insert(drag.element);
    resizeCalendarView();
  },

  // --- Scriptaculous patch --------------------------------------------------

  show: function(point, element) {
    var drop = null;
    Position.prepare();
    var cso0 = $$('.cell_0')[0].cumulativeScrollOffset();
    var co0 = $$('.cell_0')[0].cumulativeOffset();
    var co447 = $$('.cell_447')[0].cumulativeOffset();
    var xCoord = point[0]-co0[0]+cso0[0];
    var yCoord = point[1]-co0[1]+(cso0[1]-Position.deltaY); 
    var cellX = Math.floor(xCoord/115); 
    var cellY = Math.floor(yCoord/20);
    if (xCoord < 0 || xCoord > 115*6+110 || yCoord <0 || yCoord > (co447[1]-co0[1]+20)) { 
      // not on droppables..
    } else {
      if (cellY >= 64) cellY = 63; // this is possible when timeslot height is adjusted
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

    if ($$('.'+dropped.id).length > 1) {
      reflowNewRow = true;
      var rowId = dropped.id.substr(11);
      var entriesCount = $$('.'+dropped.id).length; 
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
    $$('.content')[0].insert(
      {'top': '<div class="flash notice">Error getting response from server, page may contain invalid data. Please refresh the page to fix it!</div>'}
    );
  },

  // --- DnD Handler ----------------------------------------------------------

  onStart: function(drag, event) {
    CalendarViewHandler.lastDraggableLastPost = drag.currentDelta();
    CalendarViewHandler.isDragging = true;
  }, 

  onEnd: function(drag, event) {
    CalendarViewHandler.isDragging = false;
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
            'fleet_race[scheduled_time]': null,
          }; 
        } else {
          targetUrl = '/calendar_entries/'+objectId;
          params = {'_method': 'delete'}; 
        }
        Hobo.showSpinner('Deleting...');
        new Ajax.Request(targetUrl, {
          method: 'post',
          parameters: params,
          //onSuccess: function(transport) { CalendarViewHandler.onSuccessDelete(drag); },
          onFailure: function(transport) { CalendarViewHandler.onFailedAjaxReq('delete/unschedule'); },
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
      onFailure: function(transport) { CalendarViewHandler.onFailedAjaxReq('update entry/fleet race'); },
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
    $('calendar_entry_scheduled_time_year').value = parseInt(dateDec['year']);
    $('calendar_entry_scheduled_time_month').value = parseInt(dateDec['month']);
    $('calendar_entry_scheduled_time_day').value = parseInt(dateDec['day']);
    $('calendar_entry_scheduled_time_hour').value = dateDec['hour'];
    $('calendar_entry_scheduled_time_minute').value = dateDec['minute'];
    $$('.scheduled-time-view select').each(function(elem){elem.style.display='';});
    if ($('scheduled-time-text')) {
      $('scheduled-time-text').innerHTML = '';
    }
    CalendarViewHandler.openModal();
  },

  submitForm: function(event) {
    CalendarViewHandler.closeModal();
    Hobo.showSpinner('Saving...');
    var succesId = '';
    if ($('_method') && $('_method').value == 'PUT') {
      successId = 'scheduled-time-text';
    } else {
      successId = 'overlays';
    }
    new Ajax.Updater({ success: successId}, $('calendar-entry-form').action+'?'+$('params').value, {
      asynchronous: true, 
      evalScripts: true, 
      parameters: Form.serialize($('calendar-entry-form')),
      onFailure: function(request) {
        CalendarViewHandler.onFailedAjaxReq('create/edit');
      },
      onSuccess: function(request) {
        if ($('_method') && $('_method').value == 'PUT') {
          var elem = $($('entry-elem-id').value); 
          elem.childElements()[0].innerHTML = $('calendar_entry_name').value; 
          if (elem.scrollHeight > elem.clientHeight || elem.scrollWidth > elem.clientWidth) {
            Event.observe(elem, 'mouseover', CalendarViewHandler.expandEntry);
            Event.observe(elem, 'mouseout', CalendarViewHandler.restoreEntryWidth);
          }
        }
      },
      onComplete: function(request) {
        Hobo.hideSpinner();
      },
    });
    event.stop();
  },

  editEntry: function(event) { 
    if (CalendarViewHandler.isDragging) {
      return;
    }
    var elem = event.currentTarget.parentNode;
    $('entry-elem-id').value = elem.id;
    var dateDec = CalendarViewHandler._decodeTime($w(elem.className)[1]);
    $('calendar-entry-form').action = '/calendar_entries/'+elem.id.substr(5);
    $('calendar_entry_name').value = event.currentTarget.innerHTML;
    $('calendar_entry_scheduled_time_year').value = parseInt(dateDec['year']);
    $('calendar_entry_scheduled_time_month').value = parseInt(dateDec['month']);
    $('calendar_entry_scheduled_time_day').value = parseInt(dateDec['day']);
    $('calendar_entry_scheduled_time_hour').value = dateDec['hour'];
    $('calendar_entry_scheduled_time_minute').value = dateDec['minute'];
    var scheduledTimeText = dateDec['year']+'-'+dateDec['month']+'-'+dateDec['day']+' '+dateDec['hour']+':'+dateDec['minute'];
    if ($('scheduled-time-text')) {
      $('scheduled-time-text').innerHTML = scheduledTimeText;
    } else {
      $$('.scheduled-time-view')[0].insert("<span id='scheduled-time-text'>"+scheduledTimeText+"</span>");
    }
    if ($('_method')) {
      $('_method').value = 'PUT';
    } else {
      $('page_path').insert({'after': "<input type='hidden' id='_method' name='_method' value='PUT'>"});
    }
    $$('.scheduled-time-view select').each(function(elem){elem.style.display='none';});
    CalendarViewHandler.openModal();
  },

  expandEntry: function(event) {
    var elem = event.currentTarget;
    while (elem.scrollHeight > elem.clientHeight || elem.scrollWidth > elem.clientWidth) {
      elem.style.width = (elem.clientWidth+10)+'px';
    }
  },

  restoreEntryWidth: function(event) {
    event.currentTarget.style.width='113px';
  }

}

function createDnD(event, isAjax) {
  Droppables.show = CalendarViewHandler.show;
  Position.includeScrollOffsets = true; // make sure it works when the div is scrolled

  // draggables for calendar entries
  $$('.entry').each(function(elem) {
    new Draggable(elem, {
      revert: false,//'failure',
      scroll: 'contentcontainer',
      onStart: CalendarViewHandler.onStart, 
      onEnd: CalendarViewHandler.onEnd,
    });
    elem.addClassName('editable')
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
    elem.addClassName('editable')
    if (elem.parentNode.id == 'overlays') {
      new Draggable(elem, {
        revert: false,//'failure',
        scroll: 'contentcontainer',
        onStart:  CalendarViewHandler.onStart,
        onEnd: CalendarViewHandler.onEnd,
      });
    } else {
      if (!isAjax) {
        new Draggable(elem, {
          revert: 'true',
        });
      }
    }
  });
  
  if (!isAjax) {
  // row position
    var index = 0;
    while (index < 447) {
      for (i=0; i<4; i++) {
        var cellClass = '.cell_'+(index+i);
        CalendarViewHandler.rowTimeslot.push($$(cellClass)[0]);
      }
      index += 28;
    }
  }
}


