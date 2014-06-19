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
		  LogMsg(LogType2_Error, "HTTPServSock: Error Num "+str(ErrorCode))
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
		          LogMsg(LogType2_Error, "HTTPServSock: Error trying to close server socket, "+Str(TCPSocketList.Ubound+1)+" sockets left")
		          Exit While
		        End If
		      Else
		        tmp = TCPSocketList.Ubound
		      End If
		    Wend
		    
		    LogMsg(LogType1_Notice, "HTTPServSock: Server Stopped ("+Str(TCPSocketList.Ubound + 1)+")")
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  LogMsg(LogType0_Debug, "HTTPServSock: Constuct")
		  
		  Me.port = MyHTTPServerModule.kDefaultPort
		  Me.urls = New dictionary
		  Me.indexfiles.append("index.html")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(Port As Integer)
		  Me.constructor
		  Me.port = port
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Destructor()
		  Self.Close
		  LogMsg(LogType0_Debug, "HTTPServSock: Destruct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HandleRequest(pRequest As MyHTTPRequest)
		  // First Request handler
		  Dim url As String = pRequest.URL
		  
		  If URLs.HasKey(url) Then
		    
		    Dim pRequestHandler As MyHTTPRequestHandler = URLs.Value(url)
		    
		    pRequestHandler.HandleRequest(pRequest)
		    
		  Else
		    
		    For Each key As Variant In URLs.Keys
		      
		      // Try to match RegEx key
		      If key IsA RegEx Then
		        
		        Dim match As RegExMatch = RegEx(key).Search(URL)
		        
		        If match <> Nil Then
		          
		          Dim pRequestHandler As MyHTTPRequestHandler = URLs.Value(key)
		          
		          pRequestHandler.HandleRequest(pRequest)
		          
		        End If
		        
		      End If
		      
		    Next
		    
		  End If
		  
		  pRequest.StatusCode = 404
		  pRequest.Buffer = MyHTTPServerModule.HTTPErrorHTML(pRequest.StatusCode)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Listen()
		  System.Log(System.LogLevelInformation, "Start listening on port " + Str(Me.Port))
		  Super.Listen
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Register(regex As RegEx, pHandler As MyHTTPRequestHandler)
		  // Register a handler called whenever the URL match the regex
		  URLs.Value(regex) = pHandler
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Register(URL As String, pHandler As MyHTTPRequestHandler)
		  // Register a handler called whenever the request URL match the URL
		  URLs.value(URL) = pHandler
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SocketCount() As Integer
		  Return Self.ActiveConnections.Ubound + 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StopListening()
		  System.Log(System.LogLevelInformation, "HTTPServerSocket: Stop Listening...")
		  
		  Super.StopListening
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Unregister(URL As String)
		  If URLs.HasKey(url) Then
		    URLs.Remove(URL)
		  End
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		ClientTimeOut As Integer = 10
	#tag EndProperty

	#tag Property, Flags = &h0
		IndexFiles() As String
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
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			Type="Integer"
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
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
