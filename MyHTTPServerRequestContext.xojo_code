#tag Class
Protected Class MyHTTPServerRequestContext
	#tag CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
	#tag Method, Flags = &h0
		Sub Constructor()
		  Dim d As Xojo.Core.Date
		  d = xojo.Core.Date.Now
		  
		  Me.headers = New dictionary
		  Me.requestheaders = New dictionary
		  Me.cookies = New dictionary
		  Me.variables = New dictionary
		  
		  // Header Date
		  Me.Headers.Value(MyHTTPServerModule.kHeaderDate) = d.HTTPDate
		  
		  // Expire Date
		  'd.Minute = d.Minute' + 60
		  Me.Headers.Value(MyHTTPServerModule.kHeaderExpires) = d.HTTPDate
		  
		  // Default Content Type
		  Me.Headers.Value(MyHTTPServerModule.kHeaderContentType) = "text/html"
		  
		  // Default Host
		  Me.Headers.Value(MyHTTPServerModule.kHeaderHost) = "127.0.0.1"
		  
		  // Default Output
		  Me.statuscode = MyHTTPServerModule.kStatusNotFound
		  Me.Buffer = MyHTTPServerModule.HTTPErrorHTML(Me.statuscode)
		  
		  LogMsg(LogType0_Debug, "HTTPServRequestContext: Constuct Request Context")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Cookie(Name As Text) As Text
		  If Me.cookies.haskey(name) Then
		    Return Me.cookies.value(name)
		  Else
		    Return ""
		  End
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  LogMsg(LogType0_Debug, "HTTPServRequestContext: Destruct Request Context")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Header(Key As Text) As Text
		  If requestheaders.haskey(key) Then
		    Return requestheaders.value(key).TextValue
		  Else
		    Return ""
		  End
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadRequestParameters(FromString As Text)
		  Dim lines() As Text
		  Dim i As Integer
		  Dim key,value As Text
		  
		  requestheaders = New dictionary
		  
		  // load request headers
		  lines = fromstring.Split(MyHTTPServerModule.crlf)
		  lines.remove 0
		  For i = 0 To ubound(lines)
		    key = lines(i).Left(lines(i).IndexOf(":") - 1)
		    value = lines(i).Right(lines(i).Length - (key.Length + 2)) //Len(": ")
		    value = URLDecode(value)
		    requestheaders.value(key) = value
		  Next
		  
		  // process request headers
		  Me.cookies = New dictionary
		  lines = header(MyHTTPServerModule.kheadercookie).Split("; ")
		  For i = 0 To ubound(lines)
		    key = lines(i).Left(lines(i).IndexOf("=") - 1)
		    value = lines(i).Right(lines(i).Length - (key.Length + 1)) //Len("=")
		    value = URLDecode(value)
		    Me.cookies.value(key) = value
		  Next
		  
		  Dim sessionid As Integer
		  sessionid = Me.cookie("session-id").IntegerValue
		  psession = MyHTTPServerModule.findsession(sessionid)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadVariables(FromString As Text)
		  Dim parts(),key,value As Text
		  Dim i As Integer
		  
		  parts = fromstring.Split("&")
		  variables = New dictionary
		  
		  For i = 0 To ubound(parts)
		    key = parts(i).Left(parts(i).IndexOf("=") - 1)
		    value = parts(i).Right(parts(i).Length - (key.Length + 1)) // ("=").Length
		    value = URLDecode(value)
		    If variables.haskey(key) Then
		      variables.value(key) = variables.value(key) + "," + value
		    Else
		      variables.value(key) = value
		    End
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Print(pText As Text)
		  If Me.unused Then
		    Me.unused = False
		    Me.buffer = ""
		  End
		  Me.buffer = Me.buffer + ptext
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Session() As MyHTTPServerSession
		  Dim s As MyHTTPServerSession
		  If psession = Nil Then
		    s = MyHTTPServerModule.createsession
		    Me.setcookie("session-id",s.identifier.ToText)
		  Else
		    s = psession
		  End
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetCookie(Name As Text, Value As Text = "", Expire As Date = nil, Path As Text = "/", Domain As Text = ".", Secure As Boolean = False)
		  Dim s As Text
		  s = name + "=" + value
		  If domain <> "." Then
		    s = s + "; domain=" + domain
		  End
		  If path <> "/" Then
		    s = s + "; path=" + path
		  End
		  If expire <> Nil Then
		    s = s + "; expire=" + expire.cookiedate
		  End
		  If secure Then
		    s = s + "; secure"
		  End
		  Me.headers.value("Set-Cookie") = s
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Variable(Name As Text) As Text
		  If Me.variables.haskey(name) Then
		    Return Me.variables.value(name)
		  Else
		    Return ""
		  End
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Buffer As Text
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Cookies As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Entity As Text
	#tag EndProperty

	#tag Property, Flags = &h0
		Headers As Xojo.core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
		Private pSession As MyHTTPServerSession
	#tag EndProperty

	#tag Property, Flags = &h21
		Private RequestHeaders As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		StatusCode As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Unused As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Variables As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Buffer"
			Group="Behavior"
			Type="Text"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Entity"
			Group="Behavior"
			Type="Text"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StatusCode"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
