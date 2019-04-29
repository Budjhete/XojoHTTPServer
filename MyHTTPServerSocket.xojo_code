#tag Class
Protected Class MyHTTPServerSocket
Inherits ServerSocket
	#tag Event
		Function AddSocket() As TCPSocket
		  Return New MyHTTPServer(Self)
		End Function
	#tag EndEvent

	#tag Event
		Sub Error(ErrorCode as Integer)
		  System.Log(System.LogLevelError, "HTTPServSock: Error Num " + str(ErrorCode))
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Close()
		  Dim i, tmp, CloseTry As Integer
		  Dim TCPSocketList() As TCPSocket
		  
		  If Self.IsListening Then Self.StopListening
		  
		  If Self.ActiveConnections.Ubound > -1 Then
		    TCPSocketList = Self.ActiveConnections
		    
		    CloseTry = 0
		    i = 0
		    tmp = TCPSocketList.Ubound
		    While TCPSocketList.Ubound > -1
		      TCPSocketList(0).Disconnect
		      TCPSocketList.Remove(0)
		      
		      If tmp = TCPSocketList.Ubound Then
		        CloseTry = CloseTry + 1
		        If CloseTry > 3 Then
		          System.Log(System.LogLevelError, "HTTPServSock: Error trying to close server socket, "+Str(TCPSocketList.Ubound+1)+" sockets left")
		          Exit While
		        End If
		      Else
		        tmp = TCPSocketList.Ubound
		      End If
		    Wend
		    
		    System.Log(System.LogLevelNotice, "HTTPServSock: Server Stopped ("+Str(TCPSocketList.Ubound + 1)+")")
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  System.DebugLog "Initializing the HTTPServerSocket..."
		  
		  Me.Port = MyHTTPServerModule.kDefaultPort
		  Me.URLs = New Dictionary
		  Me.Sessions = New Dictionary
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(pPort As Integer)
		  Me.Constructor
		  
		  Me.Port = pPort
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Self.Close
		  
		  System.DebugLog "HTTPServSock: Destruct"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HandleRequest(pRequest As MyHTTPRequest)
		  // First Request handler
		  //
		  // Request are handled here before being handled by specific code
		  //
		  // The basic handling correspond to routing the Request to the first matching
		  // handler that could be found in URLs.
		  
		  Dim pURL As String = pRequest.URL
		  Dim pRequestHandler As MyHTTPRequestHandler
		  Dim pRegexMatch As RegExMatch
		  
		  // Find a handler
		  If URLs.HasKey(pURL) Then
		    
		    pRequestHandler = URLs.Value(pURL)
		    Dim pRegex As New Regex
		    pRegex.SearchPattern = ".+"
		    
		    // match the whole URL
		    pRegexMatch = pRegex.Search(pURL)
		    
		  Else
		    
		    For Each pKey As Variant In URLs.Keys
		      
		      // Try to match RegEx key
		      If pKey IsA RegEx Then
		        
		        pRegexMatch = RegEx(pKey).Search(pURL)
		        
		        If pRegexMatch <> Nil Then
		          
		          pRequestHandler = URLs.Value(pKey)
		          
		          Exit // skip the loop
		          
		        End If
		        
		      End If
		      
		    Next
		    
		  End If
		  
		  // No handler found
		  If pRequestHandler Is Nil Then
		    
		    System.DebugLog "No handler matched the Request with url " + pRequest.URL
		    
		    // Not Implemented
		    pRequest.Status = 501
		    pRequest.Body = MyHTTPServerModule.HTTPErrorHTML(pRequest.Status)
		    
		    Return
		    
		  End If
		  
		  // Authentication
		  If pRequestHandler IsA MyHTTPAuthRequestHandler Then
		    
		    If pRequest.RequestHeaders.HasKey("Authorization") Then
		      
		      Dim pRegex As New RegEx
		      pRegex.SearchPattern = "Basic ([\w=]+)"
		      
		      Dim pSecret As String = DecodeBase64(pRegex.Search(pRequest.RequestHeaders.Value("Authorization").StringValue).SubExpressionString(1))
		      
		      Dim pCredentials() As String = Split(pSecret, ":")
		      
		      If MyHTTPAuthRequestHandler(pRequestHandler).Authenticate(pCredentials(0).DefineEncoding(Encodings.UTF8).ToText, pCredentials(1).DefineEncoding(Encodings.UTF8).ToText) Then
		        
		        System.Log(System.LogLevelSuccess, "Authentication successful for user " + pCredentials(0) + " using a password.")
		        
		      Else
		        
		        // Authentication failure
		        pRequest.Headers.Value("WWW-Authenticate") = "Basic realm=""" + MyHTTPAuthRequestHandler(pRequestHandler).Realm + """"
		        pRequest.Status = 401
		        
		        System.Log(System.LogLevelWarning, "Authentication failed for user " + pCredentials(0) + " using a password.")
		        
		        Return
		        
		      End If
		      
		    Else
		      
		      System.Log(System.LogLevelNotice, "Performing HTTP Basic authentication for realm " + MyHTTPAuthRequestHandler(pRequestHandler).Realm + "...")
		      
		      // Authentication
		      pRequest.Headers.Value("WWW-Authenticate") = "Basic realm=""" + MyHTTPAuthRequestHandler(pRequestHandler).Realm + """"
		      pRequest.Status = 401
		      
		      Return
		      
		    End If
		    
		  End If
		  
		  // Handle the Request
		  pRequestHandler.HandleRequest(pRequest, pRegexMatch)
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Listen()
		  System.Log(System.LogLevelInformation, "Start listening on port " + Str(Me.Port))
		  
		  Super.Listen
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Register(pRegex As RegEx, pHandler As MyHTTPRequestHandler)
		  // Register a handler called whenever the URL match the regex
		  URLs.Value(pRegex) = pHandler
		  
		  System.Log(System.LogLevelNotice, "Registered a handler for regex pattern " + pRegex.SearchPattern)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Register(pURL As String, pHandler As MyHTTPRequestHandler)
		  // Register a handler called whenever the request URL match the URL
		  URLs.value(pURL) = pHandler
		  
		  System.Log(System.LogLevelNotice, "Registered a handler for URL " + pURL)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SocketCount() As Integer
		  Return Self.ActiveConnections.Ubound + 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StopListening()
		  System.Log(System.LogLevelInformation, "Stop Listening on port " + Str(Me.Port) + "...")
		  
		  Super.StopListening
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		ClientTimeOut As Integer = 10
	#tag EndProperty

	#tag Property, Flags = &h0
		Sessions As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private URLs As Dictionary
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="ClientTimeOut"
			Group="Behavior"
			InitialValue="10"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			Type="Integer"
			EditorType="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaximumSocketsConnected"
			Visible=true
			Group="Behavior"
			InitialValue="10"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinimumSocketsAvailable"
			Visible=true
			Group="Behavior"
			InitialValue="2"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Port"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
			EditorType="String"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
