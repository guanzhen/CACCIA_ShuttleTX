
  Function OnClick_Test1 ( Reason )
  Dim param
  param = Command_getLaneFixed(1)
  If param > -1 Then
    DebugMessage "Lane 1 Param : " & param
  Else
    DebugMessage "Failed"
  End If
  End Function
  
    Function OnClick_Test2 ( Reason )
  Dim param
  param = Command_getLaneFixed(2)
  If param > -1 Then
    DebugMessage "Lane 2 Param : " & param
  Else
    DebugMessage "Failed"
  End If
  End Function
  
  Function OnClick_Test3 ( Reason )
  Dim param
  param = Command_getLaneFixed(3)
  If param > -1 Then
    DebugMessage "Lane 3 Param : " & param
  Else
    DebugMessage "Failed"
  End If
  End Function
  
  Function OnClick_Test4 ( Reason )
  Dim param
  param = Command_getLaneFixed(4)
  If param > -1 Then
    DebugMessage "Lane 4 Param : " & param
  Else
    DebugMessage "Failed"
  End If
  End Function
  
  Function testing ()
  Dim sig_timerend,sig_cycleloopend,cycleloop,looping
  Dim interval
  Dim start_time,stop_time,now_time
  Dim lane
  Dim CanManagerPUB
  Set sig_timerend = Signal.Create
  Set sig_cycleloopend = Signal.Create

  Memory.Get "CanManagerPUB",CanManagerPUB
  CanManagerPUB.Deliver = False
  CanManagerPUB.Events = False

  DebugMessage "memory set sig_cycleloopend"
  Memory.Set "sig_cycleloopend",sig_cycleloopend
  LogAdd "EMC Test Started"
  DebugMessage "Start Timer1"
  looping = 1
  cycleloop = 1
  If CheckUValue(Visual.Select("test_interval").Value) Then
    interval = String.SafeParse(Visual.Select("test_interval").Value)
  Else
    LogAdd "Invalid Interval!"
    looping = 0
    cycleloop = 0
  End If
  lane = 1
  start_time = Time
  Visual.Select("timer_elapsed").Value = ""
  Visual.Select("timer_end").Value =  ""
  Visual.Select("timer_start").Value = FormatTimeString(start_time)
  Memory.Set "sig_timerend",sig_timerend
  DebugMessage "memory set sig_timerend"
  Timer_Handler TIMER_START,interval
  Do while cycleloop = 1

    'if send command NOK,  exit loop
    If Not test_moveshuttle(lane) Then
      looping = 0
      cycleloop = 0
      Timer_Handler TIMER_STOP,0
    End If

    Do while looping = 1
     now_time = (Time - start_time)
     Visual.Select("timer_elapsed").Value = FormatTimeString(now_time)

     If sig_timerend.wait(50) Then
      looping = 0
     End If

     If sig_cycleloopend.wait(50) Then
      looping = 0
      cycleloop = 0
      LogAdd "Stopping..."
     End If
    Loop

    'Check if sig_TimerStop still exist. if it does not exist, timer has stopped.
    If Memory.Exists("sig_TimerStop") = False Then
      looping = 1
      Memory.Free "sig_timerend"
      DebugMessage "memory free sig_timerend"
      Memory.Set "sig_timerend",sig_timerend
      DebugMessage "memory set sig_timerend"
      Timer_Handler TIMER_START,interval
      'toggle the lane to move to
      If lane = 1 Then
        lane = 2
      Else
        lane = 1
      End If

    End If

    System.Delay(100)
  Loop

  stop_time = Time
  Visual.Select("timer_end").Value =  FormatTimeString(stop_time)

  Do While Memory.Exists("sig_TimerStop") = True
    If Memory.Exists("sig_timerend") Then
      Memory.Free "sig_timerend"
    End If
    now_time = (Time - start_time)
    Visual.Select("timer_elapsed").Value = FormatTimeString(now_time)

    System.Delay(100)
  Loop

  If Memory.Exists("sig_timerend") Then
    Memory.Free "sig_timerend"
    DebugMessage "memory free sig_timerend"
  End If

  If Memory.Exists("sig_cycleloopend") Then
  Memory.Free "sig_cycleloopend"
  DebugMessage "memory free sig_cycleloopend"
  End If
  DebugMessage "Timer1 Ended"
  LogAdd "EMC Test Stopped"
End Function

Function OnClick_EventOccur ( Reason )
  DebugMessage "Event"
  If Memory.Exists("sig_cycleloopend") Then
    Memory.sig_cycleloopend.Get
    Visual.Select("item_flag").Value = "Set"
  End If
  'Timer_Handler TIMER_STOP,0
  'DebugMessage "Stop Timer1 Ended"
End Function


Function OnClick_SetWaitFlag ( Reason )
  DebugMessage "Set Flag"
  If Memory.Exists("sig_cycleloopend") Then
    Memory.sig_cycleloopend.Set 1
    Visual.Select("item_flag").Value = "Set"
  End If
  'Timer_Handler TIMER_STOP,0
  'DebugMessage "Stop Timer1 Ended"
End Function

Function OnClick_ClearWaitFlag ( Reason )
  DebugMessage "Clear Flag"
  If Memory.Exists("sig_cycleloopend") Then
    Memory.sig_cycleloopend.Set 0
    Visual.Select("item_flag").Value = "Clear"
  End If
  'Timer_Handler TIMER_STOP,0
  'DebugMessage "Stop Timer1 Ended"
End Function


Function test_moveshuttle ( lane )
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  test_moveshuttle = False
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOVE_SHUTTLE)
    CanSendArg.Data(1) = lane
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Move Shuttle to "&get_LaneName(lane)
      test_moveshuttle = True
    Else
      LogAdd "Move Shuttle Failed!"
    End If
  End If
End Function
