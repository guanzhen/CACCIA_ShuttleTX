
Function OnClick_Send( Reason )
  Dim CanManager
  Dim CanSendArg, CanReadArg
  Dim TioCnt,Timeout
  Timeout = 1000
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  Memory.Get "CanManager",CanManager

  CanSendArg.CanID = &h644
  CanSendArg.Data(0) = &h54
  CanSendArg.Data(1) = &h00
  CanSendArg.Length = 2
  CANSend CanSendArg

  For TioCnt = 0 To Timeout
    If CanManager.PeekMessage (CanReadArg, 1) Then
      DebugMessage "CanMgr " & CanReadArg.Format(CFM_SHORT)
    End If
  Next
End Function

Function OnClick_Send2( Reason )
  Visual.Select("Send2").InnerHtml = "Refresh IOs"
  DebugMessage "Send2"
  DebugMessage Visual.Exists("Send2")

  'Visual.Select("Send2").InnerHtml = "Send2"
  GetIOState
End Function

Function OnClick_Send3( Reason )
  Dim CanSendArg, CanReadArg
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  CanSendArg.CanID = &h644
  CanSendArg.Data(0) = &h37
  CanSendArg.Data(1) = &h00
  CanSendArg.Length = 2
  If CANSendCmd(CanSendArg,CanReadArg, 250) = True Then
    DebugMessage "SendCommand OK"
  Else
    DebugMessage "Sendcommand NOK"
  End If

End Function

Function OnClick_btntestTimer1Start ( Reason )
  Dim sig_timerend,looping
  Set sig_timerend = Signal.Create
  Memory.Set "sig_timerend",sig_timerend
  DebugMessage "Start Timer1"
  Timer_Handler TIMER_START,10
  looping = 1

  Do while looping = 1
   If sig_timerend.wait(50) Then
    looping = 0
   End If
  Loop
  DebugMessage "Timer1 Ended"
  Memory.Free "sig_timerend"
End Function

Function OnClick_btntestTimer1Stop ( Reason )
  DebugMessage "Stop Timer1 Clicked"
  Timer_Handler TIMER_STOP,0
  DebugMessage "Stop Timer1 Ended"
End Function
