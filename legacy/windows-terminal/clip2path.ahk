#Requires AutoHotkey v2

; Historical Windows Terminal wrapper. WezTerm calls clip2path.ps1 directly,
; so this file is preserved for recovery but is not installed or started.
#HotIf WinActive("ahk_class CASCADIA_HOSTING_WINDOW_CLASS")

^!v:: {
    if !ClipboardContainsImage() {
        return
    }

    RunWait 'powershell -NoProfile -WindowStyle Hidden -Command "'
        . '$out = & \"$env:APPDATA\wezterm\clip2path.ps1\"; '
        . 'if ($out) { Set-Clipboard $out }"', , "Hide"

    Send "^v"
}

#HotIf

ClipboardContainsImage() {
    return DllCall("IsClipboardFormatAvailable", "UInt", 2)
        || DllCall("IsClipboardFormatAvailable", "UInt", 8)
        || DllCall("IsClipboardFormatAvailable", "UInt", 17)
}
