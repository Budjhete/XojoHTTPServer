#tag Class
Protected Class MyHTTPFileRequestHandler
Implements MyHTTPRequestHandler
	#tag Method, Flags = &h0
		Sub Constructor(pRoot As FolderItem)
		  
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
		      
		      pRequest.Buffer = "<h2>" + pFolderItem.DisplayName + "</h2>"
		      
		      pRequest.Buffer = pRequest.Buffer + "<ul>"
		      
		      For pIndex As Integer = 0 To pFolderItem.Count - 1
		        pRequest.Buffer = pRequest.Buffer + "<li><a href='" + pFolderItem.Item(pIndex).Name + "'" + pFolderItem.Item(pIndex).DisplayName + "</a></li>"
		      Next
		      
		      pRequest.Buffer = pRequest.Buffer + "</ul>"
		      
		    Else
		      
		      // Output file content
		      
		    End If
		    
		    pRequest.StatusCode = 404
		    pRequest.Buffer = MyHTTPServerModule.HTTPErrorHTML(pRequest.StatusCode)
		    
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
