## Running JBPM with PostgreSQL 

# Pre-requisite

- Docker 17.10 


# Building Docker Image 

```
docker build --build-arg DB_HOST=localhost --build-arg DB_NAME=test --build-arg DB_USER=test --build-arg DB_PASS=testPassword -t dockerworx/jbpm-postgresql .
```

# Running Wildfly 11.0.0.Final with PostgreSQL 

```
docker run -d dockerworx/jbpm-postgresql

```

# How to access UI

http://<IP>
  
  
