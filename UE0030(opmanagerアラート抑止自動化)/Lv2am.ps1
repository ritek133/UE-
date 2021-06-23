# 作者：Huang TaiCheng
# 概要：
# opmanager監視抑止自動化 
# 設定値：抑止設定：8時間＝28800000
#         　　　　　1時間＝3600000
#　　　　　　　　 　解除＝0
#                 　1日間＝86400000
#                 　12時間＝43200000
#                 　無期限＝-1
#                 　1週間＝604800000
#                 　2時間＝7200000

# カレントを実行パスに変更
cd "$($MyInvocation.MyCommand.Path)\.."

#抑止時間設定
$time=0


# 監視抑止ループ
#----------------------------------------------------------------------------------------------------------------------------------------------------
$list_file=".\date\L2am_nodelist.txt"
$arr = (Get-Content $list_file) -as [string[]]
$i=1
foreach ($node in $arr) {
write-host $node "を処理する"

$uri = "http://v-polmgr:8060/api/json/device/ConfigureSuppressAlarm?apiKey=(API KEY INPUT)&name=$node&suppressInterval=$time"
$suc=Invoke-RestMethod -Method post -Uri $uri | ft -hide | Out-String | ForEach-Object { $_.Trim() }
#-----------------------------------------------------------------------------------------------------------------------------------------------------

#成功判別
#--------------------------------------------------------------------------
if ($suc -eq "@{message=アラート抑止ルールが正常に追加されました}"){
                 write-host $node　"抑止OK"
                 }
elseif ($suc -eq "@{message=アラート抑止ルールを更新しました}"){
                 write-host $node　"抑止OK"            
                 }
elseif($suc -eq "@{message=アラート抑止状態を解除しました}"){              
                 write-host $node　"抑止解除OK"
                 }
else{
                 write-host $node "NG"
                 }
#-------------------------------------------------------------------------

# 1秒待ち
sleep 1

	$i++
}