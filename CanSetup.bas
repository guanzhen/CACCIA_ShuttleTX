Function btn_CanConnect( id, id1 )
  Dim ShuttleConfig,Net
  DebugMessage"Launch Can Connect"
  Net = Visual.Script("opt_net")
  ShuttleConfig = Visual.Script("opt_config")
  DebugMessage "Selected Config :"&ShuttleConfig
  DebugMessage "Selected Net :"&Net
  If ShuttleConfig = 0 Then
    Window.Title = "Shuttle TX Control - Upstream"
  Elseif ShuttleConfig = 1 Then
    Window.Title = "Shuttle TX Control - Downstream"
  End If

  Visual.Script("dhxWins").unload()
  'Initialise can using the settings by user.
  InitCAN ShuttleConfig,Net,"1000"
  Visual.Select("Layer_CanSetup").Style.Display = "none"
  Visual.Select("Layer_MessageLog").Style.Display = "block"
  Visual.Select("Layer_TabStrip").Style.Display = "block"

End Function

'No longer needed since we are using DHTMLX window
Function InitWindowCanSetup

  Visual.Select("Layer_CanSetup").Style.Height  = CANSETUP_HEIGHT
  Visual.Select("Layer_CanSetup").Style.Width   = CANSETUP_WIDTH
  Visual.Select("Layer_CanSetup").Style.Display = "block"
  Visual.Select("Layer_CanSetup").Align = "center"

End Function
