FROM python:3.13


# Create Installation and Symlinks directories
RUN cd / && mkdir Tooling && mkdir ToolingBins
RUN echo 'export PATH=~/ToolingBins:$PATH' >> ~/.bashrc

# Install Git
RUN apt-get install -y git
RUN cd /ToolingBins && \
        ln -s /Tooling/git git

# Install Babylon
RUN cd /Tooling
RUN git clone https://github.com/Cosmo-Tech/Babylon.git Babylon && cd Babylon && git checkout 5.0.0
RUN python3 -m venv .venv && .venv/bin/pip install pyproject.toml
RUN cd /ToolingBins && \
        ln -s /Tooling/Babylon/.venv/bin/babylon babylon

# Install Kubectl
RUN cd /Tooling
RUN apt-get install -y apt-transport-https ca-certificates curl gnupg && \
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
        chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
RUN echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
        chmod 644 /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && \
        apt-get install -y kubectl

# Install Azure CLI
RUN cd /Tooling
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Terraform
RUN cd /Tooling
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
RUN apt-get update && \
        apt-get install -y terraform
RUN cd /ToolingBins && \
        ln -s /Tooling/terraform terraform
RUN mkdir /BMA && cd /BMA

ENTRYPOINT [ "bash" ]