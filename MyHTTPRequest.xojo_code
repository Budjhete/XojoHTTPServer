#tag Class
Protected Class MyHTTPRequest
	#tag Method, Flags = &h0
		Sub Constructor()
		  Dim pNow As New Date
		  
		  Me.Headers = New Dictionary
		  Me.RequestHeaders = New Dictionary
		  Me.Cookies = New Dictionary
		  Me.Variables = New Dictionary
		  
		  // Header Date
		  Me.Headers.Value("Date") = pNow.HTTPDate
		  
		  // Expire Date
		  pNow.Minute = pNow.Minute' + 60
		  Me.Headers.Value("Expires") = pNow.HTTPDate
		  
		  // Default Content Type
		  Me.Headers.Value(MyHTTPServerModule.kHeaderContentType) = "text/html"
		  
		  // Default Headers
		  Me.Headers.Value("Content-Type") = "text/html; charset=utf-8"
		  Me.Headers.Value("Connection") = "close"
		  Me.Headers.Value("Host") = "127.0.0.1"
		  Me.Headers.Value("X-Powered-By") = "MyHTTPServer"
		  
		  System.DebugLog "HTTPServRequestContext: Constuct Request Context"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  System.DebugLog "HTTPServRequestContext: Destruct Request Context"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadRequestParameters(FromString As String)
		  Dim lines() As String
		  Dim i As Integer
		  Dim key,value As String
		  
		  // load request headers
		  Me.RequestHeaders = New Dictionary
		  lines = fromstring.Split(MyHTTPServerModule.crlf)
		  lines.remove 0
		  For i = 0 To ubound(lines)
		    key = Left(lines(i),InStr(lines(i),":") - 1)
		    value = Right(lines(i),Len(lines(i)) - (Len(key) + Len(": ")))
		    value = URLDecode(value)
		    RequestHeaders.value(key) = value
		  Next
		  
		  // process request headers
		  Me.Cookies = New Dictionary
		  lines = Me.Headers.Lookup("Cookie", "").Split("; ")
		  For i = 0 To ubound(lines)
		    key = Left(lines(i),InStr(lines(i),"=") - 1)
		    value = Right(lines(i),Len(lines(i)) - (Len(key) + Len("=")))
		    value = URLDecode(value)
		    Me.Cookies.Value(key) = value
		  Next
		  
		  Dim pSessionID As Integer = Val(Me.Cookies.Lookup("session-id", ""))
		  Me.Session = MyHTTPServerModule.FindSession(pSessionID)
		  
		  If Me.Session = Nil Then
		    
		    pSessionID = MyHTTPServerModule.createsession.Identifier
		    Me.SetCookie("session-id", Str(pSessionID))
		    
		    System.DebugLog "Created a new session with id " + Str(pSessionID)
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadVariables(FromString As String)
		  Dim parts(),key,value As String
		  Dim i As Integer
		  
		  parts = fromstring.Split("&")
		  variables = New dictionary
		  
		  For i = 0 To ubound(parts)
		    key = Left(parts(i),InStr(parts(i),"=") - 1)
		    value = Right(parts(i),Len(parts(i)) - (Len(key) + Len("=")))
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
		Sub SetCookie(Name As String, Value As String = "", Expire As Date = nil, Path As String = "/", Domain As String = ".", Secure As Boolean = False)
		  Dim s As String = name + "=" + value
		  
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
		  
		  Me.Headers.Value("Set-Cookie") = s
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Body As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Cookies As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Entity As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Headers As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Method As String = "GET"
	#tag EndProperty

	#tag Property, Flags = &h0
		RequestHeaders As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Session As MyHTTPServerSession
	#tag EndProperty

	#tag Property, Flags = &h0
		Status As Integer = 200
	#tag EndProperty

	#tag Property, Flags = &h0
		URL As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Variables As Dictionary
	#tag EndProperty


	#tag Constant, Name = DELETE, Type = String, Dynamic = False, Default = \"DELETE", Scope = Public
	#tag EndConstant

	#tag Constant, Name = GET, Type = String, Dynamic = False, Default = \"GET", Scope = Public
	#tag EndConstant

	#tag Constant, Name = POST, Type = String, Dynamic = False, Default = \"POST", Scope = Public
	#tag EndConstant

	#tag Constant, Name = PUT, Type = String, Dynamic = False, Default = \"PUT", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Buffer"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Entity"
			Group="Behavior"
			Type="String"
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
			Name="Method"
			Group="Behavior"
			Type="String"
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
		#tag ViewProperty
			Name="URL"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
