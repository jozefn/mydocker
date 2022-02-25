@ECHO OFF
cd c:/Users/%%USERNAME%%
del .env
echo WUSER=%USERNAME% >> .env
docker run -dit -p 80:80 -v /c/Users/%USERNAME%/vine/vine_files:/home/vine/files \
                         -v /c/Users/%USERNAME%/vine/vine_data:/home/vine/data \
 --env-file .env testrw:v3
