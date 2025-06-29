# ----------------------------------------------------------------------------
# Attribution Assurance License (AAL)
# Copyright © 2025 AERO Company (Olivier Flentge)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions, and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions, and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. The name "AERO", "AERO Company", "Olivier Flentge", or any derivatives
#    thereof, may not be used to endorse or promote products derived from this
#    software without specific prior written permission, except as required for
#    attribution under clause 4.
# 4. Any use of the Software, whether modified or unmodified, must include a
#    visible and clear attribution to the original authorship. This includes,
#    but is not limited to, the display of the following acknowledgment:
#       "Powered by AERO Company – https://aero.nu"
#    The acknowledgment must be present in the documentation, terminal output,
#    and any public-facing UI, website, or control panel.
# 5. If the Software is used in a commercial or monetized context, the
#    attribution requirements in clause 4 are mandatory and non-negotiable.
# 6. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
# ----------------------------------------------------------------------------

# --- Build stage ------------------------------------------------------------
FROM rust:1.78-slim AS builder

# Install required build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        musl-dev git coreutils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Source retrieval arguments
ARG GIT_URL="https://github.com/Pumpkin-MC/Pumpkin.git"
ARG GIT_BRANCH="main"
ARG GIT_COMMIT=""

WORKDIR /src

# Clone repository
RUN git clone --branch "${GIT_BRANCH}" --depth 1 "${GIT_URL}" . \
    && if [ -n "${GIT_COMMIT}" ]; then \
         git fetch --depth 1 origin "${GIT_COMMIT}" && git checkout "${GIT_COMMIT}" ; \
       fi

# Build release (locked Cargo.lock for reproducibility)
RUN cargo build --release --locked

# Strip binary for minimal size
RUN strip "target/release/pumpkin"

# --- Runtime-stage --------------------
FROM debian:bookworm-slim AS runtime

# Create non-root user
RUN groupadd -r pumpkin && useradd -r -g pumpkin pumpkin

# Minimal runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tini sed \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/pumpkin

# Copy binary & entrypoint
COPY --from=builder /src/target/release/pumpkin /usr/local/bin/pumpkin
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY config/pumpkin.toml ./config/pumpkin.toml

RUN chown -R pumpkin:pumpkin /home/pumpkin \
    && chmod +x /usr/local/bin/entrypoint.sh

USER pumpkin

# Default environment variables (can be overridden via Pterodactyl)
ENV CONFIG_FILE="config/pumpkin.toml" \
    MOTD="Welcome to my AERO server!"

# Port exposed by Pterodactyl
EXPOSE ${SERVER_PORT}

ENTRYPOINT ["tini", "--", "/usr/local/bin/entrypoint.sh"] 