FROM ghcr.io/graalvm/jdk:java17-21.3 as build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
RUN ./mvnw verify --fail-never

COPY src src
RUN ./mvnw -B package

FROM ghcr.io/graalvm/jdk:java17-21.3

COPY --from=build target/library-0.0.1-SNAPSHOT.jar .
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "library-0.0.1-SNAPSHOT.jar"]
