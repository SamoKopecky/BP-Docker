FROM debian:latest
WORKDIR /root

# Parameters
ARG OPENSSL_VER=1.1.1d
ARG NGINX_VER=1.19.6
ARG PYTHON_VER=3.7.9

# Install required packages
RUN apt-get update && \
apt-get install -y wget && \
apt-get install -y make && \
apt-get install -y build-essential && \
apt-get install -y zlib1g-dev && \
apt-get install -y vim && \
apt-get install -y curl && \
apt-get install -y git && \
apt-get install -y bsdmainutils && \
apt-get install -y procps && \
apt-get install -y dnsutils

# Download and extract openssl version of OPENSSL_VER
RUN wget https://www.openssl.org/source/openssl-$OPENSSL_VER.tar.gz && \
tar -xzf openssl-$OPENSSL_VER.tar.gz && \
rm openssl-$OPENSSL_VER.tar.gz

# Download and extract python version of PYTHON_VER
RUN wget https://www.python.org/ftp/python/$PYTHON_VER/Python-$PYTHON_VER.tgz && \
tar -xzf Python-$PYTHON_VER.tgz && \
rm Python-$PYTHON_VER.tgz 

# Download and extract nginx  version of NGINX_VER
RUN wget https://nginx.org/download/nginx-$NGINX_VER.tar.gz && \
tar -xzf nginx-$NGINX_VER.tar.gz && \
rm nginx-$NGINX_VER.tar.gz

# Download and extract required package for nginx
RUN wget https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.bz2 && \
tar -xf pcre-8.44.tar.bz2 && \
rm pcre-8.44.tar.bz2

# Compile and install openssl
RUN cd /root/openssl-$OPENSSL_VER && \
./Configure enable-ssl2 enable-ssl3 enable-ssl3-method linux-x86_64 no-shared --prefix=/usr --openssldir=/usr/lib/ssl enable-weak-ssl-ciphers -DOPENSSL_TLS_SECURITY_LEVEL=0 && \
make && \
make install

# Configure python
RUN cd /root/Python-$PYTHON_VER && \
./configure --with-openssl=/usr/ --enable-optimizations --with-ssl-default-suites=openssl CFLAGS="-I/usr/include" LDFLAGS="-L/usr"

# Compile and install nginx
RUN cd /root/nginx-$NGINX_VER && \
./configure --sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/nginx.conf --pid-path=/usr/local/nginx/nginx.pid --with-http_ssl_module --with-pcre=../pcre-8.44 && \
make && \
make install

# Edit PATH for nginx
ENV PATH="/usr/local/nginx:${PATH}"

# Create keys for nginx server
RUN mkdir keys && \
openssl req -x509 -newkey rsa:2048 -keyout /root/keys/key.pem -out /root/keys/cert.pem -days 365 -nodes -subj "/C=SK/ST=Slovakia/L=Slovakia/O=BP/OU=BP/CN=BP.sk" 

# Copy config file 
COPY nginx.conf /usr/local/nginx/nginx.conf
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
