rem *********************************************
rem �쐬�ҁFHuang Taicheng
rem CAB�𓀁��t�@�C������o
rem *********************************************

rem �o�b�`���݃t�H���_���J�����g�ɂ���
pushd %0\..

rem *************�ϐ��鍐*************

set logfile=..\log\
set intput=..\data\intput
set output=..\data\output
set intputlist=..\data\input_list.txt
set outputlist=..\data\output_list.txt
set today=%DATE:~-10,4%%DATE:~-5,2%%DATE:~-2%

rem *************���C������***********
rem ***********�t�@�C�������X�g�擾*********

dir /b %intput% >%intputlist%


rem ****************�𓀏���*************

for /f,%%a in (%intputlist%) do (
echo "������="%%a >>%logfile%%today%.txt 2>&1
expand -I %intput%\* %output%  >>%logfile%%today%.txt 2>&1
)
dir /b %output% >%outputlist%