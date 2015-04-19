; ################################################################
; appends \ to the path if missing
; example: !insertmacro GetCleanDir "c:\blabla"
; Pop $0 => "c:\blabla\"




!macro GetCleanDir INPUTDIR
  ; ATTENTION: USE ON YOUR OWN RISK!
  ; Please report bugs here: http://stefan.bertels.org/
  !define Index_GetCleanDir 'GetCleanDir_Line${__LINE__}'
  Push $R0
  Push $R1
  StrCpy $R0 "${INPUTDIR}"
  StrCmp $R0 "" ${Index_GetCleanDir}-finish
  StrCpy $R1 "$R0" "" -1
  StrCmp "$R1" "\" ${Index_GetCleanDir}-finish
  StrCpy $R0 "$R0\"
${Index_GetCleanDir}-finish:
  Pop $R1
  Exch $R0
  !undef Index_GetCleanDir
!macroend
 
; ################################################################
; appends \ to the path if missing and returns parent directory
; example: !insertmacro GetCleanDir "c:\blabla\subdir"
; Pop $0 => "c:\blabla\"
!macro GetCleanParentDir INPUTDIR
  ; ATTENTION: USE ON YOUR OWN RISK!
  ; Please report bugs here: http://stefan.bertels.org/
  !define Index_GetCleanParentDir 'GetCleanParentDir_Line${__LINE__}'
  Push $R0
  Push $R1
  Push $R2
  !insertmacro GetCleanDir "${INPUTDIR}"
  Pop $R0
  StrCpy $R1 "$R0"
${Index_GetCleanParentDir}-loop:
  StrCmp "$R1" "" ${Index_GetCleanParentDir}-finish
  StrCpy $R1 "$R1" -1
  StrCpy $R2 "$R1" "" -1
  StrCmp "$R2" "\" 0 ${Index_GetCleanParentDir}-loop
  StrCpy $R0 "$R1"
${Index_GetCleanParentDir}-finish:
  Pop $R2
  Pop $R1
  Exch $R0
  !undef Index_GetCleanParentDir
!macroend
 
; ################################################################
; split "c:\test" into "c:" and "\test"
; split "\\server\share\test\test" into "\\server\share" and "\test\test"
; split other patterns into "" and "PATH"
; the two parts will be pushed on the stack
; get parts with Pop $drive and Pop $folder
!macro SplitPath PATH
  ; ATTENTION: USE ON YOUR OWN RISK!
  ; Please report bugs here: http://stefan.bertels.org/
  !define Index_SplitPath 'SplitPath_${__LINE__}'
  Push $R0
  StrCpy $R0 "${PATH}" ; $R0 contains PATH
  Push $R1
  Push $R2 ; number of the first "\" of folder part
  Push $R3
  Push $R4
 
  ; check for path type (c:\test or \\server\share\test)
  StrCpy $R2 $R0 2 0
  StrCmp $R2 "\\" 0 ${Index_SplitPath}-nounc
  StrCpy $R2 3
  StrLen $R1 $R0
  StrCpy $R4 -1
${Index_SplitPath}-loop:
  IntOp $R4 $R4 + 1
  IntCmp $R4 $R1 ${Index_SplitPath}-end
  StrCpy $R3 $R0 1 $R4
  StrCmp $R3 "\" 0 ${Index_SplitPath}-loop
  IntCmp $R2 0 ${Index_SplitPath}-split
  IntOp $R2 $R2 - 1
  Goto ${Index_SplitPath}-loop
${Index_SplitPath}-split:
  StrCpy $R1 $R0 "" $R4
  StrCpy $R0 $R0 $R4
  Goto ${Index_SplitPath}-finish
${Index_SplitPath}-end:
  StrCpy $R1 ""
  Goto ${Index_SplitPath}-finish
 
${Index_SplitPath}-nounc:
  StrCpy $R2 $R0 1 1
  StrCmp $R2 ":" 0 ${Index_SplitPath}-fallback
  StrCpy $R1 $R0 "" 2
  StrCpy $R0 $R0 2
  Goto ${Index_SplitPath}-finish
 
${Index_SplitPath}-fallback:
  StrCpy $R1 $R0
  StrCpy $R0 ""
${Index_SplitPath}-finish:
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R1 ; folder part
  Exch
  Exch $R0 ; drive part
  !undef Index_SplitPath
!macroend
 
; ################################################################
; mkdir DIRECTORY and return the part which already existed (BASEDIR)
!macro MakeDirBase DIRECTORY
  ; ATTENTION: USE ON YOUR OWN RISK!
  ; Please report bugs here: http://stefan.bertels.org/
  !define Index_MakeDirBase 'MakeDirBase_${__LINE__}'
  Push $R0
  StrCpy $R0 "${DIRECTORY}" ; $R0 contains DIRECTORY
  Push $R1 ; $R1 is tmp path (increasing)
  Push $R2 ; number of "\" to ignore (1 for c:\, 4 for \\server\share\)
  Push $R3 ; pos
  Push $R4 ; len
  Push $R5 ; tmp char
  Push $R6 ; BASEDIR (return value)
  ; save outdir
  Push $OUTDIR
 
  !insertmacro GetCleanDir $R0
  Pop $R0
  !insertmacro SplitPath $R0
  Pop $R1 ; drive
  Pop $R2 ; folder
  StrCmp $R1 "" ${Index_MakeDirBase}-fallback ; ohne Laufwerk/UNC?
  StrCpy $R3 $R2 1 0
  StrCmp $R3 "\" 0 ${Index_MakeDirBase}-fallback ; relativ?
 
  StrCpy $R3 0
  StrCpy $R1 "$R1\"
  StrCpy $R6 $R1
  StrLen $R4 $R2
${Index_MakeDirBase}-loop:
  IntOp $R3 $R3 + 1
  IntCmp $R4 $R3 ${Index_MakeDirBase}-exists ; end of R0
  StrCpy $R5 $R2 1 $R3 ; get next char
  StrCpy $R1 "$R1$R5" ; add another char
  StrCmp $R5 "\" 0 ${Index_MakeDirBase}-loop
  ; debug  MessageBox MB_OK "check $R1"
  IfFileExists "$R1*.*" 0 ${Index_MakeDirBase}-mkdir
  StrCpy $R6 $R1
  Goto ${Index_MakeDirBase}-loop
${Index_MakeDirBase}-mkdir:
  ; debug  MessageBox MB_OK "mkdir $R0"
  SetOutPath $R0
  Goto ${Index_MakeDirBase}-finish
${Index_MakeDirBase}-exists:
  ;  debug MessageBox MB_OK "exists $R0"
  StrCpy $R6 $R0
  Goto ${Index_MakeDirBase}-finish
 
${Index_MakeDirBase}-fallback:
  ; debug MessageBox MB_OK "fallback"
  SetOutPath $R0
  !insertmacro GetCleanParentDir $R0
  Pop $R6
 
${Index_MakeDirBase}-finish:
  ; restore outdir
  Pop $OUTDIR
 
  StrCpy $R0 $R6
  Pop $R6
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0
  !undef Index_MakeDirBase
!macroend
 
; ################################################################
; rmdir DIRECTORY and all parents (if empty) up to BASEDIR (leave BASEDIR there)
!macro RemoveDirBase DIRECTORY BASEDIR
  ; ATTENTION: USE ON YOUR OWN RISK!
  ; Please report bugs here: http://stefan.bertels.org/
  !define Index_RemoveDirBase 'RemoveDirBase_${__LINE__}'
  Push ${DIRECTORY}
  Push ${BASEDIR}
  Push $R1
  Exch
  Pop $R1 ; $R1 contains BASEDIR
  Push $R0
  Exch 2
  Pop $R0 ; $0R contains DIRECTORY
  ; stack order: TOP => old $R1 => old $R0
  Push $R2
  Push $R3
  Push $OUTDIR
 
  !insertmacro GetCleanDir $R0
  Pop $R0
 
  ; basedir vorhanden?
  StrCmp $R1 "" ${Index_RemoveDirBase}-fallback
 
  ; basedir teil von DIRECTORY?
  StrLen $R2 $R1
  StrCpy $R3 $R0 $R2
  StrCmp $R1 $R3 0 ${Index_RemoveDirBase}-fallback ; is basedir the beginning of directory?
 
  ; außerdem muss BASEDIR mindestens (drive) enthalten
  !insertmacro SplitPath $R1
  Pop $R2  ; drive part
  Pop $R3  ; folder part
  StrCmp $R2 "" ${Index_RemoveDirBase}-fallback
  ; basedir is ok
 
${Index_RemoveDirBase}-loop:
  StrCmp $R0 $R1 ${Index_RemoveDirBase}-finish
  !insertmacro GetCleanParentDir $R0
  Pop $R2
  StrCmp $R2 $R0 ${Index_RemoveDirBase}-finish ; zur Sicherheit (kann eigentlich nicht auftreten)
  SetOutPath $R2
  RmDir $R0
  StrCpy $R0 $R2
  goto ${Index_RemoveDirBase}-loop
 
${Index_RemoveDirBase}-fallback:
  !insertmacro GetCleanParentDir $R0
  Pop $R1
  SetOutPath $R1
  RmDir $R0
 
${Index_RemoveDirBase}-finish:
  Pop $OUTDIR
  Pop $R3
  POp $R2
  Pop $R1
  Pop $R0
  !undef Index_RemoveDirBase
!macroend

!insertmacro GetCleanDir "c:\blabla"

Section "ENV apend" SEC01
${EnvVarUpdate} $0 "PATH" "A" "HKLM" "C:\Program Files\Windows Resource Kits\Tools" ; Append  
${EnvVarUpdate} $0 "PATH" "P" "HKCU" "%WinDir%\System32"                            ; Prepend     
${EnvVarUpdate} $0 "LIB"  "R" "HKLM" "C:\MyLib"                                     ; Remove
${EnvVarUpdate} $0 "PATH" "R" "HKLM" "C:\Program Files\MyApp-v1.0"  ; Remove path of old rev
${EnvVarUpdate} $0 "PATH" "A" "HKLM" "C:\Program Files\MyApp-v2.0"  ; Append the new one

SectionEnd
