#Requires AutoHotkey v2.0
#SingleInstance Force

; Make the ISO/OEM-102 key behave exactly like the physical backtick key.
; A native remap forwards all held modifiers, so Ctrl+ISO is Ctrl+backtick,
; and the same remains true for Alt, Shift, Win, or combinations of them.
SC056::SC029

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
