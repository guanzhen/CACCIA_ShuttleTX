'List of constants for IO inputs. Ensure that all the respective IOs HTML image tag have the ID format "iledn" , 
'where n correspond to the below table
Const IO_I_StartButton      = 0
Const IO_I_StopButton       = 1  
Const IO_I_EmergencyStop    = 2
Const IO_I_Cover            = 3
Const IO_I_ControlVoltage   = 4
Const IO_I_PCB_Sensor       = 5
Const IO_I_PCB_Jam_Input    = 6
Const IO_I_PCB_Jam_Output   = 7
Const IO_I_Barcode_scanner  = 8
Const IO_in_Max             = 8
Const IO_out_Max            = 8

Function IO_I_setValue ( Target, Value )
  Dim IO_in_Array
  Dim LedName
  Memory.Get "IO_in_Array",IO_in_Array
  
  if Value = 1 Then
    LedName = String.Format("iled%01d",Target)
    IO_in_Array.Data(Target) = 1
    Visual.Select(LedName).Src = "./resources/led_round_green.png"
    DebugMessage "Set LED on:" & LedName
    
    
  Elseif Value = 0 Then
    LedName = String.Format("iled%01d",Target)  
    IO_in_Array.Data(Target) = 0    
    DebugMessage "Set LED off:" & LedName
    Visual.Select(LedName).Src = "./resources/led_round_grey.png"
  Else
    DebugMessage "Invalid IO Input value to set"
  End If  
  
End Function

Function IO_setToggle ( Target )
  Dim IO_in_Array
  Memory.Get "IO_in_Array",IO_in_Array
  If IO_in_Array.Data(Target) = 0 Then
    IO_I_setValue Target, 1
  Else
    IO_I_setValue Target, 0
  End If
  
End Function

Function InitWindowIOs ()
  Dim IO_in_Array,IO_out_Array
  Dim i
  Set IO_in_Array = CreateObject( "MATH.Array" )
  Set IO_out_Array = CreateObject( "MATH.Array" )
  
  Memory.Set "IO_in_Array",IO_in_Array
  'setup input array
  For i = 0  To IO_in_Max
  	'DebugMessage "add "&i
    IO_in_Array.Add(0)
    'set all the LED values in the newly created array, and update the display
    IO_I_setValue i,IO_in_Array.Data(i)
    'Assign the attribute to each of the image elements
    Visual.Select(String.Format("iled%01d",i)).setAttribute "attr","io_i_image"
  Next
  DebugMessage "Added " & i & " input elements"
  'setup output array
  For i = 0  To IO_out_Max
  	'DebugMessage "add "&i
    IO_out_Array.Add(0)
  Next  
End Function

Function GetIOState()
  Dim CanSendArg, CanReadArg
  Dim iByte, iBit, bitCount, exitLoop
  
  Set CanSendArg =  CreateObject("ICAN.CanSendArg")
  Set CanReadArg =  CreateObject("ICAN.CanReadArg")
  bitCount = 0
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
          IO_I_setValue bitCount,Lang.Bit(CanReadArg.Data(iByte),iBit)
          bitCount = bitCount+1
          'stop at the maximum number of LEDs to update
          If bitCount > IO_in_Max Then
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
