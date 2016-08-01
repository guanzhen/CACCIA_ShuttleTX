
Sub Testing

End Sub

Function btn_CanConnect( id, id1 )
  Dim ShuttleConfig,Net
  DebugMessage"Launch Can Connect"
  Visual.Select("Layer_MessageLog").Style.Display = "block"
  Visual.Select("Layer_TabStrip").Style.Display = "block"
  ShuttleConfig = Visual.Script("opt_net")
  Net = Visual.Script("opt_config")
  DebugMessage "Selected Config :"&ShuttleConfig
  DebugMessage "Selected Net :"&Net
  
  'DebugMessage "Selected Config :"& Visual.Script("winframe").contentWindow.document.getElementById("opt_shuttleconfig").value
  'DebugMessage "Selected Net :"& Visual.Script("winframe").contentWindow.document.getElementById("opt_cannet").value
  Visual.Script("dhxWins").unload()  
  InitCAN ShuttleConfig,Net,"1000"  
End Function

'No longer needed since we are using DHTMLX window
Function InitWindowCanSetup

  Visual.Select("Layer_CanSetup").Style.Height  = CANSETUP_HEIGHT
  Visual.Select("Layer_CanSetup").Style.Width   = CANSETUP_WIDTH
  Visual.Select("Layer_CanSetup").Style.Display = "block"
  Visual.Select("Layer_CanSetup").Align = "center"
  
End Function
