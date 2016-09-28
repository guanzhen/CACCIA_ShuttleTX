
Function OnClick_btnGetApp ( Reason )
Dim FWver_Hi,FWver_Lo
Dim WidthStat, ShuttleStat
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
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_DELETE_PCB)
    CanSendArg.Length = 1
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      LogAdd "Delete PCB command sent"
    Else
       LogAdd "Delete PCB command failed"
    End If    
  Else

  End if
  
End Function

Function OnClick_btnabort ( Reason )

CANSendAbort

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
