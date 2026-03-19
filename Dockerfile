FROM ubuntu:24.04
ENV TARGETARCH="linux-x64"
# Also can be "linux-arm", "linux-arm64".

WORKDIR /azp/

RUN apt update \
    && apt install -y curl git jq libicu74 curl unzip sudo ca-certificates nano \
    # install docker cli
    && sudo install -m 0755 -d /etc/apt/keyrings \
    && sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && sudo chmod a+r /etc/apt/keyrings/docker.asc \
    && echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update \
     && apt install docker-ce-cli -y \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash\
    # install kubectl and helm
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh && ./get_helm.sh
    

WORKDIR /azp/

COPY ./start.sh ./
RUN chmod +x ./start.sh

# Create agent user and set up home directory
# RUN useradd -m -d /home/agent agent
# RUN echo agent ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/agent \
#      && chmod 0440 /etc/sudoers.d/agent
# RUN chown -R agent:agent /azp /home/agent

# USER agent

# RUN sudo groupadd docker\ 
#      && sudo usermod -aG docker agent \ 
#      && sudo newgrp docker

# Another option is to run the agent as root.
ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT [ "./start.sh" ]