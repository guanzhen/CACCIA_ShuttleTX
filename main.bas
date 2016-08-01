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
  
  
  'Wait for user to click on connect button.
  Visual.Script("win").attachEvent "onClose" , Lang.GetRef( "btn_CanConnect" , 1)

End Sub

Function tabbar_onSelect (id, id2, id3)
  DebugMessage "tabbar selected"
End Function 


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