FROM ghcr.io/graalvm/jdk:java17-21.3 as build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B package

FROM ghcr.io/graalvm/jdk:java17-21.3

COPY --from=build target/library.jar .
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "library.jar"]
