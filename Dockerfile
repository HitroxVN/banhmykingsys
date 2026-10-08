# dockerfile phias backend
FROM maven:3.9.16-eclipse-temurin-17-alpine AS build
WORKDIR /build

COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine AS runtime
WORKDIR /app

RUN addgroup -S app && adduser -S -G app app

COPY --from=build /build/target/*.jar app.jar

RUN mkdir -p /app/uploads /app/private-uploads/cv && chown -R app:app /app
VOLUME ["/app/uploads", "/app/private-uploads"]

USER app
EXPOSE 8080
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75"

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
    CMD wget -qO- http://127.0.0.1:${SERVER_PORT:-8080}/api/v1/health || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
