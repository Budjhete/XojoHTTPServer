#tag Class
Protected Class MyHTTPServerSocket
Inherits ServerSocket
	#tag Event
		Function AddSocket() As TCPSocket
		  Dim s As MyHTTPServerClientHandler
		  s = New MyHTTPServerClientHandler
		  s.parent = Self
		  Return s
		End Function
	#tag EndEvent

	#tag Event
		Sub Error(ErrorCode as Integer)
		  LogMsg(LogType2_Error, "HTTPServSock: Error Num "+str(ErrorCode))
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddURL(URL As String, File As FolderItem)
		  Dim i As Integer
		  urls.value(url) = file
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddURL(URL As String, Handler As MyHTTPServerRequestHandler)
		  urls.value(url) = handler
		End Sub
	#tag EndMethod

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
		Sub ForwardContext(URL As String, Context As MyHTTPServerRequestContext)
		  Dim v As variant
		  Dim handler As MyHTTPServerRequestHandler
		  Dim t As TextInputStream
		  Dim i As Integer
		  Dim baseurl As String
		  Dim file As String = ""
		  
		  
		  ' If no match then go hunting
		  If urls.haskey(url) = False Then
		    
		    ' Check for index file
		    If Right(url, 1) = "/" Then
		      For i = 0 To ubound(indexfiles)
		        If urls.haskey(url + indexfiles(i)) Then
		          url = url + indexfiles(i)
		          Exit For
		        End If
		      Next
		    End If
		    
		    If urls.haskey(url) = False Then ' Check for base directory
		      baseurl = url
		      While InStr(0, baseurl, "/") > 0
		        baseurl = url.Left(MyHTTPServerModule.InStrReverse(Len(baseurl)-1, baseurl, "/"))
		        If urls.haskey(baseurl) Then
		          file = url.Right(Len(url)-Len(baseurl))
		          url = baseurl
		          
		          Exit While
		        End If
		      Wend
		    End If
		  End If
		  
		  If urls.haskey(url) Then
		    v = urls.value(url)
		    #pragma BreakOnExceptions Off
		    If v IsA folderitem Then
		      Dim f As FolderItem
		      f = v
		      
		      If f.Exists Then
		        
		        If file <> "" Then
		          Dim tmpf As FolderItem
		          
		          try
		            tmpf = New FolderItem(f.URLPath+MyHTTPServerModule.URLEncode(file), FolderItem.PathTypeURL)
		            
		          Catch err As UnsupportedFormatException
		            context.statuscode = MyHTTPServerModule.kStatusNotFound
		            context.buffer = MyHTTPServerModule.HTTPErrorHTML(context.statuscode)
		            
		            Exit Sub
		          End Try
		          
		          
		          If tmpf.Exists Then
		            f = New FolderItem(tmpf)
		            tmpf = Nil
		          Else
		            tmpf = Nil
		            
		            // File Not Found
		            context.statuscode = MyHTTPServerModule.kStatusNotFound
		            context.buffer = MyHTTPServerModule.HTTPErrorHTML(context.statuscode)
		            
		            Exit Sub
		          End If
		          
		        End If
		        
		        
		        If f.Directory Then
		          ' Check for index files in directory
		          For i = 0 To ubound(indexfiles)
		            If f.Child(indexfiles(i)).Exists Then
		              f = f.Child(indexfiles(i))
		              Exit For
		            End If
		          Next
		          
		          ' No file found, showing index
		          If f.Directory Then
		            Context.Print(HTTPDirectoryHTML(url+file, f))
		            
		            Context.statuscode = MyHTTPServerModule.kstatusok
		          End If
		        End If
		        
		        
		        If f.Directory = False Then
		          Context.Headers.Value(MyHTTPServerModule.kHeaderContentType) = MyHTTPServerModule.HTTPMimeString(f.FileExtension)
		          
		          Dim ReadStream As BinaryStream = BinaryStream.Open(f, False)
		          If ReadStream.Length > 0 Then
		            Context.Headers.Value(MyHTTPServerModule.kHeaderDate) = f.ModificationDate.HTTPDate
		            
		            Context.Buffer = ReadStream.Read(ReadStream.Length)
		            ReadStream.Close
		            ReadStream = Nil
		            
		            Context.statuscode = MyHTTPServerModule.kstatusok
		          Else
		            Context.statuscode = MyHTTPServerModule.kStatusInternalServerError
		            context.buffer = MyHTTPServerModule.HTTPErrorHTML(context.statuscode)
		            
		          End If
		        End If
		        
		        
		        f = Nil
		      Else
		        f = Nil
		        
		        // File does not exist, Send a 404 Error
		        context.statuscode = MyHTTPServerModule.kStatusNotFound
		        context.buffer = MyHTTPServerModule.HTTPErrorHTML(context.statuscode)
		        
		        
		      End If
		      
		    Elseif v IsA MyHTTPServerRequestHandler Then
		      handler = MyHTTPServerRequestHandler(v)
		      handler.handlerequest(context)
		    End If
		    #pragma BreakOnExceptions Default
		  End If
		  
		Exception err
		  context.statuscode = MyHTTPServerModule.kstatusinternalservererror
		  context.buffer = MyHTTPServerModule.HTTPErrorHTML(context.statuscode)
		  
		  'Raise err
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Listen()
		  LogMsg(LogType1_Notice, "HTTPServSock: Start Listening")
		  Super.Listen
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveURL(URL As String)
		  If urls.haskey(url) Then
		    urls.remove(url)
		  End
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SocketCount() As Integer
		  Return Self.ActiveConnections.Ubound+1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StopListening()
		  LogMsg(LogType1_Notice, "HTTPServSock: Stop Listening")
		  Super.StopListening
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
