#NoEnv
#Persistent
SetBatchLines, -1

; =========================================================
; 【超級設定區】(如果不準，請改這裡！)
; =========================================================

; 1. 你的 G25 是幾號控制器？ (通常是 1，如果沒反應改成 2)
JoyID := 1

; 2. 煞車 (Brake) 要讀取哪個軸？ (你剛剛測試時，踩離合器在跳的那個)
; 選項通常有: JoyU, JoyV, JoyZ, JoyR
BrakeAxis := "JoyU"  ; <--- 預設猜測是 JoyU (Slider)，如果不會動改這裡！

; 3. 油門 (Gas) 要讀取哪個軸？ (通常是 JoyY)
GasAxis   := "JoyY"

; 4. 轉向 (Steer) 要讀取哪個軸？ (通常是 JoyX)
SteerAxis := "JoyX"

; =========================================================
; 以下程式碼會自動套用上面的設定，不用動
; =========================================================

; --- 視窗設定 ---
GuiWidth := 280
GuiHeight := 260
BackgroundColor := "000000" ; 純黑背景 (OBS 去背用)

; +E0x02000000 = 雙重緩衝 (防止閃爍/破圖)
; -Caption = 移除標題列
Gui, +AlwaysOnTop -Caption +ToolWindow +E0x02000000
Gui, Color, %BackgroundColor%

; 讓視窗可拖曳
OnMessage(0x201, "WM_LBUTTONDOWN")

; --- 介面佈局 ---
Gui, Font, s14 cWhite bold, Verdana

; 1. 轉向條 (橫向)
Gui, Add, Text, x10 y10 w260 Center, Steering
Gui, Add, Progress, vProgSteer x10 y40 w260 h25 c00A2FF Background333333, 50

; 2. 踏板區 (直立)
; 左邊顯示 "Brake"，但內部邏輯是讀取你設定的離合器軸
Gui, Add, Text, x40 y80 w60 Center, Brake
Gui, Add, Progress, vProgBrake x40 y120 w70 h130 Vertical cRed Background333333, 0

Gui, Add, Text, x180 y80 w60 Center, Gas
Gui, Add, Progress, vProgGas x180 y120 w70 h130 Vertical cLime Background333333, 0

; 3. 檔位顯示
;Gui, Font, s70 cYellow bold, Arial
;Gui, Add, Text, vGearText x100 y115 w120 h120 Center, N

Gui, Show, w%GuiWidth% h%GuiHeight% NoActivate, G25_Graphical_HUD
SetTimer, UpdateHUD, 30
return

UpdateHUD:
; --- 動態讀取你在上面設定的軸 ---
; 組合字串，例如 1JoyX, 1JoyU
CurrentSteer := JoyID . SteerAxis
CurrentGas   := JoyID . GasAxis
CurrentBrake := JoyID . BrakeAxis

GetKeyState, rawSteer, %CurrentSteer%
GetKeyState, rawGas,   %CurrentGas%
GetKeyState, rawBrake, %CurrentBrake%

; --- 踏板反轉修正 ---
; 羅技踏板通常：沒踩=100 (滿), 踩死=0 (空)
; 我們要反轉成：沒踩=0 (空), 踩死=100 (滿)
if (rawGas < 50) 
{
    ; 這是油門區段 (0~49)
    ; 公式：(50 - 數值) * 2
    FinalGas := (50 - rawGas) * 2
}
else
{
    ; 這是煞車區段或沒踩 (50~100)，油門顯示為 0
    FinalGas := 0
}
FinalBrake := 100 - rawBrake

; 如果你發現「沒踩反而是滿的」，請把上面那行改成：FinalBrake := rawBrake (拿掉 100 -)

; --- 更新圖形介面 ---
GuiControl,, ProgSteer, %rawSteer%
GuiControl,, ProgGas,   %FinalGas%
GuiControl,, ProgBrake, %FinalBrake%

; --- 檔位邏輯 (針對 G25 H排檔) ---
Gear := "N"
; 使用 JoyID 變數來偵測按鈕
if GetKeyState(JoyID . "Joy1")
    Gear := "1"
else if GetKeyState(JoyID . "Joy2")
    Gear := "2"
else if GetKeyState(JoyID . "Joy3")
    Gear := "3"
else if GetKeyState(JoyID . "Joy4")
    Gear := "4"
else if GetKeyState(JoyID . "Joy5")
    Gear := "5"
else if GetKeyState(JoyID . "Joy6")
    Gear := "6"
else if GetKeyState(JoyID . "Joy7") ; 倒檔
    Gear := "R"

GuiControl,, GearText, %Gear%
return

; --- 拖曳功能 ---
WM_LBUTTONDOWN() {
    PostMessage, 0xA1, 2
}

GuiClose:
ExitApp