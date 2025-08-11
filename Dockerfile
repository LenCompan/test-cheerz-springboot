FROM eclipse-temurin:17-jdk-alpine
RUN addgroup --system spring && adduser --system --group spring
USER spring:spring

COPY ./build/libs/hello-world-0.0.1-SNAPSHOT.jar /app/

ENTRYPOINT ["java","-jar","app/hello-world-0.0.1-SNAPSHOT.jar"]