
Const MOTOR_CONVEYOR = 4
Const MOTOR_SHUTTLE = 2
Const MOTOR_WIDTH_ADJ = 3

'-------------------------------------------------------
' Init Windows
'-------------------------------------------------------

Sub Init_WindowMotor( )
DebugMessage "Init Motor Window"
Visual.Select("text_belt_currforward").ReadOnly = True
Visual.Select("text_belt_currbackward").ReadOnly = True
Visual.Select("text_shuttle_currmax").ReadOnly = True
Visual.Select("text_shuttle_currforward").ReadOnly = True
Visual.Select("text_shuttle_currbackward").ReadOnly = True
Visual.Select("text_WA_currmax").ReadOnly = True
Visual.Select("text_WA_currforward").ReadOnly = True
Visual.Select("text_WA_currbackward").ReadOnly = True

Visual.Select("input_shuttle_position").value = "100000"
Visual.Select("input_WA_position").value = "100000"

Visual.Select("row_WA_currmax").style.display = "none"
Visual.Select("row_shuttle_currmax").style.display = "none"
Visual.Select("frame_beltmotor").style.display = "none"
Visual.Select("btn_belt_checkcurr").style.display = "none"
Visual.Select("btn_WA_checkcurr").style.display = "none"
Visual.Select("btn_shuttle_checkcurr").style.display = "none"

End Sub


'-------------------------------------------------------
' On Click Events
'-------------------------------------------------------


Function OnClick_btn_shuttle_calibrate( Reason )
LogAdd "Shuttle Motor calibrate"
Motor_Calibrate( MOTOR_SHUTTLE )
End Function

'-------------------------------------------------------

Function OnClick_btn_shuttle_refrun( Reason )
LogAdd "Shuttle Motor reference run"
Motor_RefRun( MOTOR_SHUTTLE )
End Function

'-------------------------------------------------------

Function OnClick_btn_shuttle_mvtopos( Reason )
  If CheckSValue(Visual.Select("input_shuttle_position").Value) Then
    LogAdd "Shuttle Motor Move to position"
    
    CMD_PrepareSA Visual.Select("input_shuttle_position").Value,1,0
  Else
    LogAdd "Shuttle Motor Move to position failed!"
  End If
End Function

'-------------------------------------------------------
' Check Current Functions

Function OnClick_btn_belt_checkcurr( Reason )
  Dim CanReadArg
  Dim Curr_Forw, Curr_Back
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  LogAdd "Belt Motor check current"
  Motor_CheckCurr( MOTOR_SHUTTLE ) 
  CAN_getparam CanReadArg , $(PAR_CONV_CURRENT_FORW)
  Curr_Forw = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_belt_currforward").value = String.Format("%d",Curr_Forw)  
  CAN_getparam CanReadArg , $(PAR_CONV_CURRENT_BACKW)
  Curr_Back = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_belt_currbackward").value = String.Format("%d",Curr_Back)
  
End Function

'-------------------------------------------------------

Function OnClick_btn_shuttle_checkcurr( Reason )
  Dim CanReadArg
  Dim Curr_Forw, Curr_Back
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  LogAdd "Shuttle Motor check current"  
  Motor_CheckCurr( MOTOR_SHUTTLE ) 
  CAN_getparam CanReadArg , $(PAR_SHUTTLE_CURRENT_FORW)
  Curr_Forw = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_shuttle_currforward").value = String.Format("%d",Curr_Forw)  
  CAN_getparam CanReadArg , $(PAR_SHUTTLE_CURRENT_BACKW)
  Curr_Back = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_shuttle_currbackward").value = String.Format("%d",Curr_Back)
End Function

'-------------------------------------------------------

Function OnClick_btn_WA_checkcurr( Reason )

  Dim CanReadArg
  Dim Curr_Forw, Curr_Back
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  LogAdd "Width Adjustment check current"
  Motor_CheckCurr( MOTOR_SHUTTLE ) 
  CAN_getparam CanReadArg , $(PAR_WA_CURRENT_FORW)
  Curr_Forw = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_WA_currforward").value = String.Format("%d",Curr_Forw)  
  CAN_getparam CanReadArg , $(PAR_WA_CURRENT_BACKW)
  Curr_Back = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_WA_currbackward").value = String.Format("%d",Curr_Back)
  
End Function

'-------------------------------------------------------

Function OnClick_btn_checkcurr( Reason )

  Dim CanReadArg
  Dim Curr_Forw, Curr_Back
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  LogAdd "Width Adjustment check current"
  Motor_CheckCurr( MOTOR_SHUTTLE ) 
  
  'Width Adjust
  CAN_getparam CanReadArg , $(PAR_WA_CURRENT_FORW)
  Curr_Forw = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_WA_currforward").value = String.Format("%d",Curr_Forw)  
  CAN_getparam CanReadArg , $(PAR_WA_CURRENT_BACKW)
  Curr_Back = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_WA_currbackward").value = String.Format("%d",Curr_Back)
  
  'shuttle
  CAN_getparam CanReadArg , $(PAR_SHUTTLE_CURRENT_FORW)
  Curr_Forw = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_shuttle_currforward").value = String.Format("%d",Curr_Forw)  
  CAN_getparam CanReadArg , $(PAR_SHUTTLE_CURRENT_BACKW)
  Curr_Back = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_shuttle_currbackward").value = String.Format("%d",Curr_Back)

  'belt
  Curr_Forw = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_belt_currforward").value = String.Format("%d",Curr_Forw)  
  CAN_getparam CanReadArg , $(PAR_CONV_CURRENT_BACKW)
  Curr_Back = Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
  Visual.Select("text_belt_currbackward").value = String.Format("%d",Curr_Back)
  
End Function

'-------------------------------------------------------
' Width Adjustment Motors

Function OnClick_btn_WA_calibrate( Reason )
  LogAdd "Width Adjustment Motor calibrate"
  Motor_Calibrate( MOTOR_WIDTH_ADJ )
End Function

'-------------------------------------------------------

Function OnClick_btn_WA_refrun( Reason )
  LogAdd "Width Adjustment Motor reference run"
  Motor_RefRun( MOTOR_WIDTH_ADJ )
End Function

'-------------------------------------------------------

Function OnClick_btn_WA_mvtopos( Reason )
    If CheckUValue(Visual.Select("input_WA_position").Value) Then
    LogAdd "Width Adjustment Motor Move to Position"
    CMD_PrepareWA Visual.Select("input_WA_position").value,1,0
  Else
    LogAdd "Width Adjustment Motor Move to Position failed!"
  End If
End Function

'-------------------------------------------------------

Function Motor_RefRun( Motor )
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOTOR_REFERENCE)
    CanSendArg.Data(1) = Motor
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Reference Run OK"
    Else
      LogAdd "Reference Run Failed"
    End If  
  End If
End Function

'-------------------------------------------------------

Function Motor_Calibrate( Motor )

  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOTOR_CALIBRATE)
    CanSendArg.Data(1) = Motor
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Calibrate motor OK"
    Else
      LogAdd "Calibrate motor Failed"
    End If  
  End If
End Function

'-------------------------------------------------------

Function Motor_MovePos( Motor, MovType, Pos )

  Dim CanSendArg , CanReadArg, CANConfig
  Dim POS_LL, POS_LH, POS_HL, POS_HH
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  POS_LL = Lang.GetByte(Pos,0)
  POS_LH = Lang.GetByte(Pos,1)
  POS_HL = Lang.GetByte(Pos,2)
  POS_HH = Lang.GetByte(Pos,3)
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOTOR_POSITION)
    CanSendArg.Data(1) = Motor
    CanSendArg.Data(2) = MovType
    CanSendArg.Data(3) = 0  
    CanSendArg.Data(4) = POS_LL
    CanSendArg.Data(5) = POS_LH
    CanSendArg.Data(6) = POS_HL
    CanSendArg.Data(7) = POS_HH
    
    CanSendArg.Length = 8
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Move to position OK"
    Else
      LogAdd "Move to position Failed"
    End If  
  End If

End Function 

'-------------------------------------------------------

Function Motor_CheckCurr( Motor )

  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOTOR_CURRENT)
    CanSendArg.Data(1) = Motor
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Check Current OK"
    Else
      LogAdd "Chck Current Failed"
    End If
  End If
End Function

'-------------------------------------------------------

'PAR_SHUTTLE_CURRENT_FORW
'PAR_SHUTTLE_CURRENT_BACKW
'PAR_WA_CURRENT_FORW
'PAR_WA_CURRENT_BACKW
'PAR_CONV_CURRENT_FORW
'PAR_CONV_CURRENT_BACKW


