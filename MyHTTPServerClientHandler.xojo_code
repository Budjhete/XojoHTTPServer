#tag Class
Protected Class MyHTTPServerClientHandler
Inherits Xojo.Net.TCPSocket
	#tag Event
		Sub DataAvailable()
		  // First, we use TCPSocket.Lookahead to determine if we have complete headers waiting.
		  
		  Dim la,data,headers,entity As Text
		  Dim lalength,headerslength,entitylength,requestlength As Integer
		  'Dim context As MyHTTPServerRequestContext
		  Dim m As JKRegEx.RegExMatch
		  
		  restartPoint:
		  
		  la = Xojo.Core.TextEncoding.ASCII.ConvertDataToText(Xojo.core.MemoryBlock(Me.AvailableData()))
		  
		  headerslength = la.IndexOf(MyHTTPServerModule.crlf + MyHTTPServerModule.crlf) - 1 // length of the headers
		  
		  LogMsg(LogType1_Notice, "HTTPServClientHandle("+uid.ToText+"): Data Available ["+la.Length.ToText+" totallen] "+headerslength.ToText+" headerlen")
		  If headerslength > 0 Then
		    // We have a complete header. But we're not done yet. Some HTTP methods send entity
		    // data, such as POST and PUT, which need to be read out as well, but may not be complete
		    // yet. We determine this by reading the Content-Length header which tells us how much
		    // data the entity contains. We stop once we've received that much data, and assume that
		    // everything else is a new request.
		    
		    headers = la.Left(headerslength) // the headers
		    context = New MyHTTPServerRequestContext
		    context.loadrequestparameters(headers)
		    
		    // Check for required headers
		    'If MyHTTPServerModule.kVersion = "HTTP/1.1" Then
		    'If context.Headers.HasKey("Host") = False Then
		    'MsgBox("Error")
		    'End If
		    'End If
		    Dim tCRLF as Text
		    
		    If context.header(MyHTTPServerModule.kheadercontentlength) <> "" Then
		      // Now we know there is entity data in this request.
		      tCRLF = MyHTTPServerModule.crlf + MyHTTPServerModule.crlf
		      entitylength = context.header(MyHTTPServerModule.kheadercontentlength).IntegerValue
		      requestlength = headerslength + tCRLF.Length + entitylength
		      lalength = la.Length
		      If la.Length >= requestlength Then
		        // We have the correct amount of data as well. We remove this data from the queue
		        // while ensuring that later data is left intact. Sometimes, TCPSocket may fire
		        // a DataAvailable event while having one and a half requests in the queue.
		        
		        data =  Xojo.Core.TextEncoding.ASCII.ConvertDataToText(Me.ReadData(requestlength))
		        entity = data.Mid(headerslength + 1 + tCRLF.Length ,entitylength)
		        
		        LogMsg(LogType0_Debug, "HTTPServClientHandle("+uid.ToText+"): Recived Request, "+requestlength.ToText+" len")
		      Else
		        // There is more data to be received. We take no further action in this event, and start
		        // over the next event, which should contain more data.
		        
		        LogMsg(LogType0_Debug, "HTTPServClientHandle("+uid.ToText+"): Missing Data Resetting goto START")
		      End
		    Else
		      // The request does not contain a Content-Length header, so it must be complete.
		      
		      requestlength = headerslength + tCRLF.Length
		      data = Xojo.Core.TextEncoding.ASCII.ConvertDataToText(Me.ReadData(requestlength))
		      entitylength = 0
		      entity = ""
		      
		      LogMsg(LogType0_Debug, "HTTPServClientHandle("+uid.ToText+"): Recived Request, No Length")
		    End
		    
		    // Rather than duplicate code, we handle the rest outside of the entity loop. We need
		    // to check if we have data in the data variable, otherwise we may be attempting to act
		    // on an incomplete request.
		    
		    Dim method, url, query, version As Text
		    Dim i As Integer
		    
		    If data <> "" Then
		      If searcher = Nil Then
		        searcher = New JKRegEx.RegEx
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
		        LogMsg(LogType1_Notice, "HTTPServClientHandle("+uid.ToText+"): Processing URL "+URLDecode(url))
		        parent.forwardcontext(URLDecode(url), context)
		      Else
		        context.statuscode = MyHTTPServerModule.kStatusBadRequest
		        Context.Buffer = MyHTTPServerModule.HTTPErrorHTML(context.statuscode)
		        
		      End If
		      
		      // HTTP requests rely on the Content-Length header. Rather than require the user to set
		      // the header, we simply add it based on the buffer size.
		      context.headers.value(MyHTTPServerModule.kheadercontentlength) = context.buffer.Length
		      
		      context.headers.value(MyHTTPServerModule.kHeaderConnection) = "close"
		      
		      context.headers.value(MyHTTPServerModule.kHeaderServer) = MyHTTPServerModule.VersionLongString
		      
		      
		      // Now we pipe the data back to the client
		      Me.WriteData(Xojo.Core.TextEncoding.UTF8.ConvertTextToData(MyHTTPServerModule.kversion + " " + HTTPStatusString(context.statuscode) + MyHTTPServerModule.crlf))
		      For each dHeader as Xojo.Core.DictionaryEntry in context.headers
		        'Me.write(context.headers.key(i).stringvalue + ": " + URLEncode(context.headers.value(context.headers.key(i)).stringvalue) + MyHTTPServerModule.crlf)
		        Me.WriteData(Xojo.Core.TextEncoding.UTF8.ConvertTextToData(dHeader.Key.TextValue + ": " + dHeader.Value.TextValue + MyHTTPServerModule.crlf))
		      Next
		      Me.WriteData(Xojo.Core.TextEncoding.UTF8.ConvertTextToData(MyHTTPServerModule.crlf))
		      Me.WriteData(Xojo.Core.TextEncoding.UTF8.ConvertTextToData(context.buffer))
		      
		      'me.Flush
		      Me.Disconnect
		    Else
		      // Incomplete request
		    End
		    
		    
		    
		    // Now we send the loop back to the beginning so we can handle the possibility of 2+
		    // requests in a single event.
		    data = ""
		    la = Xojo.Core.TextEncoding.ASCII.ConvertDataToText(Me.AvailableData())
		    If la.Length > 0 Then
		      System.DebugLog "HTTPServClientHandle("+uid.ToText+"): More DataAvaible - Start Over "+ la.Length.ToText
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
		  'Super.Constructor
		  
		  uid = Lastuid + 1
		  Lastuid = uid
		  
		  LogMsg(LogType0_Debug, "HTTPServClientHandle("+uid.ToText+"): Constuct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  Parent = Nil
		  LogMsg(LogType0_Debug, "HTTPServClientHandle("+uid.ToText+"): Destruct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Identifier() As Integer
		  Return uid
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Buffer As Text
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
		Private Shared Searcher As JKRegEx.RegEx
	#tag EndProperty

	#tag Property, Flags = &h0
		uid As Int64
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="IsConnected"
			Group="Behavior"
			Type="Boolean"
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
			Name="BytesAvailable"
			Group="Behavior"
			Type="UInteger"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Address"
			Visible=true
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
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
			Type="Int32"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="uid"
			Group="Behavior"
			Type="Int64"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
