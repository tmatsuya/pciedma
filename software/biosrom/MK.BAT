@ECHO OFF
tasm32 /jSMART /jJUMPS /uM520 /jLOCALS /m8 /t MAKEROM
IF ERRORLEVEL == 1 GOTO END
tlink /t MAKEROM;
:END
