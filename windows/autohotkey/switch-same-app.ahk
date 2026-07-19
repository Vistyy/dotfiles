#Requires AutoHotkey v2.0
#SingleInstance Force

; Replace PowerToys' OEM-102 -> backtick remap in the same keyboard hook.
SC056::SC029

; Use Left Alt only so Polish AltGr (Left Ctrl + Right Alt) cannot trigger these.
<!`::
{
    CycleCurrentAppWindows()
}

<!+`::
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
