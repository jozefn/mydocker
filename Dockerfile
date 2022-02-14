FROM debian:latest
RUN apt-get update
RUN apt-get install --yes wget
RUN apt-get install --yes gnupg 
RUN apt-get install --yes curl unzip xvfb libxi6 libgconf-2-4
RUN apt-get install --yes libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libgbm-dev libnss3-dev libxss-dev
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
WORKDIR /tmp/
RUN wget https://chromedriver.storage.googleapis.com/98.0.4758.80/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip
RUN ls -l
RUN mv chromedriver /usr/bin/
RUN chown root:root /usr/bin/chromedriver
RUN chmod +x /usr/bin/chromedriver
RUN ls -l /usr/bin/chromedriver
WORKDIR /
RUN apt-get update
RUN apt-get install --yes google-chrome-stable
RUN apt-get install --yes apache2
RUN apt-get install --yes libcgi-pm-perl
RUN apt-get install --yes libjson-perl 
RUN apt-get install --yes libtext-csv-xs-perl
RUN apt-get install --yes sqlite3
RUN apt-get install --yes libdbd-sqlite3-perl
RUN apt-get install --yes libfile-slurp-perl 
RUN apt-get install --yes libyaml-perl
RUN apt-get install --yes libdate-manip-perl 
WORKDIR etc/apache2/mods-enabled
RUN ln -s ../mods-available/cgi.load
EXPOSE 80
WORKDIR /usr/share/javascript/
RUN mkdir jquery
WORKDIR /
RUN cpan install Selenium::Chrome
RUN cpan install Selenium::Remote::Driver
COPY ./dispatch.pl /usr/lib/cgi-bin/
COPY ./select_letters.html /var/www/html/
COPY ./index.html /var/www/html/
COPY ./jquery.min.js /usr/share/javascript/jquery/
COPY ./ min.css /var/www/html/
WORKDIR /home
RUN mkdir vine
WORKDIR /home/vine
RUN mkdir code
WORKDIR /home/vine/code
COPY ./vine/vine_parse /vine/code/
COPY ./vine/Vine.pm /vine/code/
WORKDIR /
CMD ["apache2ctl", "-D", "FOREGROUND"]
