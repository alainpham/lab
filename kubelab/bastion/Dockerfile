FROM debian:12

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        openssl \
        ca-certificates \
        bash-completion \
        sudo \
        git \
        vim \
        ncurses-term \
        openssh-server  && update-ca-certificates &&  \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd

RUN useradd -m -s /bin/bash appuser && echo "appuser:vcwxvcwxc!!" | chpasswd

RUN curl -Lko /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/download/v1.32.5+k3s1/k3s && \
    chmod 755 /usr/local/bin/k3s && \
    ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl && \
    ln -sf /usr/local/bin/k3s /usr/local/bin/crictl && \
    ln -sf /usr/local/bin/k3s /usr/local/bin/ctr

# RUN curl -fsSLk -o /tmp/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
#     chmod 700 /tmp/get_helm.sh && \
#     /tmp/get_helm.sh

RUN curl -LkO https://get.helm.sh/helm-v3.17.0-linux-amd64.tar.gz && tar -xzvf helm-v3.17.0-linux-amd64.tar.gz && cp linux-amd64/helm /usr/local/bin/

RUN mkdir -p /etc/bash_completion.d && \
    kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null && \
    helm completion bash | tee /etc/bash_completion.d/helm > /dev/null

RUN curl -LkO https://github.com/derailed/k9s/releases/download/v0.50.6/k9s_Linux_amd64.tar.gz && \
    tar -xzvf k9s_Linux_amd64.tar.gz  -C /usr/local/bin/ k9s

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
