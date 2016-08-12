# Motivation

1. The offical docker image is not up to date.
2. I want it to be like Graphite that listen on data. Pushgateway will do it. Let me combine them together into one image.
3. The official image is based on busybox. I need iptables to limit who can push in data.

# To run it

docker build -t willnc/prometheus-combo 

```
docker run --detach=true --name=prom --hostname=prom --restart=always \
                -p 	0.0.0.0:9090:9090 -p 0.0.0.0:9091:9091 \
		-v ./data/:/usr/local/prometheus/data/ \
                --cap-add=NET_ADMIN \
                -d willnc/prometheus-combo
```

# To use it

I run bash script push_to_prom.sh on digital ocean droplet to push in cpu/network information.

Visit http://your_server_ip:9090/ to see the data/graph.

# Changes that may be needed

1. Decide where prometheus data should be put. In above example, I connect ./data/ to prometheus's data directory. Where there are lots of data coming in, this directory may be connectedt to a directory on ssd.
2. Update /etc/sysconfig/iptables in the container. Make sure prometheus is allowed to connect to pushgateway.
3. When Prometheus has new release, which seems to happen every month, change version number in Dockerfile and rebuild. If wget fail, go to https://prometheus.io/download/ to find latest url. Since storage directory is mounted to host, I hope new container will pick up all the data. I didn't get a chance to try it yet.
