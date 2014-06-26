#tag Interface
Protected Interface MyHTTPAuthRequestHandler
Implements MyHTTPRequestHandler
	#tag Method, Flags = &h0
		Function Authenticate(pUsername As String, pPassword As String) As Boolean
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Realm() As String
		  
		End Function
	#tag EndMethod


End Interface
#tag EndInterface
