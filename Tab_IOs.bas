'List of constants for IO inputs. Ensure that all the respective IOs HTML image tag have the ID format "iledn" , 
'where n correspond to the below table
Const IO_I_StartButton      = &H01
Const IO_I_StopButton       = &H02  
Const IO_I_EmergencyStop    = &H03
Const IO_I_Cover            = &H04
Const IO_I_ControlVoltage   = &H05
Const IO_I_PCB_Sensor       = &H08
Const IO_I_PCB_Jam_Input    = &H09
Const IO_I_PCB_Jam_Output   = &H0A
Const IO_I_Barcode_scanner  = &H0B
Const IO_O_coverblocked               = &H18
Const IO_O_WA_Motor                   = &H19
Const IO_O_shuttle_motor              = &H1A
Const IO_O_barcodescan_lane1          = &H1B
Const IO_O_barcodescan_lane2          = &H1C
Const IO_O_SMEMA_ip_lane1_machine_rdy = &H20
Const IO_O_SMEMA_op_lane1_PCB_avail   = &H21
Const IO_O_SMEMA_op_lane1_failed_PCB  = &H22
Const IO_O_SMEMA_ip_lane2_machine_rdy = &H23
Const IO_O_SMEMA_op_lane2_PCB_avail   = &H24
Const IO_O_SMEMA_op_lane2_failed_PCB  = &H25
Const IO_Max            = 37

Function IO_getValue( Target )
  Dim IO_Array
  Memory.Get "IO_Array",IO_Array
  IO_getValue = IO_Array.Data(Target - 1)  
End Function

Function IO_setValue ( Target, Value )
  Dim IO_Array
  Dim LedName
  Memory.Get "IO_Array",IO_Array
   
  DebugMessage "IO set:"& Target - 1
  if Value = 1 Then
    LedName = String.Format("led%02X",Target)
    IO_Array.Data(Target-1) = 1
    Visual.Select(LedName).Src = "./resources/led_round_green.png"
    DebugMessage "Set LED on:" & LedName    
    
  Elseif Value = 0 Then
    LedName = String.Format("led%02X",Target)  
    IO_Array.Data(Target-1) = 0    
    DebugMessage "Set LED off:" & LedName
    Visual.Select(LedName).Src = "./resources/led_round_grey.png"
  Else
    DebugMessage "Invalid IO Input value to set"
  End If  
  
End Function

Function IO_setToggle ( Target )
  If IO_getValue(Target) = 0 Then
    IO_setValue Target, 1
  Else
    IO_setValue Target, 0
  End If
  
End Function

Function InitWindowIOs ()
  Dim IO_Array
  Dim i
  Dim LEDName
  Set IO_Array = CreateObject( "MATH.Array" )  
  
  Visual.Select("frame_hidden").style.display = "none"
  Memory.Set "IO_Array",IO_Array
  'setup input array, with element 0
  'IO_Array.Add(0) 
  For i = 1  To IO_Max
    'DebugMessage "add "&i
    IO_Array.Add(0)
    'set all the LED values in the newly created array, and update the display
    LEDName = String.Format("led%02X",i)
    IO_setValue i,0
    'Assign the attribute to each of the image elements
    Visual.Select(LedName).setAttribute "attr","io_i_image"

  Next
  
End Function

Function GetIOState()
  Dim CanSendArg, CanReadArg
  Dim iByte, iBit, bitCount, exitLoop
  
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  bitCount = 1
  exitLoop = 0
  CanSendArg.CanID = &h644
  CanSendArg.Data(0) = &h37
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
  End If
End Function

Function OnClick_btnUpdateInputs ( Reason )
  LogAdd "Refresh Input IOs"
  GetIOState
End Function
