#tag Class
Protected Class MyHTTPServerSession
	#tag CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit)) or  (TargetIOS and (Target32Bit or Target64Bit))
	#tag Method, Flags = &h0
		Sub Constructor()
		  data = new dictionary
		  
		  uid = Lastuid + 1
		  Lastuid = uid
		  
		  LogMsg(LogType0_Debug, "HTTPServSession("+uid.ToText+"): Construct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  LogMsg(LogType0_Debug, "HTTPServSession("+uid.ToText+"): Destruct")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Identifier() As Integer
		  return uid
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Value(Key As Text) As Auto
		  if data.haskey(key) then
		    return data.value(key)
		  else
		    return ""
		  end
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Value(Key As Text, Assigns NewValue As Auto)
		  data.value(key) = newvalue
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Data As Xojo.Core.Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared Lastuid As Int64 = 100
	#tag EndProperty

	#tag Property, Flags = &h21
		#tag Note
			//Xojo.Math.RandomInt
		#tag EndNote
		Private Shared Rand As integer
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
