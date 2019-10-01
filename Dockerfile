FROM amazonlinux:latest
EXPOSE 22

COPY *.sh /
# COPY bootstrap.sh /
# COPY entrypoint.sh /
RUN ls -l
RUN /bootstrap.sh

ADD environment /root/.ssh/environment
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]