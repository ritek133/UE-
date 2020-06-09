# 作者：Huang TaiCheng
# 概要：
#  Citrix公開アプリケーション毎ユーザーリストを取得る

$myname = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$yyyymmdd = get-date -UFormat %Y%m%d

# 実行パスに変更
cd "$($MyInvocation.MyCommand.Path)\.."

# ログフォルダ作成
function MakeDir ($dir){
	if (-Not (Test-Path $dir)){
		ni $dir -ItemType Directory
	}
}

$log_dir = ".\log"
MakeDir "$log_dir"

# log出力開始
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
#Citrixモジュルロード

Add-PSSnapin Citrix*

#公開アプリケーション名一覧取得
$appname=Get-BrokerApplication |Select-Object applicationName
Write-output $appname  >.\date\Appliction_list.txt

# アプリケーション名で繰り返し

$list_file=".\date\Appliction_list.txt"

#Select-Object -Skip 3行目から
$arr = (Get-Content $list_file | Select-Object -Skip 3) -as [string[]]
$i=1
foreach ($name in $arr) {

# バッチファイ?実行
write-host $name 
write-output ">>>>>>>>>>>公開アプリケーション名："$name"<<<<<<<<<<<<<<<<<"  >>.\user_List.txt
$note= get-brokerapplication -name "$name"
$output=$note.AssociatedUserNames
Write-Output $output >>.\user_List.txt
$i++
}


# 画面ログ出力停止
Stop-Transcript
