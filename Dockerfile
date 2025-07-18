# syntax=docker/dockerfile:1.4

FROM buildkite/agent:3-ubuntu

# Use BuildKit's automatic TARGETPLATFORM support
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

# Use bash for all RUN steps
SHELL ["/bin/bash", "-c"]

# Detect ARCH from TARGETPLATFORM and persist for reuse
RUN case "$TARGETPLATFORM" in \
      "linux/amd64") ARCH="amd64" ;; \
      "linux/arm64") ARCH="arm64" ;; \
      *) echo "Unsupported TARGETPLATFORM=$TARGETPLATFORM" && exit 1 ;; \
    esac && \
    echo "ARCH=$ARCH" > /arch.env

# Install core packages
RUN apt-get update && apt-get install -y \
    make \
    shfmt \
    shellcheck \
    curl \
    git \
    unzip \
    wget \
    ca-certificates \
    libssl-dev \
    openssh-client \
    build-essential \
    python3-dev \
    python3-pip \
    python3-venv \
    apt-transport-https \
    gnupg \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Install PNPM
RUN curl -fsSL https://get.pnpm.io/install.sh | \
    env PNPM_HOME=/usr/local/bin SHELL=/bin/bash sh -

# Install .NET SDK 8.0
RUN curl -fsSL https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -o packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-sdk-8.0 && \
    rm packages-microsoft-prod.deb

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk

# Install Pulumi CLI
RUN curl -fsSL https://get.pulumi.com | sh -s -- --install-root "/usr/local/pulumi"
ENV PATH="/usr/local/pulumi/bin:$PATH"

# Install Go
ENV GO_VERSION=1.24.4
RUN source /arch.env && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -o go.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV GOPATH="/go"
ENV PATH="/usr/local/go/bin:${GOPATH}/bin:${PATH}"

# Install latest released opsh from GitHub
RUN curl -fsSL -o /usr/local/bin/opsh https://github.com/alexanderguy/opsh/releases/latest/download/opsh && \
    chmod a+rx /usr/local/bin/opsh

# Install pulumictl
RUN PULUMICTL_VERSION=0.0.49 && \
    source /arch.env && \
    curl -L -o pulumictl.tar.gz \
      "https://github.com/pulumi/pulumictl/releases/download/v${PULUMICTL_VERSION}/pulumictl-v${PULUMICTL_VERSION}-linux-${ARCH}.tar.gz" && \
    tar -xzf pulumictl.tar.gz && \
    chmod +x pulumictl && mv pulumictl /usr/local/bin/ && rm pulumictl.tar.gz

# Install Solana CLI from Anza release channel
env PATH="/root/.local/share/solana/install/active_release/bin:$PATH"
RUN source /arch.env && \
  if [ "$ARCH" = "amd64" ]; then \
    sh -c "$(curl -fsSL https://release.anza.xyz/stable/install)"; \
    solana --version \
    else \
    echo "Skipping Anza install on $ARCH"; \
    fi
# Optional: verify tools
RUN pulumictl version && pulumi version && go version && dotnet --version
WORKDIR /workdir
