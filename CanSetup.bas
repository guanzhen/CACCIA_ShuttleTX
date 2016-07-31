
Sub Testing

End Sub

Function btn_CanConnect(  )
  Dim ShuttleConfig
  DebugMessage"Launch Can Connect"
  'Visual.Select("Layer_CanSetup").Style.Display = "none"
  'Window.width = APP_WIDTH
  'Window.height = APP_HEIGHT
  Visual.Select("Layer_MessageLog").Style.Display = "block"
  Visual.Select("Layer_TabStrip").Style.Display = "block"
  'DebugMessage "Selected Config :"& winframe.contentWindow.document.getElementById("opt_shuttleconfig").value
  'DebugMessage "Selected Config :"& winframe.contentWindow.document.getElementById("opt_cannet").value
  'DebugMessage "Selected Net :"& Visual.Select("opt_shuttleconfig").Value
  'DebugMessage "Selected Net :"& Visual.Select("opt_cannet").Value
  
  'InitCAN Visual.Select("opt_shuttleconfig").Value,Visual.Select("opt_cannet").Value,"1000"  
End Function

Function InitWindowCanSetup

  Visual.Select("Layer_CanSetup").Style.Height  = CANSETUP_HEIGHT
  Visual.Select("Layer_CanSetup").Style.Width   = CANSETUP_WIDTH
  Visual.Select("Layer_CanSetup").Style.Display = "block"
  Visual.Select("Layer_CanSetup").Align = "center"
  
End Function
