# bma_prerequisites

## Build

```bash
docker build -t <<docker_image_tag>> . --build-context workspace=../ -f ./Dockerfile --build-arg PKG_FILENAME=./cosmo_tech_platform-<version>-Release-<distribution_name>.run
```

with:
- **`<<docker_image_tag>>`**: the chosen tag for the image being built (for example, `aks-dev-pmu.azure.platform.cosmotech.com/tenant-hippodrome/bma_debian_env:BMA_with_SDK`)
</br>
- **`--build-context workspace=../ -f ./Dockerfile`**: the options defining the parent folder as the workspace and the Dockerfile in the current folder as the build configuration, with the parent folder containing the necessary external repository clones (i.e. [delivery-brewery](https://github.com/Cosmo-Tech/delivery-brewery), [CosmoTech-Acceleration-Library](https://github.com/Cosmo-Tech/CosmoTech-Acceleration-Library) and [run-orchestrator](https://github.com/Cosmo-Tech/run-orchestrator); cf. the `COPY --from=workspace` commands in the Dockerfile.)
</br>
- **`cosmo_tech_platform-<version>-Release-<distribution_name>.run`**: the binary installer of the Cosmo Tech SDK / Studio component (properly set up to be executed with `chmod u+x` for instance.)

## Compose run

```bash
docker compose run --rm bma
```

Files created or modified inside `/home/bma_babylon_folder` in the container will appear in the `bma_babylon_folder` folder on your host, editable in your IDE, cf. the `docker-compose.yml` file in this repository.

## Run in WSL

```bash
docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -v /mnt/wslg:/mnt/wslg -it -v /var/run/docker.sock:/var/run/docker.sock -v ./bma_babylon_folder:/home/bma_babylon_folder --rm --entrypoint /bin/bash <<docker_image_id>>
```

with:
- `-e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -v /mnt/wslg:/mnt/wslg -it -v /var/run/docker.sock:/var/run/docker.sock`: parameters allowing the GUI of the Cosmo Tech Studio from the container with WSL on Windows
</br>
- `/home/bma_babylon_folder`: a local Windows folder (manually created in the `/home/` path of the WSL installation) to be mounted in the existing `bma_babylon_folder` inside the container
</br>
- `<<docker_image_id>>`: the `IMAGE ID` of the corresponding Docker image as in the output of the `docker images` commands

## Run on Linux

```bash
docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v ./bma_babylon_folder:/home/bma_babylon_folder --rm --entrypoint /bin/bash <<docker_image_id>>
```
