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
Visual.Select("textwithPCBmins").Value = "60"
Visual.Select("textwoPCBmins").Value = "60"
End Function

Function OnClick_btnSArun_start ( Reason )
Dim SAStartTime

LogAdd "SA Start"
SAStartTime  = System.Time
DebugMessage SAStartTime

Visual.Select("textSAstarttime").Value = String.Format("%02d,%02d,%02d",Hour(SAStartTime),Minute(SAStartTime),Second(SAStartTime))

End Function

Function OnClick_btnSArun_stop ( Reason )
  Dim TimeTargetPCB,TimeTargetnoPCB
  LogAdd "SA Stop"
  set TimeTargetPCB = Object.CreateRecord( "time_target", "time_start", "time_stop", "time_elapsed","display_starttime","display_endtime","display_elapsed")
  set TimeTargetnoPCB = Object.CreateRecord( "time_target", "time_start", "time_stop", "time_elapsed","display_starttime","display_endtime","display_elapsed")
  Memory.Set "TimeTarget",TimeTargetPCB  
  'With PCB
  With TimeTargetPCB 
  .display_starttime = "textSAstarttime"
  .display_endtime = "textSAstoptime"
  .display_elapsed = "textSAelapsed_withPCB"
  End With  
  EnduranceRunTimer_StartStop(TIMER_START)
  
  'Without PCB
  Memory.Set "TimeTarget",TimeTargetnoPCB  
  With TimeTargetPCB 
    .display_starttime = "textSAstarttime"
    .display_endtime = "textSAstoptime"
    .display_elapsed = "textSAelapsed_withoutPCB"
  End With
  TimeTargetPCB.display_elapsed = "textSAelapsed_withoutPCB"    
End Function


Function OnClick_btnendrun_wpcb_start ( Reason )
LogAdd "Endurance Run with PCB Start"

End Function

Function OnClick_btnendrun_wpcb_stop ( Reason )
LogAdd "Endurance Run with PCB Stop"

End Function

Function OnClick_btnendrun_wopcb_start ( Reason )
LogAdd "Endurance Run without PCB Start"

End Function

Function OnClick_btnendrun_wopcb_stop ( Reason )
LogAdd "Endurance Run without PCB Stop"

End Function

Function EnduranceRun_SendCmd ( TimeOut, PCB, Conveyor, Shuttle, WA)

  Dim CanSendArg , CanReadArg, CANConfig
  Dim Mode,TimeOutSel
  Dim TO_LL,TO_LH,TO_HL,TO_HH
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  Mode = 0
  Lang.Bit Mode,0,PCB
  Lang.Bit Mode,1,Conveyor
  Lang.Bit Mode,2,Shuttle
  Lang.Bit Mode,3,WA
  
  If TimeOut = 0 Then
    'Run without stop
    TimeOutSel = 0      
  Else
    'Stop after timeout
    TimeOutSel = 1
  End If
  
  TO_LL = Lang.GetByte(TimeOut,0)
  TO_LH = Lang.GetByte(TimeOut,1)
  TO_HL = Lang.GetByte(TimeOut,2)
  TO_HH = Lang.GetByte(TimeOut,3)
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_ENDURANCE_RUN)
    CanSendArg.Data(1) = Mode
    CanSendArg.Data(2) = TimeOutSel
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      Start_EnduranceRun = true
      LogAdd "Endurance run start"
    Else
      Start_EnduranceRun = false
      LogAdd "Endurance run start failed"
    End If
  else
    Start_EnduranceRun = false
    LogAdd "No CAN Manager!"
    
  End If 

End Function

Function SAEnduranceRunMonitor ( Time_PCB,Time_woPCB,en_PCB,en_woPCB )
Dim sig_timerend,sig_updatedisplay_func
Dim looping
Dim external_stop
Dim PCB_timestart, woPCB_timestart, PCB_timeelapsed,woPCB_timeelapsed,time_end
external_stop = 0

Visual.Select("textSAstarttime").Value = FormatTimeString(Time)
Visual.Select("textSAelapsed_withPCB").Value = ""
Visual.Select("textSAelapsed_withoutPCB").Value = ""
Visual.Select("textSAstoptime").Value = ""

If en_PCB = True Then
'1. Send command (PCB, Conveyor, Shuttle = True, WA = False)
'EnduranceRun_SendCmd( 0 , True, True, True, False )
  DebugMessage "Send Start Endurance Run with PCB Command"
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
   If sig_timerend.wait(50) Then    
    looping = 0
    external_stop = 1
   End If
   'Display elapsed time
   PCB_timeelapsed = Time - PCB_timestart
   Visual.Select("textSAelapsed_withPCB").Value = FormatTimeString(PCB_timeelapsed)
   System.Delay(100)
  Loop
  
  'TODO: Send Stop Command
  
  DebugMessage "Endurance Run with PCB Completed: Total Time: "& FormatTimeString(PCB_timeelapsed)
  Memory.Free "sig_timerend"
Else  
  Visual.Select("textSAelapsed_withPCB").Value = "N.A"
End If

'If Not external_stop = 1 Then
  If en_woPCB = True Then
    '1. Send command ( WA, Conveyor, Shuttle = True, PCB = False)
    'EnduranceRun_SendCmd 0 , False, True, True, True
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
       'Display elapsed time
       woPCB_timeelapsed = Time - woPCB_timestart
       Visual.Select("textSAelapsed_withoutPCB").Value = FormatTimeString(woPCB_timeelapsed)
       System.Delay(100)
      Loop
      'TODO: Send Stop Command
      DebugMessage "Endurance Run w/o PCB Completed: Total Time: "&FormatTimeString(woPCB_timeelapsed)
      Memory.Free "sig_timerend"
    Else  
      Visual.Select("textSAelapsed_withoutPCB").Value = "N.A"
    End If  
'Else
' Visual.Select("textSAelapsed_withoutPCB").Value = "-"
'End If

Visual.Select("textSAstoptime").Value = FormatTimeString(Time)

End Function
