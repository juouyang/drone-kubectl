FROM rancher/kubectl:v1.23.3

FROM alpine:3.15.4
LABEL maintainer "Ju <juouyang@gmail.com>"

# RUN apk --no-cache add curl ca-certificates && update-ca-certificates
RUN apk --no-cache add bash gettext

COPY --from=0 /bin/kubectl /usr/local/bin/kubectl