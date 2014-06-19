#tag Class
Protected Class MyHTTPServerClientHandler
Inherits TCPSocket
	#tag Event
		Sub DataAvailable()
		  // First, we use TCPSocket.Lookahead to determine if we have complete headers waiting.
		  
		  Dim la,data,headers,entity As String
		  Dim lalength,headerslength,entitylength,requestlength As Integer
		  'Dim context As MyHTTPServerRequestContext
		  Dim m As regexmatch
		  
		  restartPoint:
		  
		  la = Me.lookahead(encodings.ascii)
		  
		  headerslength = InStrB(la, MyHTTPServerModule.crlf + MyHTTPServerModule.crlf) - 1 // length of the headers
		  
		  LogMsg(LogType1_Notice, "HTTPServClientHandle("+Str(uid)+"): Data Available ["+Str(LenB(la))+" totallen] "+Str(headerslength)+" headerlen")
		  If headerslength > 0 Then
		    // We have a complete header. But we're not done yet. Some HTTP methods send entity
		    // data, such as POST and PUT, which need to be read out as well, but may not be complete
		    // yet. We determine this by reading the Content-Length header which tells us how much
		    // data the entity contains. We stop once we've received that much data, and assume that
		    // everything else is a new request.
		    
		    headers = LeftB(la, headerslength) // the headers
		    context = New MyHTTPServerRequestContext
		    context.loadrequestparameters(headers)
		    
		    // Check for required headers
		    'If MyHTTPServerModule.kVersion = "HTTP/1.1" Then
		    'If context.Headers.HasKey("Host") = False Then
		    'MsgBox("Error")
		    'End If
		    'End If
		    
		    If context.header(MyHTTPServerModule.kheadercontentlength) <> "" Then
		      // Now we know there is entity data in this request.
		      
		      entitylength = Val(context.header(MyHTTPServerModule.kheadercontentlength))
		      requestlength = headerslength + LenB(MyHTTPServerModule.crlf + MyHTTPServerModule.crlf) + entitylength
		      lalength = LenB(la)
		      If LenB(la) >= requestlength Then
		        // We have the correct amount of data as well. We remove this data from the queue
		        // while ensuring that later data is left intact. Sometimes, TCPSocket may fire
		        // a DataAvailable event while having one and a half requests in the queue.
		        
		        data = Me.read(requestlength, encodings.ascii)
		        entity = MidB(data,headerslength + 1 + LenB(MyHTTPServerModule.crlf + MyHTTPServerModule.crlf),entitylength)
		        
		        LogMsg(LogType0_Debug, "HTTPServClientHandle("+Str(uid)+"): Recived Request, "+Str(requestlength)+" len")
		      Else
		        // There is more data to be received. We take no further action in this event, and start
		        // over the next event, which should contain more data.
		        
		        LogMsg(LogType0_Debug, "HTTPServClientHandle("+Str(uid)+"): Missing Data Resetting goto START")
		      End
		    Else
		      // The request does not contain a Content-Length header, so it must be complete.
		      
		      requestlength = headerslength + LenB(MyHTTPServerModule.crlf + MyHTTPServerModule.crlf)
		      data = Me.read(requestlength, encodings.ascii)
		      entitylength = 0
		      entity = ""
		      
		      LogMsg(LogType0_Debug, "HTTPServClientHandle("+Str(uid)+"): Recived Request, No Length")
		    End
		    
		    // Rather than duplicate code, we handle the rest outside of the entity loop. We need
		    // to check if we have data in the data variable, otherwise we may be attempting to act
		    // on an incomplete request.
		    
		    Dim method, url, query, version As String
		    Dim i As Integer
		    
		    If data <> "" Then
		      If searcher = Nil Then
		        searcher = New regex
		      End
		      searcher.searchpattern = MyHTTPServerModule.kregexrequestline
		      m = searcher.search(headers)
		      
		      If m <> Nil Then
		        method = m.subexpressionstring(1)
		        url = m.subexpressionstring(2)
		        query = m.subexpressionstring(4)
		        version = m.subexpressionstring(5)
		        If method = MyHTTPServerModule.kmethodpost Then
		          // In the case of a post request, the query is stored in the entity, so we modify accordingly
		          If query <> "" Then
		            query = query + "&" + entity
		          Else
		            query = entity
		          End
		        End
		        
		        // We send the headers,entity & query to the context, before sending it to the handler.
		        context.loadrequestparameters(headers)
		        context.loadvariables query
		        context.entity = entity
		        
		        // We ask the server to send our context to whatever is handling this url
		        LogMsg(LogType1_Notice, "HTTPServClientHandle("+Str(uid)+"): Processing URL "+URLDecode(url))
		        parent.forwardcontext(URLDecode(url), context)
		      Else
		        context.statuscode = MyHTTPServerModule.kStatusBadRequest
		        Context.Buffer = MyHTTPServerModule.HTTPErrorHTML(context.statuscode)
		        
		      End If
		      
		      // HTTP requests rely on the Content-Length header. Rather than require the user to set
		      // the header, we simply add it based on the buffer size.
		      context.headers.value(MyHTTPServerModule.kheadercontentlength) = LenB(context.buffer)
		      
		      context.headers.value(MyHTTPServerModule.kHeaderConnection) = "close"
		      
		      context.headers.value(MyHTTPServerModule.kHeaderServer) = MyHTTPServerModule.VersionLongString
		      
		      
		      // Now we pipe the data back to the client
		      Me.write(MyHTTPServerModule.kversion + " " + HTTPStatusString(context.statuscode) + MyHTTPServerModule.crlf)
		      For i = 0 To context.headers.count - 1
		        'Me.write(context.headers.key(i).stringvalue + ": " + URLEncode(context.headers.value(context.headers.key(i)).stringvalue) + MyHTTPServerModule.crlf)
		        Me.write(context.headers.key(i).stringvalue + ": " + context.headers.value(context.headers.key(i)).stringvalue + MyHTTPServerModule.crlf)
		      Next
		      Me.write(MyHTTPServerModule.crlf)
		      Me.write(context.buffer)
		      
		      me.Flush
		      Me.Disconnect
		    Else
		      // Incomplete request
		    End
		    
		    
		    
		    // Now we send the loop back to the beginning so we can handle the possibility of 2+
		    // requests in a single event.
		    data = ""
		    la = Me.lookahead(encodings.ascii)
		    If LenB(la) > 0 Then
		      LogMsg(LogType0_Debug, "HTTPServClientHandle("+Str(uid)+"): More DataAvaible - Start Over "+Str(LenB(la)))
		      GoTo restartPoint
		    End If
		  End
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  // Note that this may need modifications if there are multiple constructor choices.
		  // Possible constructor calls:
		  // Constructor() -- From TCPSocket
		  // Constructor() -- From SocketCore
		  Super.Constructor
		  
		  uid = Lastuid + 1
		  Lastuid = uid
		  
		  LogMsg(LogType0_Debug, "HTTPServClientHandle("+str(uid)+"): Constuct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  Parent = Nil
		  LogMsg(LogType0_Debug, "HTTPServClientHandle("+str(uid)+"): Destruct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Identifier() As Integer
		  Return uid
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Buffer As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Context As MyHTTPServerRequestContext
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Lastuid As Int64 = 0
	#tag EndProperty

	#tag Property, Flags = &h0
		Parent As MyHTTPServerSocket
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Searcher As Regex
	#tag EndProperty

	#tag Property, Flags = &h0
		uid As Int64
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Address"
			Visible=true
			Group="Behavior"
			Type="String"
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
