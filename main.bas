Option Explicit

#include <Can.bas>
#include <SubCommon.bas>
#include <PTKL_c.h>
#include "constants.bas"
'#include "messagelog.bas"

Sub OnLoadFrame()
  InitWindows
  InitCAN
  REM System.Start("CanMgr1")
End Sub

Sub OnUnloadFrame()

End Sub

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

Sub InitCANMgr2 
  Dim CanManagerPUB
  Set CanManagerPUB = Memory.CanManager.Clone
  CanManagerPUB.Events = True
  CanManagerPUB.Deliver = True
  CanManagerPUB.Platform = 3
  CanManagerPUB.ChangeFunnel "0x408,0x008", True
  CanManagerPUB.SetArbitrationOrder CAN_ARBITRATION_PRIVATE_OR_PUBLIC
  'CanManagerPUB.SetArbitrationOrder CAN_ARBITRATION_SYNCHRONOUS 
  WithEvents.ConnectObject CanManagerPUB, "CanManagerPUB_"
End Sub

Function CanManagerPUB_Deliver( CanReadArg )
  DebugMessage "CanMgrRXDeliver" & CanReadArg.Format(CFM_SHORT)  
End Function

Function CanManager_Deliver( CanReadArg )
  DebugMessage "CanDeliver" & CanReadArg.Format(CFM_SHORT)
End Function 

Sub InitWindows

  Window.width = 1024
  Window.height = 600
  Visual.Select("Layer_MessageLog").Style.Display = "block"
  
  'Create log window
  CreateLogWindow

End Sub

Function OnClick_Send( Reason )
  Dim CanManager
  Dim CanSendArg, CanReadArg
  Dim TioCnt,Timeout
  Timeout = 1000
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  Memory.Get "CanManager",CanManager  

  CanSendArg.CanID = &h608
  CanSendArg.Data(0) = &h54
  CanSendArg.Data(1) = &h00
  CanSendArg.Length = 2
  CANSend CanSendArg,CanManager
  
  For TioCnt = 0 To Timeout
    If CanManager.PeekMessage (CanReadArg, 1) Then
      DebugMessage "CanMgr " & CanReadArg.Format(CFM_SHORT)
    End If
  Next
End Function


Sub CANSend ( CanSendArg, CanManager )
  Dim debug
  'debug = CONST_DEBUG
 
  CanManager.Send CanSendArg
  'If debug Then
    DebugMessage CanSendArg.Format(CFM_SHORT)
  'End If
  
End Sub

'**********************************************************************
'* Purpose: Create a logging window to log messages
'* Input:  none
'* Output: none
'**********************************************************************
Sub CreateLogWindow()
  Dim DebugLogWindow

  Set DebugLogWindow = CreateObject("WinAPI.Window")
  DebugLogWindow.Title = "Tesla Debug Log"
  Call Memory.Set("DebugLogWindow", DebugLogWindow)
End Sub
'+++++++++++++++++++++ End of CreateLogWindow() +++++++++++++++++++++++

'************************************************************************
'* Purpose: Display message log on Caccia log window        *
'* Input:  sMessage                   *
'* Output: None                    *
'************************************************************************
Sub DebugMessage(sMessage)
  Dim sTimeStamp, sDate, sTime, DebugLogWindow

  If NOT Memory.Get("DebugLogWindow", DebugLogWindow) Then
    Exit Sub
  End If

  If Len(sMessage) <> 0 Then
    sDate = Convert.FormatTime(System.Time, "%d-%m-%Y")
    sTime = String.Format("%02d:%02d:%02d", Hour(Time), Minute(Time), Second(Time))
    sTimeStamp = sDate & " " & sTime & " "
    DebugLogWindow.Log(sTimeStamp & sMessage & vbCrLf)
  End If
End Sub
' +++++++++++++++++++ End of DebugMessage() ++++++++++++