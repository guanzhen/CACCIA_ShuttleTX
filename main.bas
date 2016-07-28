Option Explicit

#include <Can.bas>
#include <SubCommon.bas>
#include <PTKL_c.h>
#include <Ptkl_shuttle.h>
#include "Can.bas"
#include "IOs.bas"
'#include "MessageLog.bas"
'#include "Constants.bas"

Sub OnLoadFrame()
  InitWindows
  InitCAN
  REM System.Start("CanMgr1")
End Sub

Sub OnUnloadFrame()

End Sub
Sub InitWindows

  Window.width = 1024
  Window.height = 600
  Visual.Select("Layer_MessageLog").Style.Display = "block"
  
  'Create log window
  CreateLogWindow

End Sub

'**********************************************************************
'* Purpose: Create a logging window to log messages
'* Input:  none
'* Output: none
'**********************************************************************
Sub CreateLogWindow()
  Dim DebugLogWindow

  Set DebugLogWindow = CreateObject("WinAPI.Window")
  DebugLogWindow.Title = "Tesla Debug Log"
  Call Memory.Set("DebugLogWindow", DebugLogWindow)
End Sub
'+++++++++++++++++++++ End of CreateLogWindow() +++++++++++++++++++++++

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

Function OnClick_btnLogGridClear( ByVal Reason )
  Visual.Script( "LogGrid").clearAll()
End Function

Function LogAdd ( ByVal sMessage )
  Dim Gridobj  
  Set Gridobj = Visual.Script("LogGrid")
  Dim MsgId
  MsgId = Gridobj.uid()
  If NOT(sMessage = "") Then
    Gridobj.addRow MsgId, ""& FormatDateTime(Date, vbShortDate) &","& FormatDateTime(Time, vbShortTime)&":"& String.Format("%02d ", Second(Time)) &","& sMessage
    'Wish of SCM (automatically scroll to newest Msg)
    Gridobj.showRow( MsgId )
  End If  
End Function

Function OnClick_Send( Reason )
  Dim CanManager
  Dim CanSendArg, CanReadArg
  Dim TioCnt,Timeout
  Timeout = 1000
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  Memory.Get "CanManager",CanManager  

  CanSendArg.CanID = &h608
  CanSendArg.Data(0) = &h54
  CanSendArg.Data(1) = &h00
  CanSendArg.Length = 2
  CANSend CanSendArg,CanManager
  
  For TioCnt = 0 To Timeout
    If CanManager.PeekMessage (CanReadArg, 1) Then
      DebugMessage "CanMgr " & CanReadArg.Format(CFM_SHORT)
    End If
  Next
End Function

Function OnClick_Send2( Reason )
  DebugMessage "Init IOs"
  Init_IOs
End Function

Function OnClick_Send3( Reason )
  IO_setToggle IO_I_EmergencyStop
End Function