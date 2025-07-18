FROM docker.io/buildkite/hosted-agent-base:ubuntu-v1.0.1@sha256:f1378abd34fccb2b7b661aaf3b06394509a4f7b5bb8c2f8ad431e7eaa1cabc9c
# Install system packages (Ubuntu-based)

RUN apt-get update && apt-get install -y \
    make \
    shfmt \
    shellcheck \
    curl \
    git \
    unzip \
    wget \
    ca-certificates \
    openssh-client \
    build-essential \
    python3-dev \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install yarn from dl.yarnpkg.com
RUN apt-get update && apt-get install -y curl apt-transport-https  && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn # Install Yarn

# Install dotnet from microsoft
RUN wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
  dpkg -i packages-microsoft-prod.deb && \
  apt-get update && \
  apt-get install -y dotnet-sdk-8.0


RUN git clone https://github.com/alexanderguy/opsh.git && cd opsh  && make install


RUN curl -fsSL https://get.pulumi.com | sh -x
RUN mv ~/.pulumi /usr/local/pulumi # Adjust path as needed
ENV PATH="$PATH:/usr/local/pulumi/bin"

RUN ls -Rl /usr/local

# Verify installation
RUN pulumi version


# Set Go version
ENV GO_VERSION=1.24.3

# Install Go (official binary distribution)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        GOARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        GOARCH="arm64"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GOARCH}.tar.gz" -o go.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz


# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Create working directories
RUN mkdir -p /go/src /go/bin

# Optional: verify Go version
RUN go version

RUN PULUMICTL_VERSION=0.0.49 && \
  ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        ARCH="amd64"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        ARCH="arm64"; \
    else \
        echo "Unsupported architecture: $ARCH"; exit 1; \
    fi && \
  curl -L -o pulumictl.tar.gz  \
    "https://github.com/pulumi/pulumictl/releases/download/v${PULUMICTL_VERSION}/pulumictl-v${PULUMICTL_VERSION}-linux-${ARCH}.tar.gz" && \
  tar -xzf pulumictl.tar.gz  && \
  chmod +x pulumictl && \
  mv pulumictl /usr/local/bin/ && \
  rm pulumictl.tar.gz 

