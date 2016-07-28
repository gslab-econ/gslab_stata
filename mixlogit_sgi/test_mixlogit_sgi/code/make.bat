REM ****************************************************
REM * make.bat: double-click to run all scripts
REM ****************************************************

SET LOG=..\output\make.log

REM DELETE OUTPUT & TEMP FILES
DEL /F /Q ..\output\
RMDIR ..\temp /S /Q
mkdir ..\temp

REM LOG START
ECHO make.bat started	>%LOG%
ECHO %DATE%		>>%LOG%
ECHO %TIME%		>>%LOG%
dir ..\output\ >>%LOG%

REM GET_EXTERNALS
get_externals externals.txt	..\external\ >>%LOG% 2>&1
COPY %LOG%+get_externals.log %LOG%
DEL get_externals.log

REM ANALYSIS.DO
%STATAEXE% /e do mixlogit_sgi_examples.do
COPY %LOG%+mixlogit_sgi_examples.log %LOG%
MOVE mixlogit_sgi_examples.log ../output/mixlogit_sgi_examples.log

REM Check the logs
perl ..\external\logcheck.pl

REM CLOSE LOG
ECHO make.bat completed	>>%LOG%
ECHO %DATE%		>>%LOG%
ECHO %TIME%		>>%LOG%

PAUSE
