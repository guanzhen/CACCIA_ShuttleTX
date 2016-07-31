var LogGrid
var tabbar

function loadtabs() 
{
  tabbar = new dhtmlXTabBar("tabbar_main","top");
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

function load_messagebox() 
{
  LogGrid = new dhtmlXGridObject('MessageLogObj');  
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


dhtmlxEvent(window,"load",function()
{
var formStructure
formStructure = [

    {type:"settings",position:"label-top"},
    {type: "fieldset",name:"cansetup", label: "Can Setup", list:[
      {type: "combo", label: "Net", name: "combonet", options:[
      {text: "1", value: "0",selected: true},
      {text: "2", value: "1" }
      ]},
      {type:"newcolumn"},
      {type: "combo", label: "Configuration", name: "comboconfig",  inputLeft:50,  options:[
      {text: "Upstream", value: "0", selected: true},
      {text: "DownStream", value: "1" }
      ]},
      {type:"button", name:"Connect",width:100,offsetTop:10,offsetLeft:100, value:"Connect"}
    ]}
];
var formData = [
		{type: "combo", name: "myCombo", label: "Select Band", options:[
				{value: "opt_a", text: "Cradle Of Filth"},
				{value: "opt_b", text: "Children Of Bodom", selected:true}
		]},
		{type: "combo", name: "myCombo2", label: "Select Location", options:[
				{value: "1", text: "Open Air"},
				{value: "2", text: "Private Party"}
		]}
];
var dhxWins= new dhtmlXWindows();
var win = dhxWins.createWindow("cansetup", 100, 100, 500 , 200);
dhxWins.window("cansetup").setText("CAN Setup");
//load_messagebox();
//loadtabs();
//Layer_TabStrip.style.display = "block";
//Layer_MessageLog.style.display = "block";

var dhxForm = dhxWins.window("cansetup").attachForm(formData);
//doOnLoad_dhtmlx40();
});