#!/bin/bash
docker cp dispatch.pl $1:/usr/lib/cgi-bin/
docker cp select_letters.html $1:/var/www/html/
docker cp index.html $1:/var/www/html/
docker cp jquery.min.js $1:/usr/share/javascript/jquery/
docker cp min.css $1:/var/www/html/
