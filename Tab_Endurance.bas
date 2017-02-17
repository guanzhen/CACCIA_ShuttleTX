
const TEST_PCB_LENGTH = 1600

'-------------------------------------------------------
Function Init_WindowEndurance
DebugMessage "Init Endurance Run Window"
Visual.Select("textSAstarttime").ReadOnly = true
Visual.Select("textSAstoptime").ReadOnly = true
Visual.Select("textSAelapsed_withPCB").ReadOnly = true
Visual.Select("textSAelapsed_withoutPCB").ReadOnly = true
Visual.Select("textSAstarttime").ReadOnly = true
Visual.Select("textSAstoptime").ReadOnly = true
Visual.Select("cbwithPBC").Checked  = true
Visual.Select("cbwoPBC").Checked = true

Visual.Select("cbshuttle").Checked = true
Visual.Select("cbpcbcyclicrun").Checked = true

Visual.Select("cbwopcbshuttle").Checked = true
Visual.Select("cbwopcbWA").Checked = true
Visual.Select("cbwopcbconveyor").Checked = true

Visual.Select("textwithPCBmins").Value = "60"
Visual.Select("textwoPCBmins").Value = "60"
End Function
'-------------------------------------------------------
Function OnClick_btnSArun_start ( Reason )
Dim Checked_PCB,Checked_woPCB
Dim Duration_PCB,Duration_woPCB
Dim NoError
NoError = 1

Checked_PCB = Visual.Select("cbwithPBC").Checked
Checked_woPCB = Visual.Select("cbwoPBC").Checked

If NOT Memory.Exists("sig_externalstop") Then
  If NOT Checked_PCB AND NOT Checked_woPCB Then
    NoError = 0
    LogAdd "No tests are selected!"
  End If

  If CheckUValue(Visual.Select("textwithPCBmins").Value) Then
    Duration_PCB = String.SafeParse (Visual.Select("textwithPCBmins").Value) * 60
    DebugMessage "PCB Duration: "& Duration_PCB
  Else
    LogAdd "Invalid value for PCB duration."
    NoError = 0
  End If

  If CheckUValue(Visual.Select("textwoPCBmins").Value) Then
    Duration_woPCB = (String.SafeParse (Visual.Select("textwoPCBmins").Value))  * 60
    DebugMessage "woPCB Duration: "& Duration_woPCB
  Else
    LogAdd "Invalid value for w/o PCB duration."
    NoError = 0
  End If

  If NoError = 1 Then
    LogAdd "System Acceptance start!"
    Visual.Select("btnSArun_start").Disabled = True
    System.Start SARun_Monitor(Duration_PCB,Duration_woPCB,Checked_PCB,Checked_woPCB)
  Else
    LogAdd "System Acceptance cannot start."
  End If
Else
    LogAdd "System Acceptance already started."
End If
  DebugMessage "System Acceptance button exit"
End Function

'-------------------------------------------------------
Function OnClick_btnSArun_stop ( Reason )
  DebugMessage "Stop Timer1 Clicked"
  SARun_Stop
  DebugMessage "Stop Timer1 Ended"
End Function
'-------------------------------------------------------
Function StopAllEnduranceRuns( )
ERun_Stop
SARun_Stop
End Function
'-------------------------------------------------------
Function OnClick_btnendrun_wpcb_start ( Reason )
Dim optShuttle,optCyclic
Dim NoError
optShuttle = Visual.Select("cbshuttle").Checked
optCyclic = Visual.Select("cbpcbcyclicrun").Checked
NoError = 1

If NOT optShuttle AND NOT optCyclic Then
  NoError = 0
  LogAdd "No tests are selected!"
End If

If NoError = 1 Then
  LogAdd "Endurance Run with PCB Start"
  Visual.Select("btnendrun_wpcb_start").Disabled = True
  Visual.Select("btnendrun_wopcb_start").Disabled = True
  System.Start ERun_Monitor(optCyclic,optCyclic,optShuttle,false)
End If
End Function
'-------------------------------------------------------
Function OnClick_btnendrun_wpcb_stop ( Reason )
  ERun_Stop
End Function
'-------------------------------------------------------
Function OnClick_btnendrun_wopcb_start ( Reason )
Dim opt_shuttle,opt_WA,opt_conveyor
Dim NoError
opt_shuttle = Visual.Select("cbwopcbshuttle").Checked
opt_WA = Visual.Select("cbwopcbWA").Checked
opt_conveyor = Visual.Select("cbwopcbconveyor").Checked
NoError = 1

If NOT opt_shuttle AND NOT opt_WA AND NOT opt_conveyor Then
  NoError = 0
  LogAdd "No tests are selected!"
End If

If NoError = 1 Then
  LogAdd "Endurance Run without PCB Start"
  System.Start ERun_Monitor(false,opt_conveyor,opt_shuttle,opt_WA)
End If

End Function
'-------------------------------------------------------
Function OnClick_btnendrun_wopcb_stop ( Reason )
  ERun_Stop
End Function
'-------------------------------------------------------
Function OnClick_btnunloadPCB ( Reason )
  UnLoadPCB
End Function
'-------------------------------------------------------
Function ERun_Stop( )
If Memory.Exists("sig_ERexternalstop") Then
  LogAdd "Endurance Run Stopped"
  Memory.sig_ERexternalstop.Set
Else
  LogAdd "No Endurance run to stop."
End If
End Function
'-------------------------------------------------------
Function SARun_Stop()
If Memory.Exists("sig_externalstop") Then
  LogAdd "SA Run Stopped"
  Memory.sig_externalstop.Set
  Command_Abort
Else
  Command_Abort
  'LogAdd "No SA run to stop."
End If
End Function

'-------------------------------------------------------

Function ERun_Monitor(optPCB, optConveyor, optShuttle, optWA)
Dim sig_ERexternalstop,sig_timerend
Dim ERexternal_stop
Dim looping
Dim time_start,time_stop,time_elapsed
'Dim en_Shuttle,enCyclic
If Not Memory.Exists("sig_ERexternalstop") Then
  Set sig_ERexternalstop = Signal.Create
  Memory.Set "sig_ERexternalstop", sig_ERexternalstop
  ERexternal_stop = 0
  time_start = Time
  Visual.Select("textERstarttime").Value = FormatTimeString(time_start)
  Visual.Select("textERstoptime").Value = ""
  Visual.Select("textERelapsedtime").Value = ""
  '1. Send command (PCB, Conveyor, Shuttle = True, WA = False)
  If optPCB = 1 Then
    PreparePCBEndurance
  End If
  Command_Set_ParamERLimit 5000
  If Command_Prepare_ERun(0 , optPCB, optConveyor, optShuttle, optWA) = False Then
    'Error occured
    ERexternal_stop = 1
    LogAdd "Unable to communicate with Shuttle TX"
  End If

  looping = 1

  Do while looping = 1
  'If timer has finished set loop to exit
   'If stop button pressed, or other stops occured.
    If sig_ERexternalstop.wait(50) Then
      looping = 0
    End If
    If ERexternal_stop = 1 Then
      looping = 0
    End If
    
   'Display elapsed time
    time_elapsed = Time - time_start
   Visual.Select("textERelapsedtime").Value = FormatTimeString(time_elapsed)
   System.Delay(200)
  Loop
  Command_Abort
  time_stop = Time
  Visual.Select("textERstoptime").Value = FormatTimeString(time_stop)
  If optPCB = 1 Then
    UnLoadPCB
  End If
  DebugMessage "Endurance Run Stopped. Total Time: "& FormatTimeString(time_elapsed)
  Memory.Free "sig_ERexternalstop"
  Visual.Select("btnendrun_wpcb_start").Disabled = False
  Visual.Select("btnendrun_wopcb_start").Disabled = False

Else
  LogAdd "Endurance Run already running!"
End If
End Function

Function SARun_Monitor ( Time_PCB,Time_woPCB,en_PCB,en_woPCB )
Dim sig_timerend,sig_updatedisplay_func
Dim sig_externalstop
Dim looping
Dim external_stop
Dim PCB_timestart, woPCB_timestart, PCB_timeelapsed,woPCB_timeelapsed,time_end

Visual.Select("textSAstarttime").Value = FormatTimeString(Time)
Visual.Select("textSAelapsed_withPCB").Value = ""
Visual.Select("textSAelapsed_withoutPCB").Value = ""
Visual.Select("textSAstoptime").Value = ""

Set sig_externalstop = Signal.Create
Memory.Set "sig_externalstop", sig_externalstop
external_stop = 0

Command_Set_ParamERLimit 5000
LogAdd "Clearing conveyor of any existing PCB..."
UnLoadPCB

If en_PCB = True Then
'1. Send command (PCB, Conveyor, Shuttle = True, WA = False)
  PreparePCBEndurance
  DebugMessage "Send Start SA Run with PCB Command"
  If Command_Prepare_ERun(0 , True, True, True, False) = False Then
    'Error occured
    external_stop = 1
    LogAdd "Unable to communicate with Shuttle TX"
  End If
'2. Set timer
  Set sig_timerend = Signal.Create
  Memory.Set "sig_timerend",sig_timerend
  DebugMessage "Start Timer1"
  PCB_timestart = Time
  'Visual.Select("textSAstarttime").Value = FormatTimeString(PCB_timestart)
  Timer_Handler TIMER_START,Time_PCB
  looping = 1
'3. wait for timerend signal
  Do while looping = 1
  'If timer has finished set loop to exit
   If sig_timerend.wait(50) Then
    looping = 0
   End If
   'If stop button pressed, or other stops occured.
   If sig_externalstop.wait(50) OR external_stop = 1 Then
    looping = 0
    external_stop = 1
    Timer_Handler TIMER_STOP,0
    End If
   'Display elapsed time
   PCB_timeelapsed = Time - PCB_timestart
   Visual.Select("textSAelapsed_withPCB").Value = FormatTimeString(PCB_timeelapsed)
   System.Delay(100)
  Loop
  'Send the CAN abort command, to terminate the current endurance run.
  'Do this only if loop exit not due to errors.
  If Not external_stop = 1 Then
    LogAdd "Unloading Test PCB"
    UnLoadPCB
  End If
  Memory.Free "sig_timerend"
  DebugMessage "SA Run with PCB Completed: Total Time: "& FormatTimeString(PCB_timeelapsed)

Else
  Visual.Select("textSAelapsed_withPCB").Value = "N.A"
End If
'If external stop is triggered, stop the endurance run (skip the w/o PCB step)
If external_stop = 0 Then
  'If en_PCB = True Then
    
  'End If
  If en_woPCB = True Then
    'Wait 2 seconds for previous operation to finish
    System.Delay(2000)  
    '1. Send command ( WA, Conveyor, Shuttle = True, PCB = False)
    Command_Prepare_ERun 0 , False, True, True, True
    DebugMessage "Send Start Endurance Run wo PCB Command"
    '2. Set timer
      Set sig_timerend = Signal.Create
      Memory.Set "sig_timerend",sig_timerend
      DebugMessage "Start Timer1"
      woPCB_timestart = Time
      Timer_Handler TIMER_START,Time_woPCB
      looping = 1
    '3. wait for timer signal
      Do while looping = 1
        If sig_timerend.wait(50) Then
          looping = 0
        End If
        If sig_externalstop.wait(50) Then
          Timer_Handler TIMER_STOP,0
          looping = 0
        End If
        'Display elapsed time
        woPCB_timeelapsed = Time - woPCB_timestart
        Visual.Select("textSAelapsed_withoutPCB").Value = FormatTimeString(woPCB_timeelapsed)
        System.Delay(100)
      Loop
      'Send the CAN abort command, to terminate the current endurance run.
      Command_Abort
      DebugMessage "Endurance Run w/o PCB Completed: Total Time: "&FormatTimeString(woPCB_timeelapsed)
      Memory.Free "sig_timerend"
    Else
      Visual.Select("textSAelapsed_withoutPCB").Value = "N.A"
    End If
Else
 Visual.Select("textSAelapsed_withoutPCB").Value = "-"
End If

Visual.Select("textSAstoptime").Value = FormatTimeString(Time)
LogAdd "System Acceptance ended!"
Visual.Select("btnSArun_start").Disabled = False    
Memory.Free "sig_externalstop"
Command_Abort
End Function

Sub PreparePCBEndurance ()
  Memory.InhibitErrors = 1
  ' Move shuttle to middle position
  Command_Prepare_ShuttlePosition 0,1,0
  System.Delay 2000
  ' Open the shuttle to accomodate test PCB (10cm)
  Command_Prepare_WidthAdjustment 100000,1,0
  'Command_Set_LaneParameter 4,$(P_LANE_POS_FIXED_RAIL),0
  System.Delay 1000
  System.MessageBox "Please insert Test PCB", "Insert Test PCB", MB_OK
  System.Delay 500  
  Memory.InhibitErrors = 0
  
  Command_Set_PCBLength TEST_PCB_LENGTH
End Sub

Sub UnLoadPCB ()
  Memory.InhibitErrors = 1
  Command_Abort
  System.Delay(1000)
  Command_Prepare_ShuttlePosition 0,1,0
  System.Delay(2000)  
  Command_Prepare_MotorVelocity 500,$(MOTOR_CONVEYOR)
  System.Delay(2000)
  Command_Abort
  System.Delay(500)
  Command_Prepare_CalibrateSensor  
  'System.MessageBox "Please Remove PCB from shuttle","Remove Test PCB",MB_OK
  'Command_Prepare_MoveOut 3
  'System.Delay(2000)  
  'Command_Abort  
  'System.Delay(500)  
  'Command_DeletePCB
  Memory.InhibitErrors = 0
End Sub
