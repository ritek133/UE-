rem *********************************************
rem 作成者：Huang Taicheng
rem CAB解凍＆ファイル名提出
rem *********************************************

rem バッチ存在フォルダをカレントにする
pushd %0\..

rem *************変数宣告*************

set logfile=..\log\
set intput=..\data\intput
set output=..\data\output
set intputlist=..\data\input_list.txt
set outputlist=..\data\output_list.txt
set today=%DATE:~-10,4%%DATE:~-5,2%%DATE:~-2%

rem *************メイン処理***********
rem ***********ファイル名リスト取得*********

dir /b %intput% >%intputlist%


rem ****************解凍処理*************

for /f,%%a in (%intputlist%) do (
echo "処理中="%%a >>%logfile%%today%.txt 2>&1
expand -I %intput%\* %output%  >>%logfile%%today%.txt 2>&1
)
dir /b %output% >%outputlist%