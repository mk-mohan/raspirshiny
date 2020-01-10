FROM upadrishta/pir:3.6.1

# install pre-requisites
RUN apt-get install -y git libssl-dev cmake cpp

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
    wget https://raw.githubusercontent.com/mk-mohan/raspirshiny/master/shiny-server.service -O /lib/systemd/system/shiny-server.service && \
    sudo chown shiny /lib/systemd/system/shiny-server.service && \
    sudo systemctl daemon-reload && \
    sudo systemctl enable shiny-server && \
    # example app
    wget https://raw.githubusercontent.com/mk-mohan/raspirshiny/master/hello/app.R -P /srv/shiny-server/hello
# 
EXPOSE 3838
CMD ["sudo systemctl start shiny-server"]