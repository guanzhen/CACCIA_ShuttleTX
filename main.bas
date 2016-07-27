Option Explicit
#include <Can.bas>
#include <SubCommon.bas>
#include <PTKL_c.h>
Sub OnLoadFrame()
InitCAN

Visual.Select("MessageLog").Style.Display = "block"
Visual.Select("div_LogGrid").Style.Display = "block"
'initDataGrid
REM System.Start("CanMgr1")
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

Function OnClick_btnLogGridClear( Reason )
  LogAdd "Test"
End Function


Function LogAdd ( sMessage )
  Dim Gridobj  
  Set Gridobj = Visual.Script("LogGrid")
  Dim MsgId
  MsgId = Gridobj.uid()
  If NOT(sMessage = "") Then
    Gridobj.addRow MsgId, ""& FormatDateTime(Date, vbShortDate) &","& FormatDateTime(Time, vbShortTime)&":"& String.Format("%02d ", Second(Time)) &","& sMessage
    'Wish of SCM (automatically scroll to newest Msg)
    Gridobj.showRow( MsgId )
  End If  
End Function 

REM Function CanMgr1
  REM Dim exitcondition
  REM Dim CanManager1
  REM Dim CanReadArg
  
  REM Set CanManager1 = Memory.CanManager.Clone
  REM Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  REM CanManager1.ChangeFunnel "0x408,0x008", True
  REM CanManager1.SetArbitrationOrder CAN_ARBITRATION_SYNCHRONOUS
    
  REM exitcondition = 0

  REM Do
    REM If CanManager1.PeekMessage (CanReadArg, 100) Then
        REM MsgBox "CanMgr1 " & CanReadArg.Format(CFM_SHORT)
    REM End If

  REM Loop Until exitcondition = 1
REM End Function

Function CanMgr2

End Function
Function CanMgr3
End Function