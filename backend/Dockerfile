FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the jar file built by Gradle
COPY ./build/libs/msa-backend-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]