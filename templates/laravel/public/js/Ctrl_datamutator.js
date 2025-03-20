class Controller extends BaseJS_Ctrl {
    create() {
        this.mode = '';
        view.widgetgroup_render(['nav-dashboard']);
    }

    __subconstruct() {
    }

    start(){
        this.setMode('duplicates');
    }

    setMode(mode) {
        this.mode = mode;
        switch (mode) {
            case 'duplicates':
                break;
        }
    }

    init() {
        // $("#maintoolbar").prependTo("#midtopbarbox");
        // var wh = $(window).height();
        // var ih = $("#topframe").outerHeight();
        // $("#data_frame").css("top", ih + "px");
        // $("#data_frame").css("height", wh - ih + "px");
    }

    inputsubmit(evnt) {
        if (evnt != undefined && evnt.keyCode == '13') {
            runMutate();
        }
        else {
            return true;
        }
    }

    runMutate() {
        var data = document.getElementById('data').value;
        if (document.getElementById('conv_commatolbr').checked) {
            data = this.commatoline(data);
        }
        if ($('#conv_tabtospc').checked()) {
            data = this.tabtospace(data);
        }
        if ($('#conv_tabtolbr').checked()) {
            data = this.tabtoline(data);
        }
        // data = convert(data);
        var quote = document.getElementById('quoteType').value;
        var colnos = parseInt($('#colnos').val());
        if (colnos == '') {
            colnos = 0;
        }
        var colcount = 0;
        data = data.replace('\r', '\n');
        data = (data.split('\n'));
        if ($('#sortoption').checked()) {
            data = data.sort();
        }
        var outputstring = '';
        var dupctrl = [];
        for (var i = 0; i < data.length; i++) {
            let dataItem = data[i];
            if (document.getElementById('dupremove').checked) {
                if (dupctrl.indexOf(dataItem) != -1) {
                    continue;
                }
                dupctrl.push(dataItem);
            }

            if (document.getElementById('blankoption').checked && dataItem ==
                '') {
            }
            else {
                if (document.getElementById('trimoption').checked) {
                    dataItem = dataItem.trim();
                }
                if (document.getElementById('spaceremove').checked) {
                    dataItem = dataItem.replace(/\s+/g, '');
                }
                if (document.getElementById('quoteoption').checked) {
                    dataItem = quote + dataItem + quote;
                }
                if (document.getElementById('conv_strtostr').checked) {
                    dataItem = this.strtostr(dataItem);
                }
                dataItem = this.prepend(dataItem,data[i]);
                dataItem = this.append(dataItem,data[i]);
                outputstring += dataItem;
                if (colnos > 0) {
                    colcount += 1;
                    if (colcount >= colnos) {
                        colcount = 0;
                        outputstring += '\r\n';
                    }
                    else {
                        outputstring += ',';
                    }
                }
                else {
                    outputstring += ',';
                }
            }
        }
        outputstring = outputstring.substr(0, outputstring.length - 1);
        if (colnos > 0) {

        }
        outputstring += '\r\n';
        var summary = 'Data count: ' + i;
        $('#summary').text(summary);
        this.outputMutation(outputstring);
    }

    noempty() {

    }

    prepend(dataItem,inputval) {
        if ($('#prep_row').val() != '') {
            let outputval=$('#prep_row').val();
            outputval=model.runtag_replace(outputval,{"<input />":inputval});
            dataItem = outputval+dataItem;
        }
        return dataItem;
    }

    append(dataItem,inputval) {
        if ($('#app_row').val() != '') {
            let outputval=$('#app_row').val();
            outputval=model.runtag_replace(outputval,{"<input />":inputval});
            dataItem = dataItem + outputval;
        }
        return dataItem;
    }

    recycleData() {
        $('#data').val($('#output').val());
        $('#output').val('');
    }

    clearData() {
        $('#data').val('');
    }

    dupremove() {

    }

    flatten() {
        var data = document.getElementById('data').value;
        data = data.replace(new RegExp('\r', 'g'), '\n');
        data = data.replace(new RegExp('\n', 'g'), '\ ');
        return data;
    }

    tabtoline(data) {
        data = data.replace(new RegExp('\t', 'g'), '\n');
        return data;
    }

    tabtospace(data) {
        data = data.replace(new RegExp('\t', 'g'), '');
        return data;
    }

    commatoline(data) {
        data = data.replace(new RegExp(',', 'g'), '\n');
        return data;
    }

    strtostr(data) {
        var from = $('#conv_strtostrfrom').val();
        var to = $('#conv_strtostrto').val();
        try {
            data = data.replace(new RegExp(from, 'g'), to);
        } catch (e) {
            alert('Regex error');
        }
        return data;
    }

    csvsplit() {
        var cols = parseInt($('#colnos').val());
        if (cols == 0) {
            $('#colnos').val(1);
        }
        $('#quoteoption').checked(false);
        // document.getElementByID("quoteoption").checked = true;
        this.runMutate();
    }

    outputMutation(dataoutput) {
        var window_width = $(window).width();
        $('#output').val(dataoutput);
    }

}
