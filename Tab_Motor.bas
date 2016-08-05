Sub test ( )

End Sub

Function Init_WindowMotor( )
Visual.Select("text_belt_currforward").ReadOnly = True
Visual.Select("text_belt_currbackward").ReadOnly = True
Visual.Select("text_shuttle_currmax").ReadOnly = True
Visual.Select("text_shuttle_currforward").ReadOnly = True
Visual.Select("text_shuttle_curbackward").ReadOnly = True
Visual.Select("text_WA_currmax").ReadOnly = True
Visual.Select("text_WA_currforward").ReadOnly = True
Visual.Select("text_WA_currbackward").ReadOnly = True
End Function

Function OnClick_btn_belt_checkcurr( Reason )
LogAdd "Belt Motor Check Current"
End Function

Function OnClick_btn_shuttle_calibrate( Reason )
LogAdd "Shuttle Motor Calibrate"
End Function

Function OnClick_btn_shuttle_refrun( Reason )
LogAdd "Shuttle Motor Reference Run"
End Function

Function OnClick_btn_shuttle_mvtopos( Reason )
  If CheckValue(Visual.Select("input_shuttle_posiiton").Value) Then
    LogAdd "Shuttle Motor Move to Position"
  Else
    LogAdd "Shuttle Motor Move to Position failed!"
  End If
End Function

Function OnClick_btn_shuttle_checkcurr( Reason )
  LogAdd "Shuttle Motor check current"
End Function


Function OnClick_btn_WA_calibrate( Reason )
  LogAdd "Belt Motor calibrate motor"
End Function

Function OnClick_btn_WA_refrun( Reason )
  LogAdd "Shuttle Motor Calibrate"
End Function

Function OnClick_btn_WA_mvtopos( Reason )
    If CheckValue(Visual.Select("input_shuttle_posiiton").Value) Then
    LogAdd "Width Adjustment Motor Move to Position"
  Else
    LogAdd "Width Adjustment Motor Move to Position failed!"
  End If
End Function

Function OnClick_btn_WA_checkcurr( Reason )
  LogAdd "Shuttle Motor Move to Position"
End Function

