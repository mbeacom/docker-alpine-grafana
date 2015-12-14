FROM alpine:latest

RUN export GRAFANA_VERSION=v2.6.0-beta1 \
    && export GOPATH=/go \
    && PATH=$PATH:$GOPATH/bin \
    && apk add --update build-base nodejs go git mercurial \
    && mkdir -p /go/src/github.com/grafana && cd /go/src/github.com/grafana \
    && git clone https://github.com/grafana/grafana.git -b ${GRAFANA_VERSION} \
    && cd grafana \
    && go run build.go setup \
    && godep restore \
    && go build . \
    && npm install \
    && npm install -g grunt-cli \
    && curl -Ls https://github.com/fgrehm/docker-phantomjs2/releases/download/v2.0.0-20150722/dockerized-phantomjs.tar.gz | tar xz -C / \
    && cd /go/src/github.com/grafana/grafana/node_modules/karma-phantomjs-launcher/node_modules/phantomjs && node install \
    && cd /go/src/github.com/grafana/grafana && export PHANTOMJS_BIN=/usr/local/bin/phantomjs  && grunt \
    && npm uninstall -g grunt-cli \
    && npm cache clear \
    && mkdir -p /usr/share/grafana/bin/ \
    && cp -a /go/src/github.com/grafana/grafana/grafana /usr/share/grafana/bin/grafana-server \
    && cp -ra /go/src/github.com/grafana/grafana/public_gen /usr/share/grafana \
    && mv /go/src/github.com/grafana/grafana/public_gen /usr/share/grafana/grafana/public \
    && cp -ra /go/src/github.com/grafana/grafana/conf /usr/share/grafana \
    && go clean -i -r \
    && apk del --purge build-base nodejs go git mercurial \
    && rm -rf /go /tmp/* /var/cache/apk/* /root/.n* /usr/local/bin/phantomjs

WORKDIR /usr/share/grafana/
CMD ["/usr/share/grafana/bin/grafana-server"]
