FROM ghcr.io/graalvm/jdk:java17-21.3 as build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src

RUN ./mvnw -B package

FROM ghcr.io/graalvm/jdk:java17-21.3

COPY --from=build target/library-0.0.1-SNAPSHOT.jar .
COPY opentelemetry-javaagent.jar .

EXPOSE 8080

ENTRYPOINT ["java", "-javaagent:opentelemetry-javaagent.jar", "-jar", "library-0.0.1-SNAPSHOT.jar"]
