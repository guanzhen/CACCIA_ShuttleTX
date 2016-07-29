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
  DebugMessage "InitCAN: Net:" &Net&" BaudRate:"& BaudRate&" CmdID:" & String.Format("%03X",CANConfig.CANIDcmd)
  
  DeleteCanManager 0,True  
  Set CanManager = LaunchCanManager( Net, BaudRate )
  CanManager.Events = True
  CanManager.Deliver = True
  'CanManager.Platform = 3
  CanManager.ChangeFunnel String.Format("%d,%d",CANConfig.CANIDAck,CANConfig.CANIDPub),True
  DebugMessage "CanManager1: FunnelSet:" & CanManager.QueryFunnel
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
  CanManagerPUB.Platform = 3  
  CanManagerPUB.ChangeFunnel String.Format("%d,%d",CANConfig.CANIDAck,CANConfig.CANIDPub), True
   DebugMessage "CanManager2: FunnelSet:" & CanManagerPUB.QueryFunnel
  CanManagerPUB.SetArbitrationOrder CAN_ARBITRATION_PRIVATE_OR_PUBLIC
  WithEvents.ConnectObject CanManagerPUB, "CanManagerPUB_"
End Sub


Function CanManager_Deliver( ByVal CanReadArg )
  DebugMessage "CanDeliver" & CanReadArg.Format(CFM_SHORT)
End Function 

Function CanManagerPUB_Deliver( ByVal CanReadArg )
  DebugMessage "CanMgrRXDeliver" & CanReadArg.Format(CFM_SHORT)  
  
  'If Prepare ID(CanData(2) = 0, meaning it is a spontanous public message, we handle the message
  If CanReadArg.Data(2) = 0 Then 
    PUB_Handler CanReadArg
  End If
End Function

Sub CANSend ( CanSendArg, CanManager )
  Dim debug
  'debug = CONST_DEBUG
 
  CanManager.Send CanSendArg
  'If debug Then
    DebugMessage CanSendArg.Format(CFM_SHORT)
  'End If
  
End Sub

Function PUB_Handler ( CanReadArg )
  Dim command
  DebugMessage "Spontanous Public Message RX"
  Select Case  CanReadArg.Data(3)
    case $(PUB_MSG_ERR_PARAM):  
        DebugMessage "Additonal Error Parameters"
        LogAdd "Pub Msg: Additonal Error Parameters"
      case $(PUB_MSG_IO_STATE):
        DebugMessage "IO State"
        LogAdd "Pub Msg: IO State "& CanReadArg.Format(CFM_SHORT)
        PUB_IO_Handler
  End Select
End Function

REM Function PUB_IO_Handler ( CanReadArg )

REM End Function



