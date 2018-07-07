#tag Class
Protected Class App
Inherits Application
	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = -, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = -, Language = Default, Definition  = \"&Quit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = -, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


End Class
#tag EndClass
