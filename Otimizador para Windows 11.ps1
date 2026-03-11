# OCULTAR CONSOLE
Add-Type -Name Win -Namespace Native -MemberDefinition @"
[DllImport("kernel32.dll")]
public static extern System.IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(System.IntPtr hWnd, int nCmdShow);
"@

$console = [Native.Win]::GetConsoleWindow()
[Native.Win]::ShowWindow($console,0)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# CORES DO TEMA
$corFundo = "#1e1e1e"
$corPainel = "#2a2a2a"
$corTexto = "White"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Modo Jogo v6"
$form.Size = New-Object System.Drawing.Size(720,480)
$form.MinimumSize = New-Object System.Drawing.Size(650,420)
$form.StartPosition = "CenterScreen"
$form.BackColor = $corFundo
$form.ForeColor = $corTexto

# -----------------------
# MONITORAMENTO RAM
# -----------------------

$panelTop = New-Object System.Windows.Forms.GroupBox
$panelTop.Text = "Monitoramento de Memoria"
$panelTop.Location = "20,20"
$panelTop.Size = "660,90"
$panelTop.BackColor = $corPainel
$panelTop.ForeColor = $corTexto
$panelTop.Anchor="Top,Left,Right"
$form.Controls.Add($panelTop)

$ramBar = New-Object System.Windows.Forms.ProgressBar
$ramBar.Location="20,30"
$ramBar.Size="620,25"
$ramBar.Anchor="Top,Left,Right"
$panelTop.Controls.Add($ramBar)

$ramLabel = New-Object System.Windows.Forms.Label
$ramLabel.Location="20,60"
$ramLabel.Size="300,20"
$ramLabel.ForeColor=$corTexto
$panelTop.Controls.Add($ramLabel)

# -----------------------
# ACOES
# -----------------------

$panelActions = New-Object System.Windows.Forms.GroupBox
$panelActions.Text="Acoes rapidas"
$panelActions.Location="20,120"
$panelActions.Size="660,90"
$panelActions.BackColor=$corPainel
$panelActions.ForeColor=$corTexto
$form.Controls.Add($panelActions)

$btnOtimizar = New-Object System.Windows.Forms.Button
$btnOtimizar.Text="Otimizar Memoria"
$btnOtimizar.Size="200,40"
$btnOtimizar.Location="120,30"
$panelActions.Controls.Add($btnOtimizar)

$btnTemp = New-Object System.Windows.Forms.Button
$btnTemp.Text="Limpar Temporarios"
$btnTemp.Size="200,40"
$btnTemp.Location="340,30"
$panelActions.Controls.Add($btnTemp)

# -----------------------
# PLANO ENERGIA
# -----------------------

$panelEnergy = New-Object System.Windows.Forms.GroupBox
$panelEnergy.Text="Plano de Energia"
$panelEnergy.Location="20,220"
$panelEnergy.Size="660,80"
$panelEnergy.BackColor=$corPainel
$panelEnergy.ForeColor=$corTexto
$form.Controls.Add($panelEnergy)

$comboPlano = New-Object System.Windows.Forms.ComboBox
$comboPlano.Location="200,30"
$comboPlano.Size="200,25"
$panelEnergy.Controls.Add($comboPlano)

$btnPlano = New-Object System.Windows.Forms.Button
$btnPlano.Text="Aplicar Plano"
$btnPlano.Location="420,28"
$btnPlano.Size="120,30"
$panelEnergy.Controls.Add($btnPlano)

# -----------------------
# AUTOMAÇÃO
# -----------------------

$panelAuto = New-Object System.Windows.Forms.GroupBox
$panelAuto.Text="Automacao"
$panelAuto.Location="20,310"
$panelAuto.Size="660,110"
$panelAuto.BackColor=$corPainel
$panelAuto.ForeColor=$corTexto
$form.Controls.Add($panelAuto)

$chkTempo = New-Object System.Windows.Forms.CheckBox
$chkTempo.Text="Otimizar por tempo (min)"
$chkTempo.Location="40,30"
$chkTempo.ForeColor=$corTexto
$panelAuto.Controls.Add($chkTempo)

$comboTempo = New-Object System.Windows.Forms.ComboBox
$comboTempo.Location="200,28"
$comboTempo.Size="80,25"
$comboTempo.Items.AddRange(@("5","10","15","20","30"))
$panelAuto.Controls.Add($comboTempo)

$chkMem = New-Object System.Windows.Forms.CheckBox
$chkMem.Text="Otimizar por uso de RAM (%)"
$chkMem.Location="360,30"
$chkMem.ForeColor=$corTexto
$panelAuto.Controls.Add($chkMem)

$comboMem = New-Object System.Windows.Forms.ComboBox
$comboMem.Location="540,28"
$comboMem.Size="60,25"
$comboMem.Items.AddRange(@("70","80","90"))
$panelAuto.Controls.Add($comboMem)

$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Text="Iniciar"
$btnStart.Location="260,65"
$btnStart.Size="70,30"
$panelAuto.Controls.Add($btnStart)

$btnStop = New-Object System.Windows.Forms.Button
$btnStop.Text="Parar"
$btnStop.Location="340,65"
$btnStop.Size="70,30"
$panelAuto.Controls.Add($btnStop)

$timerLabel = New-Object System.Windows.Forms.Label
$timerLabel.Location="440,70"
$timerLabel.Size="200,20"
$timerLabel.ForeColor=$corTexto
$panelAuto.Controls.Add($timerLabel)

$status = New-Object System.Windows.Forms.Label
$status.Location="20,430"
$status.Size="660,20"
$status.ForeColor=$corTexto
$form.Controls.Add($status)

# -----------------------
# PLANOS ENERGIA
# -----------------------

$planos=@{}
powercfg -list | ForEach-Object{
if($_ -match "([a-f0-9\-]{36}).*\((.*?)\)"){
$planos[$matches[2]]=$matches[1]
$comboPlano.Items.Add($matches[2])
}
}

$btnPlano.Add_Click({
$nome=$comboPlano.SelectedItem
if($nome){
powercfg /setactive $planos[$nome]
$status.Text="Plano aplicado: $nome"
}
})

# -----------------------
# OTIMIZACAO MEMORIA
# -----------------------

function Otimizar {

$processos = Get-Process | Where-Object {$_.WorkingSet -gt 50MB}

foreach($p in $processos){
try{$p.MinWorkingSet=$p.MinWorkingSet}catch{}
}

$status.Text="Memoria otimizada $(Get-Date -Format HH:mm:ss)"

}

$btnOtimizar.Add_Click({Otimizar})

# -----------------------
# LIMPEZA COMPLETA
# -----------------------

function LimparPasta($path){

if(Test-Path $path){

Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | ForEach-Object{
try{
Remove-Item $_.FullName -Force -Recurse -ErrorAction Stop
}catch{}
}

}

}

function LimpezaCompleta {

$paths = @(
$env:TEMP,
"C:\Windows\Temp",
"C:\Windows\Prefetch",
"$env:LOCALAPPDATA\D3DSCache",
"$env:LOCALAPPDATA\NVIDIA\DXCache",
"$env:LOCALAPPDATA\NVIDIA\GLCache",
"$env:LOCALAPPDATA\NVIDIA Corporation\NV_Cache"
)

foreach($p in $paths){
LimparPasta $p
}

$status.Text="Limpeza de caches conclui da"

}

$btnTemp.Add_Click({LimpezaCompleta})

# -----------------------
# MONITOR RAM
# -----------------------

$ramTimer = New-Object System.Windows.Forms.Timer
$ramTimer.Interval=1000
$global:ramAtual=0

$ramTimer.Add_Tick({

$ram = Get-CimInstance Win32_OperatingSystem
$uso=(($ram.TotalVisibleMemorySize-$ram.FreePhysicalMemory)/$ram.TotalVisibleMemorySize)*100

$global:ramAtual=$uso

$ramBar.Value=[int]$uso
$ramLabel.Text="Uso de RAM: "+[math]::Round($uso,1)+"%"

})

$ramTimer.Start()

# -----------------------
# AUTOMACAO
# -----------------------

$autoTimer = New-Object System.Windows.Forms.Timer
$autoTimer.Interval=1000

$global:contador=0
$global:intervalo=0

$autoTimer.Add_Tick({

if($chkTempo.Checked -and $global:intervalo -gt 0){

$global:contador--
$timerLabel.Text="Proxima otimizacao em $global:contador s"

if($global:contador -le 0){

Otimizar
$global:contador=$global:intervalo

}

}

if($chkMem.Checked){

$limite=[int]$comboMem.SelectedItem

if($global:ramAtual -ge $limite){
Otimizar
}

}

})

$btnStart.Add_Click({

if($chkTempo.Checked){

$min=[int]$comboTempo.SelectedItem
$global:intervalo=$min*60
$global:contador=$global:intervalo

}

$autoTimer.Start()
$status.Text="Automacao iniciada"

})

$btnStop.Add_Click({

$autoTimer.Stop()
$timerLabel.Text=""
$status.Text="Automacao parada"

})

$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()