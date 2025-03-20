class Middleware extends BaseJS_Middleware {
    __subconstruct() {
    }
    widgetaction(){
        alert("middleware action");
        return true;
    }
}
