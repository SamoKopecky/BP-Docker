FROM debian:latest
WORKDIR /root
RUN apt-get update && \
apt-get install -y wget && \
apt-get install -y make && \
apt-get install -y build-essential && \
apt-get install -y zlib1g-dev && \
apt-get install -y vim && \
apt-get install -y curl
RUN wget https://www.openssl.org/source/openssl-1.1.1d.tar.gz && \
tar -xzf openssl-1.1.1d.tar.gz && \
rm openssl-1.1.1d.tar.gz
RUN wget https://nginx.org/download/nginx-1.19.6.tar.gz && \
tar -xzf nginx-1.19.6.tar.gz && \
rm nginx-1.19.6.tar.gz
RUN wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.bz2 && \
tar -xf pcre-8.44.tar.bz2 && \
rm pcre-8.44.tar.bz2
RUN cd /root/openssl-1.1.1d && \
./Configure enable-ssl2 enable-ssl3 enable-ssl3-method linux-x86_64 no-shared --prefix=/usr --openssldir=/usr/lib/ssl enable-weak-ssl-ciphers -DOPENSSL_TLS_SECURITY_LEVEL=0 && \
make && \
make install
RUN cd /root/nginx-1.19.6 && \
./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf --pid-path=/usr/local/nginx/nginx.pid --with-http_ssl_module --with-pcre=../pcre-8.44 && \
make && \
make install
ENV PATH="/usr/local/nginx:${PATH}"
RUN mkdir keys && \
openssl req -x509 -newkey rsa:2048 -keyout /root/keys/key.pem -out /root/keys/cert.pem -days 365 -nodes -subj "/C=SK/ST=Slovakia/L=Slovakia/O=BP/OU=BP/CN=BP.sk" 
COPY nginx.conf /usr/local/nginx/nginx.conf
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
