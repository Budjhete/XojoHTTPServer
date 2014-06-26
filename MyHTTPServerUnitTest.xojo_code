#tag Class
Protected Class MyHTTPServerUnitTest
Inherits TestGroup
	#tag Event
		Sub Setup()
		  Dim pMyHttpServerSocket As New MyHTTPServerSocket
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub SessionTest()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub URLDecodeTest()
		  Assert.AreEqual "", URLDecode("")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub URLEncodeTest()
		  Assert.AreEqual "", URLDecode("")
		End Sub
	#tag EndMethod


End Class
#tag EndClass
