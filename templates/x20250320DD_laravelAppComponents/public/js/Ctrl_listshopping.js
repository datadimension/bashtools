class Controller extends BaseJS_Ctrl {
      __subconstruct() {
      }

      start() {
	    view.listhandler.init(listgroup,listItemGroups, listItems, "ctrl.taskdropped");
      }

      taskdropped(droppedmeta) {
	    ctrl.ajaxclient.ajax("listplanner_itemDropped", {
		  dragged_ID: droppedmeta.dragged_ID,
		  containerID_draggedFrom: droppedmeta.containerID_draggedFrom,
		  containerID_draggedTo: droppedmeta.containerID_draggedTo,
		  dragged_nextSiblingID: droppedmeta.dragged_nextSiblingID,
	    });
      }
}