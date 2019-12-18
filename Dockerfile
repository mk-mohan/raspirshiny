FROM upadrishta/pir

# install shiny
RUN R -e "install.packages('later', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('fs', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('Rcpp', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('httpuv', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('mime', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('jsonlite', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('digest', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('htmltools', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('xtable', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('R6', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('Cairo', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('sourcetools', repos='http://cran.rstudio.com/', type='source')" && \
    R -e "install.packages('shiny', repos='https://cran.rstudio.com/', type='source')"; 

# install cmake
RUN wget https://cmake.org/files/v3.16/cmake-3.16.1.tar.gz && \
    tar xzf cmake-3.16.1.tar.gz && \
    cd cmake-3.16.1 && \
    ./bootstrap && \
    make && \
    make install;

# create shiny user
RUN useradd -r -m shiny && \
    usermod -aG sudo shiny

USER shiny

# install shiny-server
RUN cd && \
    git clone https://github.com/rstudio/shiny-server.git && \
    cd shiny-server && \
    mkdir tmp && \
    cd tmp && \
    DIR=`pwd` && \
    PATH=$DIR/../bin:$PATH && \
    PYTHON=`which python` && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DPYTHON="$PYTHON" ../ && \
    make && \
    mkdir ../build && \
    sed -i '8s/.*/NODE_SHA256=7a2bb6e37615fa45926ac0ad4e5ecda4a98e2956e468dedc337117bfbae0ac68/' ../external/node/install-node.sh && \
    sed -i 's/linux-x64.tar.xz/linux-armv7l.tar.xz/' ../external/node/install-node.sh && \
    (cd .. && ./external/node/install-node.sh) && \
    (cd .. && ./bin/npm --python="${PYTHON}" install --no-optional) && \
    (cd .. && ./bin/npm --python="${PYTHON}" rebuild)

USER root

RUN cd /home/shiny/shiny-server/tmp/ && \
    sudo make install

# shiny-server post-install
RUN ln -s /usr/local/shiny-server/bin/shiny-server /usr/bin/shiny-server && \
    sudo mkdir -p /var/log/shiny-server && \
    sudo mkdir -p /srv/shiny-server && \
    sudo mkdir -p /var/lib/shiny-server && \
    sudo chown shiny /var/log/shiny-server && \
    sudo mkdir -p /etc/shiny-server && \
    # configuration
    cd && \
    cp /home/shiny/shiny-server/config/default.config /etc/shiny-server/ && \
    cd /etc/shiny-server/ && \
    sudo cp default.config shiny-server.conf && \
    # example app
    sudo mkdir /srv/shiny-server/example && \
    sudo cp /home/shiny/shiny-server/samples/sample-apps/hello/ui.R /srv/shiny-server/example/ && \
    sudo cp /home/shiny/shiny-server/samples/sample-apps/hello/server.R /srv/shiny-server/example/

# clean up
RUN rm -R cmake-3.12.0-rc2 && \
    rm -R /home/shiny/shiny-server

# copy files
COPY init.d-shiny-server /etc/init.d/shiny-server
COPY ./start.sh /start.sh
RUN chmod 755 /start.sh


EXPOSE 3838

ENTRYPOINT ["/start.sh"]
