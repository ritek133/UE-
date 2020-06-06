# 作者：Huang TaiCheng
# 概要：
# 失敗監査ログ抽出

$myname = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$yyyymmdd = get-date -UFormat %Y%m%d

# カレントを実行パスに変更
cd "$($MyInvocation.MyCommand.Path)\.."

# ログフォルダ作成
function MakeDir ($dir){
	if (-Not (Test-Path $dir)){
		ni $dir -ItemType Directory
	}
}

$log_dir = ".\log"
MakeDir "$log_dir"

# ログ出力開始
function StartLog {    
    $log_file = "$log_dir\${myname}.log"
    $old_log_file = "$log_dir\${myname}_old.log"
    $log_size = 102400

    if (Test-Path $log_file){
	    if ((dir $log_file).Length -ge $log_size){move $log_file $old_log_file -Force}
    }
    Start-Transcript $log_file -Append
}

StartLog
#
# 抽出結果の保存パスと保存名を設定
$outputcsv=".\outcsv.csv"

# ファイルリストで繰り返し
$output=".\data\output¥"
$list_file=".\data\outputlist.txt"
$arr = (Get-Content $list_file) -as [string[]]
$i=1
foreach ($list in $arr) {

# 抽出実行

write-host $list
Get-WinEvent -FilterHashtable @{
    path= "$output$list"
    LogName = 'Security'
    ProviderName = 'Microsoft-Windows-Security-Auditing'
    ID = 4625　　# 抽出イベントID指定
} | %{
    $xml = [XML]$_.ToXml()   # EventDataにアクセスするためにXML化

    $TimeCreated = ([DateTime]$xml.Event.System.TimeCreated.SystemTime).ToString('yyyy/MM/dd hh:mm:ss')
    $UserName = ($xml.Event.EventData.Data | ?{$_.Name -eq 'TargetUserName'}).'#text'
    $IpAddress = ($xml.Event.EventData.Data | ?{$_.Name -eq 'IpAddress'}).'#text'

    
    Write-Output "$TimeCreated,$AccessMaskName,$UserName,$IpAddress" >>$outputcsv
}

$i++
}

# 画面ログ出力停止
Stop-Transcript