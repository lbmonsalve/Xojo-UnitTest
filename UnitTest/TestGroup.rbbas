#tag Class
Protected Class TestGroup
	#tag Method, Flags = &h1
		Protected Sub AsyncAwait(maxSeconds As Integer)
		  If IsRunning Then
		    IsAwaitingAsync = True
		    RunTestsTimer.Period = maxSeconds * 1000
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AsyncComplete()
		  IsAwaitingAsync = False
		  If IsRunning Then
		    RunTestsTimer.Period = kTimerPeriod
		  End If
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CalculateTestDuration()
		  Dim elapsed As Double
		  
		  If CurrentClone Is Nil Then
		    elapsed = 0.0
		  Else
		    elapsed = (Microseconds - TestDuration) / 1000000.0
		  End If
		  
		  CurrentTestResult.Duration = elapsed
		  
		  Dim c As TestController = Controller
		  If c IsA Object Then
		    c.RaiseTestFinished CurrentTestResult, Self
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearResults(skipped As Boolean = False)
		  For Each tr As TestResult In mResults
		    If skipped Then
		      tr.Result = TestResult.Skipped
		    Else
		      tr.Result = TestResult.NotImplemented
		    End If
		    tr.Message = ""
		    tr.Duration = 0
		  Next
		  CurrentTestResult = Nil
		  CurrentResultIndex = 0
		  CurrentClone = Nil
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(controller As TestController, groupName As String = "")
		  groupName = groupName.Trim
		  
		  //
		  // If groupName was not given, use the name of the class
		  //
		  If groupName = "" Then
		    Dim ti As Introspection.TypeInfo = Introspection.GetType(Self)
		    groupName = ti.FullName
		  End If
		  
		  Name = groupName
		  Self.Controller = controller
		  
		  controller.AddGroup(Self)
		  
		  mAssert = New Assert
		  mAssert.Group = Self
		  
		  GetTestMethods
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Constructor(fromGroup As TestGroup)
		  //
		  // Clone from another group
		  //
		  // Only take the super's properties
		  //
		  
		  Static props() As Introspection.PropertyInfo
		  If props.Ubound = -1 Then
		    Dim ti As Introspection.TypeInfo
		    ti = Introspection.GetType(Self)
		    While ti.BaseType IsA Object And Not (ti Is ti.BaseType)
		      ti = ti.BaseType
		    Wend
		    props = ti.GetProperties
		  End If
		  
		  //
		  // Skip certain props all the time
		  //
		  Dim skipProps() As String= Array("CurrentClone", "TestTimers")
		  
		  //
		  // Since computed properties can have side effects, do them first
		  //
		  Dim doComputed As Boolean = False // Will be flipped in the loop
		  
		  Do
		    doComputed = Not doComputed
		    
		    For Each prop As Introspection.PropertyInfo In props
		      #if RBVersion> 2015.01 // new framework
		        If prop.IsComputed <> doComputed Then
		          Continue For prop
		        End If
		      #endif
		      
		      Dim propName As String= prop.Name
		      
		      If prop.IsShared Or Not prop.CanRead Or Not prop.CanWrite Or skipProps.IndexOf(propName) <> -1 Then
		        Continue For prop
		      End If
		      
		      Dim propType As String= prop.PropertyType.Name
		      Dim fromValue As Variant = prop.Value(fromGroup)
		      
		      //
		      // Handle arrays specially
		      //
		      If propType.Right(2) = "()" Then
		        Dim toArr() As Object = prop.Value(Self)
		        Dim fromArr() As Object = fromValue
		        
		        For i As Integer = 0 To fromArr.Ubound
		          toArr.Append(fromArr(i))
		        Next i
		      Else
		        prop.Value(Self) = fromValue
		      End If
		    Next prop
		    
		  Loop Until doComputed = False
		  
		  IsClone = True
		  RaiseEvent Setup
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  If IsClone Then
		    RaiseEvent TearDown
		  End If
		  
		  If Not IsClone And RunTestsTimer IsA Object Then
		    RunTestsTimer.Mode = Timer.ModeOff
		    RemoveHandler RunTestsTimer.Action, WeakAddressOf RunTestsTimer_Action
		    RunTestsTimer = Nil
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ErrorIf(condition As Boolean, message As String)
		  Assert.IsFalse(condition, message)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub GetTestMethods()
		  Dim info As Introspection.TypeInfo
		  
		  info = Introspection.GetType(Self)
		  
		  Dim methods() As Introspection.MethodInfo
		  methods = info.GetMethods
		  
		  //
		  // Get the unique set of methods
		  //
		  Dim methodsDict As New Dictionary
		  For i As Integer = 0 To methods.Ubound
		    Dim m As Introspection.MethodInfo = methods(i)
		    If m.Name.Len > kTestSuffix.Len And m.Name.Right(kTestSuffix.Len) = kTestSuffix And _
		      m.GetParameters.Ubound = -1 Then
		      methodsDict.Value(m.Name) = m // Will replace overridden methods
		    End If
		  Next
		  
		  'For Each entry As DictionaryEntry In methodsDict
		  '// Initialize test results
		  'Dim m As Introspection.MethodInfo = entry.Value
		  'Dim tr As New TestResult
		  'tr.TestName = m.Name.Left(m.Name.Len - kTestSuffix.Len)
		  'tr.MethodInfo = m
		  'tr.Result = TestResult.NotImplemented
		  '
		  'mResults.Append(tr)
		  'Next
		  
		  For i As Integer= 0 To methodsDict.Count- 1
		    // Initialize test results
		    Dim m As Introspection.MethodInfo = methodsDict.Value(methodsDict.Key(i))
		    Dim tr As New TestResult
		    tr.TestName = m.Name.Left(m.Name.Len - kTestSuffix.Len)
		    tr.MethodInfo = m
		    tr.Result = TestResult.NotImplemented
		    
		    mResults.Append(tr)
		  Next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetTestResult(testName As String) As TestResult
		  For Each tr As TestResult In mResults
		    If tr.TestName + kTestSuffix = testName Then
		      Return tr
		    End If
		  Next
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetTestTimer(key As String = "") As Double
		  Dim endTime As Double = Microseconds
		  Dim startTime As Double = TestTimers.Value(key)
		  Dim duration As Double = endTime - startTime
		  
		  Return duration
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		 Shared Function IIf(expr As Boolean, retTrue As String, retFalse As String) As String
		  If expr Then Return retTrue Else Return retFalse
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub LogTestTimer(key As String = "", stage As String = "")
		  //
		  // StartTestTimer must be called first.
		  //
		  // If not used properly, this will raise an exception, intentionally.
		  //
		  
		  Dim duration As Double = GetTestTimer(key)
		  
		  Dim durationText As String
		  Dim unit As String= "µs"
		  Dim useFormat As String= "#,###,##0"
		  
		  Const kSeconds = 1000000.0
		  
		  If duration > (60.0 * kSeconds) Then
		    duration = duration / (60.0 * kSeconds)
		    unit = "m"
		    useFormat = "#,###,##0.0##"
		    
		  ElseIf duration > (1.0 * kSeconds) Then
		    duration = duration / (1.0 * kSeconds)
		    unit = "s"
		    useFormat = "#,###,##0.0###"
		    
		  ElseIf duration > 1000.0 Then
		    duration = duration / 1000.0
		    unit = "ms"
		    useFormat = "#,###,##0.0##"
		    
		  End If
		  
		  'durationText = duration.ToText(Xojo.Core.Locale.Current, useFormat) + " " + unit
		  durationText = Str(duration, useFormat) + " " + unit
		  stage = stage.Trim
		  
		  Assert.Message "Test Timer " + _
		  IIf(key= "", "", key + " ") + _
		  IIf(stage= "", "", "[" + stage + "] ") + _
		  "took " + durationText
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ResetTestDuration()
		  TestDuration = Microseconds
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Results() As TestResult()
		  Return mResults
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RunTestsTimer_Action(sender As Timer)
		  #Pragma Unused sender
		  
		  If UseConstructor Is Nil Then
		    Dim myInfo As Introspection.TypeInfo = Introspection.GetType(Self)
		    Dim constructors() As Introspection.ConstructorInfo = myInfo.GetConstructors
		    For Each c As Introspection.ConstructorInfo In constructors
		      If c.GetParameters.Ubound = 0 Then
		        UseConstructor = c
		        Exit For c
		      End If
		    Next c
		  End If
		  
		  Dim constructorParams() As Variant
		  constructorParams.Append Self
		  
		  If CurrentClone IsA Object Then
		    CalculateTestDuration
		    If CurrentClone.IsAwaitingAsync Then
		      Assert.Fail "Asynchronous test did not complete in time"
		    End If
		  End If
		  
		  If CurrentResultIndex <= mResults.Ubound Then
		    RunTestsTimer.Period = kTimerPeriod
		    CurrentClone = Nil // Make sure TearDown happens
		    
		    Dim result As TestResult = mResults(CurrentResultIndex)
		    CurrentResultIndex = CurrentResultIndex + 1
		    
		    If Not result.IncludeMethod Then
		      result.Result = Result.Skipped
		      Return
		    End If
		    
		    //
		    // Handle any error after stopping the Timer
		    //
		    Dim err As RuntimeException
		    
		    Try
		      CurrentTestResult = result
		      Dim method As Introspection.MethodInfo = result.MethodInfo
		      
		      //
		      // Get a clone
		      //
		      CurrentClone = useConstructor.Invoke(constructorParams)
		      
		      ResetTestDuration
		      method.Invoke(CurrentClone)
		      
		      If CurrentClone.IsAwaitingAsync Then
		        Return // The next round will resume testing
		      End If
		      
		    Catch failedErr As UnitTestFailedException
		      //
		      // The exception is raised because the group was set to StopTestOnFail
		      //
		      
		    Catch e As RuntimeException
		      If e IsA EndException Or e IsA ThreadEndException Then
		        Raise e
		      End If
		      
		      //
		      // Process it below
		      //
		      err = e
		      
		    End Try
		    
		    CalculateTestDuration
		    
		    If err IsA Object Then
		      
		      If Not RaiseEvent UnhandledException(err, result.TestName) Then
		        
		        Dim eInfo As Introspection.TypeInfo
		        eInfo = Introspection.GetType(err)
		        
		        Dim errorMessage As String
		        errorMessage = "A " + eInfo.FullName + " occurred and was caught"
		        If CurrentClone Is Nil Then
		          errorMessage = errorMessage + " – something in the Setup event failed"
		        End If
		        errorMessage = errorMessage + "."
		        
		        If err.Message <> "" Then
		          errorMessage = errorMessage + &u0A + "Message: " + err.Message
		        End If
		        Assert.Fail(errorMessage)
		        
		      End If
		    End If
		    
		    Return
		  End If
		  
		  Stop
		  
		  Dim c As TestController = Controller
		  If c IsA Object Then
		    c.RaiseGroupFinished Self
		  End If
		  
		  Controller.RunNextTest
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetIncludeMethods(value As Boolean)
		  For Each result As TestResult In Results
		    result.IncludeMethod = value
		  Next
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Start()
		  If IncludeGroup Then
		    If RunTestsTimer Is Nil Then
		      RunTestsTimer = New Timer
		      AddHandler RunTestsTimer.Action, WeakAddressOf RunTestsTimer_Action
		    End If
		    RunTestsTimer.Period = kTimerPeriod
		    RunTestsTimer.Mode = Timer.ModeMultiple
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub StartTestTimer(key As String = "")
		  If TestTimers Is Nil Then
		    TestTimers = New Dictionary
		  End If
		  
		  TestTimers.Value(key) = Microseconds
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Stop()
		  CurrentClone = Nil
		  CurrentTestResult = Nil
		  If RunTestsTimer IsA Object Then
		    RunTestsTimer.Mode = Timer.ModeOff
		  End If
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Setup()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event TearDown()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event UnhandledException(err As RuntimeException, methodName As String) As Boolean
	#tag EndHook


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  Return mAssert
			End Get
		#tag EndGetter
		Protected Assert As Assert
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If mController Is Nil Then
			    Return Nil
			  Else
			    Return TestController(mController.Value)
			  End If
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value Is Nil Then
			    mController = Nil
			  Else
			    mController = New WeakRef(value)
			  End If
			  
			End Set
		#tag EndSetter
		Private Controller As TestController
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private CurrentClone As TestGroup
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CurrentResultIndex As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		CurrentTestResult As TestResult
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim duration As Double
			  
			  For Each tr As TestResult In mResults
			    If tr.Result = TestResult.Passed Or tr.Result = TestResult.Failed Then
			      duration = duration + tr.Duration
			    End If
			  Next
			  
			  Return duration
			End Get
		#tag EndGetter
		Duration As Double
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim testCount As Integer
			  
			  For Each tr As TestResult In mResults
			    If tr.Result = TestResult.Failed Then
			      testCount = testCount + 1
			    End If
			  Next
			  
			  Return testCount
			End Get
		#tag EndGetter
		FailedTestCount As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h0
		IncludeGroup As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected IsAwaitingAsync As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private IsClone As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return RunTestsTimer Isa Object And RunTestsTimer.Mode <> Timer.ModeOff
			  
			End Get
		#tag EndGetter
		IsRunning As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mAssert As Assert
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mController As WeakRef
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mResults() As TestResult
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( hidden ) Private mStopTestOnFail As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		Name As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim testCount As Integer
			  
			  For Each tr As TestResult In mResults
			    If tr.Result = TestResult.NotImplemented Then
			      testCount = testCount + 1
			    End If
			  Next
			  
			  Return testCount
			End Get
		#tag EndGetter
		NotImplementedCount As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim testCount As Integer
			  
			  For Each tr As TestResult In mResults
			    If tr.Result = TestResult.Passed Then
			      testCount = testCount + 1
			    End If
			  Next
			  
			  Return testCount
			End Get
		#tag EndGetter
		PassedTestCount As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim testCount As Integer
			  
			  For Each tr As TestResult In mResults
			    If tr.Result = TestResult.Passed Or tr.Result = TestResult.Failed Then
			      testCount = testCount + 1
			    End If
			  Next
			  
			  Return testCount
			End Get
		#tag EndGetter
		RunTestCount As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private RunTestsTimer As Timer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Dim testCount As Integer
			  
			  For Each tr As TestResult In mResults
			    If tr.Result = TestResult.Skipped Then
			      testCount = testCount + 1
			    End If
			  Next
			  
			  Return testCount
			End Get
		#tag EndGetter
		SkippedTestCount As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  If Not IsClone And CurrentClone IsA Object Then
			    Return CurrentClone.StopTestOnFail
			  Else
			    Return mStopTestOnFail
			  End If
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If Not IsClone And CurrentClone IsA Object Then
			    CurrentClone.StopTestOnFail = value
			  Else
			    mStopTestOnFail = value
			  End If
			End Set
		#tag EndSetter
		StopTestOnFail As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mResults.Ubound + 1
			End Get
		#tag EndGetter
		TestCount As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private TestDuration As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TestTimers As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private UseConstructor As Introspection.ConstructorInfo
	#tag EndProperty


	#tag Constant, Name = kTestSuffix, Type = String, Dynamic = False, Default = \"Test", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kTimerPeriod, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Duration"
			Group="Behavior"
			Type="Double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FailedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
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
			Name="IsRunning"
			Group="Behavior"
			Type="Boolean"
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
			Name="NotImplementedCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StopTestOnFail"
			Group="Behavior"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InheritedFrom="Object"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TestCount"
			Group="Behavior"
			Type="Integer"
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
