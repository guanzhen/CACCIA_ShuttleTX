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
Visual.Select("textwithPCBmins").Value = "5"
Visual.Select("textwoPCBmins").Value = "6"
End Function

Function OnClick_btnSArun_start ( Reason )
Dim Checked_PCB,Checked_woPCB
Dim Duration_PCB,Duration_woPCB
Dim NoError
NoError = 1

Checked_PCB = Visual.Select("cbwithPBC").Checked
Checked_woPCB = Visual.Select("cbwoPBC").Checked

  If NOT Checked_PCB AND NOT Checked_woPCB Then
    NoError = 0
    LogAdd "No tests are selected!"
  End If
  
  If CheckValue(Visual.Select("textwithPCBmins").Value) Then
    Duration_PCB = String.SafeParse (Visual.Select("textwithPCBmins").Value)
    DebugMessage "PCB Duration: "& Duration_PCB
  Else
    LogAdd "Invalid value for PCB duration."
    NoError = 0
  End If
  
  If CheckValue(Visual.Select("textwoPCBmins").Value) Then
    Duration_woPCB = String.SafeParse (Visual.Select("textwoPCBmins").Value)
    DebugMessage "woPCB Duration: "& Duration_woPCB
  Else
    LogAdd "Invalid value for w/o PCB duration."
    NoError = 0
  End If
  
  If NoError = 1 Then
    LogAdd "System Acceptance start!"
    System.Start SAEnduranceRunMonitor(Duration_PCB,Duration_woPCB,Checked_PCB,Checked_woPCB)
  Else
    LogAdd "System Acceptance cannot start."
  End If
  
End Function

Function OnClick_btnSArun_stop ( Reason )
  DebugMessage "Stop Timer1 Clicked"
  If Memory.Exists("sig_externalstop") Then
    LogAdd "Endurance Run Stopped"   
    Memory.sig_externalstop.Set
  Else
    LogAdd "No endurance run to stop."   
  End If
  DebugMessage "Stop Timer1 Ended"
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
  EnduranceRun_SendCmd = false
  Mode = Lang.SetBit(Mode,0,PCB)
  Mode = Lang.SetBit(Mode,1,Conveyor)
  Mode = Lang.SetBit(Mode,2,Shuttle)
  Mode = Lang.SetBit(Mode,3,WA)
  
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
    CanSendArg.Data(1) = 0
    CanSendArg.Data(2) = Mode
    CanSendArg.Data(3) = TimeOutSel
    CanSendArg.Data(4) = TO_LL
    CanSendArg.Data(5) = TO_LH
    CanSendArg.Data(6) = TO_HL
    CanSendArg.Data(7) = TO_HH
    CanSendArg.Length = 8
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      EnduranceRun_SendCmd = true
      'LogAdd "Endurance run command sent ok"
    Else
      'LogAdd "Endurance run command sent failed"
    End If
  else
    LogAdd "No CAN Manager!"    
  End If 

End Function

Function SAEnduranceRunMonitor ( Time_PCB,Time_woPCB,en_PCB,en_woPCB )
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

If en_PCB = True Then
'1. Send command (PCB, Conveyor, Shuttle = True, WA = False)
  DebugMessage "Send Start Endurance Run with PCB Command"
  If EnduranceRun_SendCmd(0 , True, True, True, False) = False Then
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
   If sig_timerend.wait(50) Then    
    looping = 0
   End If
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
  
  'TODO: Send Stop Command
  If CANSendAbort = False Then
    external_stop = 1
  End If
  DebugMessage "Endurance Run with PCB Completed: Total Time: "& FormatTimeString(PCB_timeelapsed)
  Memory.Free "sig_timerend"
Else  
  Visual.Select("textSAelapsed_withPCB").Value = "N.A"
End If

If external_stop = 0 Then
  If en_woPCB = True Then
    '1. Send command ( WA, Conveyor, Shuttle = True, PCB = False)
    EnduranceRun_SendCmd 0 , False, True, True, True
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
      'TODO: Send Stop Command
      CANSendAbort
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
Memory.Free "sig_externalstop"
End Function
