#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <File.au3>
#include <.\libs\_Mouse_UDF.au3>
#include <.\libs\MouseOnEvent.au3>

HotKeySet("+1", "_Quit")
;HotKeySet("+2", "_ClearCord")
HotKeySet("p", "_DragMode")
HotKeySet("o", "_CurveDragMode")

$dll = DllOpen("user32.dll")
$hOP = FileOpen("Exec.au3", 1)
$Paused = True

Global $secondsElapsed = 0
Global $sAnswer = 0

; LinearDrag Variables
Global $isDragMode = False
$dragStartX = 0
$dragStartY = 0
$dragEndX = 0
$dragEndY = 0

; CurveDrag Variables
Global $isCurveDragMode = False
Global $StartCurveFlag = False
Global $aPrevPos[2] = [0, 0]
Global $avPrevMousePos[2] = [0,0]

; _MouseOnEvent Listeners
_Mouse_RegisterEvent($EVENT_PRIMARY_DOWN, "_RecordDrag")
_Mouse_RegisterEvent($EVENT_PRIMARY_UP, "_RecordDragEnd")
_Mouse_RegisterEvent($EVENT_PRIMARY_CLICK, "_PrimaryClick")
_Mouse_RegisterEvent($EVENT_SECONDARY_CLICK, "_SecondaryClick")
_Mouse_RegisterEvent($EVENT_PRIMARY_DBLCLICK, "_DoubleClick")

; MouseUDF Listeners
_MouseSetOnEvent($MOUSE_WHEELSCROLLDOWN_EVENT, "_MouseScrollDown")
_MouseSetOnEvent($MOUSE_WHEELSCROLLUP_EVENT, "_MouseScrollUp")

; -------------------------------------------------------------------------------------------------------------------------------

; Main Loop
While _Mouse_Update()
    Sleep(10)
    ; Check if the flag(s) has/-ve been set by the OnEvent function
    If $isCurveDragMode And $StartCurveFlag Then
        ; Now start the "real" function from within the main code
        _CurveDragStart()
    EndIf
WEnd

; Click

Func _SecondaryClick()
    If $isCurveDragMode Then
        $avMousePos = MouseGetPos()
        ToolTip("x = " & $avMousePos[0] & "  y = " & $avMousePos[1])
        $sFormattedLine= "MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")"
        FileWriteLine($hOP, $sFormattedLine)
        ToolTip("")
        $sFormattedLineSecondary= "MouseClick(" & '"' & "secondary" & '"'& ")"
        FileWriteLine($hOP, $sFormattedLineSecondary)
        FileWriteLine($hOP, "_TogglePause()")
        ToolTip("Registered RMB")
    EndIf
EndFunc

; Scrolls
Func _MouseScrollDown()
If $isCurveDragMode Then
    ;$avMousePos = MouseGetPos()
    ;ToolTip("x = " & $avMousePos[0] & "  y = " & $avMousePos[1])
    ;$sFormattedLine= "_MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")"
    ;FileWriteLine($hOP, $sFormattedLine)
    ;FileWriteLine($hOP, "Sleep(500)")
    ;ToolTip("")
    $sFormattedLineWheelDown = "MouseWheel(" & '"' & "down" & '"' & "," & "1" & ")" & @CRLF
    FileWriteLine($hOP, $sFormattedLineWheelDown)
    FileWriteLine($hOP, "Sleep(10))" & @CRLF
EndIf
EndFunc

Func _MouseScrollUp()
    If $isCurveDragMode Then
        ;$avMousePos = MouseGetPos()
        ;ToolTip("x = " & $avMousePos[0] & "  y = " & $avMousePos[1])
        ;$sFormattedLine= "_MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")"
        ;FileWriteLine($hOP, $sFormattedLine)
        ;FileWriteLine($hOP, "Sleep(500)")
        ;ToolTip("")
        $sFormattedLineWheelUp= "MouseWheel(" & '"' & "up" & '"' & "," & "1" & ")" & @CRLF
        FileWriteLine($hOP, $sFormattedLineWheelUp)
        FileWriteLine($hOP, "Sleep(10)" & @CRLF)    
    EndIf
EndFunc

; DragModes
 Func _DragMode()
    $isDragMode = True
    ToolTip("Drag mode on")
EndFunc

Func _CurveDragMode()
    If Not $isCurveDragMode Then
        $isCurveDragMode = True
        ToolTip("Curve Drag mode on")
        _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT, "_CurveDragHelper")
        _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT, "_CurveDragHelper")
        _MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "_SecondaryClick")
        ConsoleWrite("CurveDragMode is on" & @CRLF)
    Else
        $isCurveDragMode = False
        ToolTip("Curve Drag mode off")
        _MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT, "")
        _MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT, "")
        _MouseSetOnEvent($MOUSE_SECONDARYDOWN_EVENT, "")
    EndIf
EndFunc

; DragFunctions

Func _RecordDrag()
    If $isDragMode Then
        If $dragStartX = 0 Or $dragStartY = 0 Then
            $DSMousePos = MouseGetPos()
            $dragStartX = $DSMousePos[0]
            $dragStartY = $DSMousePos[1]
            $isRecordingDrag = True
        EndIf
    EndIf
EndFunc

Func _RecordDragEnd()
    $DEMousePos = MouseGetPos()
    $dragEndX = $DEMousePos[0]
    $dragEndY = $DEMousePos[1]

    If $isDragMode And $isRecordingDrag Then
        $sFormattedLineDrag= "MouseClickDrag(" & '"' & "primary" & '"'& "," & $dragStartX & "," & $dragStartY & "," & $dragEndX & "," & $dragEndY & "," & "20" & ")"
        FileWriteLine($hOP, $sFormattedLineDrag)
        $isDragMode = False
        $isRecordingDrag = False
        $dragStartX = 0
        $dragStartY = 0
    EndIf
EndFunc

Func _CurveDragHelper()
    ; Set the flag within the OnEvent function
    If $isCurveDragMode Then
        If Not $StartCurveFlag Then
            $StartCurveFlag = True
        Else
            $StartCurveFlag = False
            ;$isCurveDragMode = False
            ;_MouseSetOnEvent($MOUSE_PRIMARYDOWN_EVENT, "")
            ;_MouseSetOnEvent($MOUSE_PRIMARYUP_EVENT, "")
        EndIf
    EndIf
EndFunc

Func _CurveDragStart()

    ConsoleWrite('MouseDown' & @CRLF)

    $avMousePos = MouseGetPos()
    $sFormattedLine= "MouseMove(" & $avMousePos[0]& ", "  & $avMousePos[1] & ")"  & @CRLF
    FileWriteLine($hOP, $sFormattedLine)
        If $avMousePos[0] = $avPrevMousePos[0] And $avMousePos[1] = $avPrevMousePos[1] Then
    FileWrite($hOP, "Sleep(5)" & @CRLF)
        Else
    FileWrite($hOP, "Sleep(200)" & @CRLF)
     EndIf
    $sFormattedMouseDown = "MouseDown(" & '"' & "primary" & '"' & ")"  & @CRLF
    FileWrite($hOP, $sFormattedMouseDown)

    While $StartCurveFlag
        ConsoleWrite("getting mouse position" & @CRLF)
        $aPos = MouseGetPos()
        ; If $aPos[0] = $avMousePos[0] And $aPos[1] = $avMousePos[1] Then ExitLoop 
        If $aPos[0] <> $aPrevPos[0] Or $aPos[1] <> $aPrevPos[1] And $aPos[0] <> $avMousePos[0] Then
            $sFormattedLineCurveDrag = "MouseMove(" & $aPos[0]& ", "  & $aPos[1] & "," & "0" & ")"  & @CRLF
            FileWriteLine($hOP, $sFormattedLineCurveDrag)
            FileWriteLine($hOP, "Sleep(10)" & @CRLF)
        EndIf
        $aPrevPos = $aPos
        Sleep(5)
    WEnd
    ConsoleWrite("MouseUp" & @CRLF)
    $sFormattedMouseUp = "MouseUp(" & '"' & "primary" & '"' & ")" & @CRLF
    FileWriteLine($hOP, $sFormattedMouseUp)
    $StartCurveFlag = False
    $avPrevMousePos = $avMousePos

    ;$sAnswer = InputBox("Question", "Where were you born?", "1", "", _
    ;          - 1, -1)
    ;$secondsElapsed = $sAnswer * 1000
    FileWriteLine($hOP, "_TogglePause()" & @CRLF & @CRLF)
    ToolTip("Registered")
EndFunc


; Script Utilities

If _Singleton("Start", 1) = 0 Then
    MsgBox($MB_SYSTEMMODAL, "Warning", "The script is already running")
    Exit
EndIf

Func _ClearCord()
    FileWrite(".\Exec.au3", ";helper" & @CRLF)
    FileWriteToLine(".\Exec.au3", 1, "#include <.\libs\_Quit.au3>")
    MsgBox($MB_SYSTEMMODAL, "Warning", "Cords reset done")
    ; FileWriteLine($hOP, "")
EndFunc

Func _Quit()
    DllClose($dll)
    FileClose($hOP)
    Exit
 EndFunc


