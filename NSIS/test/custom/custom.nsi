;Author: Joey Cz.
;Contact: psyalien69 [at] yahoo [dot] com
 
 
; Modern interface settings
!include "MUI.nsh"
!include WinMessages.nsh
 
; Define your application name
!define APPNAME "Add-on Installer Sample"
!define APPNAMEANDVERSION "${APPNAME} 1.0"
!define APP_INST_DIR $8
;define global APP Database Dir alias
!define APP_DB_DIR $9
!define MUI_ABORTWARNING
 
; Window handle of the custom page
Var hwnd
; Install type variables
Var dbInst
Var fullInst
Var autoInst
 
; The name of the installer
Name "${APPNAMEANDVERSION}"
InstallDir ""
InstallDirRegKey HKLM "Software\${APPNAMEANDVERSION}" ""
 
; The installer file
OutFile "${APPNAMEANDVERSION} Installer.exe"
 
; Show install details
ShowInstDetails show
 
; Called before anything else as installer initialises
Function .onInit
	;NOTE:
	;	following is a sample for reading from the Registry
 
  ; read the APP installation directory from the registry
  ReadRegStr ${APP_INST_DIR} HKLM "Software\Vendor\App\Version" "InstallDir"
  ; read the database location if APP installation was found
  ReadRegStr ${APP_DB_DIR} HKCU "Software\Vendor\App\Version" "Database File Type"
 
  ; Check for APP installation existence
  StrCmp ${APP_INST_DIR} "" 0 NoAbortInst
         MessageBox MB_OK "APP installtion was not found.  Please install APP before runing this installer."
         Abort ; abort if APP installation is not found
  NoAbortInst:
 
  ; Check for APP Database dir existence
  StrCmp ${APP_DB_DIR} "" 0 NoAbortDb
         MessageBox MB_OK "APP Database location was not defined.  Please configure APP before runing this installer."
         Abort ; abort if APP installation is not found
  NoAbortDb:
 
  ; ExtrAPP InstallOptions files
  ; $PLUGINSDIR will automatically be removed when the installer closes
  InitPluginsDir
  File /oname=$PLUGINSDIR\test.ini "installtype.ini"
 
FunctionEnd
 
; NOTE :
; ************************
; Pages Displayed in order
; ************************
 
; Welcome Page
!insertmacro MUI_PAGE_WELCOME
 
; License Page
!insertmacro MUI_PAGE_LICENSE "License.txt"
 
; Our custom page
;Page custom ShowCustom LeaveCustom ": Select Install Type"
Page custom ShowCustom LeaveCustom
 
; APP Installation directory Page
!define MUI_DIRECTORYPAGE_VARIABLE ${APP_INST_DIR}
!define MUI_PAGE_HEADER_TEXT "APP Installation folder location."
!define MUI_PAGE_HEADER_SUBTEXT ""
!define MUI_DIRECTORYPAGE_TEXT_TOP "Please select the folder where APP has been installed.  If you are unsure where APP! has been installed, please keep the default value."
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "APP Folder"
!define MUI_DIRECTORYPAGE_VERIFYONLEAVE
!define MUI_PAGE_CUSTOMFUNCTION_PRE APPInstallDirectoryPage_Pre
!insertmacro MUI_PAGE_DIRECTORY
 
; APP Database directory Page
!define MUI_DIRECTORYPAGE_VARIABLE ${APP_DB_DIR}
!define MUI_PAGE_HEADER_TEXT "APP Database folder location."
!define MUI_PAGE_HEADER_SUBTEXT ""
!define MUI_DIRECTORYPAGE_TEXT_TOP "Please select the folder where APP! keeps its Database files.  If you are unsure where the APP! Database folder is, please keep the default value."
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "APP Database Folder"
!define MUI_PAGE_CUSTOMFUNCTION_PRE APPDBDirectoryPage_Pre
!insertmacro MUI_PAGE_DIRECTORY
 
; Components Page
!define MUI_COMPONENTSPAGE_TEXT_TOP "Select the Components you want to install and uncheck the ones you you do not want to install. Click next to continue."
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_TITLE "Description"
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_INFO "Description info"
!define MUI_PAGE_CUSTOMFUNCTION_PRE ComponentsPage_Pre
!insertmacro MUI_PAGE_COMPONENTS
 
; Install Files Page
!insertmacro MUI_PAGE_INSTFILES
 
; Finish Page
!define MUI_FINISHPAGE_RUN "${APP_INST_DIR}\APP.exe"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME "${APP_INST_DIR}\MyAddon\Readme.txt"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!insertmacro MUI_PAGE_FINISH
 
; Uninstall Confirm Page
!insertmacro MUI_UNPAGE_CONFIRM
 
; Uninstall Files Page
!insertmacro MUI_UNPAGE_INSTFILES
 
; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL
 
Function APPInstallDirectoryPage_Pre
 
    StrCmp $autoInst true 0 end
;        MessageBox MB_ICONEXCLAMATION|MB_OK "install dir PRE page"
        Abort
 
    end:
FunctionEnd
 
Function APPDBDirectoryPage_Pre
 
    StrCmp $autoInst true 0 end
;        MessageBox MB_ICONEXCLAMATION|MB_OK "db dir PRE page"
        Abort
 
    end:
 
FunctionEnd
 
Function ComponentsPage_Pre
 
    StrCmp $autoInst true 0 end
;        MessageBox MB_ICONEXCLAMATION|MB_OK "component PRE page"
        Abort
 
    end:
 
FunctionEnd
 
Function ShowCustom
  InstallOptions::initDialog /NOUNLOAD "$PLUGINSDIR\test.ini"
  ; In this mode InstallOptions returns the window handle so we can use it
  Pop $hwnd
 
  !insertmacro MUI_HEADER_TEXT "Installation Type" "Please select the installation type, then click Next to proceede with the install."
 
  ; Now show the dialog and wait for it to finish
  InstallOptions::show
  ; Finally fetch the InstallOptions status value (we don't care what it is though)
  Pop $0
 
 
 
FunctionEnd
 
Function LeaveCustom
 
  ; At this point the user has either pressed Next or one of our custom buttons
  ; We find out which by reading from the INI file
  ReadINIStr $0 "$PLUGINSDIR\test.ini" "Settings" "State"
  StrCmp $0 0 validate  ; Next button?
  StrCmp $0 2 automaticRadio ; Automatic install
  StrCmp $0 3 customRadio  ; custom install
  StrCmp $0 7 comboBox ; Full install or DB
  Abort ; Return to the page
 
automaticRadio:
   GetDlgItem $1 $hwnd 1206 ; PathRequest control (1200 + field 7 - 1)
   EnableWindow $1 1
 
   Abort ; Return to the page
 
customRadio:
   WriteINIStr "$PLUGINSDIR\test.ini" "Field 7" "Flags" "DISABLED"
   GetDlgItem $1 $hwnd 1206 ; PathRequest control (1200 + field 7 - 1)
   EnableWindow $1 0
 
   Abort ; Return to the page
 
comboBox:
   Abort ; Return to the page
 
validate:
 
   ReadINIStr $0 "$PLUGINSDIR\test.ini" "Field 2" "State"
   StrCmp $0 1 automaticInst
   ReadINIStr $0 "$PLUGINSDIR\test.ini" "Field 3" "State"
   StrCmp $0 1 customInst
 
automaticInst:
   StrCpy $autoInst true
   Call AutomaticInstall
   Goto done
 
customInst:
   StrCpy $autoInst false
   Call CustomInstall
 
done:
FunctionEnd
 
Function AutomaticInstall
   ;MessageBox MB_ICONEXCLAMATION|MB_OK "You selected Automatic install"
 
   ReadINIStr $0 "$PLUGINSDIR\test.ini" "Field 7" "State"
   StrCmp $0 "Database Only" dbonly full
   full:
      StrCpy $fullInst true
      StrCpy $dbInst true
      Goto end
 
   dbonly:
      StrCpy $fullInst false
      StrCpy $dbInst true
 
   end:
FunctionEnd
 
Function CustomInstall
   ;MessageBox MB_ICONEXCLAMATION|MB_OK "You selected Custom install"
 
FunctionEnd
 
Section "Database" DBSection
 
	StrCmp $dbInst true dbFiles done
	dbFiles:
		;MessageBox MB_ICONEXCLAMATION|MB_OK "Installing DB Files"
 
		; Set Section properties
		SetOverwrite try
 
		; Set Section Files and Shortcuts
		SetOutPath "${APP_DB_DIR}\MyAddon\"
 
		File "Database\File1"
		File "Database\File2"
		File "Database\File3"
 
 
	done:
		;MessageBox MB_ICONEXCLAMATION|MB_OK "DONE Installing DB Files"
 
SectionEnd
 
SubSection /e "!Add-On Files" AddOnSection
	Section "Layout" LayoutSection
		StrCmp $fullInst true layout done
		layout:
			;MessageBox MB_ICONEXCLAMATION|MB_OK "Installing Layout Files"
			; LAYOUT SECTION
			; Set Section properties
			SetOverwrite try
 
			; Set Section Files and Shortcuts
			SetOutPath "${APP_INST_DIR}\Layout"
			File "Layout\File1"
			File "Layout\File2"
		done:
				;MessageBox MB_ICONEXCLAMATION|MB_OK "DONE Installing Layout Files"
 
	SectionEnd
 
	Section "Templates" TemplatesSection
		StrCmp $fullInst true templates done
		templates:
			;MessageBox MB_ICONEXCLAMATION|MB_OK "Installing Template Files"
			; TEMPLATE SECTION
			; Set Section Files and Shortcuts
			SetOutPath "${APP_INST_DIR}\Template\To Insured\"
			File "Template\File1"
			File "Template\File2"
			File "Template\File3"
 
		done:
			;MessageBox MB_ICONEXCLAMATION|MB_OK "DONE Installing Template Files"
	SectionEnd
 
	Section "Reports" ReportsSection
		StrCmp $fullInst true reports done
		reports:
			;MessageBox MB_ICONEXCLAMATION|MB_OK "Installing Reports Files"
			; REPORTS SECTION
			; Set Section Files and Shortcuts
			SetOutPath "${APP_INST_DIR}\Report"
			File "Report\File1"
 
		done:
			;MessageBox MB_ICONEXCLAMATION|MB_OK "DONE Installing Reports Files"
 
	SectionEnd
 
	Section "Documentation" DocumentationSection
		;MessageBox MB_ICONEXCLAMATION|MB_OK "Installing Documentation Files"
 
		; DOCUMENTATION SECTION
		; Set Section Files and Shortcuts
		SetOutPath "${APP_INST_DIR}\MyAddon\"
		File "Readme.txt"
		File "License.txt"
	SectionEnd
 
SubSectionEnd
 
Section -FinishSection
	; set the default layout for APP
	WriteRegStr HKCU "Software\Symantec\APP\Database" "Layout" "${APP_INST_DIR}\Layout\FILE1"
 
	; set the default database for APP
	WriteRegStr HKCU "Software\Symantec\APP\Database" "Database Name" "${APP_DB_DIR}\MyAddon\DBFILE"
 
	; set the default Word Procesor for APP
	WriteRegStr HKCU "Software\Symantec\APP" "WPDefaultDriver" "APPWrite"
 
	; set uninstall stuff
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAMEANDVERSION}" "DisplayName" "${APPNAMEANDVERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAMEANDVERSION}" "UninstallString" "${APP_DB_DIR}\MyAddon\uninstall.exe"
	CreateDirectory "${APP_INST_DIR}\MyAddon"
	WriteUninstaller "${APP_INST_DIR}\MyAddon\uninstall.exe"
 
	CreateDirectory "$SMPROGRAMS\${APPNAMEANDVERSION}"
	CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\Uninstall.lnk" "${APP_INST_DIR}\MyAddon\uninstall.exe"
	CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\Operating Manual.lnk" "${APP_INST_DIR}\MyAddon\Installation and Operating Manual.doc"
	CreateShortCut "$DESKTOP\${APPNAMEANDVERSION}.lnk" "${APP_DB_DIR}\MyAddon\FILE"
	CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\${APPNAMEANDVERSION}.lnk" "${APP_DB_DIR}\MyAddon\FILE"
 
SectionEnd
 
; Modern install component descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${DBSection} "MyAddon Database files for APP"
	!insertmacro MUI_DESCRIPTION_TEXT ${AddOnSection} "MyAddon Add-On files"
	!insertmacro MUI_DESCRIPTION_TEXT ${LayoutSection} "- Layout Files"
	!insertmacro MUI_DESCRIPTION_TEXT ${TemplatesSection} "- Template Files"
	!insertmacro MUI_DESCRIPTION_TEXT ${ReportsSection} "- Report Files"
	!insertmacro MUI_DESCRIPTION_TEXT ${DocumentationSection} "- Documentation Files"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;Uninstall section
Section Uninstall
	; read APP Installation dir from registry
	ReadRegStr ${APP_INST_DIR} HKLM "Software\Vendor\APP\Version" "InstallDir"
	; read APP Database dir from registry
	ReadRegStr ${APP_DB_DIR} HKCU "Software\Vendor\APP\Version" "Database File Type"
 
	;Remove installer misc stuff from registry...
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAMEANDVERSION}"
	DeleteRegKey HKLM "SOFTWARE\${APPNAMEANDVERSION}"
 
	; Delete self
	Delete "${APP_INST_DIR}\MyAddon\uninstall.exe"
 
	; Clean up Documenation
	Delete "${APP_INST_DIR}\MyAddon\Readme.txt"
	Delete "${APP_INST_DIR}\MyAddon\License.txt"
	Delete "${APP_INST_DIR}\MyAddon\File1"
	Delete "${APP_INST_DIR}\MyAddon\File2"
  Delete "${APP_INST_DIR}\MyAddon\File3"
	; etc..
 
	RMDir "${APP_INST_DIR}\MyAddon"
 
 
	; Delete Shortcuts
	Delete "$DESKTOP\${APPNAMEANDVERSION}.lnk"
	Delete "$SMPROGRAMS\${APPNAMEANDVERSION}\${APPNAMEANDVERSION}.lnk"
	Delete "$SMPROGRAMS\${APPNAMEANDVERSION}\Uninstall.lnk"
 
	; Clean up MyAddon Insurance Database
	Delete "${APP_DB_DIR}\MyAddon\File1"
	; etc..
 
	; Clean up MyAddon Insurance Layout
	Delete "${APP_INST_DIR}\Layout\File1"
	; etc..
 
	; Clean up MyAddon Report files
	Delete "${APP_INST_DIR}\Report\File1"
	; etc..
 
	; Clean up MyAddon Templates
	Delete "${APP_INST_DIR}\Template\File1"
	; etc..
 
	; Remove remaining directories
	RMDir "$SMPROGRAMS\${APPNAMEANDVERSION}"
	RMDir "${APP_DB_DIR}"
	; etc..
 
SectionEnd