Const IO_I_StartButton      = 0
Const IO_I_StopButton       = 1  
Const IO_I_EmergencyStop    = 2
Const IO_I_Cover            = 3
Const IO_I_ControlVoltage   = 4
Const IO_I_PCB_Sensor       = 5
Const IO_I_PCB_Jam_Input    = 6
Const IO_I_PCB_Jam_Output   = 7
Const IO_I_Barcode_scanner  = 8

Function IO_setOn ( Target, Value )
  
End Function

Function IO_setOff ( Target, Value )
  
End Function

Function IO_setToggle ( Target )

End Function



Sub Init_IOs
  Dim IO_in_Array
  Dim i
  Set IO_in_Array = CreateObject( "MATH.Array" )
  Memory.Set "IO_in_Array",IO_in_Array
  For i = 1  To IO_in_MaxNum 
  	IO_in_Array.Add(0)
  Next
    
End Sub