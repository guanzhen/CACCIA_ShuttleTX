'**********************************************************************
'* Purpose: Init CAN module listening to Async and Pub Messages (0x408,0x008)
'* Input:  none
'* Output: none
'**********************************************************************
Sub InitCAN 
  Dim CanManager
  DeleteCanManager 0,True
  Set CanManager = LaunchCanManager( 0, "1000" )
  CanManager.Events = True
  CanManager.Deliver = True
  CanManager.Platform = 3
  CanManager.ChangeFunnel "0x408,0x008", True
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
  Dim CanManagerPUB
  Set CanManagerPUB = Memory.CanManager.Clone
  CanManagerPUB.Events = True
  CanManagerPUB.Deliver = True
  CanManagerPUB.Platform = 3
  CanManagerPUB.ChangeFunnel "0x408,0x008", True
  CanManagerPUB.SetArbitrationOrder CAN_ARBITRATION_PRIVATE_OR_PUBLIC
  WithEvents.ConnectObject CanManagerPUB, "CanManagerPUB_"
End Sub


Function CanManager_Deliver( ByVal CanReadArg )
  DebugMessage "CanDeliver" & CanReadArg.Format(CFM_SHORT)
End Function 

Function CanManagerPUB_Deliver( ByVal CanReadArg )
  DebugMessage "CanMgrRXDeliver" & CanReadArg.Format(CFM_SHORT)  
  
  'If Prepare ID = 0, meaning it is a spontanous public message, we handle the message
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
      LogAdd "Pub Msg: IO State"    
  
End Select

End Function



