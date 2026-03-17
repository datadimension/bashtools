class Model extends BaseJS_Model {
    __subconstruct() {
        this.staffList = {};
        this.selectedStaffId;
    }

    /**
     * getstafflist - returns staff list in requested format:
     *     options - an array for use in a select dropdown
     * @param format
     * @returns {*}
     */
    getstafflist(format) {
        let list;
        let selected;
        switch (format) {
            case "options":
                list = [];
                this.staffList.forEach(s => {
                    if (s.PK == this.selectedStaffId) {
                        selected = true;
                    }
                    else {
                        selected = false;
                    }
                    list.push({"value": s.PK, "label": s.screenName, "selected": selected});
                });
                break;
            default:
                list = this.staffList;
        }
        return list;
    }

}
