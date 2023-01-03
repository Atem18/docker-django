# docker-django

Create a .env file in the root folder with the following content:

```bash
ALLOWED_HOSTS=["*"]
APP_DB_NAME=app
APP_DB_USER=app
APP_DB_PASSWORD=app
APP_DB_HOST=db
APP_DB_PORT=5432
DEBUG=True
ENV=dev
SECRET_KEY="django-insecure-g4t5!n2f53ixx)$y!5s9#8!$&$8%d3169@gv!i()nhcr9yk*l0"
```

## Development
docker-compose up -d

### Using a library that needs to be compiled ? 

Use compiled-lib.dockerfile in docker-images folder as an example to your Dockerfile or modify the docker-compose to add/modify:
```yaml
  container_name: web
    build:
      context: ./docker-images/.
      dockerfile: compiled-lib.dockerfile
```

## Production test
docker-compose -f docker-compose.prod.yml up -d
