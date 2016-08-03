Function Init_WindowCommands( )
Dim test
Visual.Select("textBiosVersion").Disabled = true
Visual.Select("textAppVersion").Disabled = true
Visual.Select("textAppVersion").Value = "test1"
Visual.Select("textAppVersion").Value = "test2"
End Function