Option Explicit
#include <PTKL_c.h>
#include <Ptkl_shuttle.h>
#include <Can.bas>
#include <SubCommon.bas>

#include "Tab_Motor.bas"
#include "Tab_Endurance.bas"
#include "Tab_Commands.bas"
#include "can_common.bas"
#include "CanSetup.bas"
#include "DebugLog.bas"
#include "Tab_IOs.bas"
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

Sub OnLoadFrame()
  InitWindows 
End Sub

Sub OnUnloadFrame()
'To Stop the timer
'Timer_Loop TIMER_STOP
End Sub

Sub OnReloadFrame()
'To Stop the timer
'Timer_Loop TIMER_STOP
End Sub

Sub InitWindows

  Window.height = APP_HEIGHT
  Window.width = APP_WIDTH

  'Create debug log window
  CreateDebugLogWindow
  DebugMessage "Starting Up"
    
  'Visual.ExecuteScriptFunction("load_tabbar")
  'Visual.ExecuteScriptFunction("load_messagebox")
  'Visual.ExecuteScriptFunction("load_CANsetup")
  
  'Set the images for the IO Tab
  InitWindowIOs
  Init_WindowCommands
  Init_WindowMotor
  Init_WindowEndurance
  'Wait for user to click on connect button.
  Visual.Script("win").attachEvent "onClose" , Lang.GetRef( "btn_CanConnect" , 1)

End Sub

Function OnClick_btnLogGridClear( ByVal Reason )
  Visual.Script( "LogGrid").clearAll()
End Function

Function LogAdd ( ByVal sMessage )
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

Function CheckValue(ByVal nValue)

  'Check if it is a number
  If NOT IsNumeric(nValue) Then
    LogAdd("Value entered is not a valid number")
    CheckValue = FALSE
    Exit Function
  End If

  If nValue < 0 Then
    LogAdd("Value entered must be a positive number")
    CheckValue = FALSE
    Exit Function
  Else
    CheckValue = TRUE
  End If
End Function

Function EnduranceRunTimer_StartStop( Start_nStop )
	If Start_nStop = 1 Then		
    'DebugMessage "Timer Start"
		If Not Memory.Exists("Signal_TimerStop") Then
		  System.Start "EnduranceRun_Timer",1
    Else
      DebugMessage "Timer is already running"
		End if		
	Else
    'DebugMessage "Timer Stop"
		If Memory.Exists("Signal_TimerStop") Then
	  	Memory.Signal_TimerStop.Set
		End If
		Do While Memory.Exists("Signal_TimerStop") = True
			System.Delay(100)
		Loop
	End If
End Function

Function EnduranceRun_Timer( Var1 )

  Dim l_Signal_TimerStop
  Dim l_UpdateSignal
  Dim ls_updatesignal,ls_loopcont
  Dim TimeTarget
  Set l_Signal_TimerStop = Signal.Create
  Set l_UpdateSignal = Signal.Create

  Memory.Set "Signal_TimerStop", l_Signal_TimerStop
  Memory.Set "Signal_Update", l_UpdateSignal
  DebugMessage "Timer Started"
  
  ls_loopcont = 1
  ls_updatesignal = 1
  
  If Memory.Exists("TimeTarget") Then
    Memory.Get "TimeTarget",TimeTarget
    TimeTarget.time_start = Time
    'Set the start time to current time
    If Visual.Exists(TimeTarget.display_starttime) Then
      Visual.Select(TimeTarget.display_starttime).Value = FormatTimeString(TimeTarget.time_start)
    Else
      DebugMessage "Error: cannot find element! : " & TimeTarget.time_start
    End If
    'Clear the end time field
    If Visual.Exists(TimeTarget.display_endtime) Then
      Visual.Select(TimeTarget.display_endtime).Value =  " "
    Else
      DebugMessage "Error: cannot find element! : " & TimeTarget.display_endtime 
    End If
    DebugMessage "Start time: " & TimeTarget.time_start
  Else
    'to set loop to exit immediately
    ls_loopcont = 0
    DebugMessage "Error: No timer target!"
  End If
  
	Do while ls_loopcont = 1
    TimeTarget.time_elapsed = Time - TimeTarget.time_start
    If Visual.Exists(TimeTarget.display_elapsed) Then
      Visual.Select(TimeTarget.display_elapsed).Value = FormatTimeString(TimeTarget.time_elapsed)
    Else
      DebugMessage "Error: cannot find element! : " & TimeTarget.display_elapsed
    End If
    
    'if update signal is set
    If l_UpdateSignal.wait(250) Then
	    ls_updatesignal = 1 
	  End If	  
    'If stop signal is set
	  If l_Signal_TimerStop.wait(5) Then
	  	ls_loopcont = 0
      'Display the end time
      TimeTarget.time_stop = Time
      If Visual.Exists(TimeTarget.display_endtime) Then
        Visual.Select(TimeTarget.display_endtime).Value =  FormatTimeString(TimeTarget.time_stop)
      Else
        DebugMessage "Error: cannot find element! : " & TimeTarget.display_endtime 
      End If
	  End If
  Loop
  
  DebugMessage "Timer Stopped"
  Memory.Free "Signal_TimerStop"
	Memory.Free "Signal_Update"
  DebugMessage "Timer Memory Freed"
End Function

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

Function Timer( TimeOut )
  Dim sig_TimerStop
  Dim ls_loopcont
  Dim count,start_time,stop_time,now_time
  
  Set sig_TimerStop = Signal.Create
  
  Memory.Set "sig_TimerStop", sig_TimerStop
  DebugMessage "Timer Started"
  
  ls_loopcont = 1
  start_time = Time
  DebugMessage "Timer:Start Time :" & FormatTimeString(start_time)
  'Visual.Select("timer_start").Value = FormatTimeString(start_time)
  
  Do while ls_loopcont = 1
  
    now_time = (Time - start_time)
    count = Hour(now_time)*360 + Minute(now_time)*60 +Second(now_time)
    Visual.Select("timer_elapsed").Value = count
    
    If sig_TimerStop.wait(50) Then
      ls_loopcont = 0
    End If
    
    If count >= TimeOut Then
      ls_loopcont = 0
    End If    
  Loop
  stop_time = Time
  DebugMessage "Timer:End Time :" & FormatTimeString(stop_time)
  'Visual.Select("timer_end").Value =  FormatTimeString(stop_time)
 
  If Memory.Exists("sig_timerend") Then
    Memory.sig_timerend.Set
    DebugMessage "Memory Set sig_timerend"
  End If
  
  If Memory.Exists("sig_TimerStop") Then
    Memory.Free "sig_TimerStop"
    DebugMessage "Memory Free sig_TimerStop"
  End If
  
End Function
