
Function OnClick_btnGetApp ( Reason )
Dim FWver_Hi,FWver_Lo
Dim WidthStat, ShuttleStat
  LogAdd ("Read Shuttle Information")
  If Command_getFWVer(0,FWver_Hi,FWver_Lo) = True Then
    Visual.Select("textBiosVersion").Value = String.Format("%02X.%02X", FWver_Hi,FWver_Lo)
  Else
    Visual.Select("textBiosVersion").Value = "--.--"
  End If
  If Command_getFWVer(1,FWver_Hi,FWver_Lo) = True Then
    Visual.Select("textAppVersion").Value = String.Format("%02X.%02X", FWver_Hi,FWver_Lo)
  Else
    Visual.Select("textAppVersion").Value = "--.--"
  End If

  If Command_getRefStatus (WidthStat,ShuttleStat) = True Then
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
  
  If Command_getLaneFixed(1) = 0 Then
    Visual.Select("textlane1").Value = "Right Fixed"
  ElseIf Command_getLaneFixed (1) = 1 Then
    Visual.Select("textlane1").Value = "Left Fixed"
  Else
    Visual.Select("textlane1").Value = "-"  
  End If
  
  If Command_getLaneFixed(2) = 0 Then
    Visual.Select("textlane2").Value = "Right Fixed"
  ElseIf Command_getLaneFixed (2) = 1 Then
    Visual.Select("textlane2").Value = "Left Fixed"
  Else
    Visual.Select("textlane2").Value = "-"  
  End If
  
  If Command_getLaneFixed(3) = 0 Then
    Visual.Select("textlane3").Value = "Right Fixed"
  ElseIf Command_getLaneFixed (3) = 1 Then
    Visual.Select("textlane3").Value = "Left Fixed"
  Else
    Visual.Select("textlane3").Value = "-"  
  End If
  
  If Command_getLaneFixed(4) = 0 Then
    Visual.Select("textlane4").Value = "Right Fixed"
  ElseIf Command_getLaneFixed (4) = 1 Then
    Visual.Select("textlane4").Value = "Left Fixed"
  Else
    Visual.Select("textlane4").Value = "-"  
  End If
  
  GetIOState
  'MsgBox Visual.Select("txtValue1").Value
End Function

Function Command_getRefStatus ( WidthStat, ShuttleStat)
  Dim CanSendArg,CanReadArg,CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CanManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_GET_REF_STATUS)
    CanSendArg.Length = 1
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      ShuttleStat = CanReadArg.Data(2)
      WidthStat = CanReadArg.Data(3)
      Command_getRefStatus = True
    Else
      ShuttleStat = 0
      WidthStat = 0
      Command_getRefStatus = False
    End If
  End If
End Function

Function Command_getFWVer ( ByVal App_Bios,  ByRef FWver_High, ByRef FWver_Lo )
  Dim CanSendArg, CANConfig, FWselect
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")

  If App_Bios = 0 Then
  FWselect = $(PARAM_DL_ZIEL_BIOS)
  Else
  FWselect = $(PARAM_DL_ZIEL_APPL)
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
    Memory.CanManager.Deliver = True
  Else
    LogAdd "No Can Manager!"
  End If

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
  CMD_ResetOffset 1
  CMD_ResetOffset 2
  CMD_ResetOffset 3
  CMD_ResetOffset 4  
End Function


Function CMD_ResetOffset( Lane )
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_RESET_FIXED_RAIL_OFFSET)
    CanSendArg.Data(1) = Lane
    CanSendArg.Length = 2
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      LogAdd "Reset offset command sent"
      CMD_ResetOffset = 1
    Else
      LogAdd "Reset offset command failed"
      CMD_ResetOffset = 0
    End If    
  Else

  End if
  
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

CANSendAbort

End Function


Function OnClick_btnmvoutpcb ( Reason )
  Dim lane
  If Visual.Exists("opt_destlane") Then
    lane = Visual.Select("opt_destlane").SelectedItemAttribute("value")
    DebugMessage "MoveOutPCB "&get_LaneName(lane)
    Command_moveoutPCB lane
  Else
    DebugMessage "MoveOutPCB Lane invalid! :" &lane
  End If

End Function

Function Command_moveoutPCB(lane)
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOVE_OUT)
    CanSendArg.Data(1) = lane
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Move out PCB from "&get_LaneName(lane)
    Else
      DebugMessage "Move out PCB Failed!"
    End If
  End If
End Function


Function Command_MoveConvMotor(Speed)
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOTOR_VELOCITY)
    CanSendArg.Data(1) = $(MOTOR_CONVEYOR)
    CanSendArg.Data(2) = Lang.GetByte(Speed,0)
    CanSendArg.Data(3) = Lang.GetByte(Speed,1)
    CanSendArg.Length = 4
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Move Conveyor Motor at " & Speed & "mm/s."
    Else
      DebugMessage "Move Conveyor Motor failed"
    End If
  End If
End Function

Function Command_SetLaneParam(lane,param,value)
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_SET_LANE_PAR)
    CanSendArg.Data(1) = param
    CanSendArg.Data(2) = lane
    CanSendArg.Data(3) = 0
    CanSendArg.Data(4) = Lang.GetByte(value,0)
    CanSendArg.Data(5) = Lang.GetByte(value,1)
    CanSendArg.Data(6) = Lang.GetByte(value,2)
    CanSendArg.Data(7) = Lang.GetByte(value,3)
    CanSendArg.Length = 8
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Set Lane "&get_LaneName(lane) & " param"
      Command_SetLaneParam = 1
    Else
      DebugMessage "Set Lane Param failed"
      Command_SetLaneParam = -1
    End If
  End If
End Function

Function Command_GetLaneFixed(lane)
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_GET_LANE_PAR)
    CanSendArg.Data(1) = $(P_LANE_FIXED_RAIL)
    CanSendArg.Data(2) = lane
    CanSendArg.Length = 3
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Get Lane "&get_LaneName(lane) & " param"
      Command_getLaneFixed = CanReadArg.Data(4)
    Else
      DebugMessage "Read Lane Param failed"
      Command_getLaneFixed = -1
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
      LogAdd "Move Shuttle Failed!"
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

Function Init_WindowCommands( )
Visual.Select("textBiosVersion").Disabled = true
Visual.Select("textAppVersion").Disabled = true
Visual.Select("textBiosVersion").Disabled = false
Visual.Select("textAppVersion").Disabled = false

Visual.Select("textAppVersion").ReadOnly = True
Visual.Select("textBiosVersion").ReadOnly = True
End Function
