FROM extvos/centos
MAINTAINER  "Mingcai SHEN <archsh@gmail.com>"
ENV RABBITMQ_VERSION 3.5.4-1
ENV RABBITMQ_LOGS=- RABBITMQ_SASL_LOGS=-

RUN yum install -y ca-certificates \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64" \
	&& chmod +x /usr/local/bin/gosu \
	&& set -x \
	&& curl -fSL "https://github.com/krallin/tini/releases/download/v0.5.0/tini" -o /usr/local/bin/tini \
	&& chmod +x /usr/local/bin/tini \
	&& tini -h

RUN yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm \
	&& yum install -y erlang \
	&& rpm --import https://www.rabbitmq.com/rabbitmq-signing-key-public.asc \
	&& yum install -y https://www.rabbitmq.com/releases/rabbitmq-server/v3.5.4/rabbitmq-server-3.5.4-1.noarch.rpm

ENV PATH /usr/lib/rabbitmq/bin:$PATH

RUN echo '[{rabbit, [{loopback_users, []}]}].' > /etc/rabbitmq/rabbitmq.config

VOLUME /var/lib/rabbitmq
COPY entrypoint.sh /

# add a symlink to the .erlang.cookie in /root so we can "docker exec rabbitmqctl ..." without gosu
RUN ln -sf /var/lib/rabbitmq/.erlang.cookie /root/ \
	&& chmod +x /entrypoint.sh \
	&& chmod go+rx /root/ 


ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 5672
CMD ["rabbitmq-server"]