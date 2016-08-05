Option Explicit
#include "Tab_Endurance.bas"
#include <PTKL_c.h>
#include "Tab_Motor.bas"
#include <Ptkl_shuttle.h>

#include <Can.bas>
#include "Tab_Commands.bas"
#include <SubCommon.bas>
#include "can_common.bas"
#include "CanSetup.bas"
#include "DebugLog.bas"
#include "Tab_IOs.bas"
#include "testing.bas"

'#include "Constants.bas"

'#include "MessageLog.bas"

Const APP_WIDTH = 800
Const APP_HEIGHT = 600
Const CANSETUP_WIDTH = 400
Const CANSETUP_HEIGHT = 160

Const LANE_UPSTREAM_1 = 1
Const LANE_UPSTREAM_2 = 2
Const LANE_DOWNSTREAM_1 = 3
Const LANE_DOWNSTREAM_2 = 4

Sub OnLoadFrame()
  InitWindows 
End Sub

Sub OnUnloadFrame()
End Sub

Sub InitWindows

  Window.height = APP_HEIGHT
  Window.width = APP_WIDTH

  'Create debug log window
  CreateDebugLogWindow
  DebugMessage "Starting Up"
    
  'Visual.ExecuteScriptFunction("load_tabbar")
  'Visual.ExecuteScriptFunction("load_messagebox")
  'Visual.ExecuteScriptFunction("load_CANsetup")
  
  'Set the images for the IO Tab
  InitWindowIOs
  Init_WindowCommands
  Init_WindowMotor
  'Wait for user to click on connect button.
  Visual.Script("win").attachEvent "onClose" , Lang.GetRef( "btn_CanConnect" , 1)

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

Function CheckValue(ByVal nValue)

  'Check if it is a number
  If NOT IsNumeric(nValue) Then
    LogAdd("Value entered is not a valid number")
    CheckValue = FALSE
    Exit Function
  End If

  If nValue < 0 Then
    LogAdd("Value entered must be a positive number")
    CheckValue = FALSE
    Exit Function
  Else
    CheckValue = TRUE
  End If
End Function
