Option Explicit
#include <Can.bas>
#include <SubCommon.bas>
#include <PTKL_c.h>
Sub OnLoadFrame()
InitCAN
System.Start("CanMgr1")
End Sub

Sub OnUnloadFrame()
End Sub

Sub InitCAN 
Dim CanManager

  DeleteCanManager 0,True
  Set CanManager = LaunchCanManager( 0, "1000" )
  CanManager.Events = False
  CanManager.Deliver = True
  CanManager.Platform = 3
  CanManager.ChangeFunnel "0x408,0x008", True
  'CanManager.SetArbitrationOrder CAN_ARBITRATION_PRIVATE_OR_PUBLIC
  CanManager.SetArbitrationOrder CAN_ARBITRATION_SYNCHRONOUS 
  'WithEvents.ConnectObject CanManager, "CanManager_"
End Sub

Function OnClick_Send( Reason )
Dim CanManager, CanSendArg, CanReadArg
Dim TioCnt,Timeout
Timeout = 1000
Set CanSendArg =  CreateObject("ICAN.CanSendArg")
Set CanReadArg =  CreateObject("ICAN.CanReadArg")

Memory.Get "CanManager",CanManager

CanSendArg.CanID = &h608
CanSendArg.Data(0) = &h54
CanSendArg.Data(1) = &h00
CanSendArg.Length = 2
CanManager.Send CanSendArg

For TioCnt = 0 To Timeout
  If CanManager.PeekMessage (CanReadArg, 1) Then
    MsgBox "CanMgr " & CanReadArg.Format(CFM_SHORT)
  End If
Next

End Function

Function CanMgr1
  Dim exitcondition
  Dim CanManager1
  Dim CanReadArg

  Set CanManager1 = Memory.CanManager.Clone
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  CanManager1.ChangeFunnel "0x408,0x008", True
  CanManager1.SetArbitrationOrder CAN_ARBITRATION_SYNCHRONOUS
    
  exitcondition = 0

  Do
    If CanManager1.PeekMessage (CanReadArg, 100) Then
        MsgBox "CanMgr1 " & CanReadArg.Format(CFM_SHORT)
    End If

  Loop Until exitcondition = 1
End Function

Function CanMgr2

End Function
Function CanMgr3
End Function
