@ECHO OFF
cd c:/Users/%USERNAME%
del .env
echo WUSER=%USERNAME% >> .env
docker run -it  -v C:/Users/%USERNAME%/vine/data:/home/vine/data --env-file .env vinetest:v1 bash
