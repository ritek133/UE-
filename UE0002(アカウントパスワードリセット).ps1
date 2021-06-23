# 作者：Huang TaiCheng
# 概要：ADパスワードリセットツール
#  

#引数宣告
Param ( [int]$age)


#--------function設定---------------------------------------------------------------
#<vlookup>ユーザー名とパスワード検索
function id-converter($search,$request){
                               $hitItem=Import-Csv -Header "id","name","pw" $idlist | ?{$_.id -eq $search}
                               $hitItem.$request
                               }
#-----------------------------------------------------------------------------------


cd "$($MyInvocation.MyCommand.Path)\.."
$idlist=".\date\(自動化用)外部アクセス登録ユーザーリスト2.csv"


#----------------入力処理--------------------------------
#入力方法判別
if ($age -ne ""){$input=$age}else{$input=read-host "作業IDを入れてください"}
if ($input -eq ""){exit}

#--------------初期パスワード生成処理-----------------------------
$password=id-converter $input "pw"
$Month=get-date -format "MM"
$Day=get-date -format "dd"

#---------パスワードリセット処理------------------------------------------
$userid=id-converter $input "name"
$repw=$password+$Month+$Day
$ou_name="CN=$userid,ou=(OU Name),dc=(ドメイン名),dc=(ドメイン名)"

#---------------実行コマンド---------------------------------------
write-host dsmod user '"'$ou_name'"' -pwd $repw -mustchpwd yes

#------------実行結果判断-----新パスワードをクリックボードにコピ--------------------------------
if ($? -eq "Ture") {write-host "処理OK" ; echo "対応いたしました。初期PW:"$repw | clip}
else{write-host "失敗"}

pause
