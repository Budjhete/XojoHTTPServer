#tag Class
Protected Class MyHTTPRequest
	#tag Method, Flags = &h0
		Sub Constructor(pHTTPServer As MyHTTPServer)
		  Dim pNow As New Date
		  
		  // Server that emmited the Request
		  Me.Parent = pHTTPServer
		  
		  Me.Headers = New Dictionary
		  Me.RequestHeaders = New Dictionary
		  Me.Cookies = New Dictionary
		  Me.Query = New Dictionary
		  
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
		Sub LoadQuery(FromString As String)
		  Dim parts(),key,value As String
		  Dim i As Integer
		  
		  parts = fromstring.Split("&")
		  Me.Query = New Dictionary
		  
		  For i = 0 To ubound(parts)
		    
		    key = Left(parts(i),InStr(parts(i),"=") - 1)
		    value = Right(parts(i),Len(parts(i)) - (Len(key) + Len("=")))
		    value = DecodeURLComponent(value)
		    
		    If Me.Query.HasKey(key) Then
		      Me.Query.Value(key) = Me.Query.Value(key) + "," + value
		    Else
		      Me.Query.Value(key) = value
		    End
		    
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadRequestHeaders(FromString As String)
		  // Read crlf separated headers and load headers, cookies and session
		  
		  Dim lines() As String
		  Dim i As Integer
		  Dim key,value As String
		  
		  // Process headers
		  Me.RequestHeaders = New Dictionary
		  lines = fromstring.Split(MyHTTPServerModule.crlf)
		  lines.remove 0
		  For i = 0 To ubound(lines)
		    key = Left(lines(i),InStr(lines(i),":") - 1)
		    value = Right(lines(i),Len(lines(i)) - (Len(key) + Len(": ")))
		    value = DecodeURLComponent(value)
		    RequestHeaders.value(key) = value
		  Next
		  
		  // Process cookies
		  Me.Cookies = New Dictionary
		  lines = Split(Me.Headers.Lookup("Cookie", ""), ";")'.Split("; ")
		  For i = 0 To ubound(lines)
		    key = Left(lines(i),InStr(lines(i),"=") - 1)
		    value = Right(lines(i),Len(lines(i)) - (Len(key) + Len("=")))
		    value = DecodeURLComponent(value)
		    Me.Cookies.Value(key) = value
		  Next
		  
		  // Get the session
		  Dim pSessionID As Integer = Val(Me.Cookies.Lookup("session", ""))
		  
		  // The server socket stores sessions in a Dictionary
		  If Not Me.Parent.Parent.Sessions.HasKey(pSessionID) Then
		    
		    System.DebugLog "Creating a new session with a random id..."
		    
		    Dim pRandom As New Random
		    
		    // Generates an unique and random session id
		    Do
		      pSessionID = pRandom.Number
		    Loop Until Not Me.Parent.Parent.Sessions.HasKey(pSessionID)
		    
		    // Append the session to the Dictionary
		    Me.Parent.Parent.Sessions.Value(pSessionID) = New Dictionary
		    
		    System.DebugLog "Created a new session with id " + Str(pSessionID)
		    
		    // Set the session id in the cookies
		    Me.SetCookie("session", Str(pSessionID))
		    
		  End If
		  
		  // Fetch the session
		  Me.Session = Me.Parent.Parent.Sessions.Value(pSessionID)
		  
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
		Headers As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Method As String = "GET"
	#tag EndProperty

	#tag Property, Flags = &h0
		Parent As MyHTTPServer
	#tag EndProperty

	#tag Property, Flags = &h0
		Query As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		RequestBody As String
	#tag EndProperty

	#tag Property, Flags = &h0
		RequestHeaders As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Session As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Status As Integer = 200
	#tag EndProperty

	#tag Property, Flags = &h0
		URL As String
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
			Name="Body"
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
			InitialValue="GET"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RequestBody"
			Group="Behavior"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Status"
			Group="Behavior"
			InitialValue="200"
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
