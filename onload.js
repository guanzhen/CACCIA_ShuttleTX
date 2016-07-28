function loadtabs2() {
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


function doOnLoad_dhtmlx40() 
{
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

function load_messagebox2()
{
  LogGrid = new dhtmlXGridObject('div_LogGrid');  
  LogGrid.setHeader("Date,Time,Information");
  LogGrid.setImagePath("../../../codebase/grid/imgs/");
  LogGrid.setInitWidths( "100,100,*");
  LogGrid.setColAlign ("center,center,left");
  LogGrid.setColTypes ("ro,ro,ro");
  LogGrid.setColSorting ("na,na,na");
  LogGrid.setSkin ("red_gray");
  LogGrid.enableTooltips ("true,true,true");
  LogGrid.enableResizing ("false,false,false");
  LogGrid.enableMultiselect(false);
  LogGrid.enableAutoWidth (true);
  LogGrid.init(); 
};