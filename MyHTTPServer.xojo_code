#tag Class
Protected Class MyHTTPServer
Inherits TCPSocket
	#tag Event
		Sub DataAvailable()
		  // First, we use TCPSocket.Lookahead to determine if we have complete headers waiting.
		  
		  Dim la,data,headers,entity As String
		  Dim lalength,headerslength,entitylength,requestlength As Integer
		  Dim m As RegExMatch
		  
		  restartPoint:
		  
		  la = Me.Lookahead(Encodings.ASCII)
		  
		  headerslength = InStrB(la, MyHTTPServerModule.crlf + MyHTTPServerModule.crlf) - 1 // length of the headers
		  
		  System.Log(System.LogLevelNotice, "HTTPServer #" + Str(Me.Identifier) + ": " + Str(LenB(la)) + "B of total length of data available with " + Str(headerslength) + "B of headers length.")
		  
		  If headerslength > 0 Then
		    
		    // We have a complete header. But we're not done yet. Some HTTP methods send entity
		    // data, such as POST and PUT, which need to be read out as well, but may not be complete
		    // yet. We determine this by reading the Content-Length header which tells us how much
		    // data the entity contains. We stop once we've received that much data, and assume that
		    // everything else is a new request.
		    
		    headers = LeftB(la, headerslength) // the headers
		    Me.Context = New MyHTTPRequest(Me)
		    Me.Context.LoadRequestHeaders(headers)
		    
		    // Check for required headers
		    'If MyHTTPServerModule.kVersion = "HTTP/1.1" Then
		    'If context.Headers.HasKey("Host") = False Then
		    'MsgBox("Error")
		    'End If
		    'End If
		    
		    If Me.Context.RequestHeaders.HasKey("Content-Length") Then
		      
		      // Now we know there is entity data in this request.
		      entitylength = Val(context.RequestHeaders.Lookup("Content-Length", ""))
		      requestlength = headerslength + LenB(MyHTTPServerModule.crlf + MyHTTPServerModule.crlf) + entitylength
		      lalength = LenB(la)
		      
		      If LenB(la) >= requestlength Then
		        
		        // We have the correct amount of data as well. We remove this data from the queue
		        // while ensuring that later data is left intact. Sometimes, TCPSocket may fire
		        // a DataAvailable event while having one and a half requests in the queue.
		        
		        data = Me.read(requestlength, encodings.ascii)
		        entity = MidB(data,headerslength + 1 + LenB(MyHTTPServerModule.crlf + MyHTTPServerModule.crlf),entitylength)
		        
		        System.DebugLog("HTTPServer #" + Str(Me.Identifier) + ": Recived Request, "+Str(requestlength)+" len")
		        
		      Else
		        
		        // There is more data to be received. We take no further action in this event, and start
		        // over the next event, which should contain more data.
		        System.DebugLog("HTTPServer #" + Str(Me.Identifier) + ": Missing Data Resetting goto START")
		        
		      End
		      
		    Else
		      
		      // The request does not contain a Content-Length header, so it must be complete.
		      requestlength = headerslength + LenB(MyHTTPServerModule.crlf + MyHTTPServerModule.crlf)
		      data = Me.Read(requestlength, Encodings.ASCII)
		      entitylength = 0
		      entity = ""
		      
		      System.DebugLog("HTTPServer #" + Str(Me.Identifier) + ": Recived Request, No Length")
		      
		    End
		    
		    // Rather than duplicate code, we handle the rest outside of the entity loop. We need
		    // to check if we have data in the data variable, otherwise we may be attempting to act
		    // on an incomplete request.
		    
		    Dim method, url, query, version As String
		    
		    If data <> "" Then
		      
		      If searcher = Nil Then
		        searcher = New RegEx
		      End
		      
		      searcher.SearchPattern = MyHTTPServerModule.kregexrequestline
		      m = searcher.Search(headers)
		      
		      If m <> Nil Then
		        
		        method = m.SubExpressionString(1)
		        url = m.SubExpressionString(2)
		        query = m.SubExpressionString(4)
		        version = m.SubExpressionString(5)
		        
		        // We send the headers,entity & query to the context, before sending it to the handler.
		        Me.Context.Method = method
		        Me.Context.URL = DecodeURLComponent(url)
		        Me.Context.LoadQuery query
		        Me.Context.RequestBody = entity
		        
		        // We ask the server to send our context to whatever is handling this url
		        System.Log(System.LogLevelNotice, "HTTPServer #" + Str(Me.Identifier) + ": Delegating the handling for URL " + DecodeURLComponent(url))
		        
		        Try
		          
		          Me.Parent.HandleRequest(Me.Context)
		          
		        Catch re As RuntimeException
		          
		          System.Log(System.LogLevelError, "HTTPServer #" + Str(Me.Identifier) + ": " + re.Message)
		          
		          For Each pLine As String In re.Stack
		            System.Log(System.LogLevelError, pLine)
		          Next
		          
		        End Try
		        
		      Else
		        
		        System.Log(System.LogLevelWarning, "HTTPServer #" + Str(Me.Identifier) + ": Processing a Bad Request for URL " + DecodeURLComponent(url))
		        
		        // Bad request
		        Me.Context.Status = MyHTTPServerModule.kStatusBadRequest
		        Me.Context.Body = MyHTTPServerModule.HTTPErrorHTML(Me.Context.Status)
		        
		      End If
		      
		      System.DebugLog "HTTPServer #" + Str(Me.Identifier) + ": Responding Request with URL " + DecodeURLComponent(url)
		      
		      // HTTP requests rely on the Content-Length header. Rather than require the user to set
		      // the header, we simply add it based on the buffer size.
		      Me.Context.Headers.Value(MyHTTPServerModule.kheadercontentlength) = LenB(context.Body)
		      
		      // Only support close connection, so even if the handler set it
		      // to keep-alive, we tell the client the truth.
		      Me.Context.Headers.Value(MyHTTPServerModule.kHeaderConnection) = "close"
		      
		      Me.Context.Headers.Value(MyHTTPServerModule.kHeaderServer) = MyHTTPServerModule.VersionLongString
		      
		      
		      // send the size of the data on the first bite
		      dim ttt as text = Me.Context.Headers.Value(MyHTTPServerModule.kheadercontentlength).IntegerValue.ToHex(8)
		      dim t1 as text = text.FromUnicodeCodepoint(Integer.FromHex(ttt.Mid(0, 2)))
		      dim t2 as text = text.FromUnicodeCodepoint(Integer.FromHex(ttt.Mid(2, 2)))
		      dim t3 as text = text.FromUnicodeCodepoint(Integer.FromHex(ttt.Mid(4, 2)))
		      dim t4 as text = text.FromUnicodeCodepoint(Integer.FromHex(ttt.Mid(6, 2)))
		      Me.Write(t1+t2+t3+t4)
		      // Now we pipe the data back to the client
		      Me.Write(MyHTTPServerModule.kVersion + " " + HTTPStatusString(Me.Context.Status) + MyHTTPServerModule.crlf)
		      
		      For Each pKey As String In Me.Context.Headers.Keys
		        'Me.write(context.headers.key(i).stringvalue + ": " + URLEncode(context.headers.value(context.headers.key(i)).stringvalue) + MyHTTPServerModule.crlf)
		        Me.Write(pKey + ": " + Me.Context.Headers.Value(pKey) + MyHTTPServerModule.crlf)
		      Next
		      
		      // Break a line!
		      Me.Write(MyHTTPServerModule.crlf)
		      
		      // Send the body
		      Me.Write(Me.Context.Body)
		      
		      // Finish it!
		      me.Flush
		      Me.Disconnect
		      
		    Else
		      // Incomplete request
		    End
		    
		    // Now we send the loop back to the beginning so we can handle the possibility of 2+
		    // requests in a single event.
		    data = ""
		    la = Me.LookAhead(Encodings.ascii)
		    If LenB(la) > 0 Then
		      System.DebugLog "HTTPServer #" + Str(Me.Identifier) + ": " + Str(LenB(la)) + "B of data available, starting over..."
		      GoTo restartPoint
		    End If
		  End
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor(pParent As MyHTTPServerSocket)
		  // Calling the overridden superclass constructor.
		  // Note that this may need modifications if there are multiple constructor choices.
		  // Possible constructor calls:
		  // Constructor() -- From TCPSocket
		  // Constructor() -- From SocketCore
		  Super.Constructor
		  
		  Me.Parent = pParent
		  
		  Me.Identifier = Self.Lastuid + 1
		  Self.Lastuid = Me.Identifier
		  
		  System.DebugLog("HTTP Server " + Str(Me.Identifier) + " is ready!")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  Parent = Nil
		  
		  System.DebugLog "MyHTTPServer #" + Str(Me.Identifier) + ": Destruct"
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Buffer As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Context As MyHTTPRequest
	#tag EndProperty

	#tag Property, Flags = &h0
		Identifier As Int64
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
			EditorType="Integer"
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
		#tag ViewProperty
			Name="Identifier"
			Group="Behavior"
			Type="Int64"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
