FROM ghcr.io/graalvm/jdk:java17-21.3 as build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B package

FROM ghcr.io/graalvm/jdk:java17-21.3

ENV OTEL_AGENT_VERSION=1.17.0

COPY --from=build target/library.jar .
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v${OTEL_AGENT_VERSION}/opentelemetry-javaagent.jar opentelemetry-javaagent.jar
EXPOSE 8080

ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar", "library.jar"]
