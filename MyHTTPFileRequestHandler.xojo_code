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
		  // Handles a File request
		  
		  Dim pFolderItem As FolderItem = mRoot
		  
		  Dim pPieces() As String = Split("/", pRequest.URL)
		  
		  For Each pPiece As String In pPieces
		    
		    pFolderItem = pFolderItem.Child(pPiece)
		    
		  Next
		  
		  If pFolderItem.Exists Then
		    
		    If pFolderItem.Directory Then
		      
		      // List directory content
		      
		      pRequest.Body = "<h2>" + pFolderItem.DisplayName + "</h2>"
		      
		      pRequest.Body = pRequest.Body + "<ul>"
		      
		      For pIndex As Integer = 0 To pFolderItem.Count - 1
		        pRequest.Body = pRequest.Body + "<li><a href='" + pFolderItem.Item(pIndex).Name + "'" + pFolderItem.Item(pIndex).DisplayName + "</a></li>"
		      Next
		      
		      pRequest.Body = pRequest.Body + "</ul>"
		      
		    Else
		      
		      // Output file content
		      
		    End If
		    
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
