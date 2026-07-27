# bma_prerequisites

## Build

```bash
docker build -t <<docker_image_tag>> . --build-arg PKG_FILENAME=./cosmo_tech_platform-<version>-Release-<distribution_name>.run
```

with:
- `<<docker_image_tag>>`: the chosen tag for the image being built (for example, `aks-dev-pmu.azure.platform.cosmotech.com/tenant-hippodrome/bma_debian_env:BMA_with_SDK`)
- `cosmo_tech_platform-<version>-Release-<distribution_name>.run`: the binary installer of the Cosmo Tech SDK / Studio component (properly set up to be executed with `chmod u+x ` for instance.)

## Compose run

```bash
docker compose run --rm bma
```

Files created or modified inside `/BMA` in the container will appear in the `BMA/` folder on your host, editable in your IDE, cf. the `docker-compose.yml` file in this repository.

## Run in WSL

```bash
docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -v /mnt/wslg:/mnt/wslg -it -v /var/run/docker.sock:/var/run/docker.sock -v ./bma_babylon_folder:/home/bma_babylon_folder --rm --entrypoint /bin/bash <<docker_image_id>>
```

with:
- `-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -v /mnt/wslg:/mnt/wslg -it -v /var/run/docker.sock:/var/run/docker.sock`: parameters allowing the GUI of the Cosmo Tech Studio from the container with WSL on Windows
- `/home/bma_babylon_folder`: a local Windows folder (in the `/home/` path of the WSL installation) to be mounted in the existing `bma_babylon_folder` inside the container
- `<<docker_image_id>>`: the `IMAGE ID` of the correspondig Docker image as in the output of the `docker images` command