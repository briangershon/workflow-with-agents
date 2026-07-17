# INV-PRIVILEGE-SEPARATION: no agent runtime in this image. This step's only job
# is getting code onto the shared volume.
FROM alpine:3.20

RUN apk add --no-cache git openssh-client

COPY clone.sh /usr/local/bin/clone.sh
RUN chmod +x /usr/local/bin/clone.sh

ENTRYPOINT ["/usr/local/bin/clone.sh"]
