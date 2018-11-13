FROM nginx:1.11

ENV DOCKERIZE_VERSION v0.6.1

RUN apt-get update \
    && apt-get install -y --force-yes --no-install-recommends curl \
    && curl -Ls https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
       | tar -xzv -C /usr/local/bin \
	&& apt-get purge -y curl \
	&& rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /app

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY default.conf.tmpl /tmp/default.conf.tmpl
COPY custom_50x.html /usr/share/nginx/html/custom_50x.html

ENTRYPOINT ["dockerize", "-template", "/tmp/default.conf.tmpl:/etc/nginx/conf.d/default.conf"]

VOLUME ["/app"]

CMD ["nginx", "-g", "daemon off;"]
