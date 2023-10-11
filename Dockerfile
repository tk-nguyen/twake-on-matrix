# Specify versions
ARG FLUTTER_VERSION=3.10.6
ARG OLM_VERSION=3.2.15

# Building libolm
# libolm only has amd64 recipe for now
FROM --platform=linux/amd64 nixos/nix AS olm-builder
ARG OLM_VERSION
RUN nix build -v --extra-experimental-features flakes --extra-experimental-features nix-command gitlab:matrix-org/olm/${OLM_VERSION}?host=gitlab.matrix.org\#javascript

# Setting up flutter
FROM --platform=linux/amd64 ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION} AS web-builder
COPY . /app
WORKDIR /app
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    apt install -y openssh-client && \
    rm -rf assets/js/* && \
    mkdir ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts
COPY --from=olm-builder /result/javascript assets/js/package
RUN --mount=type=ssh,required=true ./scripts/build-web.sh

# Final image
FROM nginx:alpine AS final-image
RUN rm -rf /usr/share/nginx/html
COPY --from=web-builder /app/build/web /usr/share/nginx/html/web/

# Specify the port
EXPOSE 80
