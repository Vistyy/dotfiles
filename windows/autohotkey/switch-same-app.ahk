#Requires AutoHotkey v2.0
#SingleInstance Force

; Type backtick/tilde without AutoHotkey's built-in key-remap machinery.
; SendText does not release and reapply held modifiers.
SC056::SendText "``"
+SC056::SendText "~"

; Bind directly to the physical OEM-102 key and Left Alt only.
; Polish AltGr (Left Ctrl + Right Alt) cannot match these hotkeys.
<!SC056::
{
    CycleCurrentAppWindows()
}

<!+SC056::
{
    CycleCurrentAppWindows("R")
}

; Also support keyboards with a dedicated physical backtick key.
<!SC029::
{
    CycleCurrentAppWindows()
}

<!+SC029::
{
    CycleCurrentAppWindows("R")
}

CycleCurrentAppWindows(mode := "")
{
    hwnd := WinExist("A")
    if !hwnd
        return

    proc := WinGetProcessName(hwnd)
    if !proc
        return

    groupName := "CycleGroup_" RegExReplace(proc, "\W", "_")

    ; Add all windows from the same process to a named group
    GroupAdd(groupName, "ahk_exe " proc)

    ; Cycle forward or backward through that group
    GroupActivate(groupName, mode)
}
