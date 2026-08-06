# SPDX-FileCopyrightText: Copyright (C) 2010-2026 Cosmo Tech
# SPDX-License-Identifier: LicenseRef-CosmoTech

FROM debian:stable-20260713 as builder

# Avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install the base dependencies for the Cosmo Tech Solution Development Kit (SDK), also known as Cosmo Simulation Suite (CSS)
# as in https://cogit.cosmotech.com/projects/PROD/repos/css/browse/csmPackaging/Dockerfile.base
RUN apt-get update \
        && apt-get upgrade -y \
        && apt-get install -y \
        build-essential \
        # Cosmo Tech Solution Development Kit (SDK) dependencies
        ccache \
        libdbus-1-3 \
        libegl1 \
        libfontconfig1 \
        libgbm1 \
        libgd3 \
        libgl1 \
        libglib2.0-0 \
        libglx0 \
        libnss3 \
        libopengl0 \
        libsm6 \
        libwayland-cursor0 \
        libx11-xcb1 \
        libxcb-cursor0 \
        libxcb-dri3-0 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-render0 \
        libxcb-shape0 \
        libxcb-shm0 \
        libxcb-sync1 \
        libxcb-xfixes0 \
        libxcb-xinerama0 \
        libxcb-xkb1 \
        libxkbcommon-x11-0 \
        libxkbcommon0 \
        libxkbfile1 \
        python3-dev \
        python3-pip \
        python3-venv \
        zlib1g-dev \
        # Additional dependencies for tooling
        curl \
        wget \
        gnupg \
        libcairo2 \
        lsb-release \
        ca-certificates \
        python3.13-venv \
        apt-transport-https \
        # Clean up
        && rm -rf /var/lib/apt/lists/* \
        && apt-get autopurge -y \
        && apt-get clean

# Install the Cosmo Tech Solution Development Kit (SDK), also known as Cosmo Simulation Suite (CSS)
# as in https://cogit.cosmotech.com/projects/PROD/repos/css/browse/csmPackaging/Dockerfile.test
# Run the CSS installer
FROM builder AS pkg-installer-root
ARG PKG_FILENAME
COPY $PKG_FILENAME /pkg.run
RUN chmod +x /pkg.run
RUN mkdir -p /opt/Cosmotech/css
RUN /pkg.run install --confirm-command --accept-licenses --root /opt/Cosmotech/css
ARG PKG_RELEASE_VERSION

# The final image, based on the builder, with the CSS binaries copied from the pkg-installer-root stage
FROM builder
ENV PATH=$PATH:/opt/Cosmotech/css/bin \
        LC_ALL=C
COPY --from=pkg-installer-root /opt/Cosmotech/css /opt/Cosmotech/css

# Get the content delivery-brewery repository
WORKDIR /home/
COPY --from=workspace delivery-brewery/ /home/delivery-brewery/
WORKDIR /home/delivery-brewery/
RUN rm -rf .git .gitignore Generated

# Config Tooling installation and symlinks directories
WORKDIR /home/
RUN mkdir -p /home/Tooling /home/ToolingBins
ENV PATH="/home/ToolingBins:${PATH}"

# Install Git
RUN apt update && apt install -y --no-install-recommends git
# Add git to ToolingBins
WORKDIR /home/ToolingBins/
RUN ln -s /usr/bin/git git

# Install Docker as in https://docs.docker.com/engine/install/debian/
# Add Docker's official GPG key:
RUN apt update && \
        install -m 0755 -d /etc/apt/keyrings && \
        curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
        chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
RUN tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
# Install the Docker packages
RUN apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# Allow running systemctl inside the container, as in https://shamsfiroz.medium.com/running-inside-a-docker-container-a-practical-guide-cf7b31195575
VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]
# Add docker to ToolingBins
WORKDIR /home/ToolingBins/
RUN ln -s /usr/bin/docker docker

# Install Babylon
RUN python3 -m venv /home/.babylonenv
RUN /home/.babylonenv/bin/pip install git+https://github.com/Cosmo-Tech/Babylon.git@5.4.0
# Add babylon to ToolingBins
WORKDIR /home/ToolingBins/
RUN ln -sf /home/.babylonenv/bin/babylon babylon

# Install CoAL
WORKDIR /home/Tooling/
COPY --from=workspace CosmoTech-Acceleration-Library/ /home/Tooling/CosmoTech-Acceleration-Library/
WORKDIR /home/Tooling/CosmoTech-Acceleration-Library/
RUN python3 -m venv /home/Tooling/CosmoTech-Acceleration-Library/.coalenv
RUN /home/Tooling/CosmoTech-Acceleration-Library/.coalenv/bin/pip install -r ./requirements.all.txt
RUN /home/Tooling/CosmoTech-Acceleration-Library/.coalenv/bin/pip install -r ./requirements.doc.txt
# Add CoAL to ToolingBins
WORKDIR /home/ToolingBins/
RUN ln -sf /home/Tooling/CosmoTech-Acceleration-Library/.coalenv/bin/csm-data csm-data

# Install csm-orc
WORKDIR /home/Tooling/
COPY --from=workspace run-orchestrator/ /home/Tooling/run-orchestrator/
WORKDIR /home/Tooling/run-orchestrator/
RUN rm -rf .git .github
RUN python3 -m venv /home/Tooling/run-orchestrator/.csmorcenv
RUN /home/Tooling/run-orchestrator/.csmorcenv/bin/pip install -r ./requirements.all.txt
RUN /home/Tooling/run-orchestrator/.csmorcenv/bin/pip install cairocffi~=1.7.1 CairoSVG~=2.9.0
# Add csm-orc to ToolingBins
WORKDIR /home/ToolingBins/
RUN ln -sf /home/Tooling/run-orchestrator/.csmorcenv/bin/csm-orc csm-orc

# Install kubectl as in https://kubernetes.io/docs/tasks/tools/install-kubectl-linux
WORKDIR /home/Tooling/
# Download the public signing key for the Kubernetes package repositories:
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
RUN chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# Add the appropriate Kubernetes apt repository:
RUN echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
RUN chmod 644 /etc/apt/sources.list.d/kubernetes.list
# Update apt package index, then install kubectl:
RUN apt update && apt install -y kubectl
# Add kubectl to ToolingBins
WORKDIR /home/ToolingBins/
RUN ln -s /usr/bin/kubectl kubectl

# Install Azure CLI as in https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
# Launch the script maintained by the Azure CLI team:
RUN curl -fsSL 'https://azurecliprod.blob.core.windows.net/$root/deb_install.sh' | bash
# Add az to ToolingBins
WORKDIR /home/ToolingBins/
RUN ln -s /usr/bin/az az

# Install Terraform as in https://developer.hashicorp.com/terraform/install
WORKDIR /home/Tooling/
# Add HashiCorp repository
RUN wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
# Install Terraform
RUN apt update && apt install -y terraform
# Add terraform to ToolingBins
WORKDIR /home/ToolingBins/
RUN ln -s /usr/bin/terraform terraform

# Clean after installation
RUN rm -rf /var/lib/apt/lists/* \
        && apt-get autopurge -y \
        && apt-get clean

# Create a volume for shared data between the host and the container
RUN mkdir -p /home/bma_babylon_folder
VOLUME /home/bma_babylon_folder

# Display installed versions as a basic check that the tools are correctly installed and available in the PATH
WORKDIR /home/
RUN echo $(git version)
RUN echo $(docker --version)
RUN echo $(babylon --version)
RUN echo $(csm-data --version)
RUN echo $(csm-orc --version)
RUN echo $(kubectl version --client)
RUN echo $(az --version)
RUN echo $(terraform version)
RUN echo $(csm --version)