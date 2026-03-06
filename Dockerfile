# Stage 1: Build Flutter web
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-build
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
COPY lib/ lib/
COPY web/ web/
COPY assets/ assets/
COPY analysis_options.yaml ./
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Compile Dart server
FROM dart:stable AS server-build
WORKDIR /app
COPY server/pubspec.yaml server/
COPY server/bin/ server/bin/
WORKDIR /app/server
RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server

# Stage 3: Minimal runtime
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=server-build /app/server/bin/server ./server
COPY --from=flutter-build /app/build/web ./build/web
EXPOSE 8080
CMD ["./server"]
