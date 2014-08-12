#tag Module
Protected Module MyHTTPServerModule
	#tag Method, Flags = &h0
		Function CookieDate(Extends D As Date) As String
		  dim s as string
		  select case d.dayofweek
		  case 1
		    s = "Sun"
		  case 2
		    s = "Mon"
		  case 3
		    s = "Tue"
		  case 4
		    s = "Wed"
		  case 5
		    s = "Thu"
		  case 6
		    s = "Fri"
		  case 7
		    s = "Sat"
		  end
		  
		  s = s + ", " + zeropad(d.day) + "-"
		  
		  select case d.month
		  case 1
		    s = s + "Jan"
		  case 2
		    s = s + "Feb"
		  case 3
		    s = s + "Mar"
		  case 4
		    s = s + "Apr"
		  case 5
		    s = s + "May"
		  case 6
		    s = s + "Jun"
		  case 7
		    s = s + "Jul"
		  case 8
		    s = s + "Aug"
		  case 9
		    s = s + "Sep"
		  case 10
		    s = s + "Oct"
		  case 11
		    s = s + "Nov"
		  case 12
		    s = s + "Dec"
		  end
		  
		  s = s + "-" + str(d.year) + " " + zeropad(d.hour) + ":" + zeropad(d.minute) + ":" + zeropad(d.second) + " GMT"
		  return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CRLF() As String
		  Return encodings.ascii.Chr(13) + encodings.ascii.Chr(10)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FileExtension(Extends f As FolderItem) As String
		  if f.Directory Then
		    Return "folder"
		  Else
		    Return f.Name.Right(len(f.name)-InStrReverse(-1, f.Name, "."))
		  End if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPDate(Extends myDate As Date) As String
		  Dim d As New Date(myDate)
		  Dim s As String
		  
		  d.GMTOffset = 0
		  
		  Select Case d.dayofweek
		  Case 1
		    s = "Sun"
		  Case 2
		    s = "Mon"
		  Case 3
		    s = "Tue"
		  Case 4
		    s = "Wed"
		  Case 5
		    s = "Thu"
		  Case 6
		    s = "Fri"
		  Case 7
		    s = "Sat"
		  End
		  
		  s = s + ", " + zeropad(d.day) + " "
		  
		  Select Case d.month
		  Case 1
		    s = s + "Jan"
		  Case 2
		    s = s + "Feb"
		  Case 3
		    s = s + "Mar"
		  Case 4
		    s = s + "Apr"
		  Case 5
		    s = s + "May"
		  Case 6
		    s = s + "Jun"
		  Case 7
		    s = s + "Jul"
		  Case 8
		    s = s + "Aug"
		  Case 9
		    s = s + "Sep"
		  Case 10
		    s = s + "Oct"
		  Case 11
		    s = s + "Nov"
		  Case 12
		    s = s + "Dec"
		  End
		  
		  s = s + " " + Str(d.year) + " " + zeropad(d.hour) + ":" + zeropad(d.minute) + ":" + zeropad(d.second) + " GMT"
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPDirectoryHTML(serverpath As String, f As FolderItem) As String
		  Dim s, nameshort, namefull, size As String
		  Dim i As Integer
		  
		  If f.Directory Then
		    
		    s = s + "<!DOCTYPE HTML PUBLIC ""-//W3C//DTD HTML 3.2 Final//EN"">"
		    s = s + "<html><head><title>Index of "+serverpath+"</title></head>"
		    s = s + "<body><h1>Index of "+serverpath+"</h1>"
		    s = s + "<pre>    <b>Name</b>                    <b>Last modified</b>       <b>Size</b>  <b>Description</b><hr>"
		    
		    s = s + "<img src="""+HTTPIconString("back")+""" width=""20"" height=""22""> <a href=""../"">Parent Directory</a>                              -   "+EndOfLine
		    
		    i = 1
		    While i <= f.Count
		      nameshort = f.Item(i).Name
		      namefull = f.Item(i).Name
		      If Len(nameshort) > 20 Then
		        nameshort = nameshort.Left(17)+"..>"
		      End If
		      nameshort = PadRight(nameshort+"</a>", 24)
		      
		      if f.Item(i).Directory Then
		        namefull = namefull+"/"
		        size = "   -   "
		      Else
		        If f.Item(i).Length >= 1099511627776 Then ' terebyte
		          size = Str(Floor(f.Item(i).Length/1099511627776))+"T"
		          
		        Elseif f.Item(i).Length >= 1073741824 Then ' gigabytes
		          size = Str(Floor(f.Item(i).Length/1073741824))+"T"
		          
		        Elseif f.Item(i).Length >= 1048576 Then ' megabytes
		          size = Str(Floor(f.Item(i).Length/1048576))+"M"
		          
		        Elseif f.Item(i).Length >= 1024 Then  ' kilobytes
		          size = Str(Floor(f.Item(i).Length/1024 ))+"K"
		          
		        Else 'bytes
		          size = Str(f.Item(i).Length)+"B"
		          
		        End If
		        
		        size = PadLeft(size, 6)
		        
		      End if
		      
		      s = s + "<img src="""+HTTPIconString(f.Item(i).FileExtension)+""" width=""20"" height=""22""> <a href=""./"+EncodeURLComponent(namefull)+""">"+nameshort+"    "+f.Item(i).ModificationDate.SQLDateTime+size+EndOfLine
		      
		      
		      i = i + 1
		    Wend
		    
		    s = s + "<hr></pre>"
		    s = s + "<p><em>Powered by: " + VersionLongString + "</em></p>"
		    s = s + "</body></html>"
		    
		  Else
		    s = "Not a Directory"
		    
		  End If
		  
		  f = Nil
		  
		  Return s
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPErrorHTML(Status As Integer) As String
		  Dim s As String
		  
		  s = s + "<html><head><title>" + HTTPStatusString(Status) + "</title></head>"
		  
		  s = s + "<body><h2>" + HTTPStatusString(Status) + "</h2>"
		  
		  s = s + "<p>" + HTTPStatusMessage(Status) + "</p><hr/>"
		  
		  s = s + "<p><em>Powered by: " + App.LongVersion + "</em></p></body></html>"
		  
		  Return s
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPIconString(ext As String) As String
		  ext = Lowercase(ext)
		  
		  Select Case ext
		  Case "back"
		    Return "data:image/gif;base64,"+kImageBase64_Back
		    
		  Case "folder"
		    Return "data:image/gif;base64,"+kImageBase64_Folder
		    
		  Case "txt"
		    Return "data:image/gif;base64,"+kImageBase64_Text
		    
		  Case "htm", "html"
		    Return "data:image/gif;base64,"+kImageBase64_HTML
		    
		  Case "css"
		    Return "data:image/gif;base64,"+kImageBase64_CSS
		    
		  Case "xml", "xsl"
		    Return "data:image/gif;base64,"+kImageBase64_XML
		    
		  Case "jpg", "jpeg", "png", "bmp", "gif"
		    Return "data:image/gif;base64,"+kImageBase64_Image
		    
		  Case "mov", "mp4", "m4v", "avi", "mpg", "mpeg", "wmv", "mkv"
		    Return "data:image/gif;base64,"+kImageBase64_Movie
		    
		  Case "ttf", "otf", "pfb", "pfm"
		    Return "data:image/gif;base64,"+kImageBase64_Font
		    
		  Case "zip", "tar", "rar", "7zip", "bzip", "gzip"
		    Return "data:image/gif;base64,"+kImageBase64_Compressed
		    
		  Case "wav"
		    Return "data:image/gif;base64,"+kImageBase64_WAV
		    
		  Case "mp3", "m4a", "m4b", "m4p"
		    Return "data:image/gif;base64,"+kImageBase64_Music
		    
		  Case "pdf"
		    Return "data:image/gif;base64,"+kImageBase64_PDF
		    
		  Else ' This returns the default icon
		    Return "data:image/gif;base64,"+kImageBase64_Unknown
		    
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPMimeString(ext As String) As String
		  ext = Lowercase(ext)
		  
		  Select Case ext
		  Case "ez"
		    Return "application/andrew-inset"
		    
		  Case "aw"
		    Return "application/applixware"
		    
		  Case "atom"
		    Return "application/atom+xml"
		    
		  Case "atomcat"
		    Return "application/atomcat+xml"
		    
		  Case "atomsvc"
		    Return "application/atomsvc+xml"
		    
		  Case "ccxml"
		    Return "application/ccxml+xml"
		    
		  Case "cdmia"
		    Return "application/cdmi-capability"
		    
		  Case "cdmic"
		    Return "application/cdmi-container"
		    
		  Case "cdmid"
		    Return "application/cdmi-domain"
		    
		  Case "cdmio"
		    Return "application/cdmi-object"
		    
		  Case "cdmiq"
		    Return "application/cdmi-queue"
		    
		  Case "cu"
		    Return "application/cu-seeme"
		    
		  Case "davmount"
		    Return "application/davmount+xml"
		    
		  Case "dssc"
		    Return "application/dssc+der"
		    
		  Case "xdssc"
		    Return "application/dssc+xml"
		    
		  Case "ecma"
		    Return "application/ecmascript"
		    
		  Case "emma"
		    Return "application/emma+xml"
		    
		  Case "epub"
		    Return "application/epub+zip"
		    
		  Case "exi"
		    Return "application/exi"
		    
		  Case "pfr"
		    Return "application/font-tdpfr"
		    
		  Case "stk"
		    Return "application/hyperstudio"
		    
		  Case "ipfix"
		    Return "application/ipfix"
		    
		  Case "jar"
		    Return "application/java-archive"
		    
		  Case "ser"
		    Return "application/java-serialized-object"
		    
		  Case "class"
		    Return "application/java-vm"
		    
		  Case "js"
		    Return "application/javascript"
		    
		  Case "json"
		    Return "application/json"
		    
		  Case "lostxml"
		    Return "application/lost+xml"
		    
		  Case "hqx"
		    Return "application/mac-binhex40"
		    
		  Case "cpt"
		    Return "application/mac-compactpro"
		    
		  Case "mads"
		    Return "application/mads+xml"
		    
		  Case "mrc"
		    Return "application/marc"
		    
		  Case "mrcx"
		    Return "application/marcxml+xml"
		    
		  Case "ma", "nb", "mb"
		    Return "application/mathematica"
		    
		  Case "mathml"
		    Return "application/mathml+xml"
		    
		  Case "mbox"
		    Return "application/mbox"
		    
		  Case "mscml"
		    Return "application/mediaservercontrol+xml"
		    
		  Case "meta4"
		    Return "application/metalink4+xml"
		    
		  Case "mets"
		    Return "application/mets+xml"
		    
		  Case "mods"
		    Return "application/mods+xml"
		    
		  Case "m21", "mp21"
		    Return "application/mp21"
		    
		  Case "mp4s"
		    Return "application/mp4"
		    
		  Case "doc", "dot"
		    Return "application/msword"
		    
		  Case "mxf"
		    Return "application/mxf"
		    
		  Case "bin", "dms", "lha", "lrf", "lzh", "so", "iso", "dmg", "dist", "distz", "pkg", "bpk", "dump", "elc", "deploy", "mobipocket-ebook"
		    Return "application/octet-stream"
		    
		  Case "oda"
		    Return "application/oda"
		    
		  Case "opf"
		    Return "application/oebps-package+xml"
		    
		  Case "ogx"
		    Return "application/ogg"
		    
		  Case "onetoc", "onetoc2", "onetmp", "onepkg"
		    Return "application/onenote"
		    
		  Case "xer"
		    Return "application/patch-ops-error+xml"
		    
		  Case "pdf"
		    Return "application/pdf"
		    
		  Case "pgp"
		    Return "application/pgp-encrypted"
		    
		  Case "asc", "sig"
		    Return "application/pgp-signature"
		    
		  Case "prf"
		    Return "application/pics-rules"
		    
		  Case "p10"
		    Return "application/pkcs10"
		    
		  Case "p7m", "p7c"
		    Return "application/pkcs7-mime"
		    
		  Case "p7s"
		    Return "application/pkcs7-signature"
		    
		  Case "p8"
		    Return "application/pkcs8"
		    
		  Case "ac"
		    Return "application/pkix-attr-cert"
		    
		  Case "cer"
		    Return "application/pkix-cert"
		    
		  Case "crl"
		    Return "application/pkix-crl"
		    
		  Case "pkipath"
		    Return "application/pkix-pkipath"
		    
		  Case "pki"
		    Return "application/pkixcmp"
		    
		  Case "pls"
		    Return "application/pls+xml"
		    
		  Case "ai", "eps", "ps"
		    Return "application/postscript"
		    
		  Case "cww"
		    Return "application/prs.cww"
		    
		  Case "pskcxml"
		    Return "application/pskc+xml"
		    
		  Case "rdf"
		    Return "application/rdf+xml"
		    
		  Case "rif"
		    Return "application/reginfo+xml"
		    
		  Case "rnc"
		    Return "application/relax-ng-compact-syntax"
		    
		  Case "rl"
		    Return "application/resource-lists+xml"
		    
		  Case "rld"
		    Return "application/resource-lists-diff+xml"
		    
		  Case "rs"
		    Return "application/rls-services+xml"
		    
		  Case "rsd"
		    Return "application/rsd+xml"
		    
		  Case "rss"
		    Return "application/rss+xml"
		    
		  Case "rtf"
		    Return "application/rtf"
		    
		  Case "sbml"
		    Return "application/sbml+xml"
		    
		  Case "scq"
		    Return "application/scvp-cv-request"
		    
		  Case "scs"
		    Return "application/scvp-cv-response"
		    
		  Case "spq"
		    Return "application/scvp-vp-request"
		    
		  Case "spp"
		    Return "application/scvp-vp-response"
		    
		  Case "sdp"
		    Return "application/sdp"
		    
		  Case "setpay"
		    Return "application/set-payment-initiation"
		    
		  Case "setreg"
		    Return "application/set-registration-initiation"
		    
		  Case "shf"
		    Return "application/shf+xml"
		    
		  Case "smi", "smil"
		    Return "application/smil+xml"
		    
		  Case "rq"
		    Return "application/sparql-query"
		    
		  Case "srx"
		    Return "application/sparql-results+xml"
		    
		  Case "gram"
		    Return "application/srgs"
		    
		  Case "grxml"
		    Return "application/srgs+xml"
		    
		  Case "sru"
		    Return "application/sru+xml"
		    
		  Case "ssml"
		    Return "application/ssml+xml"
		    
		  Case "tei", "teicorpus"
		    Return "application/tei+xml"
		    
		  Case "tfi"
		    Return "application/thraud+xml"
		    
		  Case "tsd"
		    Return "application/timestamped-data"
		    
		  Case "plb"
		    Return "application/vnd.3gpp.pic-bw-large"
		    
		  Case "psb"
		    Return "application/vnd.3gpp.pic-bw-small"
		    
		  Case "pvb"
		    Return "application/vnd.3gpp.pic-bw-var"
		    
		  Case "tcap"
		    Return "application/vnd.3gpp2.tcap"
		    
		  Case "pwn"
		    Return "application/vnd.3m.post-it-notes"
		    
		  Case "aso"
		    Return "application/vnd.accpac.simply.aso"
		    
		  Case "imp"
		    Return "application/vnd.accpac.simply.imp"
		    
		  Case "acu"
		    Return "application/vnd.acucobol"
		    
		  Case "atc", "acutc"
		    Return "application/vnd.acucorp"
		    
		  Case "air"
		    Return "application/vnd.adobe.air-application-installer-package+zip"
		    
		  Case "fxp", "fxpl"
		    Return "application/vnd.adobe.fxp"
		    
		  Case "xdp"
		    Return "application/vnd.adobe.xdp+xml"
		    
		  Case "xfdf"
		    Return "application/vnd.adobe.xfdf"
		    
		  Case "ahead"
		    Return "application/vnd.ahead.space"
		    
		  Case "azf"
		    Return "application/vnd.airzip.filesecure.azf"
		    
		  Case "azs"
		    Return "application/vnd.airzip.filesecure.azs"
		    
		  Case "azw"
		    Return "application/vnd.amazon.ebook"
		    
		  Case "acc"
		    Return "application/vnd.americandynamics.acc"
		    
		  Case "ami"
		    Return "application/vnd.amiga.ami"
		    
		  Case "apk"
		    Return "application/vnd.android.package-archive"
		    
		  Case "cii"
		    Return "application/vnd.anser-web-certificate-issue-initiation"
		    
		  Case "fti"
		    Return "application/vnd.anser-web-funds-transfer-initiation"
		    
		  Case "atx"
		    Return "application/vnd.antix.game-component"
		    
		  Case "mpkg"
		    Return "application/vnd.apple.installer+xml"
		    
		  Case "m3u8"
		    Return "application/vnd.apple.mpegurl"
		    
		  Case "swi"
		    Return "application/vnd.aristanetworks.swi"
		    
		  Case "aep"
		    Return "application/vnd.audiograph"
		    
		  Case "mpm"
		    Return "application/vnd.blueice.multipass"
		    
		  Case "bmi"
		    Return "application/vnd.bmi"
		    
		  Case "rep"
		    Return "application/vnd.businessobjects"
		    
		  Case "cdxml"
		    Return "application/vnd.chemdraw+xml"
		    
		  Case "mmd"
		    Return "application/vnd.chipnuts.karaoke-mmd"
		    
		  Case "cdy"
		    Return "application/vnd.cinderella"
		    
		  Case "cla"
		    Return "application/vnd.claymore"
		    
		  Case "rp9"
		    Return "application/vnd.cloanto.rp9"
		    
		  Case "c4g", "c4d", "c4f", "c4p", "c4u"
		    Return "application/vnd.clonk.c4group"
		    
		  Case "c11amc"
		    Return "application/vnd.cluetrust.cartomobile-config"
		    
		  Case "c11amz"
		    Return "application/vnd.cluetrust.cartomobile-config-pkg"
		    
		  Case "csp"
		    Return "application/vnd.commonspace"
		    
		  Case "cdbcmsg"
		    Return "application/vnd.contact.cmsg"
		    
		  Case "cmc"
		    Return "application/vnd.cosmocaller"
		    
		  Case "clkx"
		    Return "application/vnd.crick.clicker"
		    
		  Case "clkk"
		    Return "application/vnd.crick.clicker.keyboard"
		    
		  Case "clkp"
		    Return "application/vnd.crick.clicker.palette"
		    
		  Case "clkt"
		    Return "application/vnd.crick.clicker.template"
		    
		  Case "clkw"
		    Return "application/vnd.crick.clicker.wordbank"
		    
		  Case "wbs"
		    Return "application/vnd.criticaltools.wbs+xml"
		    
		  Case "pml"
		    Return "application/vnd.ctc-posml"
		    
		  Case "ppd"
		    Return "application/vnd.cups-ppd"
		    
		  Case "car"
		    Return "application/vnd.curl.car"
		    
		  Case "pcurl"
		    Return "application/vnd.curl.pcurl"
		    
		  Case "rdz"
		    Return "application/vnd.data-vision.rdz"
		    
		  Case "uvf", "uvvf", "uvd", "uvvd"
		    Return "application/vnd.dece.data"
		    
		  Case "uvt", "uvvt"
		    Return "application/vnd.dece.ttml+xml"
		    
		  Case "uvx", "uvvx"
		    Return "application/vnd.dece.unspecified"
		    
		  Case "fe_launch"
		    Return "application/vnd.denovo.fcselayout-link"
		    
		  Case "dna"
		    Return "application/vnd.dna"
		    
		  Case "mlp"
		    Return "application/vnd.dolby.mlp"
		    
		  Case "dpg"
		    Return "application/vnd.dpgraph"
		    
		  Case "dfac"
		    Return "application/vnd.dreamfactory"
		    
		  Case "ait"
		    Return "application/vnd.dvb.ait"
		    
		  Case "svc"
		    Return "application/vnd.dvb.service"
		    
		  Case "geo"
		    Return "application/vnd.dynageo"
		    
		  Case "mag"
		    Return "application/vnd.ecowin.chart"
		    
		  Case "nml"
		    Return "application/vnd.enliven"
		    
		  Case "esf"
		    Return "application/vnd.epson.esf"
		    
		  Case "msf"
		    Return "application/vnd.epson.msf"
		    
		  Case "qam"
		    Return "application/vnd.epson.quickanime"
		    
		  Case "slt"
		    Return "application/vnd.epson.salt"
		    
		  Case "ssf"
		    Return "application/vnd.epson.ssf"
		    
		  Case "es3", "et3"
		    Return "application/vnd.eszigno3+xml"
		    
		  Case "ez2"
		    Return "application/vnd.ezpix-album"
		    
		  Case "ez3"
		    Return "application/vnd.ezpix-package"
		    
		  Case "fdf"
		    Return "application/vnd.fdf"
		    
		  Case "mseed"
		    Return "application/vnd.fdsn.mseed"
		    
		  Case "seed", "dataless"
		    Return "application/vnd.fdsn.seed"
		    
		  Case "gph"
		    Return "application/vnd.flographit"
		    
		  Case "ftc"
		    Return "application/vnd.fluxtime.clip"
		    
		  Case "fm", "frame", "maker", "book"
		    Return "application/vnd.framemaker"
		    
		  Case "fnc"
		    Return "application/vnd.frogans.fnc"
		    
		  Case "ltf"
		    Return "application/vnd.frogans.ltf"
		    
		  Case "fsc"
		    Return "application/vnd.fsc.weblaunch"
		    
		  Case "oas"
		    Return "application/vnd.fujitsu.oasys"
		    
		  Case "oa2"
		    Return "application/vnd.fujitsu.oasys2"
		    
		  Case "oa3"
		    Return "application/vnd.fujitsu.oasys3"
		    
		  Case "fg5"
		    Return "application/vnd.fujitsu.oasysgp"
		    
		  Case "bh2"
		    Return "application/vnd.fujitsu.oasysprs"
		    
		  Case "ddd"
		    Return "application/vnd.fujixerox.ddd"
		    
		  Case "xdw"
		    Return "application/vnd.fujixerox.docuworks"
		    
		  Case "xbd"
		    Return "application/vnd.fujixerox.docuworks.binder"
		    
		  Case "fzs"
		    Return "application/vnd.fuzzysheet"
		    
		  Case "txd"
		    Return "application/vnd.genomatix.tuxedo"
		    
		  Case "ggb"
		    Return "application/vnd.geogebra.file"
		    
		  Case "ggt"
		    Return "application/vnd.geogebra.tool"
		    
		  Case "gex", "gre"
		    Return "application/vnd.geometry-explorer"
		    
		  Case "gxt"
		    Return "application/vnd.geonext"
		    
		  Case "g2w"
		    Return "application/vnd.geoplan"
		    
		  Case "g3w"
		    Return "application/vnd.geospace"
		    
		  Case "gmx"
		    Return "application/vnd.gmx"
		    
		  Case "kml"
		    Return "application/vnd.google-earth.kml+xml"
		    
		  Case "kmz"
		    Return "application/vnd.google-earth.kmz"
		    
		  Case "gqf", "gqs"
		    Return "application/vnd.grafeq"
		    
		  Case "gac"
		    Return "application/vnd.groove-account"
		    
		  Case "ghf"
		    Return "application/vnd.groove-help"
		    
		  Case "gim"
		    Return "application/vnd.groove-identity-message"
		    
		  Case "grv"
		    Return "application/vnd.groove-injector"
		    
		  Case "gtm"
		    Return "application/vnd.groove-tool-message"
		    
		  Case "tpl"
		    Return "application/vnd.groove-tool-template"
		    
		  Case "vcg"
		    Return "application/vnd.groove-vcard"
		    
		  Case "hal"
		    Return "application/vnd.hal+xml"
		    
		  Case "zmm"
		    Return "application/vnd.handheld-entertainment+xml"
		    
		  Case "hbci"
		    Return "application/vnd.hbci"
		    
		  Case "les"
		    Return "application/vnd.hhe.lesson-player"
		    
		  Case "hpgl"
		    Return "application/vnd.hp-hpgl"
		    
		  Case "hpid"
		    Return "application/vnd.hp-hpid"
		    
		  Case "hps"
		    Return "application/vnd.hp-hps"
		    
		  Case "jlt"
		    Return "application/vnd.hp-jlyt"
		    
		  Case "pcl"
		    Return "application/vnd.hp-pcl"
		    
		  Case "pclxl"
		    Return "application/vnd.hp-pclxl"
		    
		  Case "sfd-hdstx"
		    Return "application/vnd.hydrostatix.sof-data"
		    
		  Case "x3d"
		    Return "application/vnd.hzn-3d-crossword"
		    
		  Case "mpy"
		    Return "application/vnd.ibm.minipay"
		    
		  Case "afp", "listafp", "list3820"
		    Return "application/vnd.ibm.modcap"
		    
		  Case "irm"
		    Return "application/vnd.ibm.rights-management"
		    
		  Case "sc"
		    Return "application/vnd.ibm.secure-container"
		    
		  Case "icc", "icm"
		    Return "application/vnd.iccprofile"
		    
		  Case "igl"
		    Return "application/vnd.igloader"
		    
		  Case "ivp"
		    Return "application/vnd.immervision-ivp"
		    
		  Case "ivu"
		    Return "application/vnd.immervision-ivu"
		    
		  Case "igm"
		    Return "application/vnd.insors.igm"
		    
		  Case "xpw", "xpx"
		    Return "application/vnd.intercon.formnet"
		    
		  Case "i2g"
		    Return "application/vnd.intergeo"
		    
		  Case "qbo"
		    Return "application/vnd.intu.qbo"
		    
		  Case "qfx"
		    Return "application/vnd.intu.qfx"
		    
		  Case "rcprofile"
		    Return "application/vnd.ipunplugged.rcprofile"
		    
		  Case "irp"
		    Return "application/vnd.irepository.package+xml"
		    
		  Case "xpr"
		    Return "application/vnd.is-xpr"
		    
		  Case "fcs"
		    Return "application/vnd.isac.fcs"
		    
		  Case "jam"
		    Return "application/vnd.jam"
		    
		  Case "rms"
		    Return "application/vnd.jcp.javame.midlet-rms"
		    
		  Case "jisp"
		    Return "application/vnd.jisp"
		    
		  Case "joda"
		    Return "application/vnd.joost.joda-archive"
		    
		  Case "ktz", "ktr"
		    Return "application/vnd.kahootz"
		    
		  Case "karbon"
		    Return "application/vnd.kde.karbon"
		    
		  Case "chrt"
		    Return "application/vnd.kde.kchart"
		    
		  Case "kfo"
		    Return "application/vnd.kde.kformula"
		    
		  Case "flw"
		    Return "application/vnd.kde.kivio"
		    
		  Case "kon"
		    Return "application/vnd.kde.kontour"
		    
		  Case "kpr", "kpt"
		    Return "application/vnd.kde.kpresenter"
		    
		  Case "ksp"
		    Return "application/vnd.kde.kspread"
		    
		  Case "kwd", "kwt"
		    Return "application/vnd.kde.kword"
		    
		  Case "htke"
		    Return "application/vnd.kenameaapp"
		    
		  Case "kia"
		    Return "application/vnd.kidspiration"
		    
		  Case "kne", "knp"
		    Return "application/vnd.kinar"
		    
		  Case "skp", "skd", "skt", "skm"
		    Return "application/vnd.koan"
		    
		  Case "sse"
		    Return "application/vnd.kodak-descriptor"
		    
		  Case "lasxml"
		    Return "application/vnd.las.las+xml"
		    
		  Case "lbd"
		    Return "application/vnd.llamagraphics.life-balance.desktop"
		    
		  Case "lbe"
		    Return "application/vnd.llamagraphics.life-balance.exchange+xml"
		    
		  Case "123"
		    Return "application/vnd.lotus-1-2-3"
		    
		  Case "apr"
		    Return "application/vnd.lotus-approach"
		    
		  Case "pre"
		    Return "application/vnd.lotus-freelance"
		    
		  Case "nsf"
		    Return "application/vnd.lotus-notes"
		    
		  Case "org"
		    Return "application/vnd.lotus-organizer"
		    
		  Case "scm"
		    Return "application/vnd.lotus-screencam"
		    
		  Case "lwp"
		    Return "application/vnd.lotus-wordpro"
		    
		  Case "portpkg"
		    Return "application/vnd.macports.portpkg"
		    
		  Case "mcd"
		    Return "application/vnd.mcd"
		    
		  Case "mc1"
		    Return "application/vnd.medcalcdata"
		    
		  Case "cdkey"
		    Return "application/vnd.mediastation.cdkey"
		    
		  Case "mwf"
		    Return "application/vnd.mfer"
		    
		  Case "mfm"
		    Return "application/vnd.mfmp"
		    
		  Case "flo"
		    Return "application/vnd.micrografx.flo"
		    
		  Case "igx"
		    Return "application/vnd.micrografx.igx"
		    
		  Case "mif"
		    Return "application/vnd.mif"
		    
		  Case "daf"
		    Return "application/vnd.mobius.daf"
		    
		  Case "dis"
		    Return "application/vnd.mobius.dis"
		    
		  Case "mbk"
		    Return "application/vnd.mobius.mbk"
		    
		  Case "mqy"
		    Return "application/vnd.mobius.mqy"
		    
		  Case "msl"
		    Return "application/vnd.mobius.msl"
		    
		  Case "plc"
		    Return "application/vnd.mobius.plc"
		    
		  Case "txf"
		    Return "application/vnd.mobius.txf"
		    
		  Case "mpn"
		    Return "application/vnd.mophun.application"
		    
		  Case "mpc"
		    Return "application/vnd.mophun.certificate"
		    
		  Case "xul"
		    Return "application/vnd.mozilla.xul+xml"
		    
		  Case "cil"
		    Return "application/vnd.ms-artgalry"
		    
		  Case "cab"
		    Return "application/vnd.ms-cab-compressed"
		    
		  Case "xls", "xlm", "xla", "xlc", "xlt", "xlw"
		    Return "application/vnd.ms-excel"
		    
		  Case "xlam"
		    Return "application/vnd.ms-excel.addin.macroenabled.12"
		    
		  Case "xlsb"
		    Return "application/vnd.ms-excel.sheet.binary.macroenabled.12"
		    
		  Case "xlsm"
		    Return "application/vnd.ms-excel.sheet.macroenabled.12"
		    
		  Case "xltm"
		    Return "application/vnd.ms-excel.template.macroenabled.12"
		    
		  Case "eot"
		    Return "application/vnd.ms-fontobject"
		    
		  Case "chm"
		    Return "application/vnd.ms-htmlhelp"
		    
		  Case "ims"
		    Return "application/vnd.ms-ims"
		    
		  Case "lrm"
		    Return "application/vnd.ms-lrm"
		    
		  Case "thmx"
		    Return "application/vnd.ms-officetheme"
		    
		  Case "cat"
		    Return "application/vnd.ms-pki.seccat"
		    
		  Case "stl"
		    Return "application/vnd.ms-pki.stl"
		    
		  Case "ppt", "pps", "pot"
		    Return "application/vnd.ms-powerpoint"
		    
		  Case "ppam"
		    Return "application/vnd.ms-powerpoint.addin.macroenabled.12"
		    
		  Case "pptm"
		    Return "application/vnd.ms-powerpoint.presentation.macroenabled.12"
		    
		  Case "sldm"
		    Return "application/vnd.ms-powerpoint.slide.macroenabled.12"
		    
		  Case "ppsm"
		    Return "application/vnd.ms-powerpoint.slideshow.macroenabled.12"
		    
		  Case "potm"
		    Return "application/vnd.ms-powerpoint.template.macroenabled.12"
		    
		  Case "mpp", "mpt"
		    Return "application/vnd.ms-project"
		    
		  Case "docm"
		    Return "application/vnd.ms-word.document.macroenabled.12"
		    
		  Case "dotm"
		    Return "application/vnd.ms-word.template.macroenabled.12"
		    
		  Case "wps", "wks", "wcm", "wdb"
		    Return "application/vnd.ms-works"
		    
		  Case "wpl"
		    Return "application/vnd.ms-wpl"
		    
		  Case "xps"
		    Return "application/vnd.ms-xpsdocument"
		    
		  Case "mseq"
		    Return "application/vnd.mseq"
		    
		  Case "mus"
		    Return "application/vnd.musician"
		    
		  Case "msty"
		    Return "application/vnd.muvee.style"
		    
		  Case "nlu"
		    Return "application/vnd.neurolanguage.nlu"
		    
		  Case "nnd"
		    Return "application/vnd.noblenet-directory"
		    
		  Case "nns"
		    Return "application/vnd.noblenet-sealer"
		    
		  Case "nnw"
		    Return "application/vnd.noblenet-web"
		    
		  Case "ngdat"
		    Return "application/vnd.nokia.n-gage.data"
		    
		  Case "n-gage"
		    Return "application/vnd.nokia.n-gage.symbian.install"
		    
		  Case "rpst"
		    Return "application/vnd.nokia.radio-preset"
		    
		  Case "rpss"
		    Return "application/vnd.nokia.radio-presets"
		    
		  Case "edm"
		    Return "application/vnd.novadigm.edm"
		    
		  Case "edx"
		    Return "application/vnd.novadigm.edx"
		    
		  Case "ext"
		    Return "application/vnd.novadigm.ext"
		    
		  Case "odc"
		    Return "application/vnd.oasis.opendocument.chart"
		    
		  Case "otc"
		    Return "application/vnd.oasis.opendocument.chart-template"
		    
		  Case "odb"
		    Return "application/vnd.oasis.opendocument.database"
		    
		  Case "odf"
		    Return "application/vnd.oasis.opendocument.formula"
		    
		  Case "odft"
		    Return "application/vnd.oasis.opendocument.formula-template"
		    
		  Case "odg"
		    Return "application/vnd.oasis.opendocument.graphics"
		    
		  Case "otg"
		    Return "application/vnd.oasis.opendocument.graphics-template"
		    
		  Case "odi"
		    Return "application/vnd.oasis.opendocument.image"
		    
		  Case "oti"
		    Return "application/vnd.oasis.opendocument.image-template"
		    
		  Case "odp"
		    Return "application/vnd.oasis.opendocument.presentation"
		    
		  Case "otp"
		    Return "application/vnd.oasis.opendocument.presentation-template"
		    
		  Case "ods"
		    Return "application/vnd.oasis.opendocument.spreadsheet"
		    
		  Case "ots"
		    Return "application/vnd.oasis.opendocument.spreadsheet-template"
		    
		  Case "odt"
		    Return "application/vnd.oasis.opendocument.text"
		    
		  Case "odm"
		    Return "application/vnd.oasis.opendocument.text-master"
		    
		  Case "ott"
		    Return "application/vnd.oasis.opendocument.text-template"
		    
		  Case "oth"
		    Return "application/vnd.oasis.opendocument.text-web"
		    
		  Case "xo"
		    Return "application/vnd.olpc-sugar"
		    
		  Case "dd2"
		    Return "application/vnd.oma.dd2+xml"
		    
		  Case "oxt"
		    Return "application/vnd.openofficeorg.extension"
		    
		  Case "pptx"
		    Return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
		    
		  Case "sldx"
		    Return "application/vnd.openxmlformats-officedocument.presentationml.slide"
		    
		  Case "ppsx"
		    Return "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
		    
		  Case "potx"
		    Return "application/vnd.openxmlformats-officedocument.presentationml.template"
		    
		  Case "xlsx"
		    Return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
		    
		  Case "xltx"
		    Return "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
		    
		  Case "docx"
		    Return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
		    
		  Case "dotx"
		    Return "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
		    
		  Case "mgp"
		    Return "application/vnd.osgeo.mapguide.package"
		    
		  Case "dp"
		    Return "application/vnd.osgi.dp"
		    
		  Case "pdb", "pqa", "oprc"
		    Return "application/vnd.palm"
		    
		  Case "paw"
		    Return "application/vnd.pawaafile"
		    
		  Case "str"
		    Return "application/vnd.pg.format"
		    
		  Case "ei6"
		    Return "application/vnd.pg.osasli"
		    
		  Case "efif"
		    Return "application/vnd.picsel"
		    
		  Case "wg"
		    Return "application/vnd.pmi.widget"
		    
		  Case "plf"
		    Return "application/vnd.pocketlearn"
		    
		  Case "pbd"
		    Return "application/vnd.powerbuilder6"
		    
		  Case "box"
		    Return "application/vnd.previewsystems.box"
		    
		  Case "mgz"
		    Return "application/vnd.proteus.magazine"
		    
		  Case "qps"
		    Return "application/vnd.publishare-delta-tree"
		    
		  Case "ptid"
		    Return "application/vnd.pvi.ptid1"
		    
		  Case "qxd", "qxt", "qwd", "qwt", "qxl", "qxb"
		    Return "application/vnd.quark.quarkxpress"
		    
		  Case "bed"
		    Return "application/vnd.realvnc.bed"
		    
		  Case "mxl"
		    Return "application/vnd.recordare.musicxml"
		    
		  Case "musicxml"
		    Return "application/vnd.recordare.musicxml+xml"
		    
		  Case "cryptonote"
		    Return "application/vnd.rig.cryptonote"
		    
		  Case "cod"
		    Return "application/vnd.rim.cod"
		    
		  Case "rm"
		    Return "application/vnd.rn-realmedia"
		    
		  Case "link66"
		    Return "application/vnd.route66.link66+xml"
		    
		  Case "st"
		    Return "application/vnd.sailingtracker.track"
		    
		  Case "see"
		    Return "application/vnd.seemail"
		    
		  Case "sema"
		    Return "application/vnd.sema"
		    
		  Case "semd"
		    Return "application/vnd.semd"
		    
		  Case "semf"
		    Return "application/vnd.semf"
		    
		  Case "ifm"
		    Return "application/vnd.shana.informed.formdata"
		    
		  Case "itp"
		    Return "application/vnd.shana.informed.formtemplate"
		    
		  Case "iif"
		    Return "application/vnd.shana.informed.interchange"
		    
		  Case "ipk"
		    Return "application/vnd.shana.informed.package"
		    
		  Case "twd", "twds"
		    Return "application/vnd.simtech-mindmapper"
		    
		  Case "mmf"
		    Return "application/vnd.smaf"
		    
		  Case "teacher"
		    Return "application/vnd.smart.teacher"
		    
		  Case "sdkm", "sdkd"
		    Return "application/vnd.solent.sdkm+xml"
		    
		  Case "dxp"
		    Return "application/vnd.spotfire.dxp"
		    
		  Case "sfs"
		    Return "application/vnd.spotfire.sfs"
		    
		  Case "sdc"
		    Return "application/vnd.stardivision.calc"
		    
		  Case "sda"
		    Return "application/vnd.stardivision.draw"
		    
		  Case "sdd"
		    Return "application/vnd.stardivision.impress"
		    
		  Case "smf"
		    Return "application/vnd.stardivision.math"
		    
		  Case "sdw", "vor"
		    Return "application/vnd.stardivision.writer"
		    
		  Case "sgl"
		    Return "application/vnd.stardivision.writer-global"
		    
		  Case "sm"
		    Return "application/vnd.stepmania.stepchart"
		    
		  Case "sxc"
		    Return "application/vnd.sun.xml.calc"
		    
		  Case "stc"
		    Return "application/vnd.sun.xml.calc.template"
		    
		  Case "sxd"
		    Return "application/vnd.sun.xml.draw"
		    
		  Case "std"
		    Return "application/vnd.sun.xml.draw.template"
		    
		  Case "sxi"
		    Return "application/vnd.sun.xml.impress"
		    
		  Case "sti"
		    Return "application/vnd.sun.xml.impress.template"
		    
		  Case "sxm"
		    Return "application/vnd.sun.xml.math"
		    
		  Case "sxw"
		    Return "application/vnd.sun.xml.writer"
		    
		  Case "sxg"
		    Return "application/vnd.sun.xml.writer.global"
		    
		  Case "stw"
		    Return "application/vnd.sun.xml.writer.template"
		    
		  Case "sus", "susp"
		    Return "application/vnd.sus-calendar"
		    
		  Case "svd"
		    Return "application/vnd.svd"
		    
		  Case "sis", "sisx"
		    Return "application/vnd.symbian.install"
		    
		  Case "xsm"
		    Return "application/vnd.syncml+xml"
		    
		  Case "bdm"
		    Return "application/vnd.syncml.dm+wbxml"
		    
		  Case "xdm"
		    Return "application/vnd.syncml.dm+xml"
		    
		  Case "tao"
		    Return "application/vnd.tao.intent-module-archive"
		    
		  Case "tmo"
		    Return "application/vnd.tmobile-livetv"
		    
		  Case "tpt"
		    Return "application/vnd.trid.tpt"
		    
		  Case "mxs"
		    Return "application/vnd.triscape.mxs"
		    
		  Case "tra"
		    Return "application/vnd.trueapp"
		    
		  Case "ufd", "ufdl"
		    Return "application/vnd.ufdl"
		    
		  Case "utz"
		    Return "application/vnd.uiq.theme"
		    
		  Case "umj"
		    Return "application/vnd.umajin"
		    
		  Case "unityweb"
		    Return "application/vnd.unity"
		    
		  Case "uoml"
		    Return "application/vnd.uoml+xml"
		    
		  Case "vcx"
		    Return "application/vnd.vcx"
		    
		  Case "vsd", "vst", "vss", "vsw"
		    Return "application/vnd.visio"
		    
		  Case "vis"
		    Return "application/vnd.visionary"
		    
		  Case "vsf"
		    Return "application/vnd.vsf"
		    
		  Case "wbxml"
		    Return "application/vnd.wap.wbxml"
		    
		  Case "wmlc"
		    Return "application/vnd.wap.wmlc"
		    
		  Case "wmlsc"
		    Return "application/vnd.wap.wmlscriptc"
		    
		  Case "wtb"
		    Return "application/vnd.webturbo"
		    
		  Case "nbp"
		    Return "application/vnd.wolfram.player"
		    
		  Case "wpd"
		    Return "application/vnd.wordperfect"
		    
		  Case "wqd"
		    Return "application/vnd.wqd"
		    
		  Case "stf"
		    Return "application/vnd.wt.stf"
		    
		  Case "xar"
		    Return "application/vnd.xara"
		    
		  Case "xfdl"
		    Return "application/vnd.xfdl"
		    
		  Case "hvd"
		    Return "application/vnd.yamaha.hv-dic"
		    
		  Case "hvs"
		    Return "application/vnd.yamaha.hv-script"
		    
		  Case "hvp"
		    Return "application/vnd.yamaha.hv-voice"
		    
		  Case "osf"
		    Return "application/vnd.yamaha.openscoreformat"
		    
		  Case "osfpvg"
		    Return "application/vnd.yamaha.openscoreformat.osfpvg+xml"
		    
		  Case "saf"
		    Return "application/vnd.yamaha.smaf-audio"
		    
		  Case "spf"
		    Return "application/vnd.yamaha.smaf-phrase"
		    
		  Case "cmp"
		    Return "application/vnd.yellowriver-custom-menu"
		    
		  Case "zir", "zirz"
		    Return "application/vnd.zul"
		    
		  Case "zaz"
		    Return "application/vnd.zzazz.deck+xml"
		    
		  Case "vxml"
		    Return "application/voicexml+xml"
		    
		  Case "wgt"
		    Return "application/widget"
		    
		  Case "hlp"
		    Return "application/winhlp"
		    
		  Case "wsdl"
		    Return "application/wsdl+xml"
		    
		  Case "wspolicy"
		    Return "application/wspolicy+xml"
		    
		  Case "7z"
		    Return "application/x-7z-compressed"
		    
		  Case "abw"
		    Return "application/x-abiword"
		    
		  Case "ace"
		    Return "application/x-ace-compressed"
		    
		  Case "aab", "x32", "u32", "vox"
		    Return "application/x-authorware-bin"
		    
		  Case "aam"
		    Return "application/x-authorware-map"
		    
		  Case "aas"
		    Return "application/x-authorware-seg"
		    
		  Case "bcpio"
		    Return "application/x-bcpio"
		    
		  Case "torrent"
		    Return "application/x-bittorrent"
		    
		  Case "bz"
		    Return "application/x-bzip"
		    
		  Case "bz2", "boz"
		    Return "application/x-bzip2"
		    
		  Case "vcd"
		    Return "application/x-cdlink"
		    
		  Case "chat"
		    Return "application/x-chat"
		    
		  Case "pgn"
		    Return "application/x-chess-pgn"
		    
		  Case "cpio"
		    Return "application/x-cpio"
		    
		  Case "csh"
		    Return "application/x-csh"
		    
		  Case "deb", "udeb"
		    Return "application/x-debian-package"
		    
		  Case "dir", "dcr", "dxr", "cst", "cct", "cxt", "w3d", "fgd", "swa"
		    Return "application/x-director"
		    
		  Case "wad"
		    Return "application/x-doom"
		    
		  Case "ncx"
		    Return "application/x-dtbncx+xml"
		    
		  Case "dtb"
		    Return "application/x-dtbook+xml"
		    
		  Case "res"
		    Return "application/x-dtbresource+xml"
		    
		  Case "dvi"
		    Return "application/x-dvi"
		    
		  Case "bdf"
		    Return "application/x-font-bdf"
		    
		  Case "gsf"
		    Return "application/x-font-ghostscript"
		    
		  Case "psf"
		    Return "application/x-font-linux-psf"
		    
		  Case "otf"
		    Return "application/x-font-otf"
		    
		  Case "pcf"
		    Return "application/x-font-pcf"
		    
		  Case "snf"
		    Return "application/x-font-snf"
		    
		  Case "ttf", "ttc"
		    Return "application/x-font-ttf"
		    
		  Case "pfa", "pfb", "pfm", "afm"
		    Return "application/x-font-type1"
		    
		  Case "woff"
		    Return "application/x-font-woff"
		    
		  Case "spl"
		    Return "application/x-futuresplash"
		    
		  Case "gnumeric"
		    Return "application/x-gnumeric"
		    
		  Case "gtar"
		    Return "application/x-gtar"
		    
		  Case "hdf"
		    Return "application/x-hdf"
		    
		  Case "jnlp"
		    Return "application/x-java-jnlp-file"
		    
		  Case "latex"
		    Return "application/x-latex"
		    
		  Case "prc", "mobi"
		    Return "application/x-mobipocket-ebook"
		    
		  Case "m3u8"
		    Return "application/x-mpegurl"
		    
		  Case "application"
		    Return "application/x-ms-application"
		    
		  Case "wmd"
		    Return "application/x-ms-wmd"
		    
		  Case "wmz"
		    Return "application/x-ms-wmz"
		    
		  Case "xbap"
		    Return "application/x-ms-xbap"
		    
		  Case "mdb"
		    Return "application/x-msaccess"
		    
		  Case "obd"
		    Return "application/x-msbinder"
		    
		  Case "crd"
		    Return "application/x-mscardfile"
		    
		  Case "clp"
		    Return "application/x-msclip"
		    
		  Case "exe", "dll", "com", "bat", "msi"
		    Return "application/x-msdownload"
		    
		  Case "mvb", "m13", "m14"
		    Return "application/x-msmediaview"
		    
		  Case "wmf"
		    Return "application/x-msmetafile"
		    
		  Case "mny"
		    Return "application/x-msmoney"
		    
		  Case "pub"
		    Return "application/x-mspublisher"
		    
		  Case "scd"
		    Return "application/x-msschedule"
		    
		  Case "trm"
		    Return "application/x-msterminal"
		    
		  Case "wri"
		    Return "application/x-mswrite"
		    
		  Case "nc", "cdf"
		    Return "application/x-netcdf"
		    
		  Case "p12", "pfx"
		    Return "application/x-pkcs12"
		    
		  Case "p7b", "spc"
		    Return "application/x-pkcs7-certificates"
		    
		  Case "p7r"
		    Return "application/x-pkcs7-certreqresp"
		    
		  Case "rar"
		    Return "application/x-rar-compressed"
		    
		  Case "sh"
		    Return "application/x-sh"
		    
		  Case "shar"
		    Return "application/x-shar"
		    
		  Case "swf"
		    Return "application/x-shockwave-flash"
		    
		  Case "xap"
		    Return "application/x-silverlight-app"
		    
		  Case "sit"
		    Return "application/x-stuffit"
		    
		  Case "sitx"
		    Return "application/x-stuffitx"
		    
		  Case "sv4cpio"
		    Return "application/x-sv4cpio"
		    
		  Case "sv4crc"
		    Return "application/x-sv4crc"
		    
		  Case "tar"
		    Return "application/x-tar"
		    
		  Case "tcl"
		    Return "application/x-tcl"
		    
		  Case "tex"
		    Return "application/x-tex"
		    
		  Case "tfm"
		    Return "application/x-tex-tfm"
		    
		  Case "texinfo", "texi"
		    Return "application/x-texinfo"
		    
		  Case "ustar"
		    Return "application/x-ustar"
		    
		  Case "src"
		    Return "application/x-wais-source"
		    
		  Case "der", "crt"
		    Return "application/x-x509-ca-cert"
		    
		  Case "fig"
		    Return "application/x-xfig"
		    
		  Case "xpi"
		    Return "application/x-xpinstall"
		    
		  Case "xdf"
		    Return "application/xcap-diff+xml"
		    
		  Case "xenc"
		    Return "application/xenc+xml"
		    
		  Case "xhtml", "xht"
		    Return "application/xhtml+xml"
		    
		  Case "xml", "xsl"
		    Return "application/xml"
		    
		  Case "dtd"
		    Return "application/xml-dtd"
		    
		  Case "xop"
		    Return "application/xop+xml"
		    
		  Case "xslt"
		    Return "application/xslt+xml"
		    
		  Case "xspf"
		    Return "application/xspf+xml"
		    
		  Case "mxml", "xhvml", "xvml", "xvm"
		    Return "application/xv+xml"
		    
		  Case "yang"
		    Return "application/yang"
		    
		  Case "yin"
		    Return "application/yin+xml"
		    
		  Case "zip"
		    Return "application/zip"
		    
		  Case "adp"
		    Return "audio/adpcm"
		    
		  Case "au", "snd"
		    Return "audio/basic"
		    
		  Case "mid", "midi", "kar", "rmi"
		    Return "audio/midi"
		    
		  Case "mp4a"
		    Return "audio/mp4"
		    
		  Case "m4a", "m4p"
		    Return "audio/mp4a-latm"
		    
		  Case "mpga", "mp2", "mp2a", "mp3", "m2a", "m3a"
		    Return "audio/mpeg"
		    
		  Case "oga", "ogg", "spx"
		    Return "audio/ogg"
		    
		  Case "uva", "uvva"
		    Return "audio/vnd.dece.audio"
		    
		  Case "eol"
		    Return "audio/vnd.digital-winds"
		    
		  Case "dra"
		    Return "audio/vnd.dra"
		    
		  Case "dts"
		    Return "audio/vnd.dts"
		    
		  Case "dtshd"
		    Return "audio/vnd.dts.hd"
		    
		  Case "lvp"
		    Return "audio/vnd.lucent.voice"
		    
		  Case "pya"
		    Return "audio/vnd.ms-playready.media.pya"
		    
		  Case "ecelp4800"
		    Return "audio/vnd.nuera.ecelp4800"
		    
		  Case "ecelp7470"
		    Return "audio/vnd.nuera.ecelp7470"
		    
		  Case "ecelp9600"
		    Return "audio/vnd.nuera.ecelp9600"
		    
		  Case "rip"
		    Return "audio/vnd.rip"
		    
		  Case "weba"
		    Return "audio/webm"
		    
		  Case "aac"
		    Return "audio/x-aac"
		    
		  Case "aif", "aiff", "aifc"
		    Return "audio/x-aiff"
		    
		  Case "m3u"
		    Return "audio/x-mpegurl"
		    
		  Case "wax"
		    Return "audio/x-ms-wax"
		    
		  Case "wma"
		    Return "audio/x-ms-wma"
		    
		  Case "ram", "ra"
		    Return "audio/x-pn-realaudio"
		    
		  Case "rmp"
		    Return "audio/x-pn-realaudio-plugin"
		    
		  Case "wav"
		    Return "audio/x-wav"
		    
		  Case "cdx"
		    Return "chemical/x-cdx"
		    
		  Case "cif"
		    Return "chemical/x-cif"
		    
		  Case "cmdf"
		    Return "chemical/x-cmdf"
		    
		  Case "cml"
		    Return "chemical/x-cml"
		    
		  Case "csml"
		    Return "chemical/x-csml"
		    
		  Case "xyz"
		    Return "chemical/x-xyz"
		    
		  Case "bmp"
		    Return "image/bmp"
		    
		  Case "cgm"
		    Return "image/cgm"
		    
		  Case "g3"
		    Return "image/g3fax"
		    
		  Case "gif"
		    Return "image/gif"
		    
		  Case "ief"
		    Return "image/ief"
		    
		  Case "jp2"
		    Return "image/jp2"
		    
		  Case "jpeg", "jpg", "jpe"
		    Return "image/jpeg"
		    
		  Case "ktx"
		    Return "image/ktx"
		    
		  Case "pict", "pic", "pct"
		    Return "image/pict"
		    
		  Case "png"
		    Return "image/png"
		    
		  Case "btif"
		    Return "image/prs.btif"
		    
		  Case "svg", "svgz"
		    Return "image/svg+xml"
		    
		  Case "tiff", "tif"
		    Return "image/tiff"
		    
		  Case "psd"
		    Return "image/vnd.adobe.photoshop"
		    
		  Case "uvi", "uvvi", "uvg", "uvvg"
		    Return "image/vnd.dece.graphic"
		    
		  Case "sub"
		    Return "image/vnd.dvb.subtitle"
		    
		  Case "djvu", "djv"
		    Return "image/vnd.djvu"
		    
		  Case "dwg"
		    Return "image/vnd.dwg"
		    
		  Case "dxf"
		    Return "image/vnd.dxf"
		    
		  Case "fbs"
		    Return "image/vnd.fastbidsheet"
		    
		  Case "fpx"
		    Return "image/vnd.fpx"
		    
		  Case "fst"
		    Return "image/vnd.fst"
		    
		  Case "mmr"
		    Return "image/vnd.fujixerox.edmics-mmr"
		    
		  Case "rlc"
		    Return "image/vnd.fujixerox.edmics-rlc"
		    
		  Case "mdi"
		    Return "image/vnd.ms-modi"
		    
		  Case "npx"
		    Return "image/vnd.net-fpx"
		    
		  Case "wbmp"
		    Return "image/vnd.wap.wbmp"
		    
		  Case "xif"
		    Return "image/vnd.xiff"
		    
		  Case "webp"
		    Return "image/webp"
		    
		  Case "ras"
		    Return "image/x-cmu-raster"
		    
		  Case "cmx"
		    Return "image/x-cmx"
		    
		  Case "fh", "fhc", "fh4", "fh5", "fh7"
		    Return "image/x-freehand"
		    
		  Case "ico"
		    Return "image/x-icon"
		    
		  Case "pntg", "pnt", "mac"
		    Return "image/x-macpaint"
		    
		  Case "pcx"
		    Return "image/x-pcx"
		    
		  Case "pic", "pct"
		    Return "image/x-pict"
		    
		  Case "pnm"
		    Return "image/x-portable-anymap"
		    
		  Case "pbm"
		    Return "image/x-portable-bitmap"
		    
		  Case "pgm"
		    Return "image/x-portable-graymap"
		    
		  Case "ppm"
		    Return "image/x-portable-pixmap"
		    
		  Case "qtif", "qti"
		    Return "image/x-quicktime"
		    
		  Case "rgb"
		    Return "image/x-rgb"
		    
		  Case "xbm"
		    Return "image/x-xbitmap"
		    
		  Case "xpm"
		    Return "image/x-xpixmap"
		    
		  Case "xwd"
		    Return "image/x-xwindowdump"
		    
		  Case "eml", "mime"
		    Return "message/rfc822"
		    
		  Case "igs", "iges"
		    Return "model/iges"
		    
		  Case "msh", "mesh", "silo"
		    Return "model/mesh"
		    
		  Case "dae"
		    Return "model/vnd.collada+xml"
		    
		  Case "dwf"
		    Return "model/vnd.dwf"
		    
		  Case "gdl"
		    Return "model/vnd.gdl"
		    
		  Case "gtw"
		    Return "model/vnd.gtw"
		    
		  Case "mts"
		    Return "model/vnd.mts"
		    
		  Case "vtu"
		    Return "model/vnd.vtu"
		    
		  Case "wrl", "vrml"
		    Return "model/vrml"
		    
		  Case "manifest"
		    Return "text/cache-manifest"
		    
		  Case "ics", "ifb"
		    Return "text/calendar"
		    
		  Case "css"
		    Return "text/css"
		    
		  Case "csv"
		    Return "text/csv"
		    
		  Case "html", "htm"
		    Return "text/html"
		    
		  Case "n3"
		    Return "text/n3"
		    
		  Case "txt", "text", "conf", "def", "list", "log", "in"
		    Return "text/plain"
		    
		  Case "dsc"
		    Return "text/prs.lines.tag"
		    
		  Case "rtx"
		    Return "text/richtext"
		    
		  Case "sgml", "sgm"
		    Return "text/sgml"
		    
		  Case "tsv"
		    Return "text/tab-separated-values"
		    
		  Case "t", "tr", "roff", "man", "me", "ms"
		    Return "text/troff"
		    
		  Case "ttl"
		    Return "text/turtle"
		    
		  Case "uri", "uris", "urls"
		    Return "text/uri-list"
		    
		  Case "curl"
		    Return "text/vnd.curl"
		    
		  Case "dcurl"
		    Return "text/vnd.curl.dcurl"
		    
		  Case "scurl"
		    Return "text/vnd.curl.scurl"
		    
		  Case "mcurl"
		    Return "text/vnd.curl.mcurl"
		    
		  Case "fly"
		    Return "text/vnd.fly"
		    
		  Case "flx"
		    Return "text/vnd.fmi.flexstor"
		    
		  Case "gv"
		    Return "text/vnd.graphviz"
		    
		  Case "3dml"
		    Return "text/vnd.in3d.3dml"
		    
		  Case "spot"
		    Return "text/vnd.in3d.spot"
		    
		  Case "jad"
		    Return "text/vnd.sun.j2me.app-descriptor"
		    
		  Case "wml"
		    Return "text/vnd.wap.wml"
		    
		  Case "wmls"
		    Return "text/vnd.wap.wmlscript"
		    
		  Case "s", "asm"
		    Return "text/x-asm"
		    
		  Case "c", "cc", "cxx", "cpp", "h", "hh", "dic"
		    Return "text/x-c"
		    
		  Case "f", "for", "f77", "f90"
		    Return "text/x-fortran"
		    
		  Case "p", "pas"
		    Return "text/x-pascal"
		    
		  Case "java"
		    Return "text/x-java-source"
		    
		  Case "etx"
		    Return "text/x-setext"
		    
		  Case "uu"
		    Return "text/x-uuencode"
		    
		  Case "vcs"
		    Return "text/x-vcalendar"
		    
		  Case "vcf"
		    Return "text/x-vcard"
		    
		  Case "3gp"
		    Return "video/3gpp"
		    
		  Case "3g2"
		    Return "video/3gpp2"
		    
		  Case "h261"
		    Return "video/h261"
		    
		  Case "h263"
		    Return "video/h263"
		    
		  Case "h264"
		    Return "video/h264"
		    
		  Case "jpgv"
		    Return "video/jpeg"
		    
		  Case "jpm", "jpgm"
		    Return "video/jpm"
		    
		  Case "mj2", "mjp2"
		    Return "video/mj2"
		    
		  Case "ts"
		    Return "video/mp2t"
		    
		  Case "mp4", "mp4v", "mpg4", "m4v"
		    Return "video/mp4"
		    
		  Case "mpeg", "mpg", "mpe", "m1v", "m2v"
		    Return "video/mpeg"
		    
		  Case "ogv"
		    Return "video/ogg"
		    
		  Case "qt", "mov"
		    Return "video/quicktime"
		    
		  Case "uvh", "uvvh"
		    Return "video/vnd.dece.hd"
		    
		  Case "uvm", "uvvm"
		    Return "video/vnd.dece.mobile"
		    
		  Case "uvp", "uvvp"
		    Return "video/vnd.dece.pd"
		    
		  Case "uvs", "uvvs"
		    Return "video/vnd.dece.sd"
		    
		  Case "uvv", "uvvv"
		    Return "video/vnd.dece.video"
		    
		  Case "fvt"
		    Return "video/vnd.fvt"
		    
		  Case "mxu", "m4u"
		    Return "video/vnd.mpegurl"
		    
		  Case "pyv"
		    Return "video/vnd.ms-playready.media.pyv"
		    
		  Case "uvu", "uvvu"
		    Return "video/vnd.uvvu.mp4"
		    
		  Case "viv"
		    Return "video/vnd.vivo"
		    
		  Case "dv", "dif"
		    Return "video/x-dv"
		    
		  Case "webm"
		    Return "video/webm"
		    
		  Case "f4v"
		    Return "video/x-f4v"
		    
		  Case "fli"
		    Return "video/x-fli"
		    
		  Case "flv"
		    Return "video/x-flv"
		    
		  Case "m4v"
		    Return "video/x-m4v"
		    
		  Case "asf", "asx"
		    Return "video/x-ms-asf"
		    
		  Case "wm"
		    Return "video/x-ms-wm"
		    
		  Case "wmv"
		    Return "video/x-ms-wmv"
		    
		  Case "wmx"
		    Return "video/x-ms-wmx"
		    
		  Case "wvx"
		    Return "video/x-ms-wvx"
		    
		  Case "avi"
		    Return "video/x-msvideo"
		    
		  Case "movie"
		    Return "video/x-sgi-movie"
		    
		  Case "ice"
		    Return "x-conference/x-cooltalk"
		    
		  Else
		    ' This returns the default mime type
		    Return "application/octet-stream"
		    'Return "text/plain"
		    
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPStatusMessage(pStatus As Integer) As String
		  Select Case pStatus
		    
		  Case kStatusNotFound
		    Return "The requested URL could not be found. Please check your request and try again."
		    
		  Case kStatusInternalServerError
		    Return "The requested URL encountered an unhandled exception can cannot continue. Please contact the site's administrator."
		    
		  Else
		    
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function HTTPStatusString(Status As Integer) As String
		  // List of all HTTP status description
		  
		  Select Case Status
		    
		  Case kStatusContinue
		    Return "100 Continue"
		    
		  Case kStatusSwitchingProtocols
		    Return "101 Switching Protocols"
		    
		  Case kStatusOK
		    Return "200 OK"
		    
		  Case kStatusCreated
		    Return "201 Created"
		    
		  Case kStatusAccepted
		    Return "202 Accepted"
		    
		  Case kStatusNonAuthoritativeInformation
		    Return "203 Non-Authoritative Information"
		    
		  Case kStatusNoContent
		    Return "204 No Content"
		    
		  Case kStatusResetContent
		    Return "205 Reset Content"
		    
		  Case kStatusPartialContent
		    Return "206 Partial Content"
		    
		    
		  Case kStatusMultipleChoices
		    Return "300 Multiple Choices"
		    
		  Case kStatusMovedPermanently
		    Return "301 Moved Permanently"
		    
		  Case kStatusFound
		    Return "302 Found"
		    
		  Case kStatusSeeOther
		    Return "303 See Other"
		    
		  Case kStatusNotModified
		    Return "304 Not Modified"
		    
		  Case kStatusUseProxy
		    Return "305 Use Proxy"
		    
		  Case kStatusTemporaryRedirect
		    Return "307 Temporary Redirect"
		    
		    
		  Case kStatusBadRequest
		    Return "400 Bad Request"
		    
		  Case kStatusUnauthorized
		    Return "401 Unauthorized"
		    
		  Case kStatusPaymentRequired
		    Return "402 Payment Required"
		    
		  Case kStatusForbidden
		    Return "403 Forbidden"
		    
		  Case kStatusNotFound
		    Return "404 Not Found"
		    
		  Case kStatusMethodNotAllowed
		    Return "405 Method Not Allowed"
		    
		  Case kStatusNotAcceptable
		    Return "406 Not Acceptable"
		    
		  Case kStatusProxyAuthenticationRequired
		    Return "407 Proxy Authentication Required"
		    
		  Case kStatusRequestTimeout
		    Return "408 Request Timeout"
		    
		  Case kStatusConflict
		    Return "409 Conflict"
		    
		  Case kStatusGone
		    Return "410 Gone"
		    
		  Case kStatusLengthRequired
		    Return "411 Length Required"
		    
		  Case kStatusPreconditionFailed
		    Return "412 Precondition Failed"
		    
		  Case kStatusRequestEntityTooLarge
		    Return "413 Request Entity Too Large"
		    
		  Case kStatusRequestURITooLong
		    Return "414 Request-URI Too Long"
		    
		  Case kStatusUnsupportedMediaType
		    Return "415 Unsupported Media Type"
		    
		  Case kStatusRequestedRangeNotSatisfiable
		    Return "416 Requested Range Not Satisfiable"
		    
		  Case kStatusExpectationFailed
		    Return "417 Expectation Failed"
		    
		  Case kStatusImATeapot
		    Return "418 I'm a teapot"
		    
		    
		  Case kStatusInternalServerError
		    Return "500 Internal Server Error"
		    
		  Case kStatusNotImplemented
		    Return "501 Not Implemented"
		    
		  Case kStatusBadGateway
		    Return "502 Bad Gateway"
		    
		  Case kStatusServiceUnavailable
		    Return "503 Service Unavailable"
		    
		  Case kStatusGatewayTimeout
		    Return "504 Gateway Timeout"
		    
		  Case kStatusHTTPVersionNotSupported
		    Return "505 HTTP Version Not Supported"
		    
		  Case kStatusBandwidthLimitExceeded
		    Return "509 Bandwidth Limit Exceeded"
		    
		  End Select
		  
		  Return Str(Status) + " N/A"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function InStrReverse(startPos As Integer = - 1, source As String, substr As String) As Integer
		  // Similar to InStr, but searches backwards from the given position
		  // (or if startPos = -1, then from the end of the string).
		  // If substr can't be found, returns 0.
		  
		  Dim srcLen As Integer = source.Len
		  If startPos = -1 Then startPos = srcLen
		  
		  // Here's an easy way...
		  // There may be a faster implementation, but then again, there may not -- it probably
		  // depends on the particulars of the data.
		  Dim reversedSource As String = Reverse(source)
		  Dim reversedSubstr As String = Reverse(substr)
		  Dim reversedPos As Integer
		  reversedPos = InStr( srcLen - startPos + 1, reversedSource, reversedSubstr )
		  If reversedPos < 1 Then Return 0
		  Return srcLen - reversedPos - substr.Len + 2
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function LTrim(source As String, charsToTrim As String) As String
		  // This is an extended version of RB's LTrim function that lets you specify
		  // a set of characters to trim.
		  
		  Dim srcLen As Integer = source.Len
		  Dim leftPos, i As Integer
		  for i = 1 to srcLen
		    if InStr( charsToTrim, Mid(source, i, 1) ) = 0 then exit
		  next
		  leftPos = i
		  if leftPos > srcLen then return ""
		  
		  return Mid( source, leftPos )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function PadLeft(s as String, width as Integer, padding as String = " ") As String
		  // Pad a string to at least 'width' characters, by adding padding characters
		  // to the left side of the string.
		  
		  Dim length As Integer
		  length = Len(s)
		  If length >= width Then Return s
		  
		  Dim mostToRepeat As Integer
		  mostToRepeat = Ceil((width-length)/Len(padding))
		  Return Mid(Repeat(padding, mostToRepeat),1,width-length) + s
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function PadRight(s as String, width as Integer, padding as String = " ") As String
		  // Pad a string to at least 'width' characters, by adding padding characters
		  // to the right side of the string.
		  
		  Dim length As Integer
		  length = Len(s)
		  If length >= width Then Return s
		  
		  Dim mostToRepeat As Integer
		  mostToRepeat = Ceil((width-length)/Len(padding))
		  Return s + Mid(Repeat(padding, mostToRepeat),1,width-length)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Repeat(s as String, repeatCount as Integer) As String
		  // Concatenate a string to itself 'repeatCount' times.
		  // Example: Repeat("spam ", 5) = "spam spam spam spam spam ".
		  
		  #pragma disablebackgroundTasks
		  
		  If repeatCount <= 0 Then Return ""
		  If repeatCount = 1 Then Return s
		  
		  // Implementation note: normally, you don't want to use string concatenation
		  // for something like this, since that creates a new string on each operation.
		  // But in this case, we can double the size of the string on iteration, which
		  // quickly reduces the overhead of concatenation to insignificance.  This method
		  // is faster than any other we've found (short of declares, which were only
		  // about 2X faster and were quite platform-specific).
		  
		  Dim desiredLenB As Integer = LenB(s) * repeatCount
		  Dim output As String = s
		  Dim cutoff As Integer = (desiredLenB+1)\2
		  Dim curLenB As Integer = LenB(output)
		  
		  While curLenB < cutoff
		    output = output + output
		    curLenB = curLenB + curLenB
		  Wend
		  
		  output = output + LeftB(output, desiredLenB - curLenB)
		  Return output
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Reverse(s As String) As String
		  // Return s with the characters in reverse order.
		  
		  if Len(s) < 2 then return s
		  
		  Dim characters() as String = Split( s, "" )
		  Dim leftIndex as Integer = 0
		  Dim rightIndex as Integer = UBound(characters)
		  #pragma BackgroundTasks False
		  While leftIndex < rightIndex
		    Dim temp as String = characters(leftIndex)
		    characters(leftIndex) = characters(rightIndex)
		    characters(rightIndex) = temp
		    leftIndex = leftIndex + 1
		    rightIndex = rightIndex - 1
		  Wend
		  Return Join( characters, "" )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function RTrim(source As String, charsToTrim As String) As String
		  // This is an extended version of RB's RTrim function that lets you specify
		  // a set of characters to trim.
		  
		  Dim srcLen As Integer = source.Len
		  Dim rightPos, i As Integer
		  for i = srcLen DownTo 1
		    if InStr( charsToTrim, Mid(source, i, 1) ) = 0 then exit
		  next
		  rightPos = i
		  
		  return Mid( source, 1, rightPos )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Trim(source As String, charsToTrim As String) As String
		  // This is an extended version of RB's Trim function that lets you specify
		  // a set of characters to trim.
		  
		  Dim srcLen As Integer = source.Len
		  Dim leftPos, i As Integer
		  For i = 1 To srcLen
		    If InStr( charsToTrim, Mid(source, i, 1) ) = 0 Then Exit
		  Next
		  leftPos = i
		  If leftPos > srcLen Then Return ""
		  
		  Dim rightPos As Integer
		  For i = srcLen DownTo 1
		    If InStr( charsToTrim, Mid(source, i, 1) ) = 0 Then Exit
		  Next
		  rightPos = i
		  
		  Return Mid( source, leftPos, rightPos - leftPos + 1 )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ZeroPad(Num As Integer, Length As Integer = 2) As String
		  Dim i As Integer
		  Dim s As String
		  For i = 1 To length
		    s = s + "0"
		  Next
		  Return Left(s,Len(s) - Len(Str(num))) + Str(num)
		End Function
	#tag EndMethod


	#tag Note, Name = Icon Licence
		
		Public Domain Icons
		
		     These icons were originally made for Mosaic for X and have been
		     included in the NCSA httpd and Apache server distributions in the
		     past. They are in the public domain and may be freely included in any
		     application. The originals were done by Kevin Hughes 
		     (kevinh@kevcom.com).
		
		     Many thanks to Andy Polyakov for tuning the icon colors and adding a
		     few new images. If you'd like to contribute additions or ideas to
		     this set, please let me know.
		
		     Almost all of these icons are 20x22 pixels in size.  There are
		     alternative icons in the "small" directory that are 16x16 in size,
		     provided by Mike Brown (mike@hyperreal.org).
		
		     **** 10-10-2004 Update ****
		     This update is a drop in to substitute a more modern set of icons
		     based upon the original icons.  This set is not complete, however,
		     does cover the most used icons.  Design completed by Matt Comeione
		     and are also left in the public domain.  The full set is included,
		     however, the small set has not been altered.
		     **** 10-10-2004 Update ****
		
		Suggested Uses
		
		The following are a few suggestions, to serve as a starting point for ideas.
		Please feel free to tweak and rename the icons as you like.
		
		     a.gif
		          This might be used to represent PostScript or text layout
		          languages.
		
		     alert.black.gif, alert.red.gif
		          These can be used to highlight any important items, such as a
		          README file in a directory.
		
		     back.gif, forward.gif
		          These can be used as links to go to previous and next areas.
		
		     ball.gray.gif, ball.red.gif
		          These might be used as bullets.
		
		     binary.gif
		          This can be used to represent binary files.
		
		     binhex.gif
		          This can represent BinHex-encoded data.
		
		     blank.gif
		          This can be used as a placeholder or a spacing element.
		
		     bomb.gif
		          This can be used to repreesnt core files.
		
		     box1.gif, box2.gif
		          These icons can be used to represent generic 3D applications and
		          related files.
		
		     broken.gif
		          This can represent corrupted data.
		
		     burst.gif
		          This can call attention to new and important items.
		
		     c.gif
		          This might represent C source code.
		
		     comp.blue.gif, comp.red.gif
		          These little computer icons can stand for telnet or FTP
		          sessions.
		
		     compressed.gif
		          This may represent compressed data.
		
		     continued.gif
		          This can be a link to a continued listing of a directory.
		
		     down.gif, up.gif, left.gif, right.gif
		          These can be used to scroll up, down, left and right in a
		          listing or may be used to denote items in an outline.
		
		     dvi.gif
		          This can represent DVI files.
		
		     f.gif
		          This might represent FORTRAN or Forth source code.
		
		     folder.gif, folder.open.gif, folder.sec.gif
		          The folder can represent directories. There is also a version
		          that can represent secure directories or directories that cannot
		          be viewed.
		
		     generic.gif, generic.sec.gif, generic.red.gif
		          These can represent generic files, secure files, and important
		          files, respectively.
		
		     hand.right.gif, hand.up.gif
		          These can point out important items (pun intended).
		
		     image1.gif, image2.gif, image3.gif
		          These can represent image formats of various types.
		
		     index.gif
		          This might represent a WAIS index or search facility.
		
		     layout.gif
		          This might represent files and formats that contain graphics as
		          well as text layout, such as HTML and PDF files.
		
		     link.gif
		          This might represent files that are symbolic links.
		
		     movie.gif
		          This can represent various movie formats.
		
		     p.gif
		          This may stand for Perl or Python source code.
		
		     pie0.gif ... pie8.gif
		          These icons can be used in applications where a list of
		          documents is returned from a search. The little pie chart images
		          can denote how relevant the documents may be to your search
		          query.
		
		     patch.gif
		          This may stand for patches and diff files.
		
		     portal.gif
		          This might be a link to an online service or a 3D world.
		
		     ps.gif, quill.gif
		          These may represent PostScript files.
		
		     screw1.gif, screw2.gif
		          These may represent CAD or engineering data and formats.
		
		     script.gif
		          This can represent any of various interpreted languages, such as
		          Perl, python, TCL, and shell scripts, as well as server
		          configuration files.
		
		     sound1.gif, sound2.gif
		          These can represent sound files.
		
		     sphere1.gif, sphere2.gif
		          These can represent 3D worlds or rendering applications and
		          formats.
		
		     tex.gif
		          This can represent TeX files.
		
		     text.gif
		          This can represent generic (plain) text files.
		
		     transfer.gif
		          This can represent FTP transfers or uploads/downloads.
		
		     unknown.gif
		          This may represent a file of an unknown type.
		
		     uuencoded.gif
		          This can stand for uuencoded data.
		
		     world1.gif, world2.gif
		          These can represent 3D worlds or other 3D formats.
	#tag EndNote


	#tag Constant, Name = kDefaultPort, Type = Double, Dynamic = False, Default = \"80", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderAccept, Type = String, Dynamic = False, Default = \"Accept", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderAcceptCharset, Type = String, Dynamic = False, Default = \"Accept-Charset", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderAcceptEncoding, Type = String, Dynamic = False, Default = \"Accept-Encoding", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderAcceptLanguage, Type = String, Dynamic = False, Default = \"Accept-Language", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderAcceptRanges, Type = String, Dynamic = False, Default = \"Accept-Ranges", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderAge, Type = String, Dynamic = False, Default = \"Age", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderAllow, Type = String, Dynamic = False, Default = \"Allow", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderAuthorization, Type = String, Dynamic = False, Default = \"Authorization", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderCacheControl, Type = String, Dynamic = False, Default = \"Cache-Control", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderConnection, Type = String, Dynamic = False, Default = \"Connection", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderContentEncoding, Type = String, Dynamic = False, Default = \"Content-Encoding", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderContentLanguage, Type = String, Dynamic = False, Default = \"Content-Language", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderContentLength, Type = String, Dynamic = False, Default = \"Content-Length", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderContentLocation, Type = String, Dynamic = False, Default = \"Content-Location", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderContentMD5, Type = String, Dynamic = False, Default = \"Content-MD5", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderContentRange, Type = String, Dynamic = False, Default = \"Content-Range", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderContentType, Type = String, Dynamic = False, Default = \"Content-Type", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderCookie, Type = String, Dynamic = False, Default = \"Cookie", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderDate, Type = String, Dynamic = False, Default = \"Date", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderETag, Type = String, Dynamic = False, Default = \"ETag", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderExpect, Type = String, Dynamic = False, Default = \"Expect", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderExpires, Type = String, Dynamic = False, Default = \"Expires", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderFrom, Type = String, Dynamic = False, Default = \"From", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderHost, Type = String, Dynamic = False, Default = \"Host", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderIfMatch, Type = String, Dynamic = False, Default = \"If-Match", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderIfModifiedSince, Type = String, Dynamic = False, Default = \"If-Modified-Since", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderIfNoneMatch, Type = String, Dynamic = False, Default = \"If-None-Match", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderIfRange, Type = String, Dynamic = False, Default = \"If-Range", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderIfUnmodifiedSince, Type = String, Dynamic = False, Default = \"If-Unmodified-Since", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderLastModified, Type = String, Dynamic = False, Default = \"Last-Modified", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderLocation, Type = String, Dynamic = False, Default = \"Location", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderMaxForwards, Type = String, Dynamic = False, Default = \"Max-Forwards", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderPragma, Type = String, Dynamic = False, Default = \"Pragma", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderProxyAuthenticate, Type = String, Dynamic = False, Default = \"Proxy-Authenticate", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderProxyAuthorization, Type = String, Dynamic = False, Default = \"Proxy-Authorization", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderRange, Type = String, Dynamic = False, Default = \"Range", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderReferer, Type = String, Dynamic = False, Default = \"Referer", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderRetryAfter, Type = String, Dynamic = False, Default = \"Retry-After", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderServer, Type = String, Dynamic = False, Default = \"Server", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderSetCookie, Type = String, Dynamic = False, Default = \"Set-Cookie", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderTE, Type = String, Dynamic = False, Default = \"TE", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderTrailer, Type = String, Dynamic = False, Default = \"Trailer", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderTransferEncoding, Type = String, Dynamic = False, Default = \"Transfer-Encoding", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderUpgrade, Type = String, Dynamic = False, Default = \"Upgrade", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderUserAgent, Type = String, Dynamic = False, Default = \"User-Agent", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderVary, Type = String, Dynamic = False, Default = \"Vary", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderVia, Type = String, Dynamic = False, Default = \"Via", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderWarning, Type = String, Dynamic = False, Default = \"Warning", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kHeaderWWWAuthenticate, Type = String, Dynamic = False, Default = \"WWW-Authenticate", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Back, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAOYAABkLC7y8vHFxccwAAJkAAEVBQfVBQWYAAKejo97e3pkzM4yMjDUfH9MzM6hzc2EoKGZmZkIDA7YAANbW1uVR\rUebm5tcbG5ZQULUfH+94eMzMzE9PT5mZmfYoKP9aWrW1tTswMDgWFndra40AALoPD+F3dykcHI59fe/v73g4ON8LC+kjI8hJSZWP\rj4IAACMPD/g4OGNBQeNKSug8PGBTU00kJPBtbcXFxaeMjK2trXwBAZlmZrNERK4AADMAAIN8fP9UVMEJCU47O14AAJ50dMcYGI1h\rYfIpKfIaGv5LS+AREU4/P/8zM80MDFdXV3IAAPRMTOUwMLR0dFEBAYg2NnRTU/9mZnt7e/QkJKQAAP1CQjsrK/V1dVEsLFUxMZmZ\rmYeHh/9mZqkFBWYzM7IqKsQQEIyGhmFNTVJMTCgPD8AAANsXF0I1NSEICHxtbekLC/89PekODvE6OkpCQllQUK6KisMICNQMDP//\r/wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUAHgALAAAAAAUABYAAAf/gHiCg4SFhoYcHDcVjCiHhhMFMWgtEwkVjo+CKBpVZA9L\rOZaZjygJH0IrGF4tGgmkhxUTZilYJC+tr5oVCRo0DUhiDAgTFZqmGhwXRyoHaDfFhZcovBofRjBKEiEIroOcdAsJCRMaOQ4GSgNT\rEDcJghU3O1RXN/Y5OCVQa2o6bB8T8FT4cIKCAici3LiRksEKFAsSXGz5oKFCgDpcgBjgwUIGEA8gZ5TpcQBEDg0IiNiwAkQLnJcv\r5UQpIoZABAgUz8zQkkRLh58dVlgoQyLLiCcvFgSY0GIMkw5I4qi4cydIjywERgwBACGHuwk/ulh4M0CChKsEXAzxYUIAgqXVRH7U\rsKMDwIu7ANKAgMAhRwBX1BLcuAJgyoYFYBZwQIDALzRdAifcAJPGSY4cHwLY02AJE6FqiW5o4Dyu0aHAli55PhQIADs\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Binary, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAMQAAExMTNbW1rW1tZmZmf///2ZmZszMzO/v76WlpWZmZnp6er29vebm5ltbW62trYWFhff398XFxd3d3XNzc1BQ\rUIyMjP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUABYALAAAAAAUABYAAAXzoLAsQumcyIAIAWO970LMNAEdgeoY\rLiwfCgOh0FAwcioEDyYgDAAGgYLQiOQiyaWlOTQMBkOB17BAIByBl2NWiE4bBu/3i4i41t0DcXCMCE4DEwt3NTQ3RwZ+DoKEQ0UE\rQBEHDBIBfowWa1JUOQAREDcSURN2mU5gbV00RwukB6abDQyqM0cCrqZ6DWC0BLa4eIWFDKOSuUGOUzMQxLfGa09unMvNuAhschAF\rn6ERi8bXQxEIRhQ8lFEI268IoA1iDRQPcYl/A+sWAweViSQlJWYGPIDzakCFBw8UTFjIcEKBhw0KSHghKoLFixgvGpDwykIIADs\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Compressed, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAOYAAGYAAMzMzKWlpXJycrQpKWZmZpmZmd7e3p8bG+1BQbu2tq9zc7Q+Pm02Nubm5rW1tcwzM34SEsVKStbW1qsr\rK8mIiH19ffJRUe/v78deXsTExKysrMyGhokfH2ZmZn4HB+I1NYWFhbqHh4RbW7ExMeZcXIwXF/1aWpkmJsyZmbhWVrGmpq03N729\rvYN0dNNAQO9KSrVNTetbW78jI4yMjIMWFpmZma0xMZkiItR/f+U7O5gPD7Krq4gnJ3MAAIUMDPZWVr9ISL8uLvRERIYREc5HR8uP\rj8mAgKYpKf///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUAEkALAAAAAAUABYAAAf/gEmCBxsPGwIBDoKLjIwTGxgBBgItBxiNmBMCDgcGkwqW\rmI6bEwYanweii6UHkgEtApSKqqylnp4CE6pJkgcTrwoKGwMal40SDqcHvr8aLQMtDjnGSRg3QQo0y9uv0EY4Bw6XDiwkJCEBE+EO\rE89GMSYB4UkHLEAEFAryGBjtCypFPmiYoOjAjRMwCCBYoa5VhQwlIPh4sG/CwSEgdvzgoY5DDBkXJG7QYMkiEB0zPkTgOOEIgxcJ\rJAoY2O/GBQI+esycMEGDCBJChPjYieEAEhIfGgiguCzAhhEoiPgYaekAjg4uBjwY6MBBgAcFDNTw0WIfOQUCiMnr+rXASBTpMRRh\rYPfAQjqeATRsKFBJnThBczXYfWVIgIECAeb+dRTCgoUBAwpIHpBqFzOemCs3CgQAOw\x3D\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_CSS, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAMQAAFxcXNbW1om2tn2np5mZmcz/Zv///3p6eszMzMxmZu/v7729vbW1tWaZmebm5q2traWlpZnMzHNzc2ZmZoWF\rhff3993d3cTExJjExIyMjGZmZo28vKXR0f///wAAAAAAACH5BAUUAB0ALAAAAAAUABYAAAXcILMsTPmcEAExgdO972LMtFEpgfog\rLizXM4Ujp4LwYIzZg4EiDAmX4rGTNDAKBQ4mY0EQEAsI5BF4PZRZjIDi8BLequPZ8NBuBofhZXEiSBYucxBqAw0SQgEIew9/gTME\rGRQHEhI3DhYBFwyNHXNAMxU3XZsXjgZwqHBDCxIICp2fn6utr3OpqbOusLE1bZu6cwkJp7e+tLu8NsbAM8LEqRYXjLoQNqEKQg7a\rl2AQE9TXlwGJCOWLBN+vBAqYiiMlJikUALqQFJKU+ZQT/AATFi+6lBtIsKCFVx1CAAA7", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Folder, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAOYAAFw+H/HDlMOkhbaSbZh6W8LCwqKioubm5n9lS5mZmf/evf/Tpt+zhr29vbGLZL2betfX17e3t3JMJ6CAYO/K\rpue6jfnWssWyoKV5TNesgZdrP7+UaWdEIv/Mmc6lfO/v797e3uG1iXxTKr+Zc4R6b6N2SszMzLKLZPXFla2DWo1xVf/Wre3Ak//b\rttW0lKurq//hw/jLn/3RpZRzUltDLMOZbrWPaal+UdG1mYRYLOXCnfXIm8mrjKuHY7SUc9uwheW4jK+Macaed6h8UWNCIf/ZtLyW\rcWtIJOy9jsSddqWEY3NSKf/jx5p7XLqPY5VvSMWljIBmTPHPrNa1nPLHnP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUAFUALAAAAAAUABYAAAf/gFWCg4SFhoeIiB+Li4mDHwcgIBCUkgcHH4cHOEY2Dik3\roUYmECCXjYI4PFJFRSsrCxUlPQ0FpKWXVQMUKzK+MTssNU9GAycpGEMXpiM6VCwsQCE/Hj48LgquVBsaJiAPUA8PAzblIwIuFq4y\rAT85ESYPTPMK9fbZvTtAHiIvBUYwAipo0aogrB0VMiQRYaDAAHstWryauCAGkgxCBkhI0MDGQImwFoisGICBhxFBNjZwEPHVrxgw\rUSTM2ENlClf5UKCAhgSJSZRKjnBMAQsYiwohpv3I4CGjkiYcOA6RESNABQZMPTQVUqxHExVEOJZ4FoJpkhFG0g4I8lQFAgANQDE4\rYTpibZAeeJVMIKAiCg0a/i5oyCFChITDRxIn5sABAA0S8ECYiPDCQILLmDMbeBE5kokCBRqIHk0atLcDgQAAOw\x3D\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Font, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAPeGAP////v7+/39/fHx8a+vr+7u7vX19fj4+O/v7/b29vn5+f7+/vr6+vDw8PT09KioqPPz8/z8/Pf39+3t7fLy\r8qmpqaqqqq6urkNDQ7YoKOzs7EJCQqCgoOrq6qenp6Ojo7CwsKGhoaGhoKGgoLa2tunp6VtbW+fn562trT09PYQTE6CgoZ6fnrYp\rKaCfn89dXY0VFdVjYxISEo5hYVJSUqampZiGhqysrHp8fObm5oKDg5+gn46Ojt2FhbAnJ/Pw8KkhIcVYWLskJOGJiaurqxsbGxMT\rExAUFFBQUKemp4gUFNONjZQ1Ne3HxxATE5MXF+Xl5e6ZmfPp6aOhoOa3t1hYWI+SkvDq6ujo6EpKSo2QkCEhIaKiobUoKNiAgKSk\ro6GioRkcHJ+foKipqY8yMk9PT6GgnxMWFiIiIpA0NBcXF6ampqOhoZoZGd2EhMJYWNJgYNOBgaWlpN2Dg7cuLogrK52dnePj4ycn\rJ1VVVbxfX2JiYstxcblGRstaWtyCguTk5KMdHchZWYIqKuvr66WkpQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH/C1hNUCBEYXRhWE1QPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0w\rTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUg\rWE1QIENvcmUgNS4wLWMwNjAgNjEuMTM0Nzc3LCAyMDEwLzAyLzEyLTE3OjMyOjAwICAgICAgICAiPiA8cmRmOlJERiB4bWxuczpy\rZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjItcmRmLXN5bnRheC1ucyMiPiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91\rdD0iIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUu\rY29tL3hhcC8xLjAvbW0vIiB4bWxuczpzdFJlZj0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlUmVm\rIyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IFdpbmRvd3MiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6\rQkU3NzA4Q0EwOEExMTFFMUFENDY4QzgxQTI5RTI4MjciIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QkU3NzA4Q0IwOEExMTFF\rMUFENDY4QzgxQTI5RTI4MjciPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpCRTc3MDhDODA4\rQTExMUUxQUQ0NjhDODFBMjlFMjgyNyIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpCRTc3MDhDOTA4QTExMUUxQUQ0NjhDODFB\rMjlFMjgyNyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgH/\r/v38+/r5+Pf29fTz8vHw7+7t7Ovq6ejn5uXk4+Lh4N/e3dzb2tnY19bV1NPS0dDPzs3My8rJyMfGxcTDwsHAv769vLu6ubi3trW0\rs7KxsK+urayrqqmop6alpKOioaCfnp2cm5qZmJeWlZSTkpGQj46NjIuKiYiHhoWEg4KBgH9+fXx7enl4d3Z1dHNycXBvbm1sa2pp\raGdmZWRjYmFgX15dXFtaWVhXVlVUU1JRUE9OTUxLSklIR0ZFRENCQUA/Pj08Ozo5ODc2NTQzMjEwLy4tLCsqKSgnJiUkIyIhIB8e\rHRwbGhkYFxYVFBMSERAPDg0MCwoJCAcGBQQDAgEAACH5BAEAAIYALAAAAAAUABYAAAj/AA2BIEDgAkGCFwwWPAgChCFDBBYoYMAg\rQAQBCzJGYHDAAAUGFx5eABDAIkYAKFEuEMBAAgAUD1EAODCx5EUBKgUEUADgxkMiADAIFbqh6IacAQBYeGgBQAoSDkzg4eGARAqc\rKHGOeVgBgJ0EB0xssVKSgwCsKB88fADAQIIEVcLYqGgyI0oPawE4cJvnDJMMgDN0ydCCDoAaeSE4cEDDSZooB4b4iBGgiRAAch56\rEDBgAAUkR2ZISdADCJyJVAB8WRuhQecyRrTsdRPoBU0GALisDYDAdRYZOhTPaePnAE0AU3YjKLGniBo0OBz8eSIogQSeYrgyKFCg\rd2cKELzAegjy9gAADlwVTOju3XMcJW/cunTB9ICG9d1dD+Cjos8PtwDswJQEGtzHXW9LkFHHIHpcYQAALKSHX2+ugaeYAQa4JIKE\rBzZQIQQXZgjAhoZYgMAdgECRwwknYFFCBzASct8BITD1QAUeJLFGIR/0OAIYI5jBxgohoBcQADs\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_HTML, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAMQAAFxcXNbW1om2tn2np5mZmcz/Zv///3p6eszMzMxmZu/v7729vbW1tWaZmebm5q2traWlpZnMzHNzc2ZmZoWF\rhff3993d3cTExJjExIyMjGZmZo28vKXR0f///wAAAAAAACH5BAUUAB0ALAAAAAAUABYAAAXcILMsTPmcEAExgdO972LMtFEpgfog\rLizXM4Ujp4LwYIzZg4EiDAmX4rGTNDAKBQ4mY0EQEAsI5BF4PZRZjIDi8BLequPZ8NBuBofhZXEiSBYucxBqAw0SQgEIew9/gTME\rGRQHEhI3DhYBFwyNHXNAMxU3XZsXjgZwqHBDCxIICp2fn6utr3OpqbOusLE1bZu6cwkJp7e+tLu8NsbAM8LEqRYXjLoQNqEKQg7a\rl2AQE9TXlwGJCOWLBN+vBAqYiiMlJikUALqQFJKU+ZQT/AATFi+6lBtIsKCFVx1CAAA7", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Image, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAOYAAAB0J6u+sr4mJoWFha2trQBrjlpaWubm5jOKUHt7eyaoUfpGRhSUvtbW1p+ypff391NTU1G53PcxMQecOWZm\rZsTExIygkuUxMTClzQZ8pACLL0ehZYOhrL5JQv9aWnJycrW1tW6LWxiYQu/v73+pt93d3Uqz1oyMjP///8zMzNYrKzKLbDGtWgBx\rlgCZM/pCQhSJsJK2wxqjSGZmZpmZmaWlpb29vf9mZiOSt/9RUZmZmQCCK1SvbO47OwB1nPY5Oc4pKeEuLjqwYT2lyAyBqIypswCZ\rM/w6Ou0zMwB9KpCjlhagRCOXvgR4nimtUv9NTR+lTP5FRTaMU8lLRHCKWt4pKROMtVKrcD2nygiErf///wAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUAFoALAAAAAAUABYAAAf/gCA2NiCFBIc1NDUgDQdaj482KCgPlZUjIw2KBCmOkCCW\rmJgHJSk0ijWdnw8jpCWvDSkVNDaoqloEIze7Hk8vP4MnFTY1NQQNjzUHvDlRPUiHJ6enNRWONSUeHlFHP0EqqMWJHzbXJTk5RxIX\rQALSh4bk5k8LSEhTISwKG0qFIATytGB70UNFBx5CFEBZIsJCoRoUygks8YMdFSEyJmjUgIAACYjWBB5oQEzfBBcodwDgwIRGxGut\rUoBQeNKFBgArsFg5YQCEIwKsSlS4smSCBg1JVpjAkSFBzxK4Ko0MIEKDyhURMBDx8QECAagEJj0Y6UAKThMYGDRp0fUrLrExVUEU\rGYKDSJMCBdpCrQH3QIoYTGBk8NGiAFuve6WWaFABRKITAxJI7upTC40Ri1MQIvB4QOQEXUPSgBz5g2kKqCkYWA2BQoMRWkpVmE17\r2KDbFRo9CgQAOw\x3D\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Movie, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAMQAAFRUVMTExK6urmZmZtbW1ubm5mZmZnt7e729vczMzN7e3lpaWu7u7oSEhLW1tXNzc4yMjP///wAAAAAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUABEALAAAAAAUABYAAAXQ4NGMx2Oe6DMoRXQQSTMsdL0MDxIM\rhMIcpYfDgdAFAkXTLEEoDJALYiDBpO6Gi0DziQAQmT0CbIDVFlQ0Xa/AKCgI6AViW5QnWIxIWzFAOABzTlBqeG4EfV1mQUIIYG8w\rBzNZdA4NiycDmQICgJQyNjYDm50FQCqbRDpFDnGBfQ4LAg5HVUeinK5IXo1ijwlkf2atWoVvcWaIdnh6bq+kyYRshs6BpoyOYgkl\rAwDCSJcomUPdW0qgNQAAmQBMhglIRUfyRTpMPoYwVFT5+r0tIQA7", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Music, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAMQAACEhIczMzJmZmXd3d1lZWd7e3kFBQb29vbW1tebm5oyMjDMzM9bW1qOjo+/v72ZmZoWFhVNTU8XFxZmZma2t\rrSgoKHx8fElJSf///wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUABgALAAAAAAUABYAAAXgICaOJOmcTqmKTlIEQlQkK+sylDIQ\rSzCvroNAoYDsFgcGrcRoKARDC8FQWSB8JccDKoDwAICFFUtKPBSPyKJKEDTGhVIhXY0oGg0KYiFRmuZneHoHBxI9PyMtDxKEhQGP\rAQsMiCNmkAGTDJqSlCJmmpMFLweRPks2D6GiChYPPH2nLXOqEEQWF3CeDKQPmAUMDxBpYldxCayui5gMERG4YcUOtawXD6SaFmsV\rBBRJCWbCag9XmRIKCAikBS3Nz+Omv5CTNAnZFdvdSiffogkpGC7MoVP3j4WKBAzkrasxIgQAOw\x3D\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_PDF, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAMQAADMzM9bW1rW1tZmZmf///2ZmZszMzO/v72ZmZqWlpVlZWXl5eebm5r29vUxMTK2trd3d3ff398TExHNzc0BA\rQISEhIyMjFJSUv///wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUABgALAAAAAAUABYAAAXqoNA0QvmcyZAIAYO9b0PMNBEdgfoY\rLizXswMjp0rwYIKZoMBkSnKS4hGTJDAMlYpBITAMDI1E4hF4PWqNCYHrHbhVxzONAShQhhLBaTBpuOQ0XgFCAQZ5D31/Sk1MgwwQ\rAXmJGHIDWgZbBhE3EAYCExKKBG40CgFzAWkGB5RKDl0DFDVDn6utMwMFABOnqLWsgECznhO2ckuMvRFXv7dXmQoGM8vEtglABREF\rmpwSiNY2mwcVDAV+j54J26wJ4o8BhZiGerm2AweQhiQlJWKW0awGWMiyYMGEgwibKCgA4UUneRAjYoLACkMIADs\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Text, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAMQAAExMTN3d3bW1tZmZmWZmZv///8zMzHl5ee/v762trb29vWZmZoyMjKWlpdbW1ubm5vf391paWsPDw3Nzc4WF\rhVRUVP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUABYALAAAAAAUABYAAAXdoKAoQpmczdAIzmO9r1LMdAEhjpoY\rLizXM8Qjp2rwYAJg8GEYSIpHS3KmYBwIhMhkYFA0GgnHK0HDmiOVgVptdJFnh51DcYgAAIzEYKJwK20SEWgMAgl8fn8CWREKEgKH\rFm81EIpYAwEGjxKINAlmDAYFQwoTBgiRQAxYU6KZpaeSM6oErEyPpqh/NbavuWVYDDMQvLixBZ/CxLBKEM3NCAEShrgNNs9CD9kP\rmAINBNTP2w4OBuUGjnrfpwPQ5BIkJSYpFBG4AwwUB/oT/P1nBAFeYDJHsGC5AKcshAAAOw\x3D\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_Unknown, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAMQAAExMTN3d3bW1tZmZmWZmZv///8zMzHl5ee/v762trb29vWZmZoyMjKWlpdbW1ubm5vf391paWsPDw3Nzc4WF\rhVRUVP///wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUABYALAAAAAAUABYAAAXdoKAoQpmczdAIzmO9r1LMdAEhjpoY\rLizXM8Qjp2rwYAJg8GEYSIpHS3KmYBwIhMhkYFA0GgnHK0HDmiOVgVptdJFnh51DcYgAAIzEYKJwK20SEWgMAgl8fn8CWREKEgKH\rFm81EIpYAwEGjxKINAlmDAYFQwoTBgiRQAxYU6KZpaeSM6oErEyPpqh/NbavuWVYDDMQvLixBZ/CxLBKEM3NCAEShrgNNs9CD9kP\rmAINBNTP2w4OBuUGjnrfpwPQ5BIkJSYpFBG4AwwUB/oT/P1nBAFeYDJHsGC5AKcshAAAOw\x3D\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_WAV, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWANUAAENDQ8XFxZmZmaMbG3t7e7pycrqdnd7e3rlcXL29vVlZWbW1taxDQ+bm5rONjdHBwdbQ0KWlpd+0tO/v74uL\ri2ZmZqiCgqUzM9WcnFJSUrthYfDi4tCNjcyFheLQ0K6urszMzLZLS8yZmcaBgeW9vd+wsElJSfHk5JmZmb17e6YrK2ZmZrE7O71r\ra4SEhMynp3R0dOPS0tbW1syZmblRUfXl5aEiIrNAQLiSkvfv771aWsR6esNpaffe3urR0f///yH5BAUUAD8ALAAAAAAUABYAAAb9\rwJ9wSCwaj8jkcDIRNCacjVLYOERghwZnUEtOqgtBBSRrYELS4vcASSQWGYfhMOnwiGtIIAEBCUwWFyJMOiRUCRGJCQcHCxQmEQYq\rMT8lOkILAQ2bVX4ukAkpLUIsXQJZnDJhnwJ8Nyc/GoanjDIyAREUrAkyGhI/Oxg/FAe3bx8CuiatMjscPx3PLgEBC4kRybsyI8I8\rwrqJAgLYyswIvzSGIAQKChkV4wK7D2g/A0IHIAnIMArjuwUK/MBw6UcVPQs+uKjgwgWACDgYeKhxw5CQPHvEZADwwcaLCTvuqDkY\r4MPGBCAOnPHSQAaIADDIvGDgY0qVYqgmTLn45QPJkSAAOw\x3D\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kImageBase64_XML, Type = String, Dynamic = False, Default = \"R0lGODlhFAAWAMQAAFxcXNbW1q2trZmZmf///8TExO/v73Nzc+bm5rW1tXl5eaWlpb29vWZmZszMzPf3993d3YWFhWZmZoyMjP//\r/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAUUABQALAAAAAAUABYAAAXFYMIwSSmcy7AkAUK9L0PMNPEYgSo4\rLizXMwMip1rwYAlgcDgoFI+UJGFArUIcAwdjsRAEXgIlQYitqgqu8NQ8GBYSp8GBkRbfho63YF5fs6sBb3wUanY3VwkHaIQzf2ZD\rDIoGjGI1Q4kFk2qOVZeSlJUzCA6YmkCOo6WglQ+je5mrfmYQBa+TCzYPN0IIvQiICw2wC7pCEAEBDsp5cAPCkwMGx3kkJSYpEQAO\r0BMREQoH4eIHDeUADRAvVwXs7e7tDhCTFCEAOw\x3D\x3D", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kMethodConnect, Type = String, Dynamic = False, Default = \"CONNECT", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kMethodDelete, Type = String, Dynamic = False, Default = \"DELETE", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kMethodGet, Type = String, Dynamic = False, Default = \"GET", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kMethodHead, Type = String, Dynamic = False, Default = \"HEAD", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kMethodPost, Type = String, Dynamic = False, Default = \"POST", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kMethodPut, Type = String, Dynamic = False, Default = \"PUT", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kMethodTrace, Type = String, Dynamic = False, Default = \"TRACE", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kMimeTypes, Type = String, Dynamic = False, Default = \"# This file maps Internet media types to unique file extension(s).\r# Although created for httpd\x2C this file is used by many software systems\r# and has been placed in the public domain for unlimited redisribution.\r#\r# The table below contains both registered and (common) unregistered types.\r# A type that has no unique extension can be ignored -- they are listed\r# here to guide configurations toward known types and to make it easier to\r# identify \"new\" types.  File extensions are also commonly used to indicate\r# content languages and encodings\x2C so choose them carefully.\r#\r# Internet media types should be registered as described in RFC 4288.\r# The registry is at <http://www.iana.org/assignments/media-types/>.\r#\r# MIME type (lowercased)\t\t\tExtensions\r# \x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\t\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\x3D\r# application/1d-interleaved-parityfec\r# application/3gpp-ims+xml\r# application/activemessage\rapplication/andrew-inset\t\t\tez\r# application/applefile\rapplication/applixware\t\t\t\taw\rapplication/atom+xml\t\t\t\tatom\rapplication/atomcat+xml\t\t\t\tatomcat\r# application/atomicmail\rapplication/atomsvc+xml\t\t\t\tatomsvc\r# application/auth-policy+xml\r# application/batch-smtp\r# application/beep+xml\r# application/cals-1840\rapplication/ccxml+xml\t\t\t\tccxml\rapplication/cdmi-capability\t\t\tcdmia\rapplication/cdmi-container\t\t\tcdmic\rapplication/cdmi-domain\t\t\t\tcdmid\rapplication/cdmi-object\t\t\t\tcdmio\rapplication/cdmi-queue\t\t\t\tcdmiq\r# application/cea-2018+xml\r# application/cellml+xml\r# application/cfw\r# application/cnrp+xml\r# application/commonground\r# application/conference-info+xml\r# application/cpl+xml\r# application/csta+xml\r# application/cstadata+xml\rapplication/cu-seeme\t\t\t\tcu\r# application/cybercash\rapplication/davmount+xml\t\t\tdavmount\r# application/dca-rft\r# application/dec-dx\r# application/dialog-info+xml\r# application/dicom\r# application/dns\r# application/dskpp+xml\rapplication/dssc+der\t\t\t\tdssc\rapplication/dssc+xml\t\t\t\txdssc\r# application/dvcs\rapplication/ecmascript\t\t\t\tecma\r# application/edi-consent\r# application/edi-x12\r# application/edifact\rapplication/emma+xml\t\t\t\temma\r# application/epp+xml\rapplication/epub+zip\t\t\t\tepub\r# application/eshop\r# application/example\rapplication/exi\t\t\t\t\texi\r# application/fastinfoset\r# application/fastsoap\r# application/fits\rapplication/font-tdpfr\t\t\t\tpfr\r# application/framework-attributes+xml\r# application/h224\r# application/held+xml\r# application/http\rapplication/hyperstudio\t\t\t\tstk\r# application/ibe-key-request+xml\r# application/ibe-pkg-reply+xml\r# application/ibe-pp-data\r# application/iges\r# application/im-iscomposing+xml\r# application/index\r# application/index.cmd\r# application/index.obj\r# application/index.response\r# application/index.vnd\r# application/iotp\rapplication/ipfix\t\t\t\tipfix\r# application/ipp\r# application/isup\rapplication/java-archive\t\t\tjar\rapplication/java-serialized-object\t\tser\rapplication/java-vm\t\t\t\tclass\rapplication/javascript\t\t\t\tjs\rapplication/json\t\t\t\tjson\r# application/kpml-request+xml\r# application/kpml-response+xml\rapplication/lost+xml\t\t\t\tlostxml\rapplication/mac-binhex40\t\t\thqx\rapplication/mac-compactpro\t\t\tcpt\r# application/macwriteii\rapplication/mads+xml\t\t\t\tmads\rapplication/marc\t\t\t\tmrc\rapplication/marcxml+xml\t\t\t\tmrcx\rapplication/mathematica\t\t\t\tma nb mb\r# application/mathml-content+xml\r# application/mathml-presentation+xml\rapplication/mathml+xml\t\t\t\tmathml\r# application/mbms-associated-procedure-description+xml\r# application/mbms-deregister+xml\r# application/mbms-envelope+xml\r# application/mbms-msk+xml\r# application/mbms-msk-response+xml\r# application/mbms-protection-description+xml\r# application/mbms-reception-report+xml\r# application/mbms-register+xml\r# application/mbms-register-response+xml\r# application/mbms-user-service-description+xml\rapplication/mbox\t\t\t\tmbox\r# application/media_control+xml\rapplication/mediaservercontrol+xml\t\tmscml\rapplication/metalink4+xml\t\t\tmeta4\rapplication/mets+xml\t\t\t\tmets\r# application/mikey\rapplication/mods+xml\t\t\t\tmods\r# application/moss-keys\r# application/moss-signature\r# application/mosskey-data\r# application/mosskey-request\rapplication/mp21\t\t\t\tm21 mp21\rapplication/mp4\t\t\t\t\tmp4s\r# application/mpeg4-generic\r# application/mpeg4-iod\r# application/mpeg4-iod-xmt\r# application/msc-ivr+xml\r# application/msc-mixer+xml\rapplication/msword\t\t\t\tdoc dot\rapplication/mxf\t\t\t\t\tmxf\r# application/nasdata\r# application/news-checkgroups\r# application/news-groupinfo\r# application/news-transmission\r# application/nss\r# application/ocsp-request\r# application/ocsp-response\rapplication/octet-stream\tbin dms lha lrf lzh so iso dmg dist distz pkg bpk dump elc deploy mobipocket-ebook\rapplication/oda\t\t\t\t\toda\rapplication/oebps-package+xml\t\t\topf\rapplication/ogg\t\t\t\t\togx\rapplication/onenote\t\t\t\tonetoc onetoc2 onetmp onepkg\r# application/parityfec\rapplication/patch-ops-error+xml\t\t\txer\rapplication/pdf\t\t\t\t\tpdf\rapplication/pgp-encrypted\t\t\tpgp\r# application/pgp-keys\rapplication/pgp-signature\t\t\tasc sig\rapplication/pics-rules\t\t\t\tprf\r# application/pidf+xml\r# application/pidf-diff+xml\rapplication/pkcs10\t\t\t\tp10\rapplication/pkcs7-mime\t\t\t\tp7m p7c\rapplication/pkcs7-signature\t\t\tp7s\rapplication/pkcs8\t\t\t\tp8\rapplication/pkix-attr-cert\t\t\tac\rapplication/pkix-cert\t\t\t\tcer\rapplication/pkix-crl\t\t\t\tcrl\rapplication/pkix-pkipath\t\t\tpkipath\rapplication/pkixcmp\t\t\t\tpki\rapplication/pls+xml\t\t\t\tpls\r# application/poc-settings+xml\rapplication/postscript\t\t\t\tai eps ps\r# application/prs.alvestrand.titrax-sheet\rapplication/prs.cww\t\t\t\tcww\r# application/prs.nprend\r# application/prs.plucker\r# application/prs.rdf-xml-crypt\r# application/prs.xsf+xml\rapplication/pskc+xml\t\t\t\tpskcxml\r# application/qsig\rapplication/rdf+xml\t\t\t\trdf\rapplication/reginfo+xml\t\t\t\trif\rapplication/relax-ng-compact-syntax\t\trnc\r# application/remote-printing\rapplication/resource-lists+xml\t\t\trl\rapplication/resource-lists-diff+xml\t\trld\r# application/riscos\r# application/rlmi+xml\rapplication/rls-services+xml\t\t\trs\rapplication/rsd+xml\t\t\t\trsd\rapplication/rss+xml\t\t\t\trss\rapplication/rtf\t\t\t\t\trtf\r# application/rtx\r# application/samlassertion+xml\r# application/samlmetadata+xml\rapplication/sbml+xml\t\t\t\tsbml\rapplication/scvp-cv-request\t\t\tscq\rapplication/scvp-cv-response\t\t\tscs\rapplication/scvp-vp-request\t\t\tspq\rapplication/scvp-vp-response\t\t\tspp\rapplication/sdp\t\t\t\t\tsdp\r# application/set-payment\rapplication/set-payment-initiation\t\tsetpay\r# application/set-registration\rapplication/set-registration-initiation\t\tsetreg\r# application/sgml\r# application/sgml-open-catalog\rapplication/shf+xml\t\t\t\tshf\r# application/sieve\r# application/simple-filter+xml\r# application/simple-message-summary\r# application/simplesymbolcontainer\r# application/slate\r# application/smil\rapplication/smil+xml\t\t\t\tsmi smil\r# application/soap+fastinfoset\r# application/soap+xml\rapplication/sparql-query\t\t\trq\rapplication/sparql-results+xml\t\t\tsrx\r# application/spirits-event+xml\rapplication/srgs\t\t\t\tgram\rapplication/srgs+xml\t\t\t\tgrxml\rapplication/sru+xml\t\t\t\tsru\rapplication/ssml+xml\t\t\t\tssml\r# application/tamp-apex-update\r# application/tamp-apex-update-confirm\r# application/tamp-community-update\r# application/tamp-community-update-confirm\r# application/tamp-error\r# application/tamp-sequence-adjust\r# application/tamp-sequence-adjust-confirm\r# application/tamp-status-query\r# application/tamp-status-response\r# application/tamp-update\r# application/tamp-update-confirm\rapplication/tei+xml\t\t\t\ttei teicorpus\rapplication/thraud+xml\t\t\t\ttfi\r# application/timestamp-query\r# application/timestamp-reply\rapplication/timestamped-data\t\t\ttsd\r# application/tve-trigger\r# application/ulpfec\r# application/vemmi\r# application/vividence.scriptfile\r# application/vnd.3gpp.bsf+xml\rapplication/vnd.3gpp.pic-bw-large\t\tplb\rapplication/vnd.3gpp.pic-bw-small\t\tpsb\rapplication/vnd.3gpp.pic-bw-var\t\t\tpvb\r# application/vnd.3gpp.sms\r# application/vnd.3gpp2.bcmcsinfo+xml\r# application/vnd.3gpp2.sms\rapplication/vnd.3gpp2.tcap\t\t\ttcap\rapplication/vnd.3m.post-it-notes\t\tpwn\rapplication/vnd.accpac.simply.aso\t\taso\rapplication/vnd.accpac.simply.imp\t\timp\rapplication/vnd.acucobol\t\t\tacu\rapplication/vnd.acucorp\t\t\t\tatc acutc\rapplication/vnd.adobe.air-application-installer-package+zip\tair\rapplication/vnd.adobe.fxp\t\t\tfxp fxpl\r# application/vnd.adobe.partial-upload\rapplication/vnd.adobe.xdp+xml\t\t\txdp\rapplication/vnd.adobe.xfdf\t\t\txfdf\r# application/vnd.aether.imp\r# application/vnd.ah-barcode\rapplication/vnd.ahead.space\t\t\tahead\rapplication/vnd.airzip.filesecure.azf\t\tazf\rapplication/vnd.airzip.filesecure.azs\t\tazs\rapplication/vnd.amazon.ebook\t\t\tazw\rapplication/vnd.americandynamics.acc\t\tacc\rapplication/vnd.amiga.ami\t\t\tami\r# application/vnd.amundsen.maze+xml\rapplication/vnd.android.package-archive\t\tapk\rapplication/vnd.anser-web-certificate-issue-initiation\tcii\rapplication/vnd.anser-web-funds-transfer-initiation\tfti\rapplication/vnd.antix.game-component\t\tatx\rapplication/vnd.apple.installer+xml\t\tmpkg\rapplication/vnd.apple.mpegurl\t\t\tm3u8\r# application/vnd.arastra.swi\rapplication/vnd.aristanetworks.swi\t\tswi\rapplication/vnd.audiograph\t\t\taep\r# application/vnd.autopackage\r# application/vnd.avistar+xml\rapplication/vnd.blueice.multipass\t\tmpm\r# application/vnd.bluetooth.ep.oob\rapplication/vnd.bmi\t\t\t\tbmi\rapplication/vnd.businessobjects\t\t\trep\r# application/vnd.cab-jscript\r# application/vnd.canon-cpdl\r# application/vnd.canon-lips\r# application/vnd.cendio.thinlinc.clientconf\rapplication/vnd.chemdraw+xml\t\t\tcdxml\rapplication/vnd.chipnuts.karaoke-mmd\t\tmmd\rapplication/vnd.cinderella\t\t\tcdy\r# application/vnd.cirpack.isdn-ext\rapplication/vnd.claymore\t\t\tcla\rapplication/vnd.cloanto.rp9\t\t\trp9\rapplication/vnd.clonk.c4group\t\t\tc4g c4d c4f c4p c4u\rapplication/vnd.cluetrust.cartomobile-config\t\tc11amc\rapplication/vnd.cluetrust.cartomobile-config-pkg\tc11amz\r# application/vnd.commerce-battelle\rapplication/vnd.commonspace\t\t\tcsp\rapplication/vnd.contact.cmsg\t\t\tcdbcmsg\rapplication/vnd.cosmocaller\t\t\tcmc\rapplication/vnd.crick.clicker\t\t\tclkx\rapplication/vnd.crick.clicker.keyboard\t\tclkk\rapplication/vnd.crick.clicker.palette\t\tclkp\rapplication/vnd.crick.clicker.template\t\tclkt\rapplication/vnd.crick.clicker.wordbank\t\tclkw\rapplication/vnd.criticaltools.wbs+xml\t\twbs\rapplication/vnd.ctc-posml\t\t\tpml\r# application/vnd.ctct.ws+xml\r# application/vnd.cups-pdf\r# application/vnd.cups-postscript\rapplication/vnd.cups-ppd\t\t\tppd\r# application/vnd.cups-raster\r# application/vnd.cups-raw\rapplication/vnd.curl.car\t\t\tcar\rapplication/vnd.curl.pcurl\t\t\tpcurl\r# application/vnd.cybank\rapplication/vnd.data-vision.rdz\t\t\trdz\rapplication/vnd.dece.data\t\t\tuvf uvvf uvd uvvd\rapplication/vnd.dece.ttml+xml\t\t\tuvt uvvt\rapplication/vnd.dece.unspecified\t\tuvx uvvx\rapplication/vnd.denovo.fcselayout-link\t\tfe_launch\r# application/vnd.dir-bi.plate-dl-nosuffix\rapplication/vnd.dna\t\t\t\tdna\rapplication/vnd.dolby.mlp\t\t\tmlp\r# application/vnd.dolby.mobile.1\r# application/vnd.dolby.mobile.2\rapplication/vnd.dpgraph\t\t\t\tdpg\rapplication/vnd.dreamfactory\t\t\tdfac\rapplication/vnd.dvb.ait\t\t\t\tait\r# application/vnd.dvb.dvbj\r# application/vnd.dvb.esgcontainer\r# application/vnd.dvb.ipdcdftnotifaccess\r# application/vnd.dvb.ipdcesgaccess\r# application/vnd.dvb.ipdcesgaccess2\r# application/vnd.dvb.ipdcesgpdd\r# application/vnd.dvb.ipdcroaming\r# application/vnd.dvb.iptv.alfec-base\r# application/vnd.dvb.iptv.alfec-enhancement\r# application/vnd.dvb.notif-aggregate-root+xml\r# application/vnd.dvb.notif-container+xml\r# application/vnd.dvb.notif-generic+xml\r# application/vnd.dvb.notif-ia-msglist+xml\r# application/vnd.dvb.notif-ia-registration-request+xml\r# application/vnd.dvb.notif-ia-registration-response+xml\r# application/vnd.dvb.notif-init+xml\r# application/vnd.dvb.pfr\rapplication/vnd.dvb.service\t\t\tsvc\r# application/vnd.dxr\rapplication/vnd.dynageo\t\t\t\tgeo\r# application/vnd.easykaraoke.cdgdownload\r# application/vnd.ecdis-update\rapplication/vnd.ecowin.chart\t\t\tmag\r# application/vnd.ecowin.filerequest\r# application/vnd.ecowin.fileupdate\r# application/vnd.ecowin.series\r# application/vnd.ecowin.seriesrequest\r# application/vnd.ecowin.seriesupdate\r# application/vnd.emclient.accessrequest+xml\rapplication/vnd.enliven\t\t\t\tnml\rapplication/vnd.epson.esf\t\t\tesf\rapplication/vnd.epson.msf\t\t\tmsf\rapplication/vnd.epson.quickanime\t\tqam\rapplication/vnd.epson.salt\t\t\tslt\rapplication/vnd.epson.ssf\t\t\tssf\r# application/vnd.ericsson.quickcall\rapplication/vnd.eszigno3+xml\t\t\tes3 et3\r# application/vnd.etsi.aoc+xml\r# application/vnd.etsi.cug+xml\r# application/vnd.etsi.iptvcommand+xml\r# application/vnd.etsi.iptvdiscovery+xml\r# application/vnd.etsi.iptvprofile+xml\r# application/vnd.etsi.iptvsad-bc+xml\r# application/vnd.etsi.iptvsad-cod+xml\r# application/vnd.etsi.iptvsad-npvr+xml\r# application/vnd.etsi.iptvservice+xml\r# application/vnd.etsi.iptvsync+xml\r# application/vnd.etsi.iptvueprofile+xml\r# application/vnd.etsi.mcid+xml\r# application/vnd.etsi.overload-control-policy-dataset+xml\r# application/vnd.etsi.sci+xml\r# application/vnd.etsi.simservs+xml\r# application/vnd.etsi.tsl+xml\r# application/vnd.etsi.tsl.der\r# application/vnd.eudora.data\rapplication/vnd.ezpix-album\t\t\tez2\rapplication/vnd.ezpix-package\t\t\tez3\r# application/vnd.f-secure.mobile\rapplication/vnd.fdf\t\t\t\tfdf\rapplication/vnd.fdsn.mseed\t\t\tmseed\rapplication/vnd.fdsn.seed\t\t\tseed dataless\r# application/vnd.ffsns\r# application/vnd.fints\rapplication/vnd.flographit\t\t\tgph\rapplication/vnd.fluxtime.clip\t\t\tftc\r# application/vnd.font-fontforge-sfd\rapplication/vnd.framemaker\t\t\tfm frame maker book\rapplication/vnd.frogans.fnc\t\t\tfnc\rapplication/vnd.frogans.ltf\t\t\tltf\rapplication/vnd.fsc.weblaunch\t\t\tfsc\rapplication/vnd.fujitsu.oasys\t\t\toas\rapplication/vnd.fujitsu.oasys2\t\t\toa2\rapplication/vnd.fujitsu.oasys3\t\t\toa3\rapplication/vnd.fujitsu.oasysgp\t\t\tfg5\rapplication/vnd.fujitsu.oasysprs\t\tbh2\r# application/vnd.fujixerox.art-ex\r# application/vnd.fujixerox.art4\r# application/vnd.fujixerox.hbpl\rapplication/vnd.fujixerox.ddd\t\t\tddd\rapplication/vnd.fujixerox.docuworks\t\txdw\rapplication/vnd.fujixerox.docuworks.binder\txbd\r# application/vnd.fut-misnet\rapplication/vnd.fuzzysheet\t\t\tfzs\rapplication/vnd.genomatix.tuxedo\t\ttxd\r# application/vnd.geocube+xml\rapplication/vnd.geogebra.file\t\t\tggb\rapplication/vnd.geogebra.tool\t\t\tggt\rapplication/vnd.geometry-explorer\t\tgex gre\rapplication/vnd.geonext\t\t\t\tgxt\rapplication/vnd.geoplan\t\t\t\tg2w\rapplication/vnd.geospace\t\t\tg3w\r# application/vnd.globalplatform.card-content-mgt\r# application/vnd.globalplatform.card-content-mgt-response\rapplication/vnd.gmx\t\t\t\tgmx\rapplication/vnd.google-earth.kml+xml\t\tkml\rapplication/vnd.google-earth.kmz\t\tkmz\rapplication/vnd.grafeq\t\t\t\tgqf gqs\r# application/vnd.gridmp\rapplication/vnd.groove-account\t\t\tgac\rapplication/vnd.groove-help\t\t\tghf\rapplication/vnd.groove-identity-message\t\tgim\rapplication/vnd.groove-injector\t\t\tgrv\rapplication/vnd.groove-tool-message\t\tgtm\rapplication/vnd.groove-tool-template\t\ttpl\rapplication/vnd.groove-vcard\t\t\tvcg\rapplication/vnd.hal+xml\t\t\t\thal\rapplication/vnd.handheld-entertainment+xml\tzmm\rapplication/vnd.hbci\t\t\t\thbci\r# application/vnd.hcl-bireports\rapplication/vnd.hhe.lesson-player\t\tles\rapplication/vnd.hp-hpgl\t\t\t\thpgl\rapplication/vnd.hp-hpid\t\t\t\thpid\rapplication/vnd.hp-hps\t\t\t\thps\rapplication/vnd.hp-jlyt\t\t\t\tjlt\rapplication/vnd.hp-pcl\t\t\t\tpcl\rapplication/vnd.hp-pclxl\t\t\tpclxl\r# application/vnd.httphone\rapplication/vnd.hydrostatix.sof-data\t\tsfd-hdstx\rapplication/vnd.hzn-3d-crossword\t\tx3d\r# application/vnd.ibm.afplinedata\r# application/vnd.ibm.electronic-media\rapplication/vnd.ibm.minipay\t\t\tmpy\rapplication/vnd.ibm.modcap\t\t\tafp listafp list3820\rapplication/vnd.ibm.rights-management\t\tirm\rapplication/vnd.ibm.secure-container\t\tsc\rapplication/vnd.iccprofile\t\t\ticc icm\rapplication/vnd.igloader\t\t\tigl\rapplication/vnd.immervision-ivp\t\t\tivp\rapplication/vnd.immervision-ivu\t\t\tivu\r# application/vnd.informedcontrol.rms+xml\r# application/vnd.informix-visionary\r# application/vnd.infotech.project\r# application/vnd.infotech.project+xml\rapplication/vnd.insors.igm\t\t\tigm\rapplication/vnd.intercon.formnet\t\txpw xpx\rapplication/vnd.intergeo\t\t\ti2g\r# application/vnd.intertrust.digibox\r# application/vnd.intertrust.nncp\rapplication/vnd.intu.qbo\t\t\tqbo\rapplication/vnd.intu.qfx\t\t\tqfx\r# application/vnd.iptc.g2.conceptitem+xml\r# application/vnd.iptc.g2.knowledgeitem+xml\r# application/vnd.iptc.g2.newsitem+xml\r# application/vnd.iptc.g2.packageitem+xml\rapplication/vnd.ipunplugged.rcprofile\t\trcprofile\rapplication/vnd.irepository.package+xml\t\tirp\rapplication/vnd.is-xpr\t\t\t\txpr\rapplication/vnd.isac.fcs\t\t\tfcs\rapplication/vnd.jam\t\t\t\tjam\r# application/vnd.japannet-directory-service\r# application/vnd.japannet-jpnstore-wakeup\r# application/vnd.japannet-payment-wakeup\r# application/vnd.japannet-registration\r# application/vnd.japannet-registration-wakeup\r# application/vnd.japannet-setstore-wakeup\r# application/vnd.japannet-verification\r# application/vnd.japannet-verification-wakeup\rapplication/vnd.jcp.javame.midlet-rms\t\trms\rapplication/vnd.jisp\t\t\t\tjisp\rapplication/vnd.joost.joda-archive\t\tjoda\rapplication/vnd.kahootz\t\t\t\tktz ktr\rapplication/vnd.kde.karbon\t\t\tkarbon\rapplication/vnd.kde.kchart\t\t\tchrt\rapplication/vnd.kde.kformula\t\t\tkfo\rapplication/vnd.kde.kivio\t\t\tflw\rapplication/vnd.kde.kontour\t\t\tkon\rapplication/vnd.kde.kpresenter\t\t\tkpr kpt\rapplication/vnd.kde.kspread\t\t\tksp\rapplication/vnd.kde.kword\t\t\tkwd kwt\rapplication/vnd.kenameaapp\t\t\thtke\rapplication/vnd.kidspiration\t\t\tkia\rapplication/vnd.kinar\t\t\t\tkne knp\rapplication/vnd.koan\t\t\t\tskp skd skt skm\rapplication/vnd.kodak-descriptor\t\tsse\rapplication/vnd.las.las+xml\t\t\tlasxml\r# application/vnd.liberty-request+xml\rapplication/vnd.llamagraphics.life-balance.desktop\tlbd\rapplication/vnd.llamagraphics.life-balance.exchange+xml\tlbe\rapplication/vnd.lotus-1-2-3\t\t\t123\rapplication/vnd.lotus-approach\t\t\tapr\rapplication/vnd.lotus-freelance\t\t\tpre\rapplication/vnd.lotus-notes\t\t\tnsf\rapplication/vnd.lotus-organizer\t\t\torg\rapplication/vnd.lotus-screencam\t\t\tscm\rapplication/vnd.lotus-wordpro\t\t\tlwp\rapplication/vnd.macports.portpkg\t\tportpkg\r# application/vnd.marlin.drm.actiontoken+xml\r# application/vnd.marlin.drm.conftoken+xml\r# application/vnd.marlin.drm.license+xml\r# application/vnd.marlin.drm.mdcf\rapplication/vnd.mcd\t\t\t\tmcd\rapplication/vnd.medcalcdata\t\t\tmc1\rapplication/vnd.mediastation.cdkey\t\tcdkey\r# application/vnd.meridian-slingshot\rapplication/vnd.mfer\t\t\t\tmwf\rapplication/vnd.mfmp\t\t\t\tmfm\rapplication/vnd.micrografx.flo\t\t\tflo\rapplication/vnd.micrografx.igx\t\t\tigx\rapplication/vnd.mif\t\t\t\tmif\r# application/vnd.minisoft-hp3000-save\r# application/vnd.mitsubishi.misty-guard.trustweb\rapplication/vnd.mobius.daf\t\t\tdaf\rapplication/vnd.mobius.dis\t\t\tdis\rapplication/vnd.mobius.mbk\t\t\tmbk\rapplication/vnd.mobius.mqy\t\t\tmqy\rapplication/vnd.mobius.msl\t\t\tmsl\rapplication/vnd.mobius.plc\t\t\tplc\rapplication/vnd.mobius.txf\t\t\ttxf\rapplication/vnd.mophun.application\t\tmpn\rapplication/vnd.mophun.certificate\t\tmpc\r# application/vnd.motorola.flexsuite\r# application/vnd.motorola.flexsuite.adsi\r# application/vnd.motorola.flexsuite.fis\r# application/vnd.motorola.flexsuite.gotap\r# application/vnd.motorola.flexsuite.kmr\r# application/vnd.motorola.flexsuite.ttc\r# application/vnd.motorola.flexsuite.wem\r# application/vnd.motorola.iprm\rapplication/vnd.mozilla.xul+xml\t\t\txul\rapplication/vnd.ms-artgalry\t\t\tcil\r# application/vnd.ms-asf\rapplication/vnd.ms-cab-compressed\t\tcab\rapplication/vnd.ms-excel\t\t\txls xlm xla xlc xlt xlw\rapplication/vnd.ms-excel.addin.macroenabled.12\t\txlam\rapplication/vnd.ms-excel.sheet.binary.macroenabled.12\txlsb\rapplication/vnd.ms-excel.sheet.macroenabled.12\t\txlsm\rapplication/vnd.ms-excel.template.macroenabled.12\txltm\rapplication/vnd.ms-fontobject\t\t\teot\rapplication/vnd.ms-htmlhelp\t\t\tchm\rapplication/vnd.ms-ims\t\t\t\tims\rapplication/vnd.ms-lrm\t\t\t\tlrm\r# application/vnd.ms-office.activex+xml\rapplication/vnd.ms-officetheme\t\t\tthmx\rapplication/vnd.ms-pki.seccat\t\t\tcat\rapplication/vnd.ms-pki.stl\t\t\tstl\r# application/vnd.ms-playready.initiator+xml\rapplication/vnd.ms-powerpoint\t\t\tppt pps pot\rapplication/vnd.ms-powerpoint.addin.macroenabled.12\t\tppam\rapplication/vnd.ms-powerpoint.presentation.macroenabled.12\tpptm\rapplication/vnd.ms-powerpoint.slide.macroenabled.12\t\tsldm\rapplication/vnd.ms-powerpoint.slideshow.macroenabled.12\t\tppsm\rapplication/vnd.ms-powerpoint.template.macroenabled.12\t\tpotm\rapplication/vnd.ms-project\t\t\tmpp mpt\r# application/vnd.ms-tnef\r# application/vnd.ms-wmdrm.lic-chlg-req\r# application/vnd.ms-wmdrm.lic-resp\r# application/vnd.ms-wmdrm.meter-chlg-req\r# application/vnd.ms-wmdrm.meter-resp\rapplication/vnd.ms-word.document.macroenabled.12\tdocm\rapplication/vnd.ms-word.template.macroenabled.12\tdotm\rapplication/vnd.ms-works\t\t\twps wks wcm wdb\rapplication/vnd.ms-wpl\t\t\t\twpl\rapplication/vnd.ms-xpsdocument\t\t\txps\rapplication/vnd.mseq\t\t\t\tmseq\r# application/vnd.msign\r# application/vnd.multiad.creator\r# application/vnd.multiad.creator.cif\r# application/vnd.music-niff\rapplication/vnd.musician\t\t\tmus\rapplication/vnd.muvee.style\t\t\tmsty\r# application/vnd.ncd.control\r# application/vnd.ncd.reference\r# application/vnd.nervana\r# application/vnd.netfpx\rapplication/vnd.neurolanguage.nlu\t\tnlu\rapplication/vnd.noblenet-directory\t\tnnd\rapplication/vnd.noblenet-sealer\t\t\tnns\rapplication/vnd.noblenet-web\t\t\tnnw\r# application/vnd.nokia.catalogs\r# application/vnd.nokia.conml+wbxml\r# application/vnd.nokia.conml+xml\r# application/vnd.nokia.isds-radio-presets\r# application/vnd.nokia.iptv.config+xml\r# application/vnd.nokia.landmark+wbxml\r# application/vnd.nokia.landmark+xml\r# application/vnd.nokia.landmarkcollection+xml\r# application/vnd.nokia.n-gage.ac+xml\rapplication/vnd.nokia.n-gage.data\t\tngdat\rapplication/vnd.nokia.n-gage.symbian.install\tn-gage\r# application/vnd.nokia.ncd\r# application/vnd.nokia.pcd+wbxml\r# application/vnd.nokia.pcd+xml\rapplication/vnd.nokia.radio-preset\t\trpst\rapplication/vnd.nokia.radio-presets\t\trpss\rapplication/vnd.novadigm.edm\t\t\tedm\rapplication/vnd.novadigm.edx\t\t\tedx\rapplication/vnd.novadigm.ext\t\t\text\r# application/vnd.ntt-local.file-transfer\r# application/vnd.ntt-local.sip-ta_remote\r# application/vnd.ntt-local.sip-ta_tcp_stream\rapplication/vnd.oasis.opendocument.chart\t\todc\rapplication/vnd.oasis.opendocument.chart-template\totc\rapplication/vnd.oasis.opendocument.database\t\todb\rapplication/vnd.oasis.opendocument.formula\t\todf\rapplication/vnd.oasis.opendocument.formula-template\todft\rapplication/vnd.oasis.opendocument.graphics\t\todg\rapplication/vnd.oasis.opendocument.graphics-template\totg\rapplication/vnd.oasis.opendocument.image\t\todi\rapplication/vnd.oasis.opendocument.image-template\toti\rapplication/vnd.oasis.opendocument.presentation\t\todp\rapplication/vnd.oasis.opendocument.presentation-template\totp\rapplication/vnd.oasis.opendocument.spreadsheet\t\tods\rapplication/vnd.oasis.opendocument.spreadsheet-template\tots\rapplication/vnd.oasis.opendocument.text\t\t\todt\rapplication/vnd.oasis.opendocument.text-master\t\todm\rapplication/vnd.oasis.opendocument.text-template\tott\rapplication/vnd.oasis.opendocument.text-web\t\toth\r# application/vnd.obn\r# application/vnd.oipf.contentaccessdownload+xml\r# application/vnd.oipf.contentaccessstreaming+xml\r# application/vnd.oipf.cspg-hexbinary\r# application/vnd.oipf.dae.svg+xml\r# application/vnd.oipf.dae.xhtml+xml\r# application/vnd.oipf.mippvcontrolmessage+xml\r# application/vnd.oipf.pae.gem\r# application/vnd.oipf.spdiscovery+xml\r# application/vnd.oipf.spdlist+xml\r# application/vnd.oipf.ueprofile+xml\r# application/vnd.oipf.userprofile+xml\rapplication/vnd.olpc-sugar\t\t\txo\r# application/vnd.oma-scws-config\r# application/vnd.oma-scws-http-request\r# application/vnd.oma-scws-http-response\r# application/vnd.oma.bcast.associated-procedure-parameter+xml\r# application/vnd.oma.bcast.drm-trigger+xml\r# application/vnd.oma.bcast.imd+xml\r# application/vnd.oma.bcast.ltkm\r# application/vnd.oma.bcast.notification+xml\r# application/vnd.oma.bcast.provisioningtrigger\r# application/vnd.oma.bcast.sgboot\r# application/vnd.oma.bcast.sgdd+xml\r# application/vnd.oma.bcast.sgdu\r# application/vnd.oma.bcast.simple-symbol-container\r# application/vnd.oma.bcast.smartcard-trigger+xml\r# application/vnd.oma.bcast.sprov+xml\r# application/vnd.oma.bcast.stkm\r# application/vnd.oma.cab-address-book+xml\r# application/vnd.oma.cab-pcc+xml\r# application/vnd.oma.dcd\r# application/vnd.oma.dcdc\rapplication/vnd.oma.dd2+xml\t\t\tdd2\r# application/vnd.oma.drm.risd+xml\r# application/vnd.oma.group-usage-list+xml\r# application/vnd.oma.poc.detailed-progress-report+xml\r# application/vnd.oma.poc.final-report+xml\r# application/vnd.oma.poc.groups+xml\r# application/vnd.oma.poc.invocation-descriptor+xml\r# application/vnd.oma.poc.optimized-progress-report+xml\r# application/vnd.oma.push\r# application/vnd.oma.scidm.messages+xml\r# application/vnd.oma.xcap-directory+xml\r# application/vnd.omads-email+xml\r# application/vnd.omads-file+xml\r# application/vnd.omads-folder+xml\r# application/vnd.omaloc-supl-init\rapplication/vnd.openofficeorg.extension\t\toxt\r# application/vnd.openxmlformats-officedocument.custom-properties+xml\r# application/vnd.openxmlformats-officedocument.customxmlproperties+xml\r# application/vnd.openxmlformats-officedocument.drawing+xml\r# application/vnd.openxmlformats-officedocument.drawingml.chart+xml\r# application/vnd.openxmlformats-officedocument.drawingml.chartshapes+xml\r# application/vnd.openxmlformats-officedocument.drawingml.diagramcolors+xml\r# application/vnd.openxmlformats-officedocument.drawingml.diagramdata+xml\r# application/vnd.openxmlformats-officedocument.drawingml.diagramlayout+xml\r# application/vnd.openxmlformats-officedocument.drawingml.diagramstyle+xml\r# application/vnd.openxmlformats-officedocument.extended-properties+xml\r# application/vnd.openxmlformats-officedocument.presentationml.commentauthors+xml\r# application/vnd.openxmlformats-officedocument.presentationml.comments+xml\r# application/vnd.openxmlformats-officedocument.presentationml.handoutmaster+xml\r# application/vnd.openxmlformats-officedocument.presentationml.notesmaster+xml\r# application/vnd.openxmlformats-officedocument.presentationml.notesslide+xml\rapplication/vnd.openxmlformats-officedocument.presentationml.presentation\tpptx\r# application/vnd.openxmlformats-officedocument.presentationml.presentation.main+xml\r# application/vnd.openxmlformats-officedocument.presentationml.presprops+xml\rapplication/vnd.openxmlformats-officedocument.presentationml.slide\tsldx\r# application/vnd.openxmlformats-officedocument.presentationml.slide+xml\r# application/vnd.openxmlformats-officedocument.presentationml.slidelayout+xml\r# application/vnd.openxmlformats-officedocument.presentationml.slidemaster+xml\rapplication/vnd.openxmlformats-officedocument.presentationml.slideshow\tppsx\r# application/vnd.openxmlformats-officedocument.presentationml.slideshow.main+xml\r# application/vnd.openxmlformats-officedocument.presentationml.slideupdateinfo+xml\r# application/vnd.openxmlformats-officedocument.presentationml.tablestyles+xml\r# application/vnd.openxmlformats-officedocument.presentationml.tags+xml\rapplication/vnd.openxmlformats-officedocument.presentationml.template\tpotx\r# application/vnd.openxmlformats-officedocument.presentationml.template.main+xml\r# application/vnd.openxmlformats-officedocument.presentationml.viewprops+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.calcchain+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.chartsheet+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.comments+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.connections+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.dialogsheet+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.externallink+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.pivotcachedefinition+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.pivotcacherecords+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.pivottable+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.querytable+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.revisionheaders+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.revisionlog+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.sharedstrings+xml\rapplication/vnd.openxmlformats-officedocument.spreadsheetml.sheet\txlsx\r# application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.sheetmetadata+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.table+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.tablesinglecells+xml\rapplication/vnd.openxmlformats-officedocument.spreadsheetml.template\txltx\r# application/vnd.openxmlformats-officedocument.spreadsheetml.template.main+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.usernames+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.volatiledependencies+xml\r# application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\r# application/vnd.openxmlformats-officedocument.theme+xml\r# application/vnd.openxmlformats-officedocument.themeoverride+xml\r# application/vnd.openxmlformats-officedocument.vmldrawing\r# application/vnd.openxmlformats-officedocument.wordprocessingml.comments+xml\rapplication/vnd.openxmlformats-officedocument.wordprocessingml.document\tdocx\r# application/vnd.openxmlformats-officedocument.wordprocessingml.document.glossary+xml\r# application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml\r# application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml\r# application/vnd.openxmlformats-officedocument.wordprocessingml.fonttable+xml\r# application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml\r# application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml\r# application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml\r# application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml\r# application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml\rapplication/vnd.openxmlformats-officedocument.wordprocessingml.template\tdotx\r# application/vnd.openxmlformats-officedocument.wordprocessingml.template.main+xml\r# application/vnd.openxmlformats-officedocument.wordprocessingml.websettings+xml\r# application/vnd.openxmlformats-package.core-properties+xml\r# application/vnd.openxmlformats-package.digital-signature-xmlsignature+xml\r# application/vnd.openxmlformats-package.relationships+xml\r# application/vnd.quobject-quoxdocument\r# application/vnd.osa.netdeploy\rapplication/vnd.osgeo.mapguide.package\t\tmgp\r# application/vnd.osgi.bundle\rapplication/vnd.osgi.dp\t\t\t\tdp\r# application/vnd.otps.ct-kip+xml\rapplication/vnd.palm\t\t\t\tpdb pqa oprc\r# application/vnd.paos.xml\rapplication/vnd.pawaafile\t\t\tpaw\rapplication/vnd.pg.format\t\t\tstr\rapplication/vnd.pg.osasli\t\t\tei6\r# application/vnd.piaccess.application-licence\rapplication/vnd.picsel\t\t\t\tefif\rapplication/vnd.pmi.widget\t\t\twg\r# application/vnd.poc.group-advertisement+xml\rapplication/vnd.pocketlearn\t\t\tplf\rapplication/vnd.powerbuilder6\t\t\tpbd\r# application/vnd.powerbuilder6-s\r# application/vnd.powerbuilder7\r# application/vnd.powerbuilder7-s\r# application/vnd.powerbuilder75\r# application/vnd.powerbuilder75-s\r# application/vnd.preminet\rapplication/vnd.previewsystems.box\t\tbox\rapplication/vnd.proteus.magazine\t\tmgz\rapplication/vnd.publishare-delta-tree\t\tqps\rapplication/vnd.pvi.ptid1\t\t\tptid\r# application/vnd.pwg-multiplexed\r# application/vnd.pwg-xhtml-print+xml\r# application/vnd.qualcomm.brew-app-res\rapplication/vnd.quark.quarkxpress\t\tqxd qxt qwd qwt qxl qxb\r# application/vnd.radisys.moml+xml\r# application/vnd.radisys.msml+xml\r# application/vnd.radisys.msml-audit+xml\r# application/vnd.radisys.msml-audit-conf+xml\r# application/vnd.radisys.msml-audit-conn+xml\r# application/vnd.radisys.msml-audit-dialog+xml\r# application/vnd.radisys.msml-audit-stream+xml\r# application/vnd.radisys.msml-conf+xml\r# application/vnd.radisys.msml-dialog+xml\r# application/vnd.radisys.msml-dialog-base+xml\r# application/vnd.radisys.msml-dialog-fax-detect+xml\r# application/vnd.radisys.msml-dialog-fax-sendrecv+xml\r# application/vnd.radisys.msml-dialog-group+xml\r# application/vnd.radisys.msml-dialog-speech+xml\r# application/vnd.radisys.msml-dialog-transform+xml\r# application/vnd.rainstor.data\r# application/vnd.rapid\rapplication/vnd.realvnc.bed\t\t\tbed\rapplication/vnd.recordare.musicxml\t\tmxl\rapplication/vnd.recordare.musicxml+xml\t\tmusicxml\r# application/vnd.renlearn.rlprint\rapplication/vnd.rig.cryptonote\t\t\tcryptonote\rapplication/vnd.rim.cod\t\t\t\tcod\rapplication/vnd.rn-realmedia\t\t\trm\rapplication/vnd.route66.link66+xml\t\tlink66\r# application/vnd.ruckus.download\r# application/vnd.s3sms\rapplication/vnd.sailingtracker.track\t\tst\r# application/vnd.sbm.cid\r# application/vnd.sbm.mid2\r# application/vnd.scribus\r# application/vnd.sealed.3df\r# application/vnd.sealed.csf\r# application/vnd.sealed.doc\r# application/vnd.sealed.eml\r# application/vnd.sealed.mht\r# application/vnd.sealed.net\r# application/vnd.sealed.ppt\r# application/vnd.sealed.tiff\r# application/vnd.sealed.xls\r# application/vnd.sealedmedia.softseal.html\r# application/vnd.sealedmedia.softseal.pdf\rapplication/vnd.seemail\t\t\t\tsee\rapplication/vnd.sema\t\t\t\tsema\rapplication/vnd.semd\t\t\t\tsemd\rapplication/vnd.semf\t\t\t\tsemf\rapplication/vnd.shana.informed.formdata\t\tifm\rapplication/vnd.shana.informed.formtemplate\titp\rapplication/vnd.shana.informed.interchange\tiif\rapplication/vnd.shana.informed.package\t\tipk\rapplication/vnd.simtech-mindmapper\t\ttwd twds\rapplication/vnd.smaf\t\t\t\tmmf\r# application/vnd.smart.notebook\rapplication/vnd.smart.teacher\t\t\tteacher\r# application/vnd.software602.filler.form+xml\r# application/vnd.software602.filler.form-xml-zip\rapplication/vnd.solent.sdkm+xml\t\t\tsdkm sdkd\rapplication/vnd.spotfire.dxp\t\t\tdxp\rapplication/vnd.spotfire.sfs\t\t\tsfs\r# application/vnd.sss-cod\r# application/vnd.sss-dtf\r# application/vnd.sss-ntf\rapplication/vnd.stardivision.calc\t\tsdc\rapplication/vnd.stardivision.draw\t\tsda\rapplication/vnd.stardivision.impress\t\tsdd\rapplication/vnd.stardivision.math\t\tsmf\rapplication/vnd.stardivision.writer\t\tsdw vor\rapplication/vnd.stardivision.writer-global\tsgl\rapplication/vnd.stepmania.stepchart\t\tsm\r# application/vnd.street-stream\rapplication/vnd.sun.xml.calc\t\t\tsxc\rapplication/vnd.sun.xml.calc.template\t\tstc\rapplication/vnd.sun.xml.draw\t\t\tsxd\rapplication/vnd.sun.xml.draw.template\t\tstd\rapplication/vnd.sun.xml.impress\t\t\tsxi\rapplication/vnd.sun.xml.impress.template\tsti\rapplication/vnd.sun.xml.math\t\t\tsxm\rapplication/vnd.sun.xml.writer\t\t\tsxw\rapplication/vnd.sun.xml.writer.global\t\tsxg\rapplication/vnd.sun.xml.writer.template\t\tstw\r# application/vnd.sun.wadl+xml\rapplication/vnd.sus-calendar\t\t\tsus susp\rapplication/vnd.svd\t\t\t\tsvd\r# application/vnd.swiftview-ics\rapplication/vnd.symbian.install\t\t\tsis sisx\rapplication/vnd.syncml+xml\t\t\txsm\rapplication/vnd.syncml.dm+wbxml\t\t\tbdm\rapplication/vnd.syncml.dm+xml\t\t\txdm\r# application/vnd.syncml.dm.notification\r# application/vnd.syncml.ds.notification\rapplication/vnd.tao.intent-module-archive\ttao\rapplication/vnd.tmobile-livetv\t\t\ttmo\rapplication/vnd.trid.tpt\t\t\ttpt\rapplication/vnd.triscape.mxs\t\t\tmxs\rapplication/vnd.trueapp\t\t\t\ttra\r# application/vnd.truedoc\r# application/vnd.ubisoft.webplayer\rapplication/vnd.ufdl\t\t\t\tufd ufdl\rapplication/vnd.uiq.theme\t\t\tutz\rapplication/vnd.umajin\t\t\t\tumj\rapplication/vnd.unity\t\t\t\tunityweb\rapplication/vnd.uoml+xml\t\t\tuoml\r# application/vnd.uplanet.alert\r# application/vnd.uplanet.alert-wbxml\r# application/vnd.uplanet.bearer-choice\r# application/vnd.uplanet.bearer-choice-wbxml\r# application/vnd.uplanet.cacheop\r# application/vnd.uplanet.cacheop-wbxml\r# application/vnd.uplanet.channel\r# application/vnd.uplanet.channel-wbxml\r# application/vnd.uplanet.list\r# application/vnd.uplanet.list-wbxml\r# application/vnd.uplanet.listcmd\r# application/vnd.uplanet.listcmd-wbxml\r# application/vnd.uplanet.signal\rapplication/vnd.vcx\t\t\t\tvcx\r# application/vnd.vd-study\r# application/vnd.vectorworks\r# application/vnd.verimatrix.vcas\r# application/vnd.vidsoft.vidconference\rapplication/vnd.visio\t\t\t\tvsd vst vss vsw\rapplication/vnd.visionary\t\t\tvis\r# application/vnd.vividence.scriptfile\rapplication/vnd.vsf\t\t\t\tvsf\r# application/vnd.wap.sic\r# application/vnd.wap.slc\rapplication/vnd.wap.wbxml\t\t\twbxml\rapplication/vnd.wap.wmlc\t\t\twmlc\rapplication/vnd.wap.wmlscriptc\t\t\twmlsc\rapplication/vnd.webturbo\t\t\twtb\r# application/vnd.wfa.wsc\r# application/vnd.wmc\r# application/vnd.wmf.bootstrap\r# application/vnd.wolfram.mathematica\r# application/vnd.wolfram.mathematica.package\rapplication/vnd.wolfram.player\t\t\tnbp\rapplication/vnd.wordperfect\t\t\twpd\rapplication/vnd.wqd\t\t\t\twqd\r# application/vnd.wrq-hp3000-labelled\rapplication/vnd.wt.stf\t\t\t\tstf\r# application/vnd.wv.csp+wbxml\r# application/vnd.wv.csp+xml\r# application/vnd.wv.ssp+xml\rapplication/vnd.xara\t\t\t\txar\rapplication/vnd.xfdl\t\t\t\txfdl\r# application/vnd.xfdl.webform\r# application/vnd.xmi+xml\r# application/vnd.xmpie.cpkg\r# application/vnd.xmpie.dpkg\r# application/vnd.xmpie.plan\r# application/vnd.xmpie.ppkg\r# application/vnd.xmpie.xlim\rapplication/vnd.yamaha.hv-dic\t\t\thvd\rapplication/vnd.yamaha.hv-script\t\thvs\rapplication/vnd.yamaha.hv-voice\t\t\thvp\rapplication/vnd.yamaha.openscoreformat\t\t\tosf\rapplication/vnd.yamaha.openscoreformat.osfpvg+xml\tosfpvg\r# application/vnd.yamaha.remote-setup\rapplication/vnd.yamaha.smaf-audio\t\tsaf\rapplication/vnd.yamaha.smaf-phrase\t\tspf\r# application/vnd.yamaha.tunnel-udpencap\rapplication/vnd.yellowriver-custom-menu\t\tcmp\rapplication/vnd.zul\t\t\t\tzir zirz\rapplication/vnd.zzazz.deck+xml\t\t\tzaz\rapplication/voicexml+xml\t\t\tvxml\r# application/vq-rtcpxr\r# application/watcherinfo+xml\r# application/whoispp-query\r# application/whoispp-response\rapplication/widget\t\t\t\twgt\rapplication/winhlp\t\t\t\thlp\r# application/wita\r# application/wordperfect5.1\rapplication/wsdl+xml\t\t\t\twsdl\rapplication/wspolicy+xml\t\t\twspolicy\rapplication/x-7z-compressed\t\t\t7z\rapplication/x-abiword\t\t\t\tabw\rapplication/x-ace-compressed\t\t\tace\rapplication/x-authorware-bin\t\t\taab x32 u32 vox\rapplication/x-authorware-map\t\t\taam\rapplication/x-authorware-seg\t\t\taas\rapplication/x-bcpio\t\t\t\tbcpio\rapplication/x-bittorrent\t\t\ttorrent\rapplication/x-bzip\t\t\t\tbz\rapplication/x-bzip2\t\t\t\tbz2 boz\rapplication/x-cdlink\t\t\t\tvcd\rapplication/x-chat\t\t\t\tchat\rapplication/x-chess-pgn\t\t\t\tpgn\r# application/x-compress\rapplication/x-cpio\t\t\t\tcpio\rapplication/x-csh\t\t\t\tcsh\rapplication/x-debian-package\t\t\tdeb udeb\rapplication/x-director\t\t\tdir dcr dxr cst cct cxt w3d fgd swa\rapplication/x-doom\t\t\t\twad\rapplication/x-dtbncx+xml\t\t\tncx\rapplication/x-dtbook+xml\t\t\tdtb\rapplication/x-dtbresource+xml\t\t\tres\rapplication/x-dvi\t\t\t\tdvi\rapplication/x-font-bdf\t\t\t\tbdf\r# application/x-font-dos\r# application/x-font-framemaker\rapplication/x-font-ghostscript\t\t\tgsf\r# application/x-font-libgrx\rapplication/x-font-linux-psf\t\t\tpsf\rapplication/x-font-otf\t\t\t\totf\rapplication/x-font-pcf\t\t\t\tpcf\rapplication/x-font-snf\t\t\t\tsnf\r# application/x-font-speedo\r# application/x-font-sunos-news\rapplication/x-font-ttf\t\t\t\tttf ttc\rapplication/x-font-type1\t\t\tpfa pfb pfm afm\rapplication/x-font-woff\t\t\t\twoff\r# application/x-font-vfont\rapplication/x-futuresplash\t\t\tspl\rapplication/x-gnumeric\t\t\t\tgnumeric\rapplication/x-gtar\t\t\t\tgtar\r# application/x-gzip\rapplication/x-hdf\t\t\t\thdf\rapplication/x-java-jnlp-file\t\t\tjnlp\rapplication/x-latex\t\t\t\tlatex\rapplication/x-mobipocket-ebook\t\t\tprc mobi\rapplication/x-mpegurl\t\t\t\tm3u8\rapplication/x-ms-application\t\t\tapplication\rapplication/x-ms-wmd\t\t\t\twmd\rapplication/x-ms-wmz\t\t\t\twmz\rapplication/x-ms-xbap\t\t\t\txbap\rapplication/x-msaccess\t\t\t\tmdb\rapplication/x-msbinder\t\t\t\tobd\rapplication/x-mscardfile\t\t\tcrd\rapplication/x-msclip\t\t\t\tclp\rapplication/x-msdownload\t\t\texe dll com bat msi\rapplication/x-msmediaview\t\t\tmvb m13 m14\rapplication/x-msmetafile\t\t\twmf\rapplication/x-msmoney\t\t\t\tmny\rapplication/x-mspublisher\t\t\tpub\rapplication/x-msschedule\t\t\tscd\rapplication/x-msterminal\t\t\ttrm\rapplication/x-mswrite\t\t\t\twri\rapplication/x-netcdf\t\t\t\tnc cdf\rapplication/x-pkcs12\t\t\t\tp12 pfx\rapplication/x-pkcs7-certificates\t\tp7b spc\rapplication/x-pkcs7-certreqresp\t\t\tp7r\rapplication/x-rar-compressed\t\t\trar\rapplication/x-sh\t\t\t\tsh\rapplication/x-shar\t\t\t\tshar\rapplication/x-shockwave-flash\t\t\tswf\rapplication/x-silverlight-app\t\t\txap\rapplication/x-stuffit\t\t\t\tsit\rapplication/x-stuffitx\t\t\t\tsitx\rapplication/x-sv4cpio\t\t\t\tsv4cpio\rapplication/x-sv4crc\t\t\t\tsv4crc\rapplication/x-tar\t\t\t\ttar\rapplication/x-tcl\t\t\t\ttcl\rapplication/x-tex\t\t\t\ttex\rapplication/x-tex-tfm\t\t\t\ttfm\rapplication/x-texinfo\t\t\t\ttexinfo texi\rapplication/x-ustar\t\t\t\tustar\rapplication/x-wais-source\t\t\tsrc\rapplication/x-x509-ca-cert\t\t\tder crt\rapplication/x-xfig\t\t\t\tfig\rapplication/x-xpinstall\t\t\t\txpi\r# application/x400-bp\r# application/xcap-att+xml\r# application/xcap-caps+xml\rapplication/xcap-diff+xml\t\t\txdf\r# application/xcap-el+xml\r# application/xcap-error+xml\r# application/xcap-ns+xml\r# application/xcon-conference-info-diff+xml\r# application/xcon-conference-info+xml\rapplication/xenc+xml\t\t\t\txenc\rapplication/xhtml+xml\t\t\t\txhtml xht\r# application/xhtml-voice+xml\rapplication/xml\t\t\t\t\txml xsl\rapplication/xml-dtd\t\t\t\tdtd\r# application/xml-external-parsed-entity\r# application/xmpp+xml\rapplication/xop+xml\t\t\t\txop\rapplication/xslt+xml\t\t\t\txslt\rapplication/xspf+xml\t\t\t\txspf\rapplication/xv+xml\t\t\t\tmxml xhvml xvml xvm\rapplication/yang\t\t\t\tyang\rapplication/yin+xml\t\t\t\tyin\rapplication/zip\t\t\t\t\tzip\r# audio/1d-interleaved-parityfec\r# audio/32kadpcm\r# audio/3gpp\r# audio/3gpp2\r# audio/ac3\raudio/adpcm\t\t\t\t\tadp\r# audio/amr\r# audio/amr-wb\r# audio/amr-wb+\r# audio/asc\r# audio/atrac-advanced-lossless\r# audio/atrac-x\r# audio/atrac3\raudio/basic\t\t\t\t\tau snd\r# audio/bv16\r# audio/bv32\r# audio/clearmode\r# audio/cn\r# audio/dat12\r# audio/dls\r# audio/dsr-es201108\r# audio/dsr-es202050\r# audio/dsr-es202211\r# audio/dsr-es202212\r# audio/dvi4\r# audio/eac3\r# audio/evrc\r# audio/evrc-qcp\r# audio/evrc0\r# audio/evrc1\r# audio/evrcb\r# audio/evrcb0\r# audio/evrcb1\r# audio/evrcwb\r# audio/evrcwb0\r# audio/evrcwb1\r# audio/example\r# audio/g719\r# audio/g722\r# audio/g7221\r# audio/g723\r# audio/g726-16\r# audio/g726-24\r# audio/g726-32\r# audio/g726-40\r# audio/g728\r# audio/g729\r# audio/g7291\r# audio/g729d\r# audio/g729e\r# audio/gsm\r# audio/gsm-efr\r# audio/gsm-hr-08\r# audio/ilbc\r# audio/l16\r# audio/l20\r# audio/l24\r# audio/l8\r# audio/lpc\raudio/midi\t\t\t\t\tmid midi kar rmi\r# audio/mobile-xmf\raudio/mp4\t\t\t\t\tmp4a\raudio/mp4a-latm\t\t\tm4a m4p\r# audio/mpa\r# audio/mpa-robust\raudio/mpeg\t\t\t\t\tmpga mp2 mp2a mp3 m2a m3a\r# audio/mpeg4-generic\raudio/ogg\t\t\t\t\toga ogg spx\r# audio/parityfec\r# audio/pcma\r# audio/pcma-wb\r# audio/pcmu-wb\r# audio/pcmu\r# audio/prs.sid\r# audio/qcelp\r# audio/red\r# audio/rtp-enc-aescm128\r# audio/rtp-midi\r# audio/rtx\r# audio/smv\r# audio/smv0\r# audio/smv-qcp\r# audio/sp-midi\r# audio/speex\r# audio/t140c\r# audio/t38\r# audio/telephone-event\r# audio/tone\r# audio/uemclip\r# audio/ulpfec\r# audio/vdvi\r# audio/vmr-wb\r# audio/vnd.3gpp.iufp\r# audio/vnd.4sb\r# audio/vnd.audiokoz\r# audio/vnd.celp\r# audio/vnd.cisco.nse\r# audio/vnd.cmles.radio-events\r# audio/vnd.cns.anp1\r# audio/vnd.cns.inf1\raudio/vnd.dece.audio\t\t\t\tuva uvva\raudio/vnd.digital-winds\t\t\t\teol\r# audio/vnd.dlna.adts\r# audio/vnd.dolby.heaac.1\r# audio/vnd.dolby.heaac.2\r# audio/vnd.dolby.mlp\r# audio/vnd.dolby.mps\r# audio/vnd.dolby.pl2\r# audio/vnd.dolby.pl2x\r# audio/vnd.dolby.pl2z\r# audio/vnd.dolby.pulse.1\raudio/vnd.dra\t\t\t\t\tdra\raudio/vnd.dts\t\t\t\t\tdts\raudio/vnd.dts.hd\t\t\t\tdtshd\r# audio/vnd.everad.plj\r# audio/vnd.hns.audio\raudio/vnd.lucent.voice\t\t\t\tlvp\raudio/vnd.ms-playready.media.pya\t\tpya\r# audio/vnd.nokia.mobile-xmf\r# audio/vnd.nortel.vbk\raudio/vnd.nuera.ecelp4800\t\t\tecelp4800\raudio/vnd.nuera.ecelp7470\t\t\tecelp7470\raudio/vnd.nuera.ecelp9600\t\t\tecelp9600\r# audio/vnd.octel.sbc\r# audio/vnd.qcelp\r# audio/vnd.rhetorex.32kadpcm\raudio/vnd.rip\t\t\t\t\trip\r# audio/vnd.sealedmedia.softseal.mpeg\r# audio/vnd.vmx.cvsd\r# audio/vorbis\r# audio/vorbis-config\raudio/webm\t\t\t\t\tweba\raudio/x-aac\t\t\t\t\taac\raudio/x-aiff\t\t\t\t\taif aiff aifc\raudio/x-mpegurl\t\t\t\t\tm3u\raudio/x-ms-wax\t\t\t\t\twax\raudio/x-ms-wma\t\t\t\t\twma\raudio/x-pn-realaudio\t\t\t\tram ra\raudio/x-pn-realaudio-plugin\t\t\trmp\raudio/x-wav\t\t\t\t\twav\rchemical/x-cdx\t\t\t\t\tcdx\rchemical/x-cif\t\t\t\t\tcif\rchemical/x-cmdf\t\t\t\t\tcmdf\rchemical/x-cml\t\t\t\t\tcml\rchemical/x-csml\t\t\t\t\tcsml\r# chemical/x-pdb\rchemical/x-xyz\t\t\t\t\txyz\rimage/bmp\t\t\t\t\tbmp\rimage/cgm\t\t\t\t\tcgm\r# image/example\r# image/fits\rimage/g3fax\t\t\t\t\tg3\rimage/gif\t\t\t\t\tgif\rimage/ief\t\t\t\t\tief\rimage/jp2\t\t\tjp2\rimage/jpeg\t\t\t\t\tjpeg jpg jpe\r# image/jpm\r# image/jpx\rimage/ktx\t\t\t\t\tktx\r# image/naplps\rimage/pict\t\t\tpict pic pct\rimage/png\t\t\t\t\tpng\rimage/prs.btif\t\t\t\t\tbtif\r# image/prs.pti\rimage/svg+xml\t\t\t\t\tsvg svgz\r# image/t38\rimage/tiff\t\t\t\t\ttiff tif\r# image/tiff-fx\rimage/vnd.adobe.photoshop\t\t\tpsd\r# image/vnd.cns.inf2\rimage/vnd.dece.graphic\t\t\t\tuvi uvvi uvg uvvg\rimage/vnd.dvb.subtitle\t\t\t\tsub\rimage/vnd.djvu\t\t\t\t\tdjvu djv\rimage/vnd.dwg\t\t\t\t\tdwg\rimage/vnd.dxf\t\t\t\t\tdxf\rimage/vnd.fastbidsheet\t\t\t\tfbs\rimage/vnd.fpx\t\t\t\t\tfpx\rimage/vnd.fst\t\t\t\t\tfst\rimage/vnd.fujixerox.edmics-mmr\t\t\tmmr\rimage/vnd.fujixerox.edmics-rlc\t\t\trlc\r# image/vnd.globalgraphics.pgb\r# image/vnd.microsoft.icon\r# image/vnd.mix\rimage/vnd.ms-modi\t\t\t\tmdi\rimage/vnd.net-fpx\t\t\t\tnpx\r# image/vnd.radiance\r# image/vnd.sealed.png\r# image/vnd.sealedmedia.softseal.gif\r# image/vnd.sealedmedia.softseal.jpg\r# image/vnd.svf\rimage/vnd.wap.wbmp\t\t\t\twbmp\rimage/vnd.xiff\t\t\t\t\txif\rimage/webp\t\t\t\t\twebp\rimage/x-cmu-raster\t\t\t\tras\rimage/x-cmx\t\t\t\t\tcmx\rimage/x-freehand\t\t\t\tfh fhc fh4 fh5 fh7\rimage/x-icon\t\t\t\t\tico\rimage/x-macpaint\t\tpntg pnt mac\rimage/x-pcx\t\t\t\t\tpcx\rimage/x-pict\t\t\t\t\tpic pct\rimage/x-portable-anymap\t\t\t\tpnm\rimage/x-portable-bitmap\t\t\t\tpbm\rimage/x-portable-graymap\t\t\tpgm\rimage/x-portable-pixmap\t\t\t\tppm\rimage/x-quicktime\t\tqtif qti\rimage/x-rgb\t\t\t\t\trgb\rimage/x-xbitmap\t\t\t\t\txbm\rimage/x-xpixmap\t\t\t\t\txpm\rimage/x-xwindowdump\t\t\t\txwd\r# message/cpim\r# message/delivery-status\r# message/disposition-notification\r# message/example\r# message/external-body\r# message/feedback-report\r# message/global\r# message/global-delivery-status\r# message/global-disposition-notification\r# message/global-headers\r# message/http\r# message/imdn+xml\r# message/news\r# message/partial\rmessage/rfc822\t\t\t\t\teml mime\r# message/s-http\r# message/sip\r# message/sipfrag\r# message/tracking-status\r# message/vnd.si.simp\r# model/example\rmodel/iges\t\t\t\t\tigs iges\rmodel/mesh\t\t\t\t\tmsh mesh silo\rmodel/vnd.collada+xml\t\t\t\tdae\rmodel/vnd.dwf\t\t\t\t\tdwf\r# model/vnd.flatland.3dml\rmodel/vnd.gdl\t\t\t\t\tgdl\r# model/vnd.gs-gdl\r# model/vnd.gs.gdl\rmodel/vnd.gtw\t\t\t\t\tgtw\r# model/vnd.moml+xml\rmodel/vnd.mts\t\t\t\t\tmts\r# model/vnd.parasolid.transmit.binary\r# model/vnd.parasolid.transmit.text\rmodel/vnd.vtu\t\t\t\t\tvtu\rmodel/vrml\t\t\t\t\twrl vrml\r# multipart/alternative\r# multipart/appledouble\r# multipart/byteranges\r# multipart/digest\r# multipart/encrypted\r# multipart/example\r# multipart/form-data\r# multipart/header-set\r# multipart/mixed\r# multipart/parallel\r# multipart/related\r# multipart/report\r# multipart/signed\r# multipart/voice-message\rtext/cache-manifest\t\t\t\tmanifest\r# text/1d-interleaved-parityfec\rtext/calendar\t\t\t\t\tics ifb\rtext/css\t\t\t\t\tcss\rtext/csv\t\t\t\t\tcsv\r# text/directory\r# text/dns\r# text/ecmascript\r# text/enriched\r# text/example\rtext/html\t\t\t\t\thtml htm\r# text/javascript\rtext/n3\t\t\t\t\t\tn3\r# text/parityfec\rtext/plain\t\t\t\t\ttxt text conf def list log in\r# text/prs.fallenstein.rst\rtext/prs.lines.tag\t\t\t\tdsc\r# text/vnd.radisys.msml-basic-layout\r# text/red\r# text/rfc822-headers\rtext/richtext\t\t\t\t\trtx\r# text/rtf\r# text/rtp-enc-aescm128\r# text/rtx\rtext/sgml\t\t\t\t\tsgml sgm\r# text/t140\rtext/tab-separated-values\t\t\ttsv\rtext/troff\t\t\t\t\tt tr roff man me ms\rtext/turtle\t\t\t\t\tttl\r# text/ulpfec\rtext/uri-list\t\t\t\t\turi uris urls\r# text/vnd.abc\rtext/vnd.curl\t\t\t\t\tcurl\rtext/vnd.curl.dcurl\t\t\t\tdcurl\rtext/vnd.curl.scurl\t\t\t\tscurl\rtext/vnd.curl.mcurl\t\t\t\tmcurl\r# text/vnd.dmclientscript\r# text/vnd.esmertec.theme-descriptor\rtext/vnd.fly\t\t\t\t\tfly\rtext/vnd.fmi.flexstor\t\t\t\tflx\rtext/vnd.graphviz\t\t\t\tgv\rtext/vnd.in3d.3dml\t\t\t\t3dml\rtext/vnd.in3d.spot\t\t\t\tspot\r# text/vnd.iptc.newsml\r# text/vnd.iptc.nitf\r# text/vnd.latex-z\r# text/vnd.motorola.reflex\r# text/vnd.ms-mediapackage\r# text/vnd.net2phone.commcenter.command\r# text/vnd.si.uricatalogue\rtext/vnd.sun.j2me.app-descriptor\t\tjad\r# text/vnd.trolltech.linguist\r# text/vnd.wap.si\r# text/vnd.wap.sl\rtext/vnd.wap.wml\t\t\t\twml\rtext/vnd.wap.wmlscript\t\t\t\twmls\rtext/x-asm\t\t\t\t\ts asm\rtext/x-c\t\t\t\t\tc cc cxx cpp h hh dic\rtext/x-fortran\t\t\t\t\tf for f77 f90\rtext/x-pascal\t\t\t\t\tp pas\rtext/x-java-source\t\t\t\tjava\rtext/x-setext\t\t\t\t\tetx\rtext/x-uuencode\t\t\t\t\tuu\rtext/x-vcalendar\t\t\t\tvcs\rtext/x-vcard\t\t\t\t\tvcf\r# text/xml\r# text/xml-external-parsed-entity\r# video/1d-interleaved-parityfec\rvideo/3gpp\t\t\t\t\t3gp\r# video/3gpp-tt\rvideo/3gpp2\t\t\t\t\t3g2\r# video/bmpeg\r# video/bt656\r# video/celb\r# video/dv\r# video/example\rvideo/h261\t\t\t\t\th261\rvideo/h263\t\t\t\t\th263\r# video/h263-1998\r# video/h263-2000\rvideo/h264\t\t\t\t\th264\r# video/h264-rcdo\r# video/h264-svc\rvideo/jpeg\t\t\t\t\tjpgv\r# video/jpeg2000\rvideo/jpm\t\t\t\t\tjpm jpgm\rvideo/mj2\t\t\t\t\tmj2 mjp2\r# video/mp1s\r# video/mp2p\r# video/mp4v-es\rvideo/mp2t\t\t\t\t\tts\rvideo/mp4\t\t\t\t\tmp4 mp4v mpg4 m4v\rvideo/mpeg\t\t\t\t\tmpeg mpg mpe m1v m2v\r# video/mpeg4-generic\r# video/mpv\r# video/nv\rvideo/ogg\t\t\t\t\togv\r# video/parityfec\r# video/pointer\rvideo/quicktime\t\t\t\t\tqt mov\r# video/raw\r# video/rtp-enc-aescm128\r# video/rtx\r# video/smpte292m\r# video/ulpfec\r# video/vc1\r# video/vnd.cctv\rvideo/vnd.dece.hd\t\t\t\tuvh uvvh\rvideo/vnd.dece.mobile\t\t\t\tuvm uvvm\r# video/vnd.dece.mp4\rvideo/vnd.dece.pd\t\t\t\tuvp uvvp\rvideo/vnd.dece.sd\t\t\t\tuvs uvvs\rvideo/vnd.dece.video\t\t\t\tuvv uvvv\r# video/vnd.directv.mpeg\r# video/vnd.directv.mpeg-tts\r# video/vnd.dlna.mpeg-tts\rvideo/vnd.fvt\t\t\t\t\tfvt\r# video/vnd.hns.video\r# video/vnd.iptvforum.1dparityfec-1010\r# video/vnd.iptvforum.1dparityfec-2005\r# video/vnd.iptvforum.2dparityfec-1010\r# video/vnd.iptvforum.2dparityfec-2005\r# video/vnd.iptvforum.ttsavc\r# video/vnd.iptvforum.ttsmpeg2\r# video/vnd.motorola.video\r# video/vnd.motorola.videop\rvideo/vnd.mpegurl\t\t\t\tmxu m4u\rvideo/vnd.ms-playready.media.pyv\t\tpyv\r# video/vnd.nokia.interleaved-multimedia\r# video/vnd.nokia.videovoip\r# video/vnd.objectvideo\r# video/vnd.sealed.mpeg1\r# video/vnd.sealed.mpeg4\r# video/vnd.sealed.swf\r# video/vnd.sealedmedia.softseal.mov\rvideo/vnd.uvvu.mp4\t\t\t\tuvu uvvu\rvideo/vnd.vivo\t\t\t\t\tviv\rvideo/x-dv\t\t\tdv dif\rvideo/webm\t\t\t\t\twebm\rvideo/x-f4v\t\t\t\t\tf4v\rvideo/x-fli\t\t\t\t\tfli\rvideo/x-flv\t\t\t\t\tflv\rvideo/x-m4v\t\t\t\t\tm4v\rvideo/x-ms-asf\t\t\t\t\tasf asx\rvideo/x-ms-wm\t\t\t\t\twm\rvideo/x-ms-wmv\t\t\t\t\twmv\rvideo/x-ms-wmx\t\t\t\t\twmx\rvideo/x-ms-wvx\t\t\t\t\twvx\rvideo/x-msvideo\t\t\t\t\tavi\rvideo/x-sgi-movie\t\t\t\tmovie\rx-conference/x-cooltalk\t\t\t\tice\r", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kRegexRequestLine, Type = String, Dynamic = False, Default = \"^([^\\s\\r\\n]+) ([^\\\?\\r\\n]+)(\\\?([^\\r\\n]+))\? ([^\\r\\n]+)$\r", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusAccepted, Type = Double, Dynamic = False, Default = \"202", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusBadGateway, Type = Double, Dynamic = False, Default = \"502", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusBadRequest, Type = Double, Dynamic = False, Default = \"400", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusBandwidthLimitExceeded, Type = Double, Dynamic = False, Default = \"509", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusConflict, Type = Double, Dynamic = False, Default = \"409", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusContinue, Type = Double, Dynamic = False, Default = \"100", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusCreated, Type = Double, Dynamic = False, Default = \"201", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusExpectationFailed, Type = Double, Dynamic = False, Default = \"417", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusForbidden, Type = Double, Dynamic = False, Default = \"403", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusFound, Type = Double, Dynamic = False, Default = \"302", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusGatewayTimeout, Type = Double, Dynamic = False, Default = \"504", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusGone, Type = Double, Dynamic = False, Default = \"410", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusHTTPVersionNotSupported, Type = Double, Dynamic = False, Default = \"505", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusImATeapot, Type = Double, Dynamic = False, Default = \"418", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusInternalServerError, Type = Double, Dynamic = False, Default = \"500", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusLengthRequired, Type = Double, Dynamic = False, Default = \"411", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusMethodNotAllowed, Type = Double, Dynamic = False, Default = \"405\r", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusMovedPermanently, Type = Double, Dynamic = False, Default = \"301", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusMultipleChoices, Type = Double, Dynamic = False, Default = \"300", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusNoContent, Type = Double, Dynamic = False, Default = \"204", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusNonAuthoritativeInformation, Type = Double, Dynamic = False, Default = \"203", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusNotAcceptable, Type = Double, Dynamic = False, Default = \"406", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusNotFound, Type = Double, Dynamic = False, Default = \"404", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusNotImplemented, Type = Double, Dynamic = False, Default = \"501", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusNotModified, Type = Double, Dynamic = False, Default = \"304", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusOK, Type = Double, Dynamic = False, Default = \"200", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusPartialContent, Type = Double, Dynamic = False, Default = \"206", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusPaymentRequired, Type = Double, Dynamic = False, Default = \"402", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusPreconditionFailed, Type = Double, Dynamic = False, Default = \"412", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusProxyAuthenticationRequired, Type = Double, Dynamic = False, Default = \"407", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusRequestedRangeNotSatisfiable, Type = Double, Dynamic = False, Default = \"416", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusRequestEntityTooLarge, Type = Double, Dynamic = False, Default = \"413", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusRequestTimeout, Type = Double, Dynamic = False, Default = \"408", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusRequestURITooLong, Type = Double, Dynamic = False, Default = \"414", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusResetContent, Type = Double, Dynamic = False, Default = \"205", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusSeeOther, Type = Double, Dynamic = False, Default = \"303", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusServiceUnavailable, Type = Double, Dynamic = False, Default = \"503", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusSwitchingProtocols, Type = Double, Dynamic = False, Default = \"101", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusTemporaryRedirect, Type = Double, Dynamic = False, Default = \"307", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusUnauthorized, Type = Double, Dynamic = False, Default = \"401", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusUnsupportedMediaType, Type = Double, Dynamic = False, Default = \"415", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kStatusUseProxy, Type = Double, Dynamic = False, Default = \"305", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kVersion, Type = String, Dynamic = False, Default = \"HTTP/1.1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = VersionLongString, Type = String, Dynamic = False, Default = \"Kanjo HTTP Server 0.1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = VersionShortString, Type = String, Dynamic = False, Default = \"0.1", Scope = Protected
	#tag EndConstant


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
End Module
#tag EndModule
