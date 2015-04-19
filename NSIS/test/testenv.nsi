; ---------------------------------------
!define PRODUCT_NAME "MyApp"
!define APP_NAME "MyApp"
!define PRODUCT_WEB_SITE "http://localhost:8080/MyApp"
!define PRODUCT_VERSION "2.2.1"
!define ALL_USERS
!include WriteEnvStr.nsh
; --------------- -------------------------
SetCompressor zlib

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
Caption "${PRODUCT_NAME}"
Icon "${NSISDIR}\Contrib\Graphics\Icons\MyApp.ico "
OutFile "${PRODUCT_NAME}.exe"
LoadLanguageFile "${NSISDIR}\Contrib\Language files\English.nlf"

CRCCheck on
SilentInstall normal
XPStyle on
AutoCloseWindow false
ShowInstDetails show


InstallDir "c:\MyApp"
InstallDirRegKey HKLM "Software\LineManage""Install_Dir"
LicenseText "If you accept all terms of the agreement, select [I Agree] continue. You must accept the agreement to install ${PRODUCT_NAME} ${PRODUCT_VERSION}"
LicenseData "licence.txt "

RequestExecutionLevel user
; -------------------- ------------
Page license
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles
; - -------------------------------
Section "Installing ${PRODUCT_NAME}"
WriteRegStr HKLM "SOFTWARE\${APP_NAME}""Install_Dir""$INSTDIR"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}""DisplayName""${PRODUCT_NAME}${PRODUCT_VERSION}"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}""UninstallString"'"$INSTDIR\uninstall.exe"'

SetOutPath $INSTDIR
File /r Prerequisites\tomcat
File /r Prerequisites\MyApp.war
File /r Prerequisites\mysql.exe
File /r ico.ico
call installShortcut
call addEnv
Call installService
Call startService
WriteUninstaller "uninstall.exe"
SectionEnd
; ---------------------------- ----
UninstallText "delete ${PRODUCT_NAME}?click next to continue."
UninstallIcon "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico "

Section "Uninstall"
DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
DeleteRegKey HKLM "SOFTWARE\${APP_NAME}"
call un.stopService
call un.removeService
call un.removeEnv
RMDir /r "$SMPROGRAMS\${APP_NAME}"
RMDir /r "$INSTDIR"
SectionEnd
; ------------------ ------------------
Function .onInstSuccess
MessageBox MB_OK "You have successfully installed ${PRODUCT_NAME}. Tomcat will now start automatically"
SetOutPath "$INSTDIR\tomcat\bin"
ExecWait "startup.bat"
;MessageBox MB_OK "Tomcat is starting. Start MyApp"
ExecShell open "http://localhost:8080/MyApp"
FunctionEnd
; ------------------------------------
function "installShortcut"
WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url""InternetShortcut""URL""${PRODUCT_WEB_SITE}"
CreateDirectory "$SMPROGRAMS\${APP_NAME}"
CreateShortCut "$SMPROGRAMS\${APP_NAME}\Start ${APP_NAME}.lnk""http://localhost:8080/MyApp""""$INSTDIR\ico\ico.ico"
CreateShortCut "$SMPROGRAMS\${APP_NAME}\uninstall ${APP_NAME}.lnk" "$INSTDIR\uninstall.exe"
CreateShortCut "$DESKTOP\MyApp.lnk""http://localhost:8080/MyApp""""$INSTDIR\ico\ico.ico"
functionend
; ----------------------- ------------
function "addEnv"
Push JAVA_HOME
Push "$ProgramFiles\Java\jdk1.7.0_21"
Call WriteEnvStr
Push CATALINA_HOME
Push "$INSTDIR\tomcat"
Call WriteEnvStr

StrCpy $R0 "$ProgramFiles\Java\jdk1.7.0_21"
StrCpy $R1 "$INSTDIR\tomcat"
System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i ("JAVA_HOME",R0).r2'
System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i ("CATALINA_HOME",R1).r2'
functionend
; ---- -------------------------------
; attention, window service name can not have an underscore
function "installService"
ExecWait "$INSTDIR\mysql\bin\mysqld -install MysqlLM -defaults-file=$INSTDIR\mysql\my.ini"
SetOutPath "$INSTDIR\tomcat\bin"
ExecWait "service.bat install"
ExecWait "sc config tomcat6 start = auto"
functionend
; -------------------------------------
function "startService"
ExecWait "net start MysqlLM"
ExecWait "net start tomcat6"
ExecWait "net stop tomcat6"
ExecWait " net start tomcat6 "
functionend
; ---------------------------------- ---
function "un.stopService"
ExecWait "net stop MysqlLM"
ExecWait "net stop tomcat6"
functionend
; -----------------------------------
function "un.removeService"
ExecWait "$INSTDIR\mysql\bin\mysqld -remove MysqlLM"
ExecWait "$INSTDIR\tomcat\bin\service.bat remove tomcat6"
functionend
; ---------------------------------
function "un.removeEnv" ;
; For testing only - no need to remove JAVA_HOME from ENV variables
;Push JAVA_HOME
;Call un.DeleteEnvStr
Push CATALINA_HOME
Call un.DeleteEnvStr
functionend

;Function that calls a messagebox when installation finished correctly
;Function .onInstSuccess
;  MessageBox MB_OK "You have successfully installed ${PRODUCT_NAME}. Use the desktop icon to start the program."
;FunctionEnd
 
 
Function un.onUninstSuccess
  MessageBox MB_OK "You have successfully uninstalled ${PRODUCT_NAME}."
FunctionEnd