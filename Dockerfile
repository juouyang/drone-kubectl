FROM rancher/kubectl:v1.23.3

FROM alpine:3.15.4
LABEL maintainer "Ju <juouyang@gmail.com>"

# RUN apk --no-cache add curl ca-certificates && update-ca-certificates
RUN apk --no-cache add bash

COPY --from=0 /bin/kubectl /opt/rancher/kubectl/bin/kubectl
ENV PATH="/opt/rancher/kubectl/bin:$PATH"

COPY entrypoint.sh /bin/
ENTRYPOINT ["/bin/bash"]
CMD ["/bin/entrypoint.sh"]