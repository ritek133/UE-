# 作者：Huang TaiCheng
# 概要：パフォマンス集計（メモリ使用率）
#  

#----------------------収集時間自動生成-------------------------------------

$year=get-date -Format 'yyyy'
$month=get-date -Format 'MM'
$date=get-date -Format 'dd'

if($month -eq "01"){$stryyy=$year-1}else{$stryyy=$year}
if($month -eq "01"){$strmm=12 }else{$strmm=$month-1}
if($strmm -eq "01"){$enddd=31}
if($strmm -eq "02"){$enddd=28}
if($strmm -eq "03"){$enddd=31}
if($strmm -eq "04"){$enddd=30}
if($strmm -eq "05"){$enddd=31}
if($strmm -eq "06"){$enddd=30}
if($strmm -eq "07"){$enddd=31}
if($strmm -eq "08"){$enddd=31}
if($strmm -eq "09"){$enddd=30}
if($strmm -eq "10"){$enddd=31}
if($strmm -eq "11"){$enddd=30}
if($strmm -eq "12"){$enddd=31}
$endyyyy=$stryyy  #開始年＝終了年
$mm="{0:00}" -f $strmm　#2桁左０を補う
$endmm=$mm      #終了月＝開始月

write-host "取得期間"$stryyy $mm $strdd　"-" $endyyyy $endmm $enddd
#-----------------------------------------------------------------

#--------------変数設定--------------------------------------
$temp=".\temp\temp.txt"
$temp1=".\temp\temp1.txt"
$temp2=".\temp\temp2.txt"
$temp3=".\temp\temp3.txt"
$tempcsv1=".\temp\clock.csv"
$tempcsv2=".\temp\usage.csv"
$nodelist=".\data\node_list.txt"
$IDlist=".\data\id-hostname.csv"
#-----------------------------------------------------------

#------------------------関数設定-------------------------------------

function Convert-UnixTimeToDateTime($unixTime){
                                               $ww=$unixTime/1000
                                               $jtzone=$ww+32400
                                               $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
                                               $origin.AddSeconds($jtzone)
                                               }

function text-processing($regex,$outputtemp){
                                             $s=(Get-Content -Path $temp)
                                             $a = $s.Split("[]")　　#取得したデータを改行処理、フィルタは”[]”

                                             ForEach ($i in $a) {
                                                                 $i | select-string  -Pattern $regex -AllMatches -Encoding default | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value } | Out-String -Stream | ?{$_ -ne ""} >>$outputtemp
                                                                }
                                             }

function id-converter($search){
                               $hitItem=Import-Csv -Header "ID","Hostname" $IDlist | ?{$_.ID -eq $search}
                               $hitItem.Hostname
                               }

#-----------------------------------------------------------------------

#----------------------メイン処理LOOP開始--------------------------

cd "$($MyInvocation.MyCommand.Path)\.."
$date=get-date -Format 'yyyyMd'

$arr = (Get-Content $nodelist) 
$i=1
foreach ($node in $arr) {

#---------------ゴミ削除-----------------------

Remove-Item .\temp\*.*
#----------------------------------------------

#----------------node→hostname---------------------
$hostname=id-converter $node
#--------------------------------------------------

#-------------------GraphDataデータ取得-----------------------------------------------

                         write-host $hostname "GraphData取得"
                         $uri = "http://v-polmgr:8060/api/json/device/getGraphData?index=WMI-MemoryUtilization&policyName=WMI-MemoryUtilization&name=$node&apiKey=0215deaa2fafa70a7b91bf2402a40bbe&period=custom&startDate=01/$mm/$stryyy 00:00&endDate=$enddd/$endmm/$endyyyy 24:00"
                         Invoke-WebRequest $uri -OutFile $temp

#---------------------------------------------------------------------------

#---------------------------------時間抽出----------------------------------

                         write-host $hostname "時間抽出”
                         text-processing ‘^[0-9]............’ $temp1 #正規表現にマッチしているものを抽出

#---------------------------------------------------------------------------


#-------------------------時間変替え----------------------------------------

                         write-host $hostname "UNIX時間をJSTに読み替え"
                         $g=(Get-Content -Path $temp1)

                         ForEach ($b in $g) {
                                             Convert-UnixTimeToDateTime $b | Out-String -Stream | ?{$_ -ne ""} >>$temp2
                                            }

#---------------------------------------------------------------------------


#---------------------------------使用率抽出----------------------------------

　　　　　　　　　　　　write-host $hostname "使用率抽出"
　　　　　　　　　　　　text-processing ‘(?<=,)[0-9]*’ $temp3　#","以降の数字抽出

#---------------------------------------------------------------------------


#--------------------csv生成----------------------------------

　　　　　　　　　　　　write-host $hostname "CSV生成"
　　　　　　　　　　　　(Get-Content -Path $temp2) | ConvertFrom-CSV -header Time  >$tempcsv1
　　　　　　　　　　　　(Get-Content -Path $temp3) | ConvertFrom-CSV -header Usage  >$tempcsv2

　　　　　　　　　　　　$CSV1 = Import-Csv $tempcsv1 -Header "Time"
　　　　　　　　　　　　$CSV2 = Import-Csv $tempcsv2 -Header "Usage"
　　　　　　　　　　　　$CSV1 | ForEach-Object -Begin {$i = 0} { 
                                       　　　　　　　　　　　　 $_ | Add-Member -MemberType NoteProperty -Name 'Usage' -Value $CSV2[$i++].Usage -PassThru 
                                       　　　　　　　　　　　　} | Export-Csv ".\output\$hostname-($strmm)月分メモリ使用率-$date.csv" -NoTypeInformation -Encoding UTF8

#---------------------------------------------------------------

　　　　　　　　　　　　write-host $hostname "完了"

	$i++
}

pause