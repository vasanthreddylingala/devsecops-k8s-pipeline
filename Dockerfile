FROM eclipse-temurin:17-jre-noble
RUN groupadd -r -g 10001 app && useradd -r -u 10001 -g app -s /sbin/nologin app
WORKDIR /app
COPY --chown=10001:10001 target/devsecops-demo.jar app.jar
USER 10001:10001
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
