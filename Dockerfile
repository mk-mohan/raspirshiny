FROM upadrishta/pir:3.6.2

# install pre-requisites
RUN apt-get install -y git libssl-dev cmake cpp nginx  \
    libpq-dev postgresql-client postgresql-client-common && \
    sudo chown -R www-data:pi /var/www/html/ && \
    sudo chmod -R 770 /var/www/html/

RUN R -e "install.packages('remotes', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "remotes::install_github('r-lib/later')" && \
    R -e "install.packages('httpuv', repos='http://cran.rstudio.com/', type='source')";
##
RUN R -e "install.packages('fs', repos='http://cran.rstudio.com/', type='source')" && \ 
    R -e "install.packages('mime', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('jsonlite', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('digest', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('htmltools', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('xtable', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('R6', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('Cairo', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('sourcetools', repos='http://cran.rstudio.com/', type='source')";
##
RUN R -e "install.packages('shiny', repos='https://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('shiny.semantic', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('semantic.dashboard', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('shinythemes', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('DT', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('quantmod', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('Quandl', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('lubridate', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('plyr', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('magrittr', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('tidyquant', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('RPostgreSQL', repos='https://cran.rstudio.com/')" && \
    R -e "install.packages('plotly', repos='https://cran.rstudio.com/')";
##    
RUN R -e "remotes::install_github('schardtbc/iexcloudR')" && \
    R -e "install.packages('Riex', repos='https://cran.rstudio.com/')";
##  R -e "install.packages('later', repos='http://cran.rstudio.com/', type='source')" && \
##  R -e "install.packages('Rcpp', repos='http://cran.rstudio.com/', type='source')" && \ 
##  install.github("schardtbc/iexcloudR") 
##  install.packages("Riex")

# install shiny-server
RUN cd && \
    uname -a && \
    git clone https://github.com/rstudio/shiny-server.git && \
    cd shiny-server && \
    mkdir tmp && \
    cd tmp && \
    PATH=$PWD/../bin:$PATH && \
    #
    PYTHON=`which python` && \
    #
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DPYTHON="$PYTHON" ../ && \
    #
    make && \
    mkdir ../build && \
    # zap some stuff in external/node/install-node.sh
    sed -i 's/NODE_SHA256=.*/NODE_SHA256=bc7d4614a52782a65126fc1cc89c8490fc81eb317255b11e05b9e072e70f141d/' ../external/node/install-node.sh && \
    sed -i 's/linux-x64.tar.xz/linux-armv7l.tar.xz/' ../external/node/install-node.sh && \   
    sed -i 's#github.com/jcheng5/node-centos6/releases/download#nodejs.org/dist#' ../external/node/install-node.sh && \
    cat ../external/node/install-node.sh && \
    (cd .. && ./external/node/install-node.sh) && \
    (cd .. && ./bin/npm --python="${PYTHON}" install --no-optional) && \
    (cd .. && ./bin/npm --python="${PYTHON}" rebuild) && \
    sudo make install

# shiny-server post-install
RUN useradd -r -m shiny && usermod -aG sudo shiny && \
    ln -s /usr/local/shiny-server/bin/shiny-server /usr/bin/shiny-server && \
    sudo mkdir -p /var/log/shiny-server && \
    sudo mkdir -p /srv/shiny-server && \
    sudo mkdir -p /var/lib/shiny-server && \
    sudo chown shiny /var/log/shiny-server && \
    sudo mkdir -p /etc/shiny-server && \
    # configuration
    wget https://raw.githubusercontent.com/mk-mohan/raspirshiny/master/shiny-server.conf -O /etc/shiny-server/shiny-server.conf && \
    sudo wget https://raw.githubusercontent.com/mk-mohan/raspirshiny/master/shiny-server.service -O /lib/systemd/system/shiny-server.service && \
    sudo chown shiny /lib/systemd/system/shiny-server.service && \
    #sudo systemctl daemon-reload && \
    #sudo systemctl enable shiny-server && \
    # example app
    wget https://raw.githubusercontent.com/mk-mohan/raspirshiny/master/hello/app.R -P /srv/shiny-server/hello
# 
EXPOSE 3838
#CMD ["sudo systemctl start shiny-server"]