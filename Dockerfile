FROM nickandrew/alpine-mojo-base
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp

RUN apk add curl && cd /bin && curl -L https://cpanmin.us/ -o cpanm && chmod +x cpanm && cd /usr/src/myapp
RUN cpanm --installdeps --notest --exclude-vendor .

EXPOSE 8080

CMD [ "hypnotoad", "-f", "./script/flying_app" ]
