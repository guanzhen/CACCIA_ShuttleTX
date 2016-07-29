'**********************************************************************
'* Purpose: Create a logging window to log messages
'* Input:  none
'* Output: none
'**********************************************************************
Sub CreateDebugLogWindow()
  Dim DebugLogWindow

  Set DebugLogWindow = CreateObject("WinAPI.Window")
  DebugLogWindow.Title = "Tesla Debug Log"  
  Call Memory.Set("DebugLogWindow", DebugLogWindow)
End Sub
'+++++++++++++++++++++ End of CreateDebugLogWindow() +++++++++++++++++++++++

'************************************************************************
'* Purpose: Display message log on Caccia log window        *
'* Input:  sMessage                   *
'* Output: None                    *
'************************************************************************
Sub DebugMessage(sMessage)
  Dim sTimeStamp, sDate, sTime, DebugLogWindow

  If NOT Memory.Get("DebugLogWindow", DebugLogWindow) Then
    Exit Sub
  End If

  If Len(sMessage) <> 0 Then
    sDate = Convert.FormatTime(System.Time, "%d-%m-%Y")
    sTime = String.Format("%02d:%02d:%02d", Hour(Time), Minute(Time), Second(Time))
    sTimeStamp = sDate & " " & sTime & " "
    DebugLogWindow.Log(sTimeStamp & sMessage & vbCrLf)
  End If
End Sub
' +++++++++++++++++++ End of DebugMessage() ++++++++++++