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
'#include "Tab_Commands.bas"
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

'Commands for Command tab, until add include bug can be resolved
Function Init_WindowCommands( )
DIm test
Visual.Select("textBiosVersion").Disabled = true
Visual.Select("textAppVersion").Disabled = true
Visual.Select("textBiosVersion").Value = "00.00"
Visual.Select("textAppVersion").Value = "00.00"
End Function

Function OnClick_btnGetApp ( Reason )
Dim FWver_Hi,FWver_Lo
  LogAdd ("Read Firmware Version")      
  If Command_getFWVer(0,FWver_Hi,FWver_Lo) = True Then
    Visual.Select("textAppVersion").Value = String.Format("%02X.%02X", FWver_Hi,FWver_Lo)
  Else
    Visual.Select("textAppVersion").Value = "--.--"
  End If
  If Command_getFWVer(1,FWver_Hi,FWver_Lo) = True Then
    Visual.Select("textBiosVersion").Value = String.Format("%02X.%02X", FWver_Hi,FWver_Lo)
  Else
    Visual.Select("textBiosVersion").Value = "--.--"  
  End If
  
  'MsgBox Visual.Select("txtValue1").Value
End Function

Function Command_getFWVer ( ByVal App_Bios,  ByRef FWver_High, ByRef FWver_Lo )
  Dim CanSendArg, CANConfig, FWselect
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  
  If App_Bios = 0 Then
  FWselect = &h00
  Else 
  FWselect = &h10
  End If
  Command_getFWVer = False
  
  If Memory.Exists("CanManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    If CmdGetVersion(Memory.CanManager, CanSendArg , FWselect ,FWver_High,FWver_Lo) = Ack_Timeout Then
      LogAdd ("Read Firmware Timeout!")
    Else
      Command_getFWVer = True
    End If
  Else
    LogAdd "No Can Manager!"    
  End If 
  Memory.CanManager.Deliver = True
End Function

Function OnClick_btnrefrun ( Reason )
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_REFERENCE)
    CanSendArg.Length = 1
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Reference Run"
    Else
      LogAdd "Reference Run Failed!"
    End If  
  End If  
End Function 

Function OnClick_btnmvinpcb ( Reason )
  Dim CanSendArg , CanReadArg, CANConfig
  Dim lane
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  If Visual.Exists("opt_sourcelane") Then
    lane = Visual.Select("opt_sourcelane").SelectedItemAttribute("value")
    DebugMessage "MoveInPCB Lane :" &lane 
  Else
    DebugMessage "MoveInPCB Lane invalid! :" &lane  
  End If
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOVE_IN)
    CanSendArg.Data(1) = lane
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Move in PCB from "&get_LaneName(lane)
    Else
      LogAdd "Move in PCB Failed!"
    End If  
  End If  
End Function 

Function OnClick_btnmvoutpcb ( Reason )
  Dim CanSendArg , CanReadArg, CANConfig
  Dim lane
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  If Visual.Exists("opt_destlane") Then
    lane = Visual.Select("opt_destlane").SelectedItemAttribute("value")
    DebugMessage "MoveOutPCB "&get_LaneName(lane)
  Else
    DebugMessage "MoveOutPCB Lane invalid! :" &lane  
  End If
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOVE_OUT)
    CanSendArg.Data(1) = lane
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Move out PCB from "&get_LaneName(lane)
    Else
      LogAdd "Move out PCB Failed!"
    End If  
  End If  
End Function 

Function OnClick_btnmvshuttle ( Reason )
  Dim CanSendArg , CanReadArg, CANConfig
  Dim lane
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  If Visual.Exists("opt_mvshuttlelane") Then
    lane = Visual.Select("opt_mvshuttlelane").SelectedItemAttribute("value")
    DebugMessage "Move Shuttle to "&get_LaneName(lane)
  Else
    DebugMessage "Move Shuttle destination lane invalid! :" &lane  
  End If
  
 
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOVE_SHUTTLE)
    CanSendArg.Data(1) = lane
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Move Shuttle to "&get_LaneName(lane)
    Else
      LogAdd "Move out PCB Failed!"
    End If  
  End If
End Function 

Function get_LaneName( Lane )
  Select Case lane
  Case 1:  get_LaneName = "Upstream 1"
  Case 2:  get_LaneName = "Upstream 2"
  Case 3:  get_LaneName = "Downstream 1"
  Case 4:  get_LaneName = "Downstream 2"
  Case Else get_LaneName = "invalid"
  End Select
End Function 


