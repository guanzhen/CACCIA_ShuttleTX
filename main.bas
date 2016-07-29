Option Explicit

#include <Can.bas>
#include <SubCommon.bas>
#include <PTKL_c.h>
#include <Ptkl_shuttle.h>

#include "Can.bas"
#include "IOs.bas"
#include "DebugLog.bas"
#include "CanSetup.bas"


'#include "MessageLog.bas"
'#include "Constants.bas"

Const APP_WIDTH = 800
Const APP_HEIGHT = 600
Const CANSETUP_WIDTH = 400
Const CANSETUP_HEIGHT = 160

Sub OnLoadFrame()
  InitWindows
  'InitCAN
  REM System.Start("CanMgr1")
End Sub

Sub OnUnloadFrame()

End Sub
Sub InitWindows

  Window.width = CANSETUP_WIDTH
  Window.height = CANSETUP_HEIGHT
  
  Visual.Select("Layer_MessageLog").Style.Display = "none"
  Visual.Select("Layer_TabStrip").Style.Display = "none"
  'Create debug log window
  CreateDebugLogWindow
  InitWindowCanSetup

End Sub



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

  CanSendArg.CanID = &h644
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