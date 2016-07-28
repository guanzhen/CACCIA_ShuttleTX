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
End Function

Sub CANSend ( CanSendArg, CanManager )
  Dim debug
  'debug = CONST_DEBUG
 
  CanManager.Send CanSendArg
  'If debug Then
    DebugMessage CanSendArg.Format(CFM_SHORT)
  'End If
  
End Sub

Function PUB_Handler ( CanReadArg)

End Function



