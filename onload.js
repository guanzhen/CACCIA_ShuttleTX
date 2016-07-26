function loadtabs() {
    var tabbar = new dhtmlXTabBar("tabbar_main","top");
    tabbar.setImagePath("../../../codebase/tabbar/imgs/");
    tabbar.addTab("main_tab1","Tab1");
    tabbar.addTab("main_tab2","Tab2");
    tabbar.addTab("main_tab3","Tab3");
    tabbar.setContent( "main_tab1", iframe_tab1);
    tabbar.setContent( "main_tab2", iframe_tab2);
    tabbar.setContent( "main_tab3", iframe_tab3);
    tabbar.setTabActive("main_tab1");
    Layer_TabStrip.style.display = "block";
};


function doOnLoad_dhtmlx40() {
    var tabbar = new dhtmlXTabBar({
    parent: "tabbar_main",
    skin:   "dhx_web",
    arrows_mode: "auto",
    tabs: [
    { id: "main_tab1", text: "Tab1"},
    { id: "main_tab2", text: "Tab2"},
    { id: "main_tab3", text: "Tab3"}
    ] 
    });
    //tabbar.cells(0).attachObject("iframe_tab1");
};

function load_messagebox()
{
  var LogGrid  = new dhtmlXGridObject("MessageLog");
}