#tag Class
Protected Class TestResult
	#tag Property, Flags = &h0
		Duration As Double
	#tag EndProperty

	#tag Property, Flags = &h0
		IncludeMethod As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h0
		Message As String
	#tag EndProperty

	#tag Property, Flags = &h0
		MethodInfo As Introspection.MethodInfo
	#tag EndProperty

	#tag Property, Flags = &h0
		Result As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TestName As String
	#tag EndProperty


	#tag Constant, Name = Failed, Type = String, Dynamic = False, Default = \"Failed", Scope = Public
	#tag EndConstant

	#tag Constant, Name = NotImplemented, Type = String, Dynamic = False, Default = \"n/a", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Passed, Type = String, Dynamic = False, Default = \"Passed", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Skipped, Type = String, Dynamic = False, Default = \"Skipped", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Duration"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeMethod"
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Message"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Result"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			InheritedFrom="Object"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
