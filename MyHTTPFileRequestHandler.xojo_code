#tag Class
Protected Class MyHTTPFileRequestHandler
Implements MyHTTPRequestHandler
	#tag Method, Flags = &h0
		Sub Constructor(pRoot As FolderItem)
		  // The handler will serve files under the root FolderItem
		  mRoot = pRoot
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub HandleRequest(pRequest As MyHTTPRequest, pMatch As RegExMatch)
		  #pragma Unused pMatch
		  
		  // Handles a File request
		  // @todo fix multiple folder level
		  
		  Dim pFolderItem As FolderItem = mRoot
		  
		  If pRequest.URL <> "/" Then
		    // Remove the / starting the URL
		    pFolderItem = mRoot.Child(Mid(pRequest.URL, 2))
		  End If
		  
		  If pFolderItem.Exists Then
		    
		    If pFolderItem.Directory Then
		      
		      // List directory content
		      
		      pRequest.Body = "<h2>" + pFolderItem.DisplayName + "</h2>"
		      
		      pRequest.Body = pRequest.Body + "<ul>"
		      
		      For pIndex As Integer = 1 To pFolderItem.Count
		        pRequest.Body = pRequest.Body + "<li><a href=""" + pFolderItem.Item(pIndex).Name + """>" + pFolderItem.Item(pIndex).DisplayName + "</a></li>"
		      Next
		      
		      pRequest.Body = pRequest.Body + "</ul>"
		      
		    Else
		      
		      // Resolve Content-Type by extension
		      pRequest.Headers.Value("Content-Type") = MyHTTPServerModule.HTTPMimeString(pFolderItem.FileExtension)
		      
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
		Private mRoot As FolderItem
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
