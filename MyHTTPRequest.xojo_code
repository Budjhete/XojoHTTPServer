#tag Class
Protected Class MyHTTPRequest
	#tag Method, Flags = &h0
		Sub Constructor()
		  Dim d As New Date
		  
		  Me.headers = New dictionary
		  Me.requestheaders = New dictionary
		  Me.cookies = New dictionary
		  Me.variables = New dictionary
		  
		  // Header Date
		  Me.Headers.Value(MyHTTPServerModule.kHeaderDate) = d.HTTPDate
		  
		  // Expire Date
		  d.Minute = d.Minute' + 60
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
		Function Cookie(Name As String) As String
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
		Function Header(Key As String) As String
		  If requestheaders.haskey(key) Then
		    Return requestheaders.value(key).stringvalue
		  Else
		    Return ""
		  End
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub LoadRequestParameters(FromString As String)
		  Dim lines() As String
		  Dim i As Integer
		  Dim key,value As String
		  
		  requestheaders = New dictionary
		  
		  // load request headers
		  lines = fromstring.Split(MyHTTPServerModule.crlf)
		  lines.remove 0
		  For i = 0 To ubound(lines)
		    key = Left(lines(i),InStr(lines(i),":") - 1)
		    value = Right(lines(i),Len(lines(i)) - (Len(key) + Len(": ")))
		    value = URLDecode(value)
		    requestheaders.value(key) = value
		  Next
		  
		  // process request headers
		  Me.cookies = New dictionary
		  lines = header(MyHTTPServerModule.kheadercookie).Split("; ")
		  For i = 0 To ubound(lines)
		    key = Left(lines(i),InStr(lines(i),"=") - 1)
		    value = Right(lines(i),Len(lines(i)) - (Len(key) + Len("=")))
		    value = URLDecode(value)
		    Me.cookies.value(key) = value
		  Next
		  
		  Dim sessionid As Integer
		  sessionid = Val(Me.cookie("session-id"))
		  psession = MyHTTPServerModule.findsession(sessionid)
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
		Sub Print(Text As String)
		  If Me.unused Then
		    Me.unused = False
		    Me.buffer = ""
		  End
		  Me.buffer = Me.buffer + text
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Session() As MyHTTPServerSession
		  Dim s As MyHTTPServerSession
		  If psession = Nil Then
		    s = MyHTTPServerModule.createsession
		    Me.setcookie("session-id",Str(s.identifier))
		  Else
		    s = psession
		  End
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetCookie(Name As String, Value As String = "", Expire As Date = nil, Path As String = "/", Domain As String = ".", Secure As Boolean = False)
		  Dim s As String
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
		Function Variable(Name As String) As String
		  If Me.variables.haskey(name) Then
		    Return Me.variables.value(name)
		  Else
		    Return ""
		  End
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0
		Buffer As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Cookies As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0
		Entity As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Headers As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
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

	#tag Property, Flags = &h0
		URL As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Variables As Dictionary
	#tag EndProperty


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
