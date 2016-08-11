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
  CanManager.Events = True
  CanManager.Deliver = True
  'CanManager.Platform = 3
  CanManager.ChangeFunnel String.Format("%d,%d",CANConfig.CANIDAck,CANConfig.CANIDPub),True
  DebugMessage "CanManager1: FunnelSet:" & String.Format("0x%03X,0x%03X",CANConfig.CANIDAck,CANConfig.CANIDPub)
  CanManager.SetArbitrationOrder CAN_ARBITRATION_SYNCHRONOUS 
  WithEvents.ConnectObject CanManager, "CanManager_"  
  InitCANMgr2
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
  DebugMessage "CanPubMgr: " & CanReadArg.Format(CFM_SHORT)  
  
  'If Prepare ID(CanData(2) = 0, meaning it is a spontanous public message, we handle the message
  If CanReadArg.Data(2) = 0 Then 
    PUB_Handler CanReadArg
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
  Else
      CANSendCMD = False
  End If
  CanManager.Deliver = True
End Function

Function Get_PUB_PrepareID( ID )
Dim name
  Select Case ID
    Case	&h20	:	name ="	CMD_SET_PCB_DATA	"
    Case	&h21	:	name ="	CMD_GET_PCB_DATA	"
    Case	&h22	:	name ="	CMD_SET_LANE_PAR	"
    Case	&h23	:	name ="	CMD_GET_LANE_PAR	"
    Case	&h24	:	name ="	CMD_GET_SHUTTLE_PAR	"
    Case	&h25	:	name ="	CMD_CHECK_LANE_POS	"
    Case	&h26	:	name ="	CMD_GET_BARCODE_LABEL	"
    Case	&h27	:	name ="	CMD_GET_PCB_STATE	"
    Case	&h28	:	name ="	CMD_DELETE_PCB	"
    Case	&h29	:	name ="	CMD_INSERT_PCB	"
    Case	&h30	:	name ="	CMD_SET_HW_OPTION	"
    Case	&h31	:	name ="	CMD_GET_HW_OPTION	"
    Case	&h32	:	name ="	CMD_SET_PARAM	"
    Case	&h33	:	name ="	CMD_GET_PARAM	"
    Case	&h34	:	name ="	CMD_INFO	"
    Case	&h35	:	name ="	CMD_SET_WIDTH_OFFSET	"
    Case	&h36	:	name ="	CMD_SET_FIXED_RAIL_OFFSET	"
    Case	&h37	:	name ="	CMD_GET_IO_STATE	"
    Case	&h38	:	name ="	CMD_SET_OUTPUT	"
    Case	&h39	:	name ="	CMD_MOTOR_GET_POSITION	"
    Case	&h3A	:	name ="	CMD_MOTOR_NOTIFY_POS	"
    Case	&h3B	:	name ="	CMD_GET_REF_STATUS	"
    Case	&h3C	:	name ="	CMD_GET_INTERFACE_STATUS	"
    Case	&h41	:	name ="	CMD_PREPARE_REFERENCE	"
    Case	&h42	:	name ="	CMD_PREPARE_MOVE_IN	"
    Case	&h43	:	name ="	CMD_PREPARE_MOVE_OUT	"
    Case	&h44	:	name ="	CMD_PREPARE_MOVE_SHUTTLE	"
    Case	&h45	:	name ="	CMD_PREPARE_WIDTH_ADJUSTMENT	"
    Case	&h46	:	name ="	CMD_PREPARE_SHUTTLE_POSITION	"
    Case	&h47	:	name ="	CMD_PREPARE_BARCODE_SCANNER	"
    Case	&h48	:	name ="	CMD_PREPARE_MOTOR_REFERENCE	"
    Case	&h49	:	name ="	CMD_PREPARE_MOTOR_CALIBRATE	"
    Case	&h4A	:	name ="	CMD_PREPARE_MOTOR_CURRENT	"
    Case	&h4B	:	name ="	CMD_PREPARE_MOTOR_VELOCITY	"
    Case	&h4C	:	name ="	CMD_PREPARE_MOTOR_POSITION	"
    Case	&h4D	:	name ="	CMD_PREPARE_ENDURANCE_RUN	"
    Case Else  name = "unknown" & ID
  End Select
  Get_PUB_PrepareID = name
End Function


Function DebugDecodePub( CanReadArg )
Dim Active,Running,prepid

  If (CanReadArg.Data(0) & &h80) = True Then
    Active = "active "
  Else
    Active = "idle "
  End If
    
  If (CanReadArg.Data(0) & &h04) = True Then
    Running = "action running "
  Else
    Running = "waiting "
  End If

  prepid = Get_PUB_PrepareID(CanReadArg.Data(2))
  DebugMessage "PubMsg: "&Active & Running & prepid
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
    case Else
      DebugDecodePub CanReadArg
  
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
  Message = "PubMsg: " & IO_getName(CanReadArg.Data(4)) & " " & Status
  DebugMessage Message

End Function

Function CAN_getparam( CanReadArg , Param )

  Dim CanSendArg , CANConfig
  Dim ParamL,ParamH
  Set CanSendArg = CreateObject("ICAN.CanSendArg")

  DebugMessage "Param: " & " " & Lang.GetByte (Param,0)& " " & Lang.GetByte (Param,1)& " " & Lang.GetByte (Param,2)& " " & Lang.GetByte (Param,3)
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
      DebugMessage "Get Param OK"
    Else
      DebugMessage "Get Param Failed"
    End If  
  End If
End Function

