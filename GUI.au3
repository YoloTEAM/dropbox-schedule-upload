#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /sf /sv /soi /mi
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Winhttp.au3>
#include <WinAPI.au3>
#include <File.au3>

$hOpen = _WinHttpOpen()
$hConnect = _WinHttpConnect($hOpen, "api.dropboxapi.com")
$hConnect1 = _WinHttpConnect($hOpen, "content.dropboxapi.com")
$hConnect2 = _WinHttpConnect($hOpen, "api.ipify.org")

$IP = 0
$token = 0
$filePath = 0
$fileName = 0
$backupTime = 0
$autoMoney = 0

$hGUI = GUICreate("[YoloTEAM] Back2Drop", 430, 80, -1, -1)
GUISetBkColor(0x0080FF)
$hIToken = GUICtrlCreateInput("", 130, 9, 290, 20)
GUICtrlSetFont(-1, 8.5, 400, 0, "Tahoma", 5)
GUICtrlCreateLabel("API Access Token", 10, 12, 100, 15)
GUICtrlSetColor(-1, 0xFFFF00)
GUICtrlSetFont(-1, 8.5, 800, 0, "Tahoma", 5)
GUICtrlCreateLabel("Every", 220, 46, 35, 15)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 8.5, 800, 0, "Tahoma", 5)
$hBStart = GUICtrlCreateButton("Start", 360, 35, 60, 35)
GUICtrlSetState(-1, 128)
GUICtrlSetFont(-1, 8.5, 800, 0, "Tahoma")
$hLHelp = GUICtrlCreateLabel("?", 116, 11, 10, 15)
GUICtrlSetTip(-1, "How to get API Access Token?")
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 9, 800, 4, "Tahoma")
$hIBackupTime = GUICtrlCreateInput(10, 260, 43, 50, 20, 0x2000)
GUICtrlSetFont(-1, 8.5, 400, 0, "Tahoma", 5)
GUICtrlCreateLabel("Minute", 315, 46, 40, 15)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 8.5, 800, 0, "Tahoma")
GUICtrlCreateLabel("Upload File", 12, 46, 62, 15)
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetFont(-1, 8.5, 800, 0, "Tahoma")
$hLFilename = GUICtrlCreateLabel("[file_name]", 130, 46, 80, 15)
GUICtrlSetColor(-1, 0xFFFF00)
GUICtrlSetFont(-1, 8.5, 800, 0, "Tahoma", 5)
$hBChooseFile = GUICtrlCreateButton("...", 80, 43, 30, 20)
GUICtrlSetFont(-1, 9, 400, 0, "Tahoma", 5)
GUISetState()

While 1
	Switch GUIGetMsg()
		Case -3
			Exit
		Case $hLHelp
			_Help()
		Case $hBChooseFile
			_filePath()
		Case $hBStart
			_Back2Drop()
	EndSwitch
WEnd

Func _Help()
	ShellExecute("https://blogs.dropbox.com/developers/2014/05/generate-an-access-token-for-your-own-account/")
	ShellExecute("https://mmo4me.com/threads/yoloteam-back2drop-upload-file-len-dropbox-theo-thoi-gian-dinh-san-autoit-co-share-ma-nguon.274491/")
	ShellExecute("http://yoloteam.org/")
EndFunc   ;==>_Help

Func _filePath()
	Local $sFileOpenDialog = _WinAPI_GetOpenFileName("Choose file to Upload", @WorkingDir & "\", "All (*.*)", 1)
	If Not @error Then
		FileChangeDir(@ScriptDir)
		$filePath = $sFileOpenDialog[1] & "\" & $sFileOpenDialog[2]
		$fileName = $sFileOpenDialog[2]
		GUICtrlSetTip($hLFilename, $filePath)
		If StringLen($sFileOpenDialog[2]) > 11 Then $sFileOpenDialog[2] = StringLeft($sFileOpenDialog[2], 9) & "..."
		GUICtrlSetData($hLFilename, "[" & $sFileOpenDialog[2] & "]")
		GUICtrlSetState($hBStart, 64)
	EndIf
EndFunc   ;==>_filePath

Func _Back2Drop()
	$token = StringStripWS(GUICtrlRead($hIToken), 8)
	If Not $token Then Return

	$backupTime = GUICtrlRead($hIBackupTime) * 60000
	If $backupTime < 1 Then
		GUICtrlSetData($hIBackupTime, 10)
		Return
	EndIf

	$accountInfo = _DropboxAPI_AccountInfo()
	If @error Then
		MsgBox(16, "Error Code: " & @extended, $accountInfo, 0, $hGUI)
		Return
	EndIf

	$IP = _WinHttpSimpleSSLRequest($hConnect2,"GET","/",Default,"https://api.ipify.org/")
	If Not $IP Then $IP = "NoIP" & TimerInit()

;~ 	ConsoleWrite($IP & @CRLF)

	WinSetTitle($hGUI, "", "[YoloTEAM] Back2Drop - Starting...")

	Sleep(5000)

	_DropboxAPI_Upload()

	Local $timeInit = TimerInit()

	Do
		If TimerDiff($timeInit) > $backupTime Then
			$dropUpload = _DropboxAPI_Upload()
			If @error Then _FileWriteLog(@ScriptDir & "\log.txt", $dropUpload)
		Else
			WinSetTitle($hGUI, "", "[YoloTEAM] Back2Drop - " & Round(($backupTime - TimerDiff($timeInit)) / 1000))
		EndIf

		Sleep(500)
	Until $autoMoney = 1
EndFunc   ;==>_Back2Drop

Func _DropboxAPI_Upload()
	WinSetTitle($hGUI, "", "[YoloTEAM] Back2Drop - Upload file...")

	Local $fileData = FileRead($filePath)

	Local $hRequest = _WinHttpOpenRequest($hConnect1, "POST", "/2-beta-2/files/upload", Default, Default, Default, $WINHTTP_FLAG_SECURE)
	_WinHttpAddRequestHeaders($hRequest, "Host: content.dropboxapi.com")
	_WinHttpAddRequestHeaders($hRequest, "Content-Type: application/octet-stream")
	_WinHttpAddRequestHeaders($hRequest, "Authorization: Bearer " & $token)
	_WinHttpAddRequestHeaders($hRequest, "User-Agent: yoloteamdotorg-back2drop")
	_WinHttpAddRequestHeaders($hRequest, 'Dropbox-API-Arg: {"path":"/[Yoloteam] Back2Drop/' & $IP & '/' & $fileName & '","mute":true,"mode":"overwrite"}')
	_WinHttpAddRequestHeaders($hRequest, "Content-Length: " & StringLen($fileData))
	_WinHttpSendRequest($hRequest, -1, $fileData)
	_WinHttpReceiveResponse($hRequest)
	Local $ResponeHeader = _WinHttpQueryHeaders($hRequest)
;~ 	ConsoleWrite($ResponeHeader & @CRLF)

	Local $Data = _WinHttpSimpleReadData($hRequest, 2)
	$Data = BinaryToString($Data, 4)
;~ 	ConsoleWrite($Data & @CRLF)

	_WinHttpCloseHandle($hRequest)

	If StringInStr($ResponeHeader, "HTTP/1.1 200 OK") Then
		Return SetError(0, 200, $Data)
	Else
		Return SetError(1, 400, $Data)
	EndIf
EndFunc   ;==>_DropboxAPI_Upload

Func _DropboxAPI_AccountInfo()
	Local $hRequest = _WinHttpOpenRequest($hConnect, "GET", "/1/account/info", Default, Default, Default, $WINHTTP_FLAG_SECURE)
	_WinHttpAddRequestHeaders($hRequest, "Host: api.dropboxapi.com")
	_WinHttpAddRequestHeaders($hRequest, "Content-Type: application/octet-stream")
	_WinHttpAddRequestHeaders($hRequest, "Authorization: Bearer " & $token)
	_WinHttpAddRequestHeaders($hRequest, "User-Agent: yoloteamdotorg-back2drop")
	_WinHttpSendRequest($hRequest, -1, "")
	_WinHttpReceiveResponse($hRequest)
	Local $ResponeHeader = _WinHttpQueryHeaders($hRequest)
;~ 	ConsoleWrite($ResponeHeader & @CRLF)

	Local $Data = _WinHttpSimpleReadData($hRequest, 2)
	$Data = BinaryToString($Data, 4)
;~ 	ConsoleWrite($Data & @CRLF)

	_WinHttpCloseHandle($hRequest)

	If StringInStr($ResponeHeader, "HTTP/1.1 200 OK") Then
		Return SetError(0, 200, $Data)
	Else
		Return SetError(1, 402, $Data)
	EndIf
EndFunc   ;==>_DropboxAPI_AccountInfo
