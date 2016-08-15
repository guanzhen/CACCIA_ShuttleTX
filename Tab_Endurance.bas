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
  Timer_StartStop(TIMER_START)
  
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

Function Start_EnduranceRun ( TimeOut, Conveyor, PCB, WidthAdjustment )

  Dim CanSendArg , CanReadArg, CANConfig
  Dim Mode,TimeOutSel
  Dim TO_LL,TO_LH,TO_HL,TO_HH
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  If TimeOut = 0 Then
    'Run without stop
    Mode = 0      
  Else
    'Stop after timeout
    Mode = 1
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

