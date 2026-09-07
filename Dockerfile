# Base image: Ruby with necessary dependencies for Jekyll
FROM ruby:3.2

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    && rm -rf /var/lib/apt/lists/*


# Create a non-root user with UID 1000
RUN groupadd -g 1000 vscode && \
    useradd -m -u 1000 -g vscode vscode

# Keep container dependencies outside the bind-mounted source tree.
WORKDIR /opt/jekyll

RUN chown -R vscode:vscode /opt/jekyll

# Switch to the non-root user
USER vscode

# Gemfile.lock is intentionally ignored by this repository, so resolve the
# container's dependency set in an isolated location that is not shadowed by
# the source bind mount.
COPY --chown=vscode:vscode Gemfile ./
ENV BUNDLE_GEMFILE=/opt/jekyll/Gemfile



# Install bundler and dependencies
RUN gem install connection_pool:2.5.0
RUN bundle install

WORKDIR /usr/src/app

# Command to serve the Jekyll site
CMD ["jekyll", "serve", "-H", "0.0.0.0", "-w", "--config", "_config.yml,_config_docker.yml"]
