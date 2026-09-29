FROM ubuntu:24.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"
ENV PUB_CACHE=/home/flutteruser/.pub-cache

RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash flutteruser

RUN git clone --depth 1 --branch 3.47.5 \
    https://github.com/flutter/flutter.git \
    /opt/flutter

RUN chown -R flutteruser:flutteruser /opt/flutter

WORKDIR /app

COPY pubspec.* ./

RUN chown -R flutteruser:flutteruser /app

USER flutteruser

RUN flutter --version
RUN dart --version
RUN flutter config --enable-web

RUN flutter pub get

COPY --chown=flutteruser:flutteruser . .

RUN flutter build web --release

FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
