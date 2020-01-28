FROM upadrishta/pirplus:3.6.2

# install pre-requisites
RUN apt-get update && apt-get install -y git libssl-dev cmake cpp \
    gdebi-core pandoc pandoc-citeproc libcurl4-gnutls-dev xtail \ 
    libpq-dev postgresql-client postgresql-client-common && \
    sudo mkdir -p /var/www/html/ && \
    sudo chown -R www-data:pi /var/www/html/ && \
    sudo chmod -R 770 /var/www/html/

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
    sed -i 's/NODE_SHA256=.*/NODE_SHA256=ed4e625c84b877905eda4f356c8b4183c642e5ee6d59513d6329674ec23df234/' ../external/node/install-node.sh && \
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
    sudo mkdir -p /srv/shiny-server && \
    sudo mkdir -p /var/lib/shiny-server && \
    sudo mkdir -p /etc/shiny-server && \
    # configuration
    wget https://raw.githubusercontent.com/mk-mohan/raspirshiny/master/shiny-server.conf -O /etc/shiny-server/shiny-server.conf && \
    sudo wget https://raw.githubusercontent.com/mk-mohan/raspirshiny/master/shiny-server.service -O /lib/systemd/system/shiny-server.service && \
    sudo wget https://raw.githubusercontent.com/mk-mohan/raspirshiny/master/shiny-server.sh -O /usr/bin/shiny-server.sh && \
    sudo chmod +x /usr/bin/shiny-server.sh && \
    sudo chown shiny:shiny /lib/systemd/system/shiny-server.service

# 
EXPOSE 3838
CMD ["/bin/bash"]
##CMD ["/usr/bin/shiny-server.sh"]