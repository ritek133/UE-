# 概要：
#  


## 7-Zipの場所を指定
# スクリプトファイルのパスを取得
cd "$($MyInvocation.MyCommand.Path)\.."

#関数定義
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
foreach ($name1 in $arr0) {

# 実行コマンド
Write-Output $name1 >>.\date\filenamaelist.txt

$i++
}

#ファイル名が*.part*.rarを含めていないファイルを取り上げる
$namelist=dir $source*   -exclude "*.part*.rar" | Select-Object fullname
Write-Output $namelist >.\date\temp02.txt
#処理対処リスト再整理
$temp02=".\date\temp02.txt"
$arr1 = (Get-Content $temp02 | Select-Object -Skip 3 | Where {$_ -ne ""}) -as [string[]]
$i=1
foreach ($name2 in $arr1) {

# 実行コマンド
write-output $name2 >>.\date\filenamaelist.txt

$i++
}

#解凍処理
$list_file=".\date\filenamaelist.txt"
$pw_file=".\date\pw_file.txt"
$cn=1
$ps=(Get-Content $pw_file | Select-Object -Skip $cn) -as [string[]]
$arr = (Get-Content $list_file) -as [string[]]
$i=1
foreach ($name in $arr) {

# 実行コマンド
Write-host　"解凍処理"$name
$proc = (Start-Process $7zip -ArgumentList  "x -y  -p$ps $name -o$dist" -PassThru -Wait)
$ss=$proc.ExitCode
Write-Host $ss

#成功判断
switch($ss){
0{$name+"-成功-"}
2{

#リトライ処理

Write-Output $name >>".\date\errlist.txt"
write-host "失敗した。リトライ開始"
foreach ($rearr in $ps) {
$i=1
# 実行コマンド
$reproc = (Start-Process $7zip -ArgumentList  "x -y  -p$rearr $name -o$dist" -PassThru -Wait)
$ress=$reproc.ExitCode
Write-host "リトライ対象"$name
Write-Host $ress
Write-Host "リトライPW"$rearr

#リトライ成功判断、成功したらループ解除
if ( $ress -eq 0 )
{
Write-Host "リトライ成功、ループ解除"
break
}


$i++
}
}

}

$i++
}


#後処理
#対象ファイルリストをネーミング処理
$afop=Test-Path .\date\filenamaelist.txt 
if($afop -eq "Ture"){
Rename-Item -Path '.\date\filenamaelist.txt' -NewName "OLD_filenamaelist_$(date -f yyyyMMdd-HHmm).txt" 
}
