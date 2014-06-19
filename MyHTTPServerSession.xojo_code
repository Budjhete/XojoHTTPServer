#tag Class
Protected Class MyHTTPServerSession
	#tag Method, Flags = &h0
		Sub Constructor()
		  data = new dictionary
		  
		  uid = Lastuid + 1
		  Lastuid = uid
		  
		  LogMsg(LogType0_Debug, "HTTPServSession("+str(uid)+"): Construct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  LogMsg(LogType0_Debug, "HTTPServSession("+str(uid)+"): Destruct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Identifier() As Integer
		  return uid
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(Key As String) As Variant
		  if data.haskey(key) then
		    return data.value(key)
		  else
		    return ""
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Value(Key As String, Assigns NewValue As Variant)
		  data.value(key) = newvalue
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Data As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Lastuid As Int64 = 100
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Rand As Random
	#tag EndProperty

	#tag Property, Flags = &h21
		Private uid As Int64
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
