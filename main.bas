Option Explicit

#include <Can.bas>
#include <SubCommon.bas>
#include <PTKL_c.h>
#include <Ptkl_shuttle.h>

#include "Can.bas"
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
  'Set the images for the IO Tab
  InitWindowIOs
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