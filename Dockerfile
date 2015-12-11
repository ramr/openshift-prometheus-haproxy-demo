FROM fedora

ADD bin/ /srv/prometheus/

EXPOSE 9090

ENTRYPOINT [ "/srv/prometheus/bin/ctl.sh", "start" ]
