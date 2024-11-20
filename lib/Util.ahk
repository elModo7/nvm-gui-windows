getDomain(){
	/*objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\cimv2")
	For objComputer in objWMIService.ExecQuery("Select * from Win32_ComputerSystem") {
		Domain := objComputer.Domain, Workgroup := objComputer.Workgroup
	}
	*/
	EnvGet, userDomain, USERDOMAIN
	return userDomain
}

setUserFolder(){
	if(FileExist("C:\Users\" A_UserName "." getDomain() "\AppData\Roaming\nvm\nvm.exe")){
		return A_UserName "." getDomain()
	}else if(FileExist("C:\Users\" A_UserName "\AppData\Roaming\nvm\nvm.exe")){
		return A_UserName ; Maybe I change this for a portable NVM path select
	}
	return A_UserName
}

RunAsAdmin:
	params := ""
	if 0>0
	{
		Loop, %0%  ; For each parameter:
		{
			param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
			params .= A_Space . param
		}
	}
	If A_IsCompiled
	{
		if not A_IsAdmin
		{
		   DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
		   ExitApp
		}
	}
	Else
	{
		if not A_IsAdmin
		{
		   DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
		   ExitApp
		}
	}
return

downloadLatestVersion(unhandledParam := ""){
	Run, https://github.com/elModo7/Tunnel_Manager/releases/latest
}

; Since VerCompare is > 1.1.36.1 I will use this to keep compatibility with lower versions of AHK
VerCmp(V1, V2) {           ; VerCmp() for Windows by SKAN on D35T/D37L @ tiny.cc/vercmp 
Return ( ( V1 := Format("{:04X}{:04X}{:04X}{:04X}", StrSplit(V1 . "...", ".",, 5)*) )
       < ( V2 := Format("{:04X}{:04X}{:04X}{:04X}", StrSplit(V2 . "...", ".",, 5)*) ) )
       ? -1 : ( V2<V1 ) ? 1 : 0
}