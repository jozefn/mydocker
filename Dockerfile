FROM debian:latest
RUN apt-get update
RUN apt-get install --yes apache2
RUN apt-get install --yes libcgi-pm-perl
RUN apt-get install --yes libjson-perl 
RUN apt-get install --yes libtext-csv-xs-perl
RUN apt-get install --yes sqlite3
RUN apt-get install --yes libdbd-sqlite3-perl
RUN apt-get install --yes libfile-slurp-perl 
RUN apt-get install --yes libyaml-perl
WORKDIR etc/apache2/mods-enabled
RUN ln -s ../mods-available/cgi.load
EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]
WORKDIR usr/lib/cgi-bin
COPY vine.pl . 
WORKDIR var/www/html
COPY vine.html .
WORKDIR /usr/share/javascript/
RUN mkdir jquery
WORKDIR jquery
COPY jquery.min.js .
WORKDIR /
