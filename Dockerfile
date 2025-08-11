FROM eclipse-temurin:17-jdk-alpine

LABEL org.opencontainers.image.source="https://github.com/LenCompan/test-cheerz-springboot"

RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY ./build/libs/hello-world-0.0.1-SNAPSHOT.jar /app/

ENTRYPOINT ["java","-jar","app/hello-world-0.0.1-SNAPSHOT.jar"]