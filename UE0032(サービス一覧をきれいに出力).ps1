# 作者：Huang TaiCheng
# 概要：サービス一覧を綺麗に出力

$triggers = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services" |
     Where-Object { $_.GetSubkeyNames().Contains("TriggerInfo") } |
     ForEach-Object { $_.Name.Split("\")[-1] }

 $startMode = @{ Manual = "手動"; Disabled = "無効"; Auto = "自動"; Unknown = "不明" }
 $startOption = @{ 01 = " (トリガー開始)"; 10 = " (遅延開始)"; 11 = " (遅延開始、トリガー開始)" }

 $serviceData = Get-CimInstance -ClassName Win32_Service | Select-Object @(
     @{ n = "表示名";              e = { $_.DisplayName } }
     @{ n = "サービス名";          e = { $_.Name } }
     @{ n = "スタートアップの種類"; e = { $startMode[$_.StartMode] + $startOption[10 * ($_.StartMode -eq "Auto" -and $_.DelayedAutoStart) + $triggers.Contains($_.Name)] } }
     @{ n = "状態";                e = { if($_.State -eq "Running") { "実行" } else { "停止" } } }
 )

  $serviceData|Export-csv d:\\servicename.csv -NoTypeInformation -encoding unicode
