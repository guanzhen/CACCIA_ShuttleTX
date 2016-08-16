'**********************************************************************
'* Purpose: Init CAN module listening to Async and Pub Messages (0x408,0x008)
'* Input:  none
'* Output: none
'**********************************************************************
Sub InitCAN ( Config, Net, BaudRate )
  Dim CanManager, CanConfig
  set CANConfig = Object.CreateRecord( "Net", "CANIDcmd", "CANIDAck", "CANIDPub","Baudrate" )
  
  'Config:
  '0 = UpStream   : CAN ID Cmd: 0x644 Ack: 0x645 Pub: 0x647
  '1 = DownStream : CAN ID Cmd: 0x64C Ack: 0x64D Pub: 0x64F
  If Config = 0 Then
    With CANConfig    
      .Net = Net
      .BaudRate = BaudRate
      .CANIDcmd = &h644
      .CANIDAck = &h645
      .CANIDPub = &h647    
    End With
  Else
    With CANConfig    
      .Net = Net
      .BaudRate = BaudRate
      .CANIDcmd = &h64C
      .CANIDAck = &h64D
      .CANIDPub = &h64F
    End With
  End If
  Memory.Set "CANConfig",CANConfig
  DebugMessage "InitCAN with settings: Net:" &Net&" BaudRate:"& BaudRate&" CmdID:" & String.Format("0x%03X",CANConfig.CANIDcmd)
  
  DeleteCanManager 0,True  
  Set CanManager = LaunchCanManager( Net, BaudRate )
  If Lang.IsObject(CanManager) Then
    CanManager.Events = True
    CanManager.Deliver = True
    'CanManager.Platform = 3
    CanManager.ChangeFunnel String.Format("%d,%d",CANConfig.CANIDAck,CANConfig.CANIDPub),True
    DebugMessage "CanManager1: FunnelSet:" & String.Format("0x%03X,0x%03X",CANConfig.CANIDAck,CANConfig.CANIDPub)
    CanManager.SetArbitrationOrder CAN_ARBITRATION_SYNCHRONOUS 
    WithEvents.ConnectObject CanManager, "CanManager_"  
    InitCANMgr2
  Else
    LogAdd "No Can Manager!"
  End If
    
    
End Sub

'**********************************************************************
'* Purpose: Init CAN module listening to only Public Messages (0x008)
'* Input:  none
'* Output: none
'**********************************************************************
Sub InitCANMgr2
  Dim CanManagerPUB, CANConfig
  Set CanManagerPUB = Memory.CanManager.Clone
  Memory.Get "CANConfig",CANConfig
  CanManagerPUB.Events = True
  CanManagerPUB.Deliver = True
  'CanManagerPUB.Platform = 3  
  CanManagerPUB.ChangeFunnel String.Format("%d,%d",CANConfig.CANIDAck,CANConfig.CANIDPub), True
  DebugMessage "CanManager2: FunnelSet:" &  String.Format("0x%03X,0x%03X",CANConfig.CANIDAck,CANConfig.CANIDPub)
  CanManagerPUB.SetArbitrationOrder CAN_ARBITRATION_PRIVATE_OR_PUBLIC
  WithEvents.ConnectObject CanManagerPUB, "CanManagerPUB_"
End Sub

Function CanManager_Deliver( ByVal CanReadArg )
  DebugMessage "CanMgr1:" & CanReadArg.Format(CFM_SHORT)
End Function 

Function CanManagerPUB_Deliver( ByVal CanReadArg )
  'DebugMessage "CanPubMgr: " & CanReadArg.Format(CFM_SHORT)  
  'If Prepare ID(CanData(2) = 0, meaning it is a spontanous public message, we handle the message
  
  If CanReadArg.Data(1) = 0 Then 
    If CanReadArg.Data(2) = 0 Then
      PUB_Handler CanReadArg
    Else
      DebugDecodePub CanReadArg  
    End If
  Else
    LogAdd "Error! (" & Get_Err_Name(CanReadArg.Data(1))& ")"
    DebugMessage "PubMsg: " & CanReadArg.Format(CFM_SHORT) & " Err: (" & Get_Err_Name(CanReadArg.Data(1))& ")"
  End If  
End Function

Sub CANSend ( CanSendArg )
  Dim debug
  Dim CanManager
  
  If Memory.Exists("CanManager") Then 
    Memory.Get "CanManager",CanManager
    CanManager.Send CanSendArg
  'If debug Then
    DebugMessage CanSendArg.Format(CFM_SHORT)
  End If  
End Sub

Function CANSendCMD( CanSendArg , CanReadArg, Timeout )
  Dim CanManager
  If Memory.Exists("CanManager") Then 
    Memory.Get "CanManager",CanManager
    DebugMessage "Cmd:"&CanSendArg.Format(CFM_SHORT)
    If CanManager.SendCmd(CanSendArg,Timeout,SC_CHECK_ERROR_BYTE,CanReadArg) = SCA_NO_ERROR Then    
      DebugMessage "Command " & String.Format("%02X",CanSendArg.Data(0)) &" OK"
      CANSendCMD = True
    Else
      DebugMessage "Error with Command " & String.Format("%02X",CanSendArg.Data(0))
      CANSendCMD = False
    End If    
    CanManager.Deliver = True
  Else
      CANSendCMD = False
  End If

End Function

Function CANSendAbort ( )
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  CANSendAbort = False  
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_ABORT)
    CanSendArg.Length = 1
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Current operation aborted"
      CANSendAbort = True
    Else
      DebugMessage "attempt to abort operation failed"
    End If
  else
    LogAdd "No CAN Manager!"
    
  End If 
End Function

Function PUB_Handler ( CanReadArg )
  Dim command  
  'DebugMessage "Spontanous Public Message RX"
  Select Case  CanReadArg.Data(3)
    case $(PUB_MSG_ERR_PARAM):  
        'DebugMessage "Additonal Error Parameters"
        'LogAdd "Pub Msg: Additonal Error Parameters"
    case $(PUB_MSG_IO_STATE):
        'DebugMessage "IO State"
        'LogAdd "Pub Msg: IO State "& CanReadArg.Format(CFM_SHORT)
      PUB_IO_Handler CanReadArg
  End Select
  
End Function

Function PUB_IO_Handler ( CanReadArg )
  Dim Message
  Dim status
  
  If CanReadArg.Data(5) = 0 Then 
    Status = "Off"
  Elseif CanReadArg.Data(5) = 1 Then
    Status = "On"
  Else
    Status = "Invalid Input"
  End If
  
  IO_setValue CanReadArg.Data(4),CanReadArg.Data(5) 
  Message = "PubMsg: " & CanReadArg.Format(CFM_SHORT) & " " & IO_getName(CanReadArg.Data(4)) & " " & Status
  DebugMessage Message

End Function

Function CAN_getparam( CanReadArg , Param )

  Dim CanSendArg , CANConfig
  Dim ParamL,ParamH
  Set CanSendArg = CreateObject("ICAN.CanSendArg")

  'DebugMessage "Param: " & " " & Lang.GetByte (Param,0)& " " & Lang.GetByte (Param,1)& " " & Lang.GetByte (Param,2)& " " & Lang.GetByte (Param,3)
  ParamL = Lang.GetByte (Param,0)
  ParamH = Lang.GetByte (Param,1)
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_GET_PARAM)
    CanSendArg.Data(1) = ParamL
    CanSendArg.Data(2) = ParamH
    CanSendArg.Length = 3
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      'DebugMessage "Get Param OK"
    Else
      'DebugMessage "Get Param Failed"
    End If  
  End If
End Function

Function DebugDecodePub( CanReadArg )
Dim Active,Running,prepid

  If (Lang.Bit( CanReadArg.Data(0),7,1 )) = 1 Then
    Active = "active, "
  Else
    Active = "idle, "
  End If
    
  If (Lang.Bit( CanReadArg.Data(0),2,1 )) = 1 Then
    Running = "action running, "
  Else
    Running = "waiting, "
  End If
  prepid = CanReadArg.Data(2)
  DebugMessage "PubMsg: "& CanReadArg.Format(CFM_SHORT)  & " ("&Active & Running & " PrepID:" & prepid & ")"
End Function

Function Get_Err_Name( ID )
  Dim name
  Select Case ID
  Case	&h02	:	name ="ERR_CONTROL_VOLTAGE"
  Case	&h03	:	name ="ERR_EMERGENCY_STOP"
  Case	&h04	:	name ="ERR_ABORTED"
  Case	&h10	:	name ="ERR_MOVE_IN"
  Case	&h11	:	name ="ERR_MOVE_OUT"
  Case	&h12	:	name ="ERR_POSITION_RAIL"
  Case	&h13	:	name ="ERR_LANE_WIDTH"
  Case	&h14	:	name ="ERR_OFFSET_WIDTH"
  Case	&h15	:	name ="ERR_SHUTTLE_BLOCKED"
  Case	&h16	:	name ="ERR_WIDTH_ADJ_BLOCKED"
  Case	&h17	:	name ="ERR_WA_NOT_REFERENCED"
  Case	&h18	:	name ="ERR_SHUTTLE_NOT_REFERENCED"
  Case	&h19	:	name ="ERR_DELIVERY_UPSTREAM"
  Case	&h1A	:	name ="ERR_ARRIVED_DOWNSTREAM"
  Case	&h1B	:	name ="ERR_TRAVEL_RANGE_SHUTTLE"
  Case	&h1C	:	name ="ERR_TRAVEL_RANGE_WA"
  Case	&h1D	:	name ="ERR_TRAVEL_RANGE_RAIL_R"
  Case	&h1E	:	name ="ERR_TRAVEL_RANGE_RAIL_L"
  Case	&h1F	:	name ="ERR_MECH_LIMIT_RIGHT_SIDE"
  Case	&h20	:	name ="ERR_MECH_LIMIT_LEFT_SIDE"
  Case	&h30	:	name ="ERR_MOTOR_MOVING"
  Case	&h31	:	name ="ERR_MOTOR_COUNT"
  Case	&h32	:	name ="ERR_MOTOR_INDEX_PULSE"
  Case	&h33	:	name ="ERR_MOTOR_ENCODER"
  Case	&h34	:	name ="ERR_MOTOR_REFERENCE_MOVED"
  Case	&h40	:	name ="ERR_BARCODE_TIMEOUT"
  Case	&h41	:	name ="ERR_BARCODE_SYNTAX"
  Case	&h42	:	name ="ERR_BARCODE_FEEDBACK"
  Case	&h80	:	name ="ERR_ESW_SHUTTLE"
  Case Else  name = "unknown" & ID
  End Select
  Get_Err_Name = name
End Function 
Function Get_PUB_PrepareID( ID )
Dim name
  Select Case ID
    Case	&h02	:	name ="PAR_CHANGED"
    Case	&h03	:	name ="PAR_CONTROL_BOARD_ID"
    Case	&h0B	:	name ="PAR_VELOCITY_DRIVE_IN"
    Case	&h0C	:	name ="PAR_VELOCITY_DRIVE_OUT"
    Case	&h0D	:	name ="PAR_CONV_ACCELERATION"
    Case	&h10	:	name ="PAR_TIMEOUT_MOVE_OUT"
    Case	&h11	:	name ="PAR_TIMEOUT_MOVE_IN"
    Case	&h12	:	name ="PAR_TIMEOUT_BARCODE"
    Case	&h13	:	name ="PAR_MIN_WIDTH"
    Case	&h14	:	name ="PAR_WA_VELOCITY"
    Case	&h15	:	name ="PAR_SHUTTLE_VELOCITY"
    Case	&h16	:	name ="PAR_SHUTTLE_ACCELERATION"
    Case	&h17	:	name ="PAR_SHUTTLE_JERK"
    Case	&h18	:	name ="PAR_CURRENT_SHUTTLE_MOTOR"
    Case	&h19	:	name ="PAR_CURRENT_WA_MOTOR"
    Case	&h1A	:	name ="PAR_VELOCITY_TEST_CONV_MOTOR"
    Case	&h1B	:	name ="PAR_VELOCITY_TEST_SHUTTLE_MOTOR"
    Case	&h1C	:	name ="PAR_VELOCITY_TEST_WA_MOTOR"
    Case	&h1D	:	name ="PAR_TRAVEL_RANGE_SHUTTLE"
    Case	&h1E	:	name ="PAR_TRAVEL_RANGE_WA"
    Case	&h31	:	name ="PAR_SHUTTLE_CURRENT_FORW"
    Case	&h32	:	name ="PAR_SHUTTLE_CURRENT_BACKW"
    Case	&h33	:	name ="PAR_WA_CURRENT_FORW"
    Case	&h34	:	name ="PAR_WA_CURRENT_BACKW"
    Case	&h35	:	name ="PAR_CONV_CURRENT_FORW"
    Case	&h36	:	name ="PAR_CONV_CURRENT_BACKW"
    Case	&h40	:	name ="PAR_OPERATING_HOURS"
    Case	&h41	:	name ="PAR_BOARD_THROUGHPUT"
    Case	&h42	:	name ="PAR_SHUTTLE_MOTOR_MILEAGE"
    Case	&h43	:	name ="PAR_WA_MOTOR_MILEAGE"
    Case	&h44	:	name ="PAR_CONV_MOTOR_MILEAGE"
    Case	&hFFF	:	name ="PAR_LAST"
    Case	&hFFF	:	name ="PAR_NEXT"

    Case Else  name = "unknown" & ID
  End Select
  Get_PUB_PrepareID = name
End Function
