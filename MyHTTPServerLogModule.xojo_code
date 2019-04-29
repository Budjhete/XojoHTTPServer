#tag Module
Protected Module MyHTTPServerLogModule
	#tag CompatibilityFlags = ( TargetConsole and ( Target32Bit or Target64Bit ) ) or ( TargetWeb and ( Target32Bit or Target64Bit ) ) or ( TargetDesktop and ( Target32Bit or Target64Bit ) ) or ( TargetIOS and ( Target32Bit or Target64Bit ) )
	#tag Method, Flags = &h0
		Sub InitDebugLog()
		  Dim tmpfolder As Xojo.IO.FolderItem
		  Dim logfile As Xojo.IO.FolderItem
		  
		  tmpfolder = Xojo.IO.SpecialFolder.Temporary.child(PropCompanyName)
		  If Not tmpfolder.Exists Then
		    tmpfolder.CreateAsFolder
		    'tmpfolder.Permissions = &o777
		  End If
		  
		  DataFolder = tmpfolder.Child(PropName)
		  If Not DataFolder.Exists Then
		    If tmpfolder.IsWriteable Then
		      DataFolder.CreateAsFolder
		      'DataFolder.Permissions = &o777
		    Else
		      System.DebugLog "Unable to create Data folder. Closing App."
		      'Quit
		    End If
		  End If
		  
		  logfile = DataFolder.Child("debug.log")
		  
		  // Setup Logfile if needed
		  If App.StageCode < 3 Or DebugBuild Then
		    Try
		      If logfile <> Nil And logfile.Exists Then
		        DebugLogFile = Xojo.IO.BinaryStream.Open(logfile, Xojo.IO.BinaryStream.LockModes.ReadWrite)
		      Else
		        DebugLogFile = Xojo.IO.BinaryStream.Create(logfile)
		      End If
		      DebugLogFile.Position = DebugLogFile.Length
		    End Try
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LogMsg(Type As Integer, s As Text)
		  Dim d As Xojo.Core.Date
		  d = Xojo.Core.Date.Now
		  Dim i As Integer
		  Dim DebugLogPrefix As Text
		  
		  DebugLogPrefix = "HTTP Server "
		  
		  #if RepeatedMsgReduction Then
		    If s = LastLogString Then
		      LastLogCount = LastLogCount + 1
		    Else
		      LastLogString = s
		      LastLogCount = 0
		    End if
		    
		    if LastLogCount > 0 Then
		      s = "Last Message Repeated "+LastLogCount.ToText+" Times"
		      if LastLogCount MOD 2 = 1 Then s = s + " "
		      
		      if LastLogCount > 1 Then
		        dim tt as text = DebugLogPrefix+"Last Message Repeated "+Integer(LastLogCount-1).ToText+" Times"+EndOfLine_
		        i = tt.Length+32+((LastLogCount-1) MOD 2)
		        
		        If DebugLogFile <> Nil Then
		          DebugLogFile.Length = DebugLogFile.Length - i
		          DebugLogFile.Position = DebugLogFile.Length
		          DebugLogFile.Flush
		        End If
		      End if
		    End if
		  #endif
		  
		  Select Case Type
		    ' Only Show on Development Build
		  Case LogType0_Debug
		    If App.StageCode = 0 Or DebugBuild Then
		      s = DebugLogPrefix+"<Debug>   ["+d.SQLDateTime+"] "+s
		    Else
		      s = ""
		    End If
		    
		    ' Only Show on Alpha Build and below
		  Case LogType1_Notice
		    If App.StageCode < 2 Or DebugBuild Then
		      s = DebugLogPrefix+"<Notice>  ["+d.SQLDateTime+"] "+s
		    Else
		      s = ""
		    End If
		    
		    ' Beta Build
		  Case LogType2_Error
		    s = DebugLogPrefix+"<Error>   ["+d.SQLDateTime+"] "+s
		    
		    
		  Case LogType3_RunTime
		    s = DebugLogPrefix+"<RunTime> ["+d.SQLDateTime+"] "+s
		    
		  End Select
		  
		  if s <> "" Then
		    If DebugLogFile <> Nil Then
		      DebugLogFile.Write(Xojo.Core.TextEncoding.UTF8.ConvertTextToData(EndOfLine_+s))
		      DebugLogFile.Flush
		    Else
		      System.DebugLog(s)
		    End if
		  End if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LogMsg(Type As Integer, s As Text, err As RuntimeException)
		  s = "("+err.ErrorNumber.ToText+") "+err.Reason+" ::: "+s
		  
		  LogMsg(Type, s)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		DataFolder As Xojo.IO.FolderItem
	#tag EndProperty

	#tag Property, Flags = &h0
		DebugLogFile As Xojo.IO.BinaryStream
	#tag EndProperty

	#tag Property, Flags = &h21
		Private LastLogCount As UInt64 = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private LastLogString As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		PropCompanyName As Text = "HTTPServer"
	#tag EndProperty

	#tag Property, Flags = &h0
		PropName As Text = "Demo"
	#tag EndProperty


	#tag Constant, Name = LogType0_Debug, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LogType1_Notice, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LogType2_Error, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = LogType3_RunTime, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = RepeatedMsgReduction, Type = Boolean, Dynamic = False, Default = \"True", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PropName"
			Group="Behavior"
			InitialValue="Demo"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="PropCompanyName"
			Group="Behavior"
			InitialValue="HTTPServer"
			Type="Text"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
