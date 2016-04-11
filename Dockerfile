FROM debian:8
ADD ./sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install openssl --assume-yes && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete
RUN apt-get update && apt-get install easy-rsa --assume-yes && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete
RUN apt-get update && apt-get install rsync --assume-yes && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete
RUN apt-get update && apt-get install nano --assume-yes && rm -f /var/cache/apt/archives/*deb && find /var/lib/apt/lists/ -type f -delete

RUN useradd -m usergeneric

ADD ./kickstart.sh /home/usergeneric/
RUN chown usergeneric:usergeneric /home/usergeneric/kickstart.sh
RUN chmod +x /home/usergeneric/kickstart.sh

USER usergeneric

WORKDIR /home/usergeneric/
RUN mkdir easy-rsa/

CMD ["/home/usergeneric/kickstart.sh"]
