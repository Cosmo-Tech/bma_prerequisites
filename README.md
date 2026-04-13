# bma_prerequisites

## Build

```bash
docker build -t bma-prereq .
```

## Run

```bash
docker compose run --rm bma
```

Files created or modified inside `/BMA` in the container will appear in the `BMA/` folder on your host, editable in your IDE.