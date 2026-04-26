#NoEnv
#Persistent
SetBatchLines, -1

; =========================================================
; �i�W�ų]�w�ϡj(�p�G���ǡA�Ч�o�̡I)
; =========================================================

; 1. �A�� G25 �O�X������H (�q�`�O 1�A�p�G�S�����令 2)
JoyID := 1

; 2. �٨� (Brake) �nŪ�����Ӷb�H (�A�����ծɡA�����X���b��������)
; �ﶵ�q�`��: JoyU, JoyV, JoyZ, JoyR
BrakeAxis := "JoyU"  ; <--- �w�]�q���O JoyU (Slider)�A�p�G���|�ʧ�o�̡I

; 3. �o�� (Gas) �nŪ�����Ӷb�H (�q�`�O JoyY)
GasAxis   := "JoyY"

; 4. ��V (Steer) �nŪ�����Ӷb�H (�q�`�O JoyX)
SteerAxis := "JoyX"

; =========================================================
; �H�U�{���X�|�۰ʮM�ΤW�����]�w�A���ΰ�
; =========================================================

; --- �����]�w ---
GuiWidth := 280
GuiHeight := 260
BackgroundColor := "000000" ; �¶­I�� (OBS �h�I��)

; +E0x02000000 = �����w�� (����{�{/�}��)
; -Caption = �������D�C
Gui, +AlwaysOnTop -Caption
Gui, Color, %BackgroundColor%

; �������i�즲
OnMessage(0x201, "WM_LBUTTONDOWN")

; --- �����G�� ---
Gui, Font, s14 cWhite bold, Verdana

; 1. ��V�� (��V)
Gui, Add, Text, x10 y10 w260 Center, Steering
Gui, Add, Progress, vProgSteer x10 y40 w260 h25 c00A2FF Background333333, 50

; 2. ��O�� (����)
; ������� "Brake"�A�������޿�OŪ���A�]�w�����X���b
Gui, Add, Text, x40 y80 w60 Center, Brake
Gui, Add, Progress, vProgBrake x40 y120 w70 h130 Vertical cRed Background333333, 0

Gui, Add, Text, x180 y80 w60 Center, Gas
Gui, Add, Progress, vProgGas x180 y120 w70 h130 Vertical cLime Background333333, 0

; 3. �ɦ����
;Gui, Font, s70 cYellow bold, Arial
;Gui, Add, Text, vGearText x100 y115 w120 h120 Center, N

Gui, Show, w%GuiWidth% h%GuiHeight% NoActivate, G25_Graphical_HUD
SetTimer, UpdateHUD, 30
return

UpdateHUD:
; --- �ʺAŪ���A�b�W���]�w���b ---
; �զX�r��A�Ҧp 1JoyX, 1JoyU
CurrentSteer := JoyID . SteerAxis
CurrentGas   := JoyID . GasAxis
CurrentBrake := JoyID . BrakeAxis

GetKeyState, rawSteer, %CurrentSteer%
GetKeyState, rawGas,   %CurrentGas%
GetKeyState, rawBrake, %CurrentBrake%

; --- ��O����ץ� ---
; ù�޽�O�q�`�G�S��=100 (��), ��=0 (��)
; �ڭ̭n���ন�G�S��=0 (��), ��=100 (��)
if (rawGas < 50) 
{
    ; �o�O�o���Ϭq (0~49)
    ; �����G(50 - �ƭ�) * 2
    FinalGas := (50 - rawGas) * 2
}
else
{
    ; �o�O�٨��Ϭq�ΨS�� (50~100)�A�o����ܬ� 0
    FinalGas := 0
}
FinalBrake := 100 - rawBrake

; �p�G�A�o�{�u�S��ϦӬO�����v�A�Ч�W������令�GFinalBrake := rawBrake (���� 100 -)

; --- ��s�ϧΤ��� ---
GuiControl,, ProgSteer, %rawSteer%
GuiControl,, ProgGas,   %FinalGas%
GuiControl,, ProgBrake, %FinalBrake%

; --- �ɦ��޿� (�w�� G25 H����) ---
Gear := "N"
; �ϥ� JoyID �ܼƨӰ������s
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
else if GetKeyState(JoyID . "Joy7") ; ����
    Gear := "R"

GuiControl,, GearText, %Gear%
return

; --- �즲�\�� ---
WM_LBUTTONDOWN() {
    PostMessage, 0xA1, 2
}

GuiClose:
ExitApp

