FROM gradle:8.14-jdk21 AS build

WORKDIR /app
COPY backend/ktor-app/ /app/

RUN gradle installDist --no-daemon

FROM eclipse-temurin:21-jre

WORKDIR /app

COPY --from=build /app/build/install/ktor-app /app/
COPY backend/certs/keystore.p12 /certs/keystore.p12

EXPOSE 8443

CMD ["/app/bin/ktor-app"]