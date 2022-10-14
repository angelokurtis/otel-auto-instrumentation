FROM amazoncorretto:17.0.4 as build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B package

FROM amazoncorretto:17-alpine3.16

COPY --from=build target/library.jar .
EXPOSE 8080

CMD ["java", "-jar", "library.jar"]
