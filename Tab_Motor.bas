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
Visual.Select("input_shuttle_position").value = "100"
Visual.Select("input_WA_position").value = "100"


End Function

Function OnClick_btn_belt_checkcurr( Reason )
LogAdd "Belt Motor check current"
End Function

Function OnClick_btn_shuttle_calibrate( Reason )
LogAdd "Shuttle Motor calibrate"
End Function

Function OnClick_btn_shuttle_refrun( Reason )
LogAdd "Shuttle Motor reference run"
End Function

Function OnClick_btn_shuttle_mvtopos( Reason )
  If CheckValue(Visual.Select("input_shuttle_position").Value) Then
    LogAdd "Shuttle Motor Move to position"
  Else
    LogAdd "Shuttle Motor Move to position failed!"
  End If
End Function

Function OnClick_btn_shuttle_checkcurr( Reason )
  LogAdd "Shuttle Motor check current"
End Function


Function OnClick_btn_WA_calibrate( Reason )
  LogAdd "Width Adjustment Motor calibrate"
End Function

Function OnClick_btn_WA_refrun( Reason )
  LogAdd "Width Adjustment Motor reference run"
End Function

Function OnClick_btn_WA_mvtopos( Reason )
    If CheckValue(Visual.Select("input_WA_position").Value) Then
    LogAdd "Width Adjustment Motor Move to Position"
  Else
    LogAdd "Width Adjustment Motor Move to Position failed!"
  End If
End Function

Function OnClick_btn_WA_checkcurr( Reason )
  LogAdd "Width Adjustment check current"
End Function

