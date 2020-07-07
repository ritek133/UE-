# 作者：Huang TaiCheng
# 概要：
#  


cd "$($MyInvocation.MyCommand.Path)\.."

#ファンション定義************************************************************************************

function pathtest($path){
Test-Path $path
}

function listloop($arr0){
$i=1
foreach ($name in $arr0) {
Write-Output $name >>.\date\filenamaelist.txt
$i++
}}

#****************************************************************************************************

#環境チェック****************************************************************************************

$ck1=pathtest "C:\Program Files\7-Zip\7z.exe"
if($ck1 -ne "False"){
write-host "7zipをインストールしてください"
}

$ck2=pathtest ".\date\filenamaelist.txt "
if($ck2 -eq "True"){
Remove-Item .\date\filenamaelist.txt
}

$ck3=pathtest ".\date\errlist.txt "
if($ck3 -eq "True"){
Remove-Item .\date\errlist.txt
}

#****************************************************************************************************
$source=".\input\"
$7zip="C:\Program Files\7-Zip\7z.exe"
$dist=".\output\"

#ファイル名が*.part1.rarを含めているファイルを取り上げる
$namelist=dir $source*  -r -Filter "*.part1.rar" | Select-Object fullname
Write-Output $namelist >.\date\temp01.txt
#処理対処リスト再整理
$temp01=".\date\temp01.txt"
$arr0 = (Get-Content $temp01 | Select-Object -Skip 3 | Where {$_ -ne ""}) -as [string[]]
$i=1
listloop $arr0

#ファイル名が*.part*.rarを含めていないファイルを取り上げる
$namelist=dir $source*   -exclude "*.part*.rar" | Select-Object fullname
Write-Output $namelist >.\date\temp02.txt
#処理対処リスト再整理
$temp02=".\date\temp02.txt"
$arr1 = (Get-Content $temp02 | Select-Object -Skip 3 | Where {$_ -ne ""}) -as [string[]]
$i=1
listloop $arr1

#解凍メイン処理*****************************************************************************************

#関数定義
$list_file=".\date\filenamaelist.txt"
$pw_file=".\date\pw_file.txt"
$ps=(Get-Content $pw_file | Select-Object -Skip 1) -as [string[]]
$arr = (Get-Content $list_file) -as [string[]]

#解凍ループ

#パスワード候補計算ループ
#変数リセット
Remove-Variable pwcut

foreach ($pwcu in $ps) {
$pwcut++
Write-host "PW候補"$pwcut

$i++
}


foreach ($name in $arr) {

　# 実行コマンド
Write-host　"解凍処理"$name

#変数をクリア
Remove-Variable cut

$cut++
$proc = (Start-Process $7zip -ArgumentList  "x -y  -p$ps $name -o$dist" -PassThru -Wait -WindowStyle Hidden)
$ss=$proc.ExitCode
Write-Host "処理結果"$ss

#成功判断
switch($ss){
0{$name+"-成功-"}
2{
#失敗するときリトライ処理

#失敗ファイル名出力
#Write-Output $name >>".\date\errlist.txt"
write-host "失敗した。リトライ開始"

#関数再定義
$reps=(Get-Content $pw_file | Select-Object -Skip 2) -as [string[]]

#リトライループ
foreach ($rearr in $reps) {
$i=1
# 実行コマンド
$reproc = (Start-Process $7zip -ArgumentList  "x -y  -p$rearr $name -o$dist" -PassThru -Wait -WindowStyle Hidden)
$ress=$reproc.ExitCode
Write-host "リトライ対象"$name
Write-Host "処理結果"$ress
Write-Host "リトライPW"$rearr

#リトライ成功判断、成功したらループ解除
if ( $ress -eq 0 )
{
Write-Host "リトライ成功、ループ解除"
break
}

elseif($ress -eq 2 ) {
$cut++
Write-Host "リトライ失敗回数"$cut "=" "総回数"$pwcut
if($cut -eq $pwcut){
Write-Output $name >>".\date\errlist.txt"
}
}
$i++
}
}
}
$i++
}

#後処理*********************************************************************************************************************

#対象ファイルリストをネーミング処理
$afop=pathtest $list_file
if($afop -eq "Ture"){
Rename-Item -Path '.\date\filenamaelist.txt' -NewName "OLD_filenamaelist_$(date -f yyyyMMdd-HHmm).txt" 
}

#****************************************************************************************************************************
