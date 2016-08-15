Function Init_WindowEndurance
DebugMessage "Init Endurance Run Window"
Visual.Select("textSAstarttime").ReadOnly = true
Visual.Select("textSAstoptime").ReadOnly = true
Visual.Select("textSAelapsed_withPCB").ReadOnly = true
Visual.Select("textSAelapsed_withoutPCB").ReadOnly = true
Visual.Select("textSAstarttime").ReadOnly = true
Visual.Select("textSAstoptime").ReadOnly = true
Visual.Select("cbwithPBC").Checked  = true
Visual.Select("cbwoPBC").Checked = true
Visual.Select("textwithPCBmins").Value = "60"
Visual.Select("textwoPCBmins").Value = "60"
End Function

Function OnClick_btnSArun_start ( Reason )
LogAdd "SA Start"
End Function

Function OnClick_btnSArun_stop ( Reason )
LogAdd "SA Stop"

End Function

Function OnClick_btnendrun_wpcb_start ( Reason )
LogAdd "Endurance Run with PCB Start"

End Function

Function OnClick_btnendrun_wpcb_stop ( Reason )
LogAdd "Endurance Run with PCB Stop"

End Function

Function OnClick_btnendrun_wopcb_start ( Reason )
LogAdd "Endurance Run without PCB Start"

End Function

Function OnClick_btnendrun_wopcb_stop ( Reason )
LogAdd "Endurance Run without PCB Stop"

End Function
