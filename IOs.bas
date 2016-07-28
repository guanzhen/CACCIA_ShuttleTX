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


Sub Init_IOs
  Dim IO_in_Array,IO_out_Array
  Dim i
  Set IO_in_Array = CreateObject( "MATH.Array" )
  Set IO_out_Array = CreateObject( "MATH.Array" )
  
  Memory.Set "IO_in_Array",IO_in_Array
  For i = 0  To IO_in_Max
  	'DebugMessage "add "&i
    IO_in_Array.Add(0)
  Next
  
  'set all the LED values in the newly created array, and update the display
  For i = 0  To IO_in_Max
    IO_I_setValue i,IO_in_Array.Data(i)
  Next
  
  'Assign the attribute to each of the image elements
  For i = 0  To IO_in_Max
    Visual.Select(String.Format("iled%01d",i)).setAttribute "attr","io_i_image"
  Next
End Sub
