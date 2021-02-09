# 作者：Huang TaiCheng
# 概要：
# プリント一覧出力

cd "$($MyInvocation.MyCommand.Path)\.."
$list_file=".\node_list.txt"
$arr = (Get-Content $list_file) -as [string[]]
$i=1
foreach ($node in $arr) {

$getlist=get-printer -ComputerName $node　| select name,portname
write-output $getlist >$node-printlist.txt

$i++
}
