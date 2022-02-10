FROM debian:latest
RUN apt-get update
RUN apt-get install --yes wget
RUN apt-get install --yes gnupg 
RUN apt-get install --yes curl unzip xvfb libxi6 libgconf-2-4
RUN apt-get install --yes libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libgbm-dev libnss3-dev libxss-dev
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
WORKDIR /tmp/
RUN wget https://chromedriver.storage.googleapis.com/77.0.3865.40/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip
RUN ls -l
RUN mv chromedriver /usr/bin/
RUN chown root:root /usr/bin/chromedriver
RUN chmod +x /usr/bin/chromedriver
RUN ls -l /usr/bin/chromedriver
WORKDIR /
RUN chromedriver --version
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
WORKDIR etc/apache2/mods-enabled
RUN ln -s ../mods-available/cgi.load
EXPOSE 80
WORKDIR /usr/share/javascript/
RUN mkdir jquery
WORKDIR /
CMD ["apache2ctl", "-D", "FOREGROUND"]
