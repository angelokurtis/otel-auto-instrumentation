FROM amazoncorretto:17.0.4 as build

COPY .mvn .mvn
COPY mvnw .
COPY pom.xml .
COPY src src
RUN --mount=type=cache,target=/root/.m2 ./mvnw -B package

FROM gcr.io/distroless/java17:nonroot

COPY --from=build target/library.jar .
EXPOSE 8080

CMD ["library.jar"]
