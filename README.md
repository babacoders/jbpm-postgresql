# Running JBPM with PostgreSQL instead of default Database

# Pre-requisite

- Docker 17.10 installed on your Linux System


# How to build Docker Image 

```
docker build --build-arg DB_HOST=localhost --build-arg DB_NAME=test --build-arg DB_USER=test --build-arg DB_PASS=testPassword -t dockerworx/jbpm-postgresql .
```

## How to run Wildfly 11.0.0.Final with PostgreSQL without building the Docker Image

```
docker run -d dockerworx/jbpm-postgresql

```

# How to access UI

http://<IP>/
  
  
