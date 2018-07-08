#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  mOptions = SetOptions
		  mOptions.Parse args
		  
		  If mOptions.HelpRequested Then
		    PrintHelp
		    Return 0
		  End If
		  
		  // Initialize Groups
		  Print "Initializing Test Groups..."
		  mController = New ConsoleTestController
		  mController.LoadTestGroups
		  
		  // Filter Tests
		  FilterTests
		  
		  // Run Tests
		  Print "Running Tests..."
		  mController.Start
		  While mController.IsRunning
		    App.DoEvents
		  Wend
		  
		  // Output Results
		  Print "Saving Results..."
		  
		  Dim outputFile As FolderItem
		  outputFile = OutputResults
		  
		  PrintSummary(StdOut, mController)
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub FilterTests()
		  // Filter the tests based on the Include and Exclude options
		  
		  Dim includeOption As Option = mOptions.OptionValue(kOptionInclude)
		  Dim excludeOption As Option = mOptions.OptionValue(kOptionExclude)
		  
		  If includeOption.WasSet Or excludeOption.WasSet Then
		    Print "Filtering Tests..."
		  Else
		    Return
		  End If
		  
		  Dim includes() As String
		  If Not includeOption.Value.IsNull Then
		    Dim v() As Variant = includeOption.Value
		    For Each pattern As String In v
		      includes.Append pattern
		    Next
		  End If
		  
		  Dim excludes() As String
		  If not excludeOption.Value.IsNull Then
		    Dim v() As Variant = excludeOption.Value
		    For Each pattern As String In v
		      excludes.Append pattern
		    Next
		  End If
		  
		  mController.FilterTests(includes, excludes)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OutputResults() As FolderItem
		  Const kIndent = "   "
		  Const kFailIndent = " * "
		  
		  Dim outputFile As FolderItem
		  If mOptions.Extra.Ubound = -1 Then
		    outputFile = GetFolderItem(kDefaultExportFileName)
		  Else
		    #If RBVersion< 2013
		      outputFile = GetFolderItem(mOptions.Extra(0), FolderItem.PathTypeShell)
		    #else
		      outputFile = GetFolderItem(mOptions.Extra(0), FolderItem.PathTypeNative)
		    #endif
		    If outputFile.Directory Then
		      outputFile = outputFile.Child(kDefaultExportFileName)
		    End If
		  End If
		  
		  Dim output As TextOutputStream = TextOutputStream.Create(outputFile)
		  
		  PrintSummary(output, mController)
		  
		  #If DebugBuild
		    Dim debugOutput As String
		  #Endif
		  
		  For Each tg As TestGroup In mController.TestGroups
		    output.WriteLine("")
		    output.WriteLine(tg.Name)
		    #If DebugBuild
		      debugOutput = debugOutput + EndOfLine + tg.Name + EndOfLine
		    #Endif
		    
		    For Each tr As TestResult In tg.Results
		      Dim useIndent As String = TestGroup.IIf(tr.Result = tr.Failed, kFailIndent, kIndent)
		      Dim outLine As String = useIndent + tr.TestName + ": " + tr.Result + " (" + Format(tr.Duration, "#,###.0000000") + "s)"
		      output.WriteLine(outLine)
		      #If DebugBuild
		        debugOutput = debugOutput + outLine + EndOfLine
		      #Endif
		      
		      Dim msg As String = tr.Message
		      If msg <> "" Then
		        msg = ReplaceLineEndings(msg, EndOfLine)
		        Dim msgs() As String = msg.Split(EndOfLine)
		        
		        For i As Integer = 0 To msgs.Ubound
		          msg = msgs(i)
		          outLine  = kIndent + kIndent + msg
		          output.WriteLine(outLine)
		          #If DebugBuild
		            debugOutput = debugOutput + outLine + EndOfLine
		          #Endif
		        Next i
		      End If
		    Next
		  Next
		  
		  output.Close
		  
		  Return outputFile
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintHelp()
		  Print ""
		  Print "Usage: " + mOptions.AppName + " [params] [/path/to/export/file]"
		  Print ""
		  mOptions.ShowHelp
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintSummary(output As Writeable, controller As TestController)
		  Dim now As New Date
		  
		  Dim allTestCount As Integer = controller.AllTestCount
		  Dim runTestCount As Integer = controller.RunTestCount
		  
		  WriteLine(output, "Start: " + now.ShortDate + " " + now.ShortTime)
		  WriteLine(output, "Duration: " + Format(controller.Duration, "#,###.0000000") + "s")
		  WriteLine(output, "Groups: " + Format(controller.RunGroupCount, "#,0"))
		  WriteLine(output, "Total: " + Str(runTestCount) + TestGroup.IIf(allTestCount <> runTestCount, " of " + Str(allTestCount), "") + " tests were run")
		  WriteLine(output, "Passed: " + Str(controller.PassedCount) + _
		  TestGroup.IIf(runTestCount = 0, "", " (" + Format((controller.PassedCount / runTestCount) * 100, "##.00") + "%)"))
		  WriteLine(output, "Failed: " + Str(controller.FailedCount) + _
		  TestGroup.IIf(runTestCount = 0, "", " (" + Format((controller.FailedCount / runTestCount) * 100, "##.00") + "%)"))
		  WriteLine(output, "Skipped: " + Str(controller.SkippedCount))
		  WriteLine(output, "Not Implemented: " + Str(controller.NotImplementedCount))
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SetOptions() As OptionParser
		  Dim parser As New OptionParser
		  
		  Dim o As Option
		  
		  o = New Option("i", kOptionInclude, "Include a Group[.Method] (* is wildcard)", Option.OptionType.String)
		  o.IsArray = True
		  parser.AddOption o
		  
		  o = New Option("x", kOptionExclude, "Exclude a Group[.Method] (* is wildcard)", Option.OptionType.String)
		  o.IsArray = True
		  parser.AddOption o
		  
		  parser.AdditionalHelpNotes = "If an export path is not specified, a default file named `" + kDefaultExportFileName + _
		  "' will be created next to the app. If the path is a directory, a file of that name will be created within it."
		  
		  Return parser
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteLine(output As Writeable, s As String)
		  output.Write s
		  output.Write EndOfLine
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mController As TestController
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOptions As OptionParser
	#tag EndProperty


	#tag Constant, Name = kDefaultExportFileName, Type = String, Dynamic = False, Default = \"XojoUnitResults.txt", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionExclude, Type = String, Dynamic = False, Default = \"exclude", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kOptionInclude, Type = String, Dynamic = False, Default = \"include", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
