; Last changed date: 21/11/2024 00:08
; OS Version ...: Windows 10 x64 and Above (Support not guaranteed on Windows 7)
;@Ahk2Exe-SetName elModo7's NVM GUI
;@Ahk2Exe-SetDescription Graphical user interface for Node Version Manager (NVM).
;@Ahk2Exe-SetVersion 1.2
;@Ahk2Exe-SetCopyright Copyright (c) 2024`, elModo7
;@Ahk2Exe-SetOrigFilename NVM GUI.exe
#NoEnv
#SingleInstance Force
#Persistent
SetBatchLines, -1
global version := "1.2"
FileInstall, data/node_releases.json, % A_Temp "\node_releases.json", 0
gosub, RunAsAdmin
global userFolder, nodeVersions, nodeVersionsAvailable
global isVisible := 1
global windowTitle := "NVM GUI - elModo7 Soft"

; Tray Menu
Menu, Tray, NoStandard
Menu, Tray, Tip, NVM GUI elModo7 %version%
Menu, Tray, Add, Hide, toggleVisibility
Menu, Tray, Add, Look for Updates, lookForUpdates
Menu, Tray, Add
Menu, Tray, Add, Exit, ExitSub

userFolder := setUserFolder()
checkNVMInstalled(userFolder)

; GUI
neutron := new NeutronWindow()
neutron.Load("nvm_gui.html")
neutron.Gui("+LabelNeutron")
neutron.Show("w800 h500")
neutron.doc.getElementById("programDataJson").innerHTML := programDataJson ; Hidden Variable so that JS creates the table
Gui, Show, w800 h500, % windowTitle
showNodeVersionOnTitle()
getInstalledNodeVersions(userFolder)
Return

; INCLUDES
#Include <Util>
#Include <JSON>
#Include <Neutron>
#Include <RunCMD>

nodeSelect:
	if(A_GuiControlEvent == "DoubleClick"){
		GuiControlGet, nodeVersions,, nodeVersions
		;~ RunWait, % "cmd /c mklink /D ""C:\Program Files\nodejs"" C:\Users\" A_UserName "." getDomain() "\AppData\Roaming\nvm\" nodeVersions
		StringReplace, nodeVersionsWithoutV, nodeVersions, v,, All
		RunWait, % "nvm use " nodeVersionsWithoutV,, Hide
		GuiControl,, currentVersion, % "Now using: " nodeVersions
	}
return

checkNVMInstalled(userFolder){
	if(!FileExist("C:\Users\" userFolder "\AppData\Roaming\nvm\nvm.exe")){
		MsgBox 0x10, Fatal Error, NVM was not found!`n`nnvm.exe must be placed in this path:`n"C:\Users\" userFolder "\AppData\Roaming\nvm\nvm.exe"
		MsgBox 0x24, Download NVM, Do you want to go to the downloads page to download NVM Windows?
		IfMsgBox Yes, {
			Run, https://github.com/coreybutler/nvm-windows/releases
		}
		ExitApp
	}
}

neutronGetInstalledNodeVersions(unhandledParam := ""){
	global
	getInstalledNodeVersions(userFolder)
}

getInstalledNodeVersions(userFolder){
	global
	tableHtmlInstalled := ""
	Loop, Files, % "C:\Users\" userFolder "\AppData\Roaming\nvm\*", D
	{
			tableHtmlInstalled .= "<tr id='" A_LoopFileName "'><td>" A_LoopFileName "</td><td><button class='btn btn-secondary btn_half_size btn_set_default'><i class='fa fa-star'></i>  Set Default</button>  <button class='btn btn-danger btn_half_size btn_uninstall'><i class='fa fa-trash'></i>  Uninstall</button></td></tr>"
	}
	neutron.doc.getElementById("tableBody").innerHTML := tableHtmlInstalled
	neutron.wnd.bindButtonEvents()
}

getDownloadableNodeVersions(unhandledParam := ""){
	global
	;~ neutron.doc.getElementById("btnUpdateList").addClass()
	downloadNodeVersionList(0) ; Do not overwrite, download only if not exist
	FileRead, nodeVersionsAvailable, % A_Temp "\node_releases.json"
	nodeVersionsAvailable := JSON.Load(nodeVersionsAvailable)
	tableHtmlDownload := ""
	for, k, nodeVersion in nodeVersionsAvailable
	{
		tableHtmlDownload .= "<tr id='" nodeVersion.version "'><td>" nodeVersion.version "</td><td><button class='btn btn-success btn_install'><i class='fa fa-download'></i>  Download & Install</button></td></tr>"
	}
	neutron.doc.getElementById("tableBody").innerHTML := tableHtmlDownload
	neutron.wnd.bindButtonEvents()
}

uninstallNodeVersion(unhandledParam := "", version := ""){
	global
	neutron.wnd.showLoadingModal()
	RunWait, % "nvm uninstall " version,, Hide
	Sleep, 1000
	neutron.wnd.hideLoadingModal()
	Sleep, 300
	neutron.wnd.neutronGetInstalledNodeVersions()
}

installNodeVersion(unhandledParam := "", version := ""){
	global
	neutron.wnd.showLoadingModal()
	RunWait, % "nvm install " version,, Hide
	Sleep, 1000
	neutron.wnd.hideLoadingModal()
	Sleep, 300
	neutron.wnd.neutronGetInstalledNodeVersions()
}

useNodeVersion(unhandledParam := "", version := ""){
	global
	neutron.wnd.showLoadingModal()
	RunWait, % "nvm use " version,, Hide
	Sleep, 1000
	neutron.wnd.hideLoadingModal()
	Sleep, 300
	showNodeVersionOnTitle()
}

showNodeVersionOnTitle(){
	global
	neutron.doc.getElementById("wndTitle").innerHTML := "<span class='text-info'>Node.js Version Manager GUI v" version "</span>"
	neutron.doc.getElementById("nodeVersion").innerHTML := RunCMD("node -v")
}

closeApp(unhandledParam := ""){
	gosub, ExitSub
}

neutronDownloadNodeVersionList(unhandledParam := ""){
	downloadNodeVersionList(1)
	getDownloadableNodeVersions()
}

downloadNodeVersionList(overwrite := 1){
	global
	if(overwrite || !FileExist(A_Temp "\node_releases.json")){
		neutron.wnd.showLoadingModal()
		FileDelete, % A_Temp "\node_releases.json"
		URLDownloadToFile, https://nodejs.org/download/release/index.json, % A_Temp "\node_releases.json"
		Sleep, 1000
		neutron.wnd.hideLoadingModal()
	}
}

goToGitHub(unhandledParam := ""){
	Run, https://github.com/elModo7
}

goToNVMGithub(unhandledParam := ""){
	Run, https://github.com/coreybutler/nvm-windows
}

toggleVisibility:
	DetectHiddenWindows, On
	if isVisible
	{
		WinHide, % windowTitle
		if(!nogui)
			Menu, tray, Rename, Hide, Show
		isVisible = 0
	}
	else
	{
		WinShow, % windowTitle
		WinActivate, % windowTitle
		if(!nogui)
			Menu, tray, Rename, Show, Hide
		isVisible = 1
	}
return

; This is still a placeholder
lookForUpdates:
	gitHubData := JSON.Load(urlDownloadToVar("https://api.github.com/repos/elModo7/NVM_GUI-win/releases/latest"))
	gitHubVersion := gitHubData.tag_name
	versionDiff := VerCmp(gitHubVersion, version)
	if(versionDiff == "-1"){
		neutron.doc.getElementById("msgVersionCheck").innerHTML := "Your NVM GUI is more recent than the current public version:<br>Local: v" version "<br>Remote: v" gitHubVersion
	}else if(versionDiff == "0"){
		neutron.doc.getElementById("msgVersionCheck").innerHTML := "NVM GUI is up to date:<br>Local: v" version "<br>Remote: v" gitHubVersion
	}else if(versionDiff == "1"){
		neutron.doc.getElementById("msgVersionCheck").innerHTML := "There is a new NVM GUI version:<br>Local: v" version "<br>Remote: v" gitHubVersion "<br><br><a href='#' onclick='ahk.downloadLatestVersion()'>You can download it by clicking this message.</a>"
	}
	neutron.wnd.showVersionCheckModal()
return

NeutronClose:
GuiClose:
ExitSub:
ExitApp

; Neutron's FileInstall Resources
FileInstall, nvm_gui.html, nvm_gui.html
FileInstall, bootstrap.min.css, bootstrap.min.css
FileInstall, font-awesome.min.css, font-awesome.min.css
FileInstall, bootstrap.min.js, bootstrap.min.js
FileInstall, jquery.min.js, jquery.min.js
FileInstall, fontawesome-webfont.woff, fontawesome-webfont.woff