# 作者：Huang TaiCheng
# 概要：
# KMS向き先変更確認バッチ

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
# ノードリストで繰り返し
$list_file=".\node_list.txt"
$arr = (Get-Content $list_file) -as [string[]]
$i=1
foreach ($node in $arr) {


# バッチファイル実行
write-host $node
Invoke-Command $node -ScriptBlock {cscript "C:\Windows\System32\slmgr.vbs" /dli} |find " DNS の KMS コンピューター名"
$i++
}

# 画面ログ出力停止
Stop-Transcript
