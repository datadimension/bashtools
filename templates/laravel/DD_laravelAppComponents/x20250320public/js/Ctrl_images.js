class Controller extends BaseJS_Ctrl {
//        https://dev.to/imamcu07/embed-or-display-image-to-html-page-from-google-drive-3ign
    __subconstruct() {
        this.currentdirid = null;
        this.currentdirname = null;
        this.dirList = [];
        this.imageList = [];
        this.imageBucket = [];
        this.singleImage;
        this.selectedThumbIds = [];
        this.imageMeta;
        this.viewMode = 'images';
        this.toggleAllState=false;
        this.imageBucketTargetName;
    }

    start() {
        this.showDirectoryByID(gimagedir_currentid);
    }

    updateContent(serverdata) {
        this.currentdirid = serverdata.data.dirID;
        this.currentdirname = serverdata.data.directoryname;
        this.dirList = serverdata.data.dirlist;
        this.imageList = serverdata.data.imagelist;
        this.imageBucket = serverdata.data.imageBucket;
        this.imageBucketTargetName = serverdata.data.imageBucketTargetName;
        this.setViewMode('images');
        this.selectedThumbIds = [];
    }

    displayContent(serverdata) {
        //hide all and then show according to mode and content availability
        $('#directorythumbFrame').hide();
        $('#directorythumbContent').hide();

        $('#bucketThumbFrame').hide();
        $('#bucketThumbContent').hide();

        //$('#imageThumbFrame').hide();
        $('#imageThumbContent').hide();

        if (this.dirList.length > 0) {//show availability
            $('#directorythumbFrame').show();
            $('#dirCount').html(this.dirList.length);
        }
        if (this.imageBucket.length > 0) {
            $('#bucketThumbFrame').show();
            $('#bucketCount').html(this.imageBucket.length);
        }
        if (this.imageList.length > 0) {
            $('#imageThumbFrame').show();
            $('#imageCount').html(this.imageList.length);

        }
        switch (this.viewMode) {
            case 'subdirs':
                $('#directorythumbContent').show();
                break;
            case 'bucket':
                $('#bucketThumbContent').show();
                break;
            case 'images':
                $('#imageThumbContent').show();
            default:
            //show nothing
        }
        $('#directoryname').html(this.currentdirname);
        $('#imageBucketTargetName').html(this.imageBucketTargetName);
        this.renderDirectoryThumbnailMeta(this.dirList);
        this.renderBucket();
        this.renderImageThumbnailMeta(this.imageList);
    }

    setViewMode(mode) {
        if (mode == this.viewMode) {
            mode = 'images';
        }
        this.viewMode = mode;
        this.displayContent();
    }

    /*20200627
    imagedirchange(selector) {
        let directoryid = $('#' + selector.elemid).val();
        model.runtagvals_set({'<currentimagedir />': directoryid});
        this.ajax('setimagedir', {'directory': directoryid}, 'ctrl.changeimages');
    }


    changeimages(serverdata) {
        this.renderThumbnailIdArray(serverdata.data);
    }
*/

    /* DIRECTORY CONTROLS **********************************/
    showDirectoryByID(dirid) {
        ctrl.ajax('setImageDir', {'action': 'setbyid', 'dirid': dirid});
    }

    moveUpDirectory() {
        ctrl.ajax('setImageDir', {'action': 'moveup', 'dirid': this.currentdirid});
    }

    /**
     * renderThumbnailIdArray renders an array of image ids that are clickable to view full
     * @param imageMeta
     */
    renderDirectoryThumbnailMeta(itemMeta) {
        $('#directorythumbframe').html('');
        let dhtml = '';
        for (let i in itemMeta) {
            let itemid = itemMeta[i].UUID;
            let btn = {
                btnsclass: 'gdirthumb',
                label_1: itemMeta[i].name,
                icon: '/DD_libmedia/images/icons/general/folder_win.png',
                action: 'ctrl.showDirectoryByID(\'' + itemid + '\')',
            };
            let btndef = view.widget_getCFG(btn, {
                btnsclass: 'xgdirthumb',
            });
            dhtml += btndef.dhtml;
            //dhtml += '<div class="gdirframe" onclick="ctrl.showDirectoryByID(\'' + itemid + '\')">' + itemMeta[i].name + '</div>';
        }
        $('#directorythumbContent').html(dhtml);
    }

    /* MAIN IMAGE ***************************************************************/
    changeMainImage(imageUUID) {
        alert('Loading Main Image. Please wait ' + '&nbsp;<img src=\'/DD_libmedia/images/animated/loadingwaitbar.gif\' /> ');
        let src = 'https://drive.google.com/uc?id=' + imageUUID;
        $('#g_imagemainview').attr('src', src);
        this.singleImage = array_havingkeyval(this.imageMeta, 'UUID', imageUUID);
    }

    /**
     * sets the thumb of the currently selected main image as selected
     */
    selectThumbOfSingle() {
        if (this.selectedThumbIds.indexOf(this.singleImage.UUID) == -1) {
            $('#thumbtop-' + this.singleImage.UUID).css('background-color', '#ff0000');
            this.selectedThumbIds.push(this.singleImage.UUID);
        }
    }

    /**
     * shows on Google Drive site the directory containing the current main selected image
     */
    showGDriveDirectory() {
        ctrl.openURL('https://drive.google.com/drive/u/0/folders/' + this.currentdirid, 'imagesdir');
    }

    /* BUCKET ****************************************************/

    /**
     * bucketSelectedAddTo
     */
    bucketSelectedAddTo() {
        let imageUUIDs = '';
        for (let i in this.selectedThumbIds) {
            let image = array_havingkeyval(this.imageMeta, 'UUID', this.selectedThumbIds[i]);
            imageUUIDs += image.UUID + ',';
        }
        imageUUIDs = imageUUIDs.rtim();
        ctrl.ajax('bucketSelectedAddTo', {imageUUIDs: imageUUIDs}, 'ctrl.bucketSelectedAddedTo', {'msg': 'Adding images to Bucket'});
    }

    bucketSelectedAddedTo(serverData) {
        this.imageBucket = serverData.data.imageBucket;
        this.setViewMode('bucket');
    }

    renderBucket() {
        let dhtml = '';
        if (this.imageBucket.length > 0) {
            for (let i in this.imageBucket) {
                let imageid = this.imageBucket[i];
                dhtml +=
                    '<div class="thumbcard" >' +
                    '<img class="thumbimg" src="https://drive.google.com/thumbnail?id=' + imageid + '" />' +
                    '</div>';
            }
            $('#bucketThumbContent').html(dhtml);
        }
    }

    bucketEmptyInTarget(){
        ctrl.ajax('bucketEmptyInTarget', {}, 'ctrl.bucketEmptiedToDir', {'msg': 'Emptying bucket in this directory'});
    }

    bucketEmptyHere() {
        ctrl.ajax('bucketEmptyToDir', {dirId: this.currentdirid}, 'ctrl.bucketEmptiedToDir', {'msg': 'Emptying bucket in this directory'});
    }

    storeMainBucketTarget() {
        ctrl.ajax('storeMainBucketTarget', {dirId: this.currentdirid}, 'ctrl.storedMainBucketTarget', {'msg': 'Setting stored bucket target'});
    }

    /* THUMBNAILS ****************************************************/

    /**
     * renderThumbnailIdArray renders an array of image ids that are clickable to view full
     * @param imageMeta
     */
    renderImageThumbnailMeta(imageMeta) {
        $('#imageThumbContent').html('');
        $('#g_imagemainview').attr('src', '');

        let dhtml = '';
        if (imageMeta.length > 0) {
            this.imageMeta = imageMeta;
            this.singleImage = imageMeta[0];
            for (let i in imageMeta) {
                let imageid = imageMeta[i].UUID;
                dhtml +=
                    '<div class="thumbcard" >' +
                    '<div class="thumbnamelabel" id="thumbtop-' + imageid + '" onclick="ctrl.thumbToggleSelected(\'' + imageid + '\')">' +
                    imageMeta[i].name +
                    '</div>' +
                    '<img onclick="ctrl.changeMainImage(\'' + imageid + '\')" class="thumbimg"' + ' src="https://drive.google.com/thumbnail?id=' + imageid + '" />' +
                    '</div>';
            }
            $('#imageThumbContent').html(dhtml);
            this.changeMainImage(this.singleImage.UUID);
        }
        else {
            this.singleImage = null;
            this.imageMeta = null;
        }
    }

    /**
     *
     */
    imageThumbSelectAll() {
        this.forceToggleOn=!this.forceToggleOn;
        for (let i in this.imageList) {
            this.thumbToggleSelected(this.imageList[i].UUID, this.forceToggleOn);
        }
    }

    /**
     * deselect or select all in image set
     * @param imageId
     * @param set - forces set or unset
     */
    thumbToggleSelected(imageId, forceToggleOn = null) {
        if (forceToggleOn === true || this.selectedThumbIds.indexOf(imageId) == -1) {
            $('#thumbtop-' + imageId).css('background-color', '#ff0000');
            this.selectedThumbIds.push(imageId);
        }
        else {
            $('#thumbtop-' + imageId).css('background-color', '#000000');
            this.selectedThumbIds.splice(this.selectedThumbIds.indexOf(imageId), 1);
        }
    }

    /** confirms and then deletes thumbs */
    deleteSelectedThumbs() {
        let dhtml = '';
        let imageUUIDs = '';
        for (let i in this.selectedThumbIds) {
            let image = array_havingkeyval(this.imageMeta, 'UUID', this.selectedThumbIds[i]);
            imageUUIDs += image.UUID + ',';
            dhtml += image.name + ',';
        }
        imageUUIDs = imageUUIDs.rtim();
        view.confirmAction('Delete selected images ?' + dhtml, 'ctrl.ajax(\'deleteImages\',{imageUUIDs:\'' + imageUUIDs + '\'})');
    }

}
