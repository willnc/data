FROM centos:6

MAINTAINER willnc   

EXPOSE 9090 9091    

ENV prom_version 1.0.1
ENV pushgateway_version 0.3.0

RUN cd /usr/local/ ; \
        wget https://github.com/prometheus/prometheus/releases/download/v${prom_version}/prometheus-${prom_version}.linux-amd64.tar.gz ; \
        wget https://github.com/prometheus/pushgateway/releases/download/${pushgateway_version}/pushgateway-${pushgateway_version}.linux-amd64.tar.gz ; \
        tar xzf prometheus-${prom_version}.linux-amd64.tar.gz ; \
        tar xzf pushgateway-${pushgateway_version}.linux-amd64.tar.gz ; \
        ln -s /usr/local/prometheus-${prom_version}.linux-amd64 /usr/local/prometheus ; \
        ln -s  /usr/local/pushgateway-${pushgateway_version}.linux-amd64 /usr/local/pushgateway

COPY  prometheus.yml /usr/local/prometheus/
COPY sysroot/ /

CMD ["/etc/docker/docker.init"]

