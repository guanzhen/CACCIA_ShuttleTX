
Function Init_WindowCommands( )
Visual.Select("textBiosVersion").Disabled = true
Visual.Select("textAppVersion").Disabled = true
Visual.Select("textBiosVersion").Disabled = false
Visual.Select("textAppVersion").Disabled = false

Visual.Select("textAppVersion").ReadOnly = True
Visual.Select("textBiosVersion").ReadOnly = True
End Function


Function OnClick_btnGetApp ( Reason )
Dim FWver_Hi,FWver_Lo
Dim WidthStat, ShuttleStat
Dim CANData,CANDataLength
  LogAdd ("Read Shuttle Information")
  If Command_GetVersion(0,FWver_Hi,FWver_Lo) = True Then
    Visual.Select("textBiosVersion").Value = String.Format("%02X.%02X", FWver_Hi,FWver_Lo)
  Else
    Visual.Select("textBiosVersion").Value = "--.--"
  End If
  If Command_GetVersion(1,FWver_Hi,FWver_Lo) = True Then
    Visual.Select("textAppVersion").Value = String.Format("%02X.%02X", FWver_Hi,FWver_Lo)
  Else
    Visual.Select("textAppVersion").Value = "--.--"
  End If

  If Command_GetRefenceStatus(WidthStat,ShuttleStat) = True Then
    If WidthStat = 1 Then
      Visual.Select("textstatuswidthref").Value = "Not Referenced"
    Else
      Visual.Select("textstatuswidthref").Value = "Referenced"
    End If
    If ShuttleStat = 1 Then
      Visual.Select("textstatusshuttleref").Value = "Not Referenced"
    Else
      Visual.Select("textstatusshuttleref").Value = "Referenced"
    End If
  End If
  
  If Command_Get_LaneParam_FixedRail(1) = 0 Then
    Visual.Select("textlane1").Value = "Right Fixed"
  ElseIf Command_Get_LaneParam_FixedRail (1) = 1 Then
    Visual.Select("textlane1").Value = "Left Fixed"
  Else
    Visual.Select("textlane1").Value = "-"  
  End If
  
  If Command_Get_LaneParam_FixedRail(2) = 0 Then
    Visual.Select("textlane2").Value = "Right Fixed"
  ElseIf Command_Get_LaneParam_FixedRail (2) = 1 Then
    Visual.Select("textlane2").Value = "Left Fixed"
  Else
    Visual.Select("textlane2").Value = "-"  
  End If
  
  If Command_Get_LaneParam_FixedRail(3) = 0 Then
    Visual.Select("textlane3").Value = "Right Fixed"
  ElseIf Command_Get_LaneParam_FixedRail (3) = 1 Then
    Visual.Select("textlane3").Value = "Left Fixed"
  Else
    Visual.Select("textlane3").Value = "-"  
  End If
  
  If Command_Get_LaneParam_FixedRail(4) = 0 Then
    Visual.Select("textlane4").Value = "Right Fixed"
  ElseIf Command_Get_LaneParam_FixedRail (4) = 1 Then
    Visual.Select("textlane4").Value = "Left Fixed"
  Else
    Visual.Select("textlane4").Value = "-"  
  End If
  
  If Command_Get_PCBState($(PARAM_PCB_STATE_START)) = True Then
    Memory.Get "CANDataLength",CANDataLength
    Memory.Get "CANData",CANData

    If CANDataLength = 2 Then
      Visual.Select("textPCBstatus").Value = "No PCB"
      'Visual.Select("textPCBloc").Value = "No PCB"
    Else
      Visual.Select("textPCBstatus").Value = Get_PCBState ( CANData(6) )      
      'Visual.Select("textPCBloc").Value = Get_PCBlocation ( CANData(6) )      
    End If
  Else
    Visual.Select("textPCBstatus").Value = "-"
    'Visual.Select("textPCBloc").Value = "-"
  End If
  Command_Get_IOStates
  'MsgBox Visual.Select("txtValue1").Value
End Function

Function Get_PCBState ( StateByte )
  Dim State
  Dim TextOut
  State = Lang.Bit(StateByte,0,7)
  Select Case State
  Case $(PCB_STATE_DELETED) : TextOut = "Deleted"
  Case $(PCB_STATE_INSERTED) : TextOut = "Inserted"
  Case $(PCB_STATE_REMOVED) : TextOut = "Removed"
  Case $(PCB_STATE_MOVING) : TextOut = "Moving"
  Case $(PCB_STATE_MOVED) : TextOut = "Moved"
  Case $(PCB_STATE_MOVING_SHUTTLE) : TextOut = "Moving Shuttle"
  Case $(PCB_STATE_MOVED_SHUTTLE) : TextOut = "Moved Shuttle"
  Case $(PCB_STATE_MOVED_SHUTTLE) : TextOut = "Error"
  Case Else : TextOut = "Error"
  End Select
  
  If Lang.Bit(StateByte,4) Then
  TextOut = "Failed:" & TextOut
  End If
  
  If Lang.Bit(StateByte,5) Then
  TextOut = "Manual:" & TextOut
  Else
  TextOut = "Line:" & TextOut  
  End If  
  Get_PCBState = TextOut
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

Function OnClick_btndeletepcb ( Reason )
  Command_DeletePCB
End Function

Function OnClick_btncalsensor ( Reason )
  CMD_CalibrateSensor
End Function

Function OnClick_btnresetoffset ( Reason )
  Command_Reset_FixedRailOffset 1
  Command_Reset_FixedRailOffset 2
  Command_Reset_FixedRailOffset 3
  Command_Reset_FixedRailOffset 4  
End Function

Function CMD_CalibrateSensor
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_CALIBRATE_SENSOR)
    CanSendArg.Length = 1
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      LogAdd "Calibrate sensor command sent"
      CMD_CalibrateSensor = 1
    Else
      CMD_CalibrateSensor = 0
      LogAdd "Calibrate sensor command failed"
    End If    
  Else

  End if
  
End Function

Function OnClick_btnabort ( Reason )

Command_Abort

End Function


Function OnClick_btnmvoutpcb ( Reason )
  Dim lane
  If Visual.Exists("opt_destlane") Then
    lane = Visual.Select("opt_destlane").SelectedItemAttribute("value")
    DebugMessage "MoveOutPCB "&get_LaneName(lane)
    Command_Prepare_MoveOut lane
  Else
    DebugMessage "MoveOutPCB Lane invalid! :" &lane
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
  
  Command_MoveShuttle lane
  
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
