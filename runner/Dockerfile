# Use official Alpine base
FROM ubuntu:22.04

# Environment variables
ARG RUNNER_VERSION=2.328.0
ARG OPENJDK_VERSION=17
ARG NODE_VERSION=18

# Install dependencies including glibc compatibility for GitHub runner
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    sudo \
    curl \
    jq \
    git \
    unzip \
    openjdk-17-jdk \
    maven \
    nodejs \
    npm \
    python3 \
    python3-pip \
    gettext \
    uuid-runtime \
    && npm install -g yarn \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2 (static binary)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Create non-root user for runner
RUN useradd -m runner && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/runner

# Download and extract GitHub Actions runner, then install runner dependencies
RUN curl -sSL "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" -o actions-runner.tar.gz \
    && tar -xzf actions-runner.tar.gz \
    && rm actions-runner.tar.gz \
    && ./bin/installdependencies.sh \
    && chown -R runner:runner /home/runner \
    && rm -rf /var/lib/apt/lists/*

# Copy your startup script (you need to provide this with your build context)
COPY --chown=runner:runner runner/start.sh /home/runner/start.sh
RUN chmod +x /home/runner/start.sh

# Switch to runner user
USER runner
ENTRYPOINT ["/home/runner/start.sh"]
