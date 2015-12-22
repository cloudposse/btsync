changequote({{,}})dnl
define(BTSYNC_USER, {{{{btsync}}}})dnl
define(BTSYNC_LOG, /dev/stderr)dnl
define(BTSYNC_CONF, /etc/btsync/cluster.conf)dnl
define(ETCD_HOST, localhost)dnl
define(ETCD_PORT, 4001)dnl
define(CONFD_PREFIX, {{/btsync}})dnl
define(CONFD_INTERVAL, {{10}})dnl

# Due to https://github.com/Supervisor/supervisor/issues/126 cannot reliably use ENV everywhere. 


[supervisord]
nodaemon=true
logfile=/dev/stdout
logfile_maxbytes=0
minfds=2048
minprocs=256


# Overlayfs does not work with unix domain sockets: https://github.com/docker/docker/issues/12080
[inet_http_server]
port = 127.0.0.1:9001

[supervisorctl]
serverurl=http://127.0.0.1:9001

[program:btsync]
user=BTSYNC_USER
command=btsync --nodaemon --log "BTSYNC_LOG" --config "BTSYNC_CONF" 
autostart=true
autorestart=true
stopsignal=TERM
stopwaitsecs=60

stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
#redirect_stderr=true

stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:confd]
autorestart=true
command=confd -prefix=CONFD_PREFIX -interval=CONFD_INTERVAL -node=http://ETCD_HOST:ETCD_PORT
stopsignal=TERM
stopwaitsecs=20

stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
#redirect_stderr=true

stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
