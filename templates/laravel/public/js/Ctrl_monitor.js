class Controller extends BaseJS_Ctrl {
    __subconstruct() {
        this.running = true;
        view.widgetgroup_render("monitor");
    }

    start() {
        this.currentpage = 0;
        model.monitorpages.forEach(function (page, i) {
            let dhtml =
                '<iframe id="monitorpage-' + i + '" src="' + page.url + '"></iframe>';
            $("#dd-body").append(dhtml);
            let maindims = view.getboxmodel($("#dd-body").parent());
            $("#monitorpage-" + i).width(maindims.width);
            $("#monitorpage-" + i).height(maindims.height - 1);
            $("#monitorpage-" + i).css("position", "absolute");
            $("#monitorpage-" + i).css("z-index", "-1");
        });
        this.showPage(this.currentpage);
        pagetimer = setTimeout("ctrl.rotatepage()", 5000);
    }

    showPage(pageno) {
        $("#monitorpage-" + pageno).css("z-index", "0");
    }

    rotatepage(dir) {
        $("#monitorpage-" + this.currentpage).css("z-index", "-1");
        if (dir == 1) {
            this.currentpage++;
            if (this.currentpage >= model.monitorpages.length) {
                this.currentpage = 0;
            }
        }
        else{
            this.currentpage--;
            if (this.currentpage =-1) {
                this.currentpage = model.monitorpages.length-1;
            }
        }
        this.showPage(this.currentpage);
        if (this.running) {
            pagetimer = setTimeout("ctrl.rotatepage(1)", model.monitorpages[this.currentpage].duration * 1000);
        }
    }

    monitorctrl(action) {
        switch (action) {
            case "play":
                alert("Running");
                pagetimer = setTimeout("ctrl.rotatepage(1)", model.monitorpages[this.currentpage].duration * 1000);
                this.running=true;
                break;
            case "stop":
                clearTimeout(pagetimer);
                alert("Stopped");
                this.running=false;
                break;
            case "next":
                this.rotatepage(1);
                break;
            case "prev":
                this.rotatepage(-1);
                break;

        }
    }

}
