#tag Class
Protected Class MyHTTPFileRequestHandler
Implements MyHTTPRequestHandler
	#tag CompatibilityFlags = false
	#tag Method, Flags = &h0
		Sub Constructor(pRoot As Xojo.IO.FolderItem)
		  // The handler will serve files under the root FolderItem
		  mRoot = pRoot
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HandleRequest(pRequest As MyHTTPRequest, pMatch As RegExMatch)
		  #pragma Unused pMatch
		  
		  // Handles a File request
		  // @todo fix multiple folder level
		  
		  Dim pFolderItem As Xojo.IO.FolderItem = mRoot
		  
		  If pRequest.URL <> "/" Then
		    // Remove the / starting the URL
		    pFolderItem = mRoot.Child(pRequest.URL.ToText.Mid(2))
		  End If
		  
		  If pFolderItem.Exists Then
		    
		    If pFolderItem.IsFolder Then
		      
		      // List directory content
		      
		      pRequest.Body = "<h2>" + pFolderItem.DisplayName + "</h2>"
		      
		      pRequest.Body = pRequest.Body + "<ul>"
		      
		      For pIndex As Integer = 1 To pFolderItem.Count
		        pRequest.Body = pRequest.Body + "<li><a href=""" + pFolderItem.Item(pIndex).Name + """>" + pFolderItem.Item(pIndex).DisplayName + "</a></li>"
		      Next
		      
		      pRequest.Body = pRequest.Body + "</ul>"
		      
		    Else
		      
		      // Resolve Content-Type by extension
		      pRequest.Headers.Value("Content-Type") = MyHTTPServerModule.HTTPMimeString(pFolderItem.Extension)
		      
		      // Output file content
		      pRequest.Body = TextInputStream.Open(pFolderItem).ReadAll
		      
		    End If
		    
		  Else
		    
		    pRequest.Status = 404
		    pRequest.Body = MyHTTPServerModule.HTTPErrorHTML(pRequest.Status)
		    
		  End If
		  
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mRoot As Xojo.IO.FolderItem
	#tag EndProperty


	#tag ViewBehavior
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
