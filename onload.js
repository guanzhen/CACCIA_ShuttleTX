var LogGrid
var tabbar
var dhxWins,win,winframe
var opt_net,opt_config
function load_tabbar()
{
  tabbar = new dhtmlXTabBar("tabbar_main","top");
  tabbar.enableAutoReSize( true );
  tabbar.setImagePath("../../../codebase/tabbar/imgs/");
  tabbar.setSkin("dhx_skyblue");

  tabbar.addTab("main_tab1","Commands");
  tabbar.addTab("main_tab2","Endurance");
  tabbar.addTab("main_tab3","Motor");
  tabbar.addTab("main_tab4","IO Controls");
  tabbar.addTab("main_tab5","Testing");
  tabbar.setContent( "main_tab1", iframe_tab1);
  tabbar.setContent( "main_tab2", iframe_tab2);
  tabbar.setContent( "main_tab3", iframe_tab3);
  tabbar.setContent( "main_tab4", iframe_tab4);
  tabbar.setContent( "main_tab5", iframe_tab5);
  tabbar.hideTab("main_tab5");
  for ( var i = 1; i <= tabbar.getNumberOfTabs(); i++ )
  {
    tabbar.setCustomStyle( 'main_tab' + i, 'gray', 'black', 'font-size:10pt;font-family:Arial;font-weight: bold;' );
  }
  //tabbar.normalize();

  tabbar.setTabActive("main_tab2");
  tabbar.setTabActive("main_tab1");
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

function load_CANsetup()
{
var dhxForm,formStructure
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
dhxWins = new dhtmlXWindows();
//dhxWins.attachViewportTo("Layer_CanSetup");
win = dhxWins.createWindow("cansetup", 100, 100, 500 , 200);
win.setText("CAN Setup");
win.attachURL("CanSetup.html");
win.center();
//win.keepInViewport();
winframe = win.getFrame();
};


dhtmlxEvent(window,"load",function()
{
  load_messagebox();
  load_tabbar();
  load_CANsetup();
  Layer_TabStrip.style.display = "none";
  Layer_MessageLog.style.display = "none";
});

function onclick_btncanconnect()
{
  opt_config = winframe.contentWindow.document.getElementById("opt_shuttleconfig").value;
  opt_net = winframe.contentWindow.document.getElementById("opt_cannet").value;
  win.close();

}
function doOnLoad_dhtmlx40()
{
    var tabbar = new dhtmlXTabBar({
    parent: "tabbar_main",
    skin:   "dhx_web",
    arrows_mode: "auto",
    tabs: [
    { id: "main_tab1", text: "Testing"},
    { id: "main_tab2", text: "Commands"},
    { id: "main_tab3", text: "IO Controls"}
    ]
    });
    //tabbar.cells(0).attachObject("iframe_tab1");
};


/*
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
 */
