

Function Command_GetRefenceStatus( WidthStat, ShuttleStat)
  Dim CanSendArg,CanReadArg,CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CanManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_GET_REF_STATUS)
    CanSendArg.Length = 1
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      ShuttleStat = CanReadArg.Data(2)
      WidthStat = CanReadArg.Data(3)
      Command_GetRefenceStatus= True
    Else
      ShuttleStat = 0
      WidthStat = 0
      Command_GetRefenceStatus= False
    End If
  End If
End Function
'-------------------------------------------------------

Function Command_Get_PCBState ( StartNext )

Dim CanSendArg , CanReadArg, CANConfig
Set CanSendArg =  CreateObject("ICAN.CanSendArg")
Set CanReadArg =  CreateObject("ICAN.CanReadArg")
 
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_GET_PCB_STATE)
    CanSendArg.Data(1) = StartNext
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      Command_Get_PCBState = True
    Else
      Command_Get_PCBState = False
    End If
  else
    LogAdd "No CAN Manager!"
    
  End If 
 
End Function

'-------------------------------------------------------


Function Command_GetVersion ( ByVal App_Bios,  ByRef FWver_High, ByRef FWver_Lo )
  Dim CanSendArg, CANConfig, FWselect
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")

  If App_Bios = 0 Then
  FWselect = $(PARAM_DL_ZIEL_BIOS)
  Else
  FWselect = $(PARAM_DL_ZIEL_APPL)
  End If
  Command_GetVersion = False

  If Memory.Exists("CanManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    If CmdGetVersion(Memory.CanManager, CanSendArg , FWselect ,FWver_High,FWver_Lo) = Ack_Timeout Then
      LogAdd ("Read Firmware Timeout!")
    Else
      Command_GetVersion = True
    End If
    Memory.CanManager.Deliver = True
  Else
    LogAdd "No Can Manager!"
  End If

End Function

'-------------------------------------------------------

Function Command_Abort ( )
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  Command_Abort = False  
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_ABORT)
    CanSendArg.Length = 1
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Current operation aborted"
      Command_Abort = True
    Else
      DebugMessage "attempt to abort operation failed"
    End If
  else
    LogAdd "No CAN Manager!"
    
  End If 
End Function

'-------------------------------------------------------

Function Command_Prepare_WidthAdjustment ( Width , rel_abs, fixedrail)
  'fixedrail 
  ' 0 = right side fixed
  ' 1 = left side fixed
  'abs_rel
  ' 0 = relative width position 
  ' 1 = absolute width position
  DebugMessage "Width Adjustment :" & Width
  
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Dim Error_Flag
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  Error_Flag = 0
  
  If rel_abs < 0 OR rel_abs > 1 Then
    Error_Flag = 1
  End If
  
  If fixedrail < 0 OR fixedrail > 1 Then
    Error_Flag = 1
  End If
  
  If Error_Flag = 0 Then
    If Memory.Exists( "CanManager" ) Then
      Memory.Get "CANConfig",CANConfig
      CanSendArg.CanId = CANConfig.CANIDcmd
      CanSendArg.Data(0) = $(CMD_PREPARE_WIDTH_ADJUSTMENT)
      CanSendArg.Data(1) = rel_abs
      CanSendArg.Data(2) = fixedrail
      CanSendArg.Data(3) = 0
      CanSendArg.Data(4) = Lang.GetByte(Width,0)
      CanSendArg.Data(5) = Lang.GetByte(Width,1)
      CanSendArg.Data(6) = Lang.GetByte(Width,2)
      CanSendArg.Data(7) = Lang.GetByte(Width,3)
      CanSendArg.Length = 8
      If CANSendCMD(CanSendArg,CanReadArg,250) = True Then

      Else

      End If
    Else

    End if
  
  Else
    DebugMessage "Invalid Param"
  End If
End Function
'-------------------------------------------------------
'Prepare shuttle adjustment
Function Command_Prepare_ShuttlePosition ( Position, rel_abs, fixedrail)
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Dim Error_Flag
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")
  'fixedrail 
  ' 0 = right side fixed
  ' 1 = left side fixed
  'abs_rel
  ' 0 = relative shuttle position 
  ' 1 = absolute shuttle position

  Error_Flag = 0

  If rel_abs < 0 OR rel_abs > 1 Then
    Error_Flag = 1
  End If
  
  If fixedrail < 0 OR fixedrail > 1 Then
    Error_Flag = 1
  End If
  
  If Error_Flag = 0 Then
    If Memory.Exists( "CanManager" ) Then
      Memory.Get "CANConfig",CANConfig
      CanSendArg.CanId = CANConfig.CANIDcmd
      CanSendArg.Data(0) = $(CMD_PREPARE_SHUTTLE_POSITION)
      CanSendArg.Data(1) = rel_abs
      CanSendArg.Data(2) = fixedrail
      CanSendArg.Data(3) = 0
      CanSendArg.Data(4) = Lang.GetByte(Position,0)
      CanSendArg.Data(5) = Lang.GetByte(Position,1)
      CanSendArg.Data(6) = Lang.GetByte(Position,2)
      CanSendArg.Data(7) = Lang.GetByte(Position,3)
      CanSendArg.Length = 8
      
      If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
        Command_Prepare_ShuttlePosition = True
      Else
        Command_Prepare_ShuttlePosition = False      
      End If
      
    Else    
      Command_Prepare_ShuttlePosition = False      
    End if
  
  Else
    DebugMessage "Invalid Param"
  End If
End Function
'-------------------------------------------------------
Function Command_Prepare_MoveOut(lane)
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOVE_OUT)
    CanSendArg.Data(1) = lane
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Move out PCB from "&Get_LaneName(lane)
    Else
      DebugMessage "Move out PCB Failed!"
    End If
  End If
End Function
'-------------------------------------------------------
Function Command_Prepare_MotorVelocity(Speed,Axis)
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOTOR_VELOCITY)
    CanSendArg.Data(1) = Axis
    CanSendArg.Data(2) = Lang.GetByte(Speed,0)
    CanSendArg.Data(3) = Lang.GetByte(Speed,1)
    CanSendArg.Length = 4
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Move Conveyor Motor at " & Speed & "mm/s."
    Else
      DebugMessage "Move Conveyor Motor failed"
    End If
  End If
End Function
'-------------------------------------------------------
Function Command_Prepare_ERun ( TimeOut, PCB, Conveyor, Shuttle, WA)

  Dim CanSendArg , CanReadArg, CANConfig
  Dim Mode,TimeOutSel
  Dim TO_LL,TO_LH,TO_HL,TO_HH
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  Mode = 0
  Command_Prepare_ERun = false
  Mode = Lang.SetBit(Mode,0,PCB)
  Mode = Lang.SetBit(Mode,1,Conveyor)
  Mode = Lang.SetBit(Mode,2,Shuttle)
  Mode = Lang.SetBit(Mode,3,WA)
  DebugMessage PCB & " " & Conveyor & " " & Shuttle & " " & WA
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
      Command_Prepare_ERun = true
      'LogAdd "Endurance run command sent ok"
    Else
      'LogAdd "Endurance run command sent failed"
    End If
  else
    LogAdd "No CAN Manager!"
  End If

End Function


'-------------------------------------------------------

Function Command_Prepare_MotorCalibrate( Motor )

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

Function Command_Prepare_MotorPosition( Motor, MovType, Pos )

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

Function Command_Prepare_MotorCurrent( Motor )

  Dim CanSendArg , CanReadArg, CANConfig, PrepareID
  Dim loopcnt
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  loopcnt = 6000
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOTOR_CURRENT)
    CanSendArg.Data(1) = Motor
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      PrepareID = CanReadArg.Data(2)
      Do while loopcnt > 0
        If Memory.CanManager.PeekMessage (CanReadArg, 10) Then
          If CanReadArg.Data(0) = &h00 AND CanReadArg.Data(2) = PrepareID Then
            loopcnt = -1
            LogAdd "Check current ok"
            Command_Prepare_MotorCurrent = 1
          else
            loopcnt = loopcnt - 1
          End If      
        Else
          loopcnt = loopcnt - 1
        End If
      Loop
      
      If loopcnt = 0 Then
        LogAdd "Check current Timeout"
        Command_Prepare_MotorCurrent = 0
      End If
    Else
      LogAdd "Check current failed to start"
    End If
  End If
End Function

'-------------------------------------------------------

Function Command_Prepare_MotorReference( Motor )
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

Function Command_Prepare_CalibrateSensor ()
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_CALIBRATE_SENSOR)
    CanSendArg.Length = 1
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      LogAdd "Calibrate sensor command sent"
      Command_Prepare_CalibrateSensor = 1
    Else
      Command_Prepare_CalibrateSensor = 0
      LogAdd "Calibrate sensor command failed"
    End If    
  Else

  End if
  
End Function
'-------------------------------------------------------

Function Command_Prepare_BarcodeScanner (Lane,ScannerPos)
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_BARCODE_SCANNER)
    CanSendArg.Data(1) = Lane
    CanSendArg.Data(2) = ScannerPos
    CanSendArg.Length = 3
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      LogAdd "Prepare barcode command sent"
      Command_Prepare_CalibrateSensor = 1
    Else
      Command_Prepare_CalibrateSensor = 0
      LogAdd "Prepare barcode command failed"
    End If    
  Else

  End if
End Function 
'-------------------------------------------------------
Function Command_MoveShuttle ( lane )
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_PREPARE_MOVE_SHUTTLE)
    CanSendArg.Data(1) = lane
    CanSendArg.Length = 2
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      LogAdd "Move Shuttle to "&Get_LaneName(lane)
    Else
      LogAdd "Move Shuttle Failed!"
    End If
  End If
End Function
'-------------------------------------------------------
Function Command_Reset_FixedRailOffset( Lane )
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_RESET_FIXED_RAIL_OFFSET)
    CanSendArg.Data(1) = Lane
    CanSendArg.Length = 2
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      LogAdd "Reset fixed rail offset command sent"
      Command_Reset_FixedRailOffset = 1
    Else
      LogAdd "Reset fixed rail offset command failed"
      Command_Reset_FixedRailOffset = 0
    End If    
  Else

  End if
  
End Function
'-------------------------------------------------------
Function Command_Set_LaneParameter(lane,param,value)
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_SET_LANE_PAR)
    CanSendArg.Data(1) = param
    CanSendArg.Data(2) = lane
    CanSendArg.Data(3) = 0
    CanSendArg.Data(4) = Lang.GetByte(value,0)
    CanSendArg.Data(5) = Lang.GetByte(value,1)
    CanSendArg.Data(6) = Lang.GetByte(value,2)
    CanSendArg.Data(7) = Lang.GetByte(value,3)
    CanSendArg.Length = 8
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Set Lane "&Get_LaneName(lane) & " param"
      Command_Set_LaneParameter = 1
    Else
      DebugMessage "Set Lane Param failed"
      Command_Set_LaneParameter = -1
    End If
  End If
End Function

'-------------------------------------------------------

Function Command_Set_ParamERLimit( Value )
  Dim CanReadArg,CanSendArg,CANConfig
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_SET_PARAM)
    CanSendArg.Data(1) = Lang.GetByte ($(PAR_ENDUR_LIMIT_ADJ),0)
    CanSendArg.Data(2) = Lang.GetByte ($(PAR_ENDUR_LIMIT_ADJ),1)
    CanSendArg.Data(3) = Lang.GetByte (Value,0)
    CanSendArg.Data(4) = Lang.GetByte (Value,1)
    CanSendArg.Data(5) = Lang.GetByte (Value,2)
    CanSendArg.Data(6) = Lang.GetByte (Value,3)
    CanSendArg.Length = 7
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      Command_Set_ParamERLimit = true
      DebugMessage "Set ER Limit OK"
      'LogAdd "Endurance run command sent ok"
    Else
      DebugMessage "Set ER Limit NOK"
      Command_Set_ParamERLimit = false
      'LogAdd "Endurance run command sent failed"
    End If
  else
    LogAdd "No CAN Manager!"
  End If
End Function

'-------------------------------------------------------
'Toggle the output of the selected IO
Function Command_Set_OutputToggleIO ( Target )
  Dim CanSendArg, CanReadArg, CANConfig
  Dim NewValue 
  If IO_getValue(Target) = 1 Then
    NewValue = 0
  Else
    NewValue = 1
  End If
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  Memory.Get "CANConfig",CANConfig
  CanSendArg.CanID = CANConfig.CANIDcmd
  CanSendArg.Data(0) = $(CMD_SET_OUTPUT)
  CanSendArg.Data(1) = Target  
  CanSendArg.Data(2) = NewValue  
  CanSendArg.Length = 3
  If CANSendCmd(CanSendArg,CanReadArg, 250) = True Then
    LogAdd "Toggle : " & IO_getName(Target)
    IO_setValue Target, NewValue
  Else
    LogAdd "Toggle " & IO_getName(Target) & " output failed!"
  End If  
End Function

'-------------------------------------------------------
Function Command_Set_PCBData ( PCB_Ref, DataID, Value)
'Set PCB Data
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_SET_PCB_DATA)
    CanSendArg.Data(1) = DataID
    CanSendArg.Data(2) = PCB_Ref
    CanSendArg.Data(3) = 0
    CanSendArg.Data(4) = Lang.GetByte(Value,0)
    CanSendArg.Data(5) = Lang.GetByte(Value,1)    
    CanSendArg.Length = 6
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      Command_Set_PCBData = True
    Else
      Command_Set_PCBData = False
    End If    
  Else
    Command_Set_PCBData = False
  End if
  
End Function

'-------------------------------------------------------
Function Command_Set_PCBData_Single ( PCB_Ref,DataID,Value )

  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_SET_PCB_DATA)
    CanSendArg.Data(1) = $(PCB_DATA_OPTIONS_SINGLE)
    CanSendArg.Data(2) = PCB_Ref
    CanSendArg.Data(3) = 0
    CanSendArg.Data(4) = DataID
    CanSendArg.Data(5) = Value
    CanSendArg.Length = 6
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      Command_Set_PCBData_Single = True
    Else
      Command_Set_PCBData_Single = False
    End If    
  Else
    Command_Set_PCBData_Single = False
  End if
  
End Function

'-------------------------------------------------------
Function Command_Set_PCBLength (Value)
  DebugMessage "Set PCB length: " & Value
  Command_Set_PCBLength = Command_Set_PCBData(PCB_LANE1,$(PCB_DATA_LENGTH),Value)
  Command_Set_PCBLength = Command_Set_PCBData(PCB_LANE2,$(PCB_DATA_LENGTH),Value)
  Command_Set_PCBLength = Command_Set_PCBData(PCB_SHUTTLE,$(PCB_DATA_LENGTH),Value)
End Function 
'-------------------------------------------------------
Function Command_DeletePCB ()
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_DELETE_PCB)
    CanSendArg.Length = 1
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      LogAdd "Delete PCB command sent"
    Else
       LogAdd "Delete PCB command failed"
    End If    
  Else

  End if  
End Function

'-------------------------------------------------------
Function Command_Get_HWOption ( )
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_GET_HW_OPTION)   
    CanSendArg.Length = 1
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      LogAdd "Get HW option command sent"
    Else
       LogAdd "Get HW option command failed"
    End If    
  Else

  End if  
End Function

'-------------------------------------------------------
Function Command_Set_HWOption ( Param , Value )
  Dim CanSendArg,CanReadArg, CANConfig
  Dim CanManager
  Set CanSendArg = CreateObject("ICAN.CanSendArg")
  Set CanReadArg = CreateObject("ICAN.CanReadArg")

  If Memory.Exists( "CanManager" ) Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanId = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_SET_HW_OPTION)   
    CanSendArg.Data(1) = Param
    CanSendArg.Data(2) = Value    
    CanSendArg.Length = 3
    
    If CANSendCMD(CanSendArg,CanReadArg,250) = True Then
      DebugMessage "Set HW Option"
    Else
      DebugMessage "Set HW Option command failed"
    End If    
  Else
    
  End if  
End Function

'-------------------------------------------------------
' Gets the IO state of ALL the input and outputs
Function Command_Get_IOStates()
  Dim CanSendArg, CanReadArg,CANConfig
  Dim iByte, iBit, bitCount, exitLoop
  Dim btncount,btnname
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  bitCount = 0
  exitLoop = 0
  Memory.Get "CANConfig",CANConfig
  CanSendArg.CanID = CANConfig.CANIDcmd
  CanSendArg.Data(0) = $(CMD_GET_IO_STATE)
  CanSendArg.Data(1) = &h00
  CanSendArg.Length = 2
  
  'Send out Get IO State Command
  If CANSendCmd(CanSendArg,CanReadArg, 250) = True Then
    'For iByte = 2 to 7   
      'Debugmessage "Byte: " & CanReadArg.Data(iByte)
    'Next
    
      For iByte = 2 to 7
        For iBit = 0 to 7
          IO_setValue bitCount,Lang.Bit(CanReadArg.Data(iByte),iBit)
          bitCount = bitCount+1
          'stop at the maximum number of LEDs to update
          If bitCount > IO_Max Then
            exitLoop = 1
            Exit For
          End If
        Next
        If exitLoop = 1 Then
          Exit For
        End If
      Next
    Command_Get_IOStates = True
  Else
    Command_Get_IOStates = False    
  End If  
End Function

'-------------------------------------------------------
Function Command_Get_BarcodeLabel ( startline, pcbid, topbottom )
  Dim CanSendArg , CanReadArg, CANConfig
  Dim Data(7),i,stringcontents,StringArray 
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  Set StringArray = CreateObject("MATH.StringArray")
  DebugMessage "Start:" & startline &  " PCBDID: " & pcbid & " topbottom:" & topbottom
  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_GET_BARCODE_LABEL)
    CanSendArg.Data(1) = startline
    CanSendArg.Data(2) = 0
    CanSendArg.Data(3) = 0
    'CanSendArg.Data(2) = Lang.GetByte(0,pcbid)
    'CanSendArg.Data(3) = Lang.GetByte(1,pcbid)
    CanSendArg.Data(4) = topbottom
    CanSendArg.Length = 5
    
    CANSendCMD CanSendArg,CanReadArg, 250
    If CanReadArg.Data(1) = $(ACK_OK) Then
      DebugMessage "Get barcode label " & CanReadArg.Format
      For i = 2 To CanReadArg.Length - 1 
        StringArray.Add(Chr(CanReadArg.Data(i)))
      Next
      stringcontents = StringArray.ComposeString("")
      Command_Get_BarcodeLabel = stringcontents
    ElseIf CanReadArg.Data(1) = $(ACK_NO_MORE_DATA) Then
      DebugMessage "Get barcode no more data" & CanReadArg.Format    
      Command_Get_BarcodeLabel = $(ACK_NO_MORE_DATA)
    Else
      DebugMessage "Get barcode error " & CanReadArg.Format
      Command_Get_BarcodeLabel = $(ACK_NOK)
    End If   
  End If
End Function
'-------------------------------------------------------
Function Command_Get_LaneParam_FixedRail(lane)
  Dim CanSendArg , CanReadArg, CANConfig
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")

  If Memory.Exists("CANManager") Then
    Memory.Get "CANConfig",CANConfig
    CanSendArg.CanID = CANConfig.CANIDcmd
    CanSendArg.Data(0) = $(CMD_GET_LANE_PAR)
    CanSendArg.Data(1) = $(P_LANE_FIXED_RAIL)
    CanSendArg.Data(2) = lane
    CanSendArg.Length = 3
    If CANSendCMD(CanSendArg,CanReadArg, 250) = True Then
      DebugMessage "Get Lane "&Get_LaneName(lane) & " param"
      Command_Get_LaneParam_FixedRail = CanReadArg.Data(4)
    Else
      DebugMessage "Read Lane Param failed"
      Command_Get_LaneParam_FixedRail = -1
    End If
  End If
End Function
'-------------------------------------------------------
Function Command_Get_ParamERLimit()
  Dim CanReadArg
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  
  Command_Get_Param  CanReadArg,$(PAR_ENDUR_LIMIT_ADJ)  
  DebugMessage "Limit: " & Lang.MakeLong4(CanReadArg.Data(4),CanReadArg.Data(5),CanReadArg.Data(6),CanReadArg.Data(7))
   
  End Function
