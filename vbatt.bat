@ECHO OFF
cd c:/Users/%USERNAME%
del .env
echo WUSER=%USERNAME% >> .env
docker run -it  -v /c/Users/%USERNAME%/vine/vine_files:/vine --env-file .env testrw:v3 bash
