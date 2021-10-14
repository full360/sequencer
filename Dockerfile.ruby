FROM ruby:2.7-alpine

# Install required packages
RUN apk add --no-cache \
  unzip \
  ca-certificates \
  bash \
  && update-ca-certificates

#set time zone
RUN mv /etc/localtime /etc/localtime.bak ; ln -s /usr/share/zoneinfo/UTC /etc/localtime

RUN gem install full360-sequencer

# this is the entry point
ADD entrypoint.sh /usr/sbin/runner.sh
RUN chmod 755 /usr/sbin/runner.sh
ENTRYPOINT ["/usr/sbin/runner.sh"]
