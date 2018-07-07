#tag Class
Protected Class Assert
	#tag Method, Flags = &h0
		Sub AreDifferent(expected As Object, actual As Object, message As String = "")
		  If Not (expected Is actual) Then
		    Pass(message)
		  Else
		    Fail("Objects are not the same", message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreDifferent(expected As String, actual As String, message As String = "")
		  If expected.Encoding <> actual.Encoding Or StrComp(expected, actual, 0) <> 0 Then
		    Pass()
		  Else
		    Fail("String '" + actual + "' is the same", message )
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As Color, actual As Color, message As String = "")
		  Dim expectedColor, actualColor As String
		  
		  If expected = actual Then
		    Pass(message)
		  Else
		    expectedColor = "RGB(" + Str(expected.Red) + ", " + Str(expected.Green) + ", " + Str(expected.Blue) + ")"
		    actualColor = "RGB(" + Str(actual.Red) + ", " + Str(actual.Green) + ", " + Str(actual.Blue) + ")"
		    Fail(FailEqualMessage(expectedColor, actualColor), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As Currency, actual As Currency, message As String = "")
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As Date, actual As Date, message As String = "")
		  If expected Is actual Or expected.TotalSeconds = actual.TotalSeconds Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(expected.ShortDate + " " + expected.LongTime, actual.ShortDate + " " + actual.LongTime), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected() As Double, actual() As Double, message As String = "")
		  Dim expectedSize, actualSize As Double
		  
		  expectedSize = UBound(expected)
		  actualSize = UBound(actual)
		  
		  If expectedSize <> actualSize Then
		    Fail( "Expected Integer array Ubound <" + Str(expectedSize) + _
		    "> but was <" + Str(actualSize) + ">.", _
		    message)
		    Return
		  End If
		  
		  For i As Integer = 0 To expectedSize
		    If expected(i) <> actual(i) Then
		      Fail( FailEqualMessage("Array(" + Str(i) + ") = '" + Str(expected(i)) + "'", _
		      "Array(" + Str(i) + ") = '" + Str(actual(i)) + "'"), _
		      message)
		      Return
		    End If
		  Next
		  
		  Pass(message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As Double, actual As Double, tolerance As Double, message As String = "")
		  Dim diff As Double
		  
		  diff = Abs(expected - actual)
		  If diff <= (Abs(tolerance) + 0.00000001) Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Format(expected, "-#########.##########"), Format(actual, "-#########.##########")), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As Double, actual As Double, message As String = "")
		  Dim tolerance As Double = 0.00000001
		  
		  AreEqual(expected, actual, tolerance, message)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As Int16, actual As Int16, message As String = "")
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As Int32, actual As Int32, message As String = "")
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As Int64, actual As Int64, message As String = "")
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As Int8, actual As Int8, message As String = "")
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected() As Integer, actual() As Integer, message As String = "")
		  Dim expectedSize, actualSize As Integer
		  
		  expectedSize = UBound(expected)
		  actualSize = UBound(actual)
		  
		  If expectedSize <> actualSize Then
		    Fail( "Expected Integer array Ubound <" + Str(expectedSize) + _
		    "> but was <" + Str(actualSize) + ">.", _
		    message)
		    Return
		  End If
		  
		  For i As Integer = 0 To expectedSize
		    If expected(i) <> actual(i) Then
		      Fail( FailEqualMessage("Array(" + Str(i) + ") = '" + Str(expected(i)) + "'", _
		      "Array(" + Str(i) + ") = '" + Str(actual(i)) + "'"), _
		      message)
		      Return
		    End If
		  Next
		  
		  Pass(message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (not TargetHasGUI and not TargetWeb and not TargetIOS) or  (TargetWeb) or  (TargetHasGUI)
		Sub AreEqual(expected As MemoryBlock, actual As MemoryBlock, message As String = "")
		  If expected = actual Then
		    Pass()
		    Return
		  End If
		  
		  If expected Is Nil Xor actual Is Nil Then
		    Fail("One given MemoryBlock is Nil", message)
		    Return
		  End If
		  
		  Dim expectedSize As Integer = expected.Size
		  Dim actualSize As Integer = actual.Size
		  
		  If expectedSize <> actualSize Then
		    Fail( "Expected MemoryBlock Size [" + Str(expectedSize) + _
		    "] but was [" + Str(actualSize) + "].", _
		    message)
		    Return
		  End If
		  
		  Dim sExpected As String = expected.StringValue(0, expectedSize)
		  Dim sActual As String = actual.StringValue(0, actualSize)
		  
		  If StrComp(sExpected, sActual, 0) = 0 Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(EncodeHex(sExpected, True), EncodeHex(sActual, True)), message )
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected() As String, actual() As String, message As String = "")
		  Dim expectedSize, actualSize As Integer
		  
		  expectedSize = UBound(expected)
		  actualSize = UBound(actual)
		  
		  If expectedSize <> actualSize Then
		    Fail( "Expected String array Ubound <" + Str(expectedSize) + _
		    "> but was <" + Str(actualSize) + ">.", _
		    message)
		    Return
		  End If
		  
		  For i As Integer = 0 To expectedSize
		    If expected(i) <> actual(i) Then
		      Fail( FailEqualMessage("Array(" + Str(i) + ") = '" + expected(i) + "'", _
		      "Array(" + Str(i) + ") = '" + actual(i) + "'"), _
		      message)
		      Return
		    End If
		  Next
		  
		  Pass(message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As String, actual As String, message As String = "")
		  // This is a case-insensitive comparison
		  
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(expected, actual), message )
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As UInt16, actual As UInt16, message As String = "")
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As UInt32, actual As UInt32, message As String = "")
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As UInt64, actual As UInt64, message As String = "")
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqual(expected As UInt8, actual As UInt8, message As String = "")
		  If expected = actual Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqualMB(expected As MemoryBlock, actual As MemoryBlock, message As String = "")
		  If expected = actual Then
		    Pass()
		    Return
		  End If
		  
		  If expected Is Nil Xor actual Is Nil Then
		    Fail("One given MemoryBlock is Nil", message)
		    Return
		  End If
		  
		  Dim expectedSize As Integer = expected.Size
		  Dim actualSize As Integer = actual.Size
		  
		  If expectedSize <> actualSize Then
		    Fail( "Expected MemoryBlock Size [" + Str(expectedSize) + _
		    "] but was [" + Str(actualSize) + "].", _
		    message)
		  Else
		    Fail(FailEqualMessage(EncodeHex(expected), EncodeHex(actual)), message )
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreEqualProperties(expected As Object, actual As Object, message As String = "")
		  Dim tExp As Introspection.TypeInfo= Introspection.GetType(expected)
		  Dim tAct As Introspection.TypeInfo= Introspection.GetType(actual)
		  
		  If Not (tExp.IsClass And tAct.IsClass) Then
		    Fail("Objects are not class", message)
		    Return
		  End If
		  
		  For Each propExp As Introspection.PropertyInfo In tExp.GetProperties
		    If Not (propExp.IsPublic And propExp.CanRead And propExp.CanWrite) Then Continue
		    
		    For Each propAct As Introspection.PropertyInfo In tAct.GetProperties
		      If Not (propAct.IsPublic And propAct.CanRead And propAct.CanWrite) Then Continue
		      
		      If propAct.Name= propExp.Name Then
		        Dim valueExp As Variant= propExp.Value(expected)
		        Dim valueAct As Variant= propAct.Value(actual)
		        If valueExp<> valueAct Then
		          Fail(propAct.Name+ " are not the same: exp:"+ valueExp.StringValue+ " act:"+ valueAct.StringValue, message)
		          Return
		        End If
		      End If
		    Next
		  Next
		  
		  Pass(message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As Color, actual As Color, message As String = "")
		  Dim expectedColor, actualColor As String
		  
		  If expected <> actual Then
		    Pass()
		  Else
		    expectedColor = "RGB(" + Str(expected.Red) + ", " + Str(expected.Green) + ", " + Str(expected.Blue) + ")"
		    actualColor = "RGB(" + Str(actual.Red) + ", " + Str(actual.Green) + ", " + Str(actual.Blue) + ")"
		    Fail(FailEqualMessage(expectedColor, actualColor), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As Currency, actual As Currency, message As String = "")
		  //NCM-written
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (not TargetHasGUI and not TargetWeb and not TargetIOS) or  (TargetWeb) or  (TargetHasGUI)
		Sub AreNotEqual(expected As Date, actual As Date, message As String = "")
		  //NCM-written
		  If expected Is Nil Xor actual Is Nil Then
		    Pass()
		  ElseIf expected Is Nil And actual Is Nil Then
		    Fail("Both Dates are Nil", message)
		  ElseIf expected = actual Or expected.TotalSeconds = actual.TotalSeconds Then
		    Fail("Both Dates are the same", message)
		  Else
		    Pass()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As Double, actual As Double, tolerance As Double, message As String = "")
		  Dim diff As Double
		  
		  diff = Abs(expected - actual)
		  If diff > (Abs(tolerance) + 0.00000001) Then
		    Pass()
		  Else
		    'Fail(FailEqualMessage(Format(expected, "-#########.##########"), Format(actual, "-#########.##########")), message)
		    Fail(FailEqualMessage(Str(expected, "#########.##########"), Str(actual, "#########.##########")), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As Double, actual As Double, message As String = "")
		  Dim tolerance As Double = 0.00000001
		  
		  AreNotEqual(expected, actual, tolerance, message)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As Int16, actual As Int16, message As String = "")
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As Int32, actual As Int32, message As String = "")
		  //NCM-written
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As Int64, actual As Int64, message As String = "")
		  //NCM-written
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As Int8, actual As Int8, message As String = "")
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (not TargetHasGUI and not TargetWeb and not TargetIOS) or  (TargetWeb) or  (TargetHasGUI)
		Sub AreNotEqual(expected As MemoryBlock, actual As MemoryBlock, message As String = "")
		  If expected = actual Then
		    Fail("The MemoryBlocks are the same", message)
		    
		  ElseIf expected Is Nil Xor actual Is Nil Then
		    Pass()
		    
		  Else
		    Dim expectedSize As Integer = expected.Size
		    Dim actualSize As Integer = actual.Size
		    
		    If expectedSize <> actualSize Then
		      Pass()
		      
		    Else
		      
		      Dim sExpected As String = expected.StringValue(0, expectedSize)
		      dim sActual As String = actual.StringValue(0, actualSize)
		      
		      If StrComp(sExpected, sActual, 0) <> 0 Then
		        Pass()
		      Else
		        Fail("The MemoryBlock is the same: " + EncodeHex(sExpected, True), message )
		      End If
		      
		    End If
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (not TargetHasGUI and not TargetWeb and not TargetIOS) or  (TargetWeb) or  (TargetHasGUI)
		Sub AreNotEqual(expected As String, actual As String, message As String = "")
		  //NCM-written
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail("The Strings '" + actual + " are equal but shouldn't be", message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As UInt16, actual As UInt16, message As String = "")
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As UInt32, actual As UInt32, message As String = "")
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As UInt64, actual As UInt64, message As String = "")
		  //NCM-written
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreNotEqual(expected As UInt8, actual As UInt8, message As String = "")
		  If expected <> actual Then
		    Pass()
		  Else
		    Fail(FailEqualMessage(Str(expected), Str(actual)), message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreSame(expected As Object, actual As Object, message As String = "")
		  If expected Is actual Then
		    Pass(message)
		  Else
		    Fail("Objects are not the same", message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreSame(expected() As String, actual() As String, message As String = "")
		  Dim expectedSize, actualSize As Integer
		  
		  expectedSize = UBound(expected)
		  actualSize = UBound(actual)
		  
		  If expectedSize <> actualSize Then
		    Fail( "Expected Text array Ubound [" + Str(expectedSize) + _
		    "] but was [" + Str(actualSize) + "].", _
		    message)
		    Return
		  End If
		  
		  For i As Integer = 0 To expectedSize
		    If StrComp(expected(i), actual(i), 0) <> 0 Then
		      Fail(FailEqualMessage("Array(" + Str(i) + ") = '" + (expected(i)) + "'", _
		      "Array(" + Str(i) + ") = '" + (actual(i)) + "'"), _
		      message)
		      Return
		    ElseIf expected(i).Encoding <> actual(i).Encoding Then
		      Fail("The text encoding of item " + Str(i) + " ('" + (expected(i)) + "') differs", message)
		      Return
		    End If
		  Next
		  
		  Pass()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AreSame(expected As String, actual As String, message As String = "")
		  If StrComp(expected, actual, 0) = 0 Then
		    Pass(message)
		  Else
		    Fail(FailEqualMessage(expected, actual), message )
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  Group = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DoesNotMatch(regExPattern As String, actual As String, message As String = "")
		  If regExPattern = "" Then
		    Dim err As New RegExException
		    err.Message = "No pattern was specified"
		    Raise err
		  End If
		  
		  Dim rx As New RegEx
		  rx.SearchPattern = regExPattern
		  
		  If rx.Search(actual) Is Nil Then
		    Pass()
		  Else
		    Fail("[" + (actual) + "]  matches the pattern /" + (regExPattern) + "/", message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Fail(failMessage As String, message As String = "")
		  Group.CurrentTestResult.Result = TestResult.Failed
		  
		  If Group.CurrentTestResult.Message = "" Then
		    Group.CurrentTestResult.Message = message + ": " + failMessage
		  Else
		    Group.CurrentTestResult.Message = Group.CurrentTestResult.Message + EndOfLine + message + ": " + failMessage
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( Hidden )  Function FailEqualMessage(expected As String, actual As String) As String
		  Dim message As String
		  
		  message = "Expected <" + expected + "> but was <" + actual + ">."
		  
		  Return message
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IsFalse(condition As Boolean, message As String = "")
		  If condition Then
		    Fail("<false> expected, but was <true>.", message)
		  Else
		    Pass(message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IsNil(anObject As Object, message As String = "")
		  If anObject = Nil Then
		    Pass(message)
		  Else
		    Fail("Object was expected to be <nil>, but was not.", message)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IsNotNil(anObject As Object, message As String = "")
		  If anObject <> Nil Then
		    Pass(message)
		  Else
		    Fail("Expected value not to be <nil>, but was <nil>.", message)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub IsTrue(condition As Boolean, message As String = "")
		  If condition Then
		    Pass(message)
		  Else
		    Fail("<true> expected, but was <false>.", message)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Matches(regExPattern As String, actual As String, message As String = "")
		  If regExPattern = "" Then
		    Dim err As New RegExException
		    err.Message = "No pattern was specified"
		    Raise err
		  End If
		  
		  Dim rx As New RegEx
		  rx.SearchPattern = regExPattern
		  
		  If rx.Search(actual) Is Nil Then
		    Fail("[" + (actual) + "]  does not match the pattern /" + (regExPattern) + "/", message)
		  Else
		    Pass()
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Message(msg As String)
		  If Group.CurrentTestResult.Message = "" Then
		    Group.CurrentTestResult.Message = msg
		  Else
		    Group.CurrentTestResult.Message = Group.CurrentTestResult.Message + EndOfLine + msg
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Pass(message As String = "")
		  If Group.CurrentTestResult.Result <> TestResult.Failed Then
		    Group.CurrentTestResult.Result = TestResult.Passed
		    Group.CurrentTestResult.Message = message
		  End If
		  
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Failed As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Group As TestGroup
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Failed"
			Group="Behavior"
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
			Name="Name"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
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
