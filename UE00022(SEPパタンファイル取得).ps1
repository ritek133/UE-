
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $True }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

cd "$($MyInvocation.MyCommand.Path)\.."
$temp01=".\temp\temp01.txt"
$output=".\output.txt"

#-------------------token取得処理-------------------------------------------------------------------

$cred= @{
username = "symantecadmin"
password = "Vpr0tect?"
domain = ""
}
#converts $cred array to json to send to the SEPM
$auth = $cred | ConvertTo-Json
 
#取得したトークンをエクスポート
$get_token=Invoke-RestMethod -Uri https://v-sepmgr:8446/sepm/api/v1/identity/authenticate -Method Post -Body $auth -ContentType 'application/json'
$get_token | Select-Object token >$temp01


#エクスポートしたトークンファイルを整理して読み取る
$token=Get-Content $temp01 | Select-Object -Skip 3

#-------------------------------------------------------------------------------------------------------------------------------------------------------------

#メイン処理
$headers = @{Authorization = "Bearer $token"}
Invoke-RestMethod -Uri https://v-sepmgr:8446/sepm/api/v1/stats/client/content -Method GET -Headers $headers -UseBasicParsing >$output