
Option Explicit
#include <PTKL_c.h>
#include "Ptkl_shuttle.h"
#include <Can.bas>
#include <SubCommon.bas>
#include <System.bas>

#include "Constants.bas"
#include "can_common.bas"
#include "Can_Commands.bas"
#include "DebugLog.bas"
#include "Tab_Commands.bas"
#include "Tab_Motor.bas"
#include "Tab_IOs.bas"
#include "Tab_Endurance.bas"
#include "Tab_EMC_Test.bas"
#include "testing.bas"

'#include "Constants.bas"

'#include "MessageLog.bas"

Const APP_WIDTH = 800
Const APP_HEIGHT = 600
Const CANSETUP_WIDTH = 400
Const CANSETUP_HEIGHT = 160

Const LANE_UPSTREAM_1 = 1
Const LANE_UPSTREAM_2 = 2
Const LANE_DOWNSTREAM_1 = 3
Const LANE_DOWNSTREAM_2 = 4

Const TIMER_START = 1
Const TIMER_STOP = 0

'-------------------------------------------------------

Sub OnLoadFrame()
  InitWindows
End Sub

'-------------------------------------------------------

Sub OnUnloadFrame()
'To Stop the timer
StopAllEnduranceRuns
Timer_Handler TIMER_STOP,0
End Sub

'-------------------------------------------------------

Sub OnReloadFrame()
'To Stop the timer
StopAllEnduranceRuns
Timer_Handler TIMER_STOP,0
End Sub

'-------------------------------------------------------

Sub InitWindows
  Dim InhibitErrors
  Window.height = APP_HEIGHT
  Window.width = APP_WIDTH
  InhibitErrors = 0
  Memory.Set "InhibitErrors",InhibitErrors
  'Create debug log window
  'CreateDebugLogWindow
  DebugMessage "Starting Up"

  'Visual.ExecuteScriptFunction("load_tabbar")
  'Visual.ExecuteScriptFunction("load_messagebox")
  'Visual.ExecuteScriptFunction("load_CANsetup")

  'Set the images for the IO Tab
  Init_WindowIO
  Init_WindowCommands
  Init_WindowMotor
  Init_WindowEndurance
  Window.AdjustLayout "body_main"
  'Wait for user to click on connect button.
  Visual.Script("win").attachEvent "onClose" , Lang.GetRef( "btn_CanConnect" , 1)

End Sub

'-------------------------------------------------------

Function OnClick_btnLogGridClear( ByVal Reason )
  Visual.Script( "LogGrid").clearAll()
End Function

'-------------------------------------------------------

Function OnClick_ButtonDebugLog( Reason )
  If Memory.Exists("DebugLogWindow") Then
    DebugWindowClose
    Visual.Select("ButtonDebugLog").Value = "Open DebugLog"
  Else 
    CreateDebugLogWindow
    Visual.Select("ButtonDebugLog").Value = "Close DebugLog"
  End If
End Function

'-------------------------------------------------------

Function LogAdd ( ByVal sMessage )
  Dim Gridobj
  Set Gridobj = Visual.Script("LogGrid")
  Dim MsgId
  MsgId = Gridobj.uid()
  If NOT(sMessage = "") AND Memory.InhibitErrors = 0 Then
    Gridobj.addRow MsgId, ""& FormatDateTime(Date, vbShortDate) &","& FormatDateTime(Time, vbShortTime)&":"& String.Format("%02d ", Second(Time)) &","& sMessage
    'Wish of SCM (automatically scroll to newest Msg)
    Gridobj.showRow( MsgId )
  End If
End Function

'-------------------------------------------------------

Function CheckUValue(ByVal nValue)

  'Check if it is a number
  If NOT IsNumeric(nValue) Then
    LogAdd("Value entered is not a valid number")
    CheckUValue = FALSE
    Exit Function
  End If

  If nValue < 0 Then
    LogAdd("Value entered must be a positive number")
    CheckUValue = FALSE
    Exit Function
  Else
    CheckUValue = TRUE
  End If
End Function

'-------------------------------------------------------

Function CheckSValue(ByVal nValue)
  'Check if it is a number
  If NOT IsNumeric(nValue) Then
    LogAdd("Value entered is not a valid number")
    CheckSValue = FALSE
    Exit Function
  Else
    CheckSValue = TRUE  
  End If
End Function

'-------------------------------------------------------

Function FormatTimeString( Var_Time )
  FormatTimeString = String.Format("%02d:%02d:%02d", Hour(Var_Time), Minute(Var_Time), Second(Var_Time))
End Function

Function Timer_Handler ( StartStop , TimeOut )
	If StartStop = 1 Then
    'DebugMessage "Timer Start"
		If Not Memory.Exists("sig_TimerStop") Then
		  System.Start "Timer", TimeOut
    Else
      DebugMessage "Timer is already running"
      If Memory.Exists("sig_timerend") Then
        Memory.sig_timerend.Set
      End If
		End if
	Else
    'DebugMessage "Timer Stop"
		If Memory.Exists("sig_TimerStop") Then
	  	Memory.sig_TimerStop.Set
		End If
		Do While Memory.Exists("sig_TimerStop") = True
			System.Delay(100)
		Loop
	End If
End Function

'-------------------------------------------------------

Function Timer( TimeOut )
  Dim sig_TimerStop
  Dim ls_loopcont
  Dim count,start_time,stop_time,now_time

  Set sig_TimerStop = Signal.Create

  Memory.Set "sig_TimerStop", sig_TimerStop
  If TimeOut > 0 Then
    DebugMessage "Timer Started with timeout" & TimeOut
  Else
    DebugMessage "Timer Started without timeout"
  End If

  ls_loopcont = 1
  start_time = Time
  DebugMessage "Timer:Start Time :" & FormatTimeString(start_time)
  'Visual.Select("timer_start").Value = FormatTimeString(start_time)

  Do while ls_loopcont = 1

    now_time = (Time - start_time)
    count = Hour(now_time)*3600 + Minute(now_time)*60 +Second(now_time)

    If sig_TimerStop.wait(500) Then
      ls_loopcont = 0
    End If

    If count >= TimeOut AND NOT TimeOut=0 Then
      ls_loopcont = 0
    End If
  Loop
  stop_time = Time
  DebugMessage "Timer:End Time :" & FormatTimeString(stop_time)
  'Visual.Select("timer_end").Value =  FormatTimeString(stop_time)

  If Memory.Exists("sig_timerend") Then
    Memory.sig_timerend.Set
    DebugMessage "Memory Set sig_timerend"
  Else
    DebugMessage "Error : Memory sig_timerend does not exists!"

  End If

  If Memory.Exists("sig_TimerStop") Then
    Memory.Free "sig_TimerStop"
    DebugMessage "Memory Free sig_TimerStop"
  Else
    DebugMessage "Error: Memory sig_TimerStop does not exists!"

  End If
  DebugMessage "Timer Exit"
End Function
