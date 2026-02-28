# =============================================================
# Model Checking Toolbox
# Pre-installs SPIN, NuSMV, TLA+ (TLC), and UPPAAL (CLI)
# =============================================================
#
# Build:
#   docker build -t model-checker .
#
# Run (mount your models):
#   docker run --rm -v $(pwd):/models -w /models model-checker
#
# Examples inside the container:
#   spin -a models/spin/railway_crossing.pml && gcc -o pan pan.c && ./pan -a -N safety
#   NuSMV models/nusmv/railway_crossing.smv
#   cd models/tlaplus && tlc -config RailwayCrossing.cfg RailwayCrossing.tla
#   verifyta models/uppaal/railway_crossing.xml models/uppaal/railway_crossing.q
# =============================================================

FROM ubuntu:24.04

# ---- Tool versions (override at build time) ----
ARG SPIN_VERSION=6.5.2
ARG NUSMV_VERSION=2.7.0
ARG TLA_VERSION=v1.8.0
ARG UPPAAL_VERSION=5.0.0
ARG JAVA_VERSION=21

# ---- Labels ----
LABEL maintainer="model-checking-toolbox"
LABEL description="All-in-one model checking image: SPIN, NuSMV, TLA+/TLC, UPPAAL"
LABEL spin.version="${SPIN_VERSION}"
LABEL nusmv.version="${NUSMV_VERSION}"
LABEL tla.version="${TLA_VERSION}"
LABEL uppaal.version="${UPPAAL_VERSION}"

# ---- Base packages ----
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        make \
        wget \
        curl \
        ca-certificates \
        unzip \
        bzip2 \
        openjdk-${JAVA_VERSION}-jre-headless \
        xz-utils \
        yacc \
    && rm -rf /var/lib/apt/lists/*

# =============================================================
# 1. SPIN (Promela model checker)
#    https://github.com/nimble-code/Spin
# =============================================================
ARG SPIN_URL=https://github.com/nimble-code/Spin/archive/refs/tags/version-${SPIN_VERSION}.tar.gz
RUN mkdir -p /tmp/spin && cd /tmp/spin \
    && wget -qO- "${SPIN_URL}" | tar xz --strip-components=1 \
    && cd Src \
    && make \
    && cp spin /usr/local/bin/spin \
    && cd / && rm -rf /tmp/spin \
    && spin -V

# =============================================================
# 2. NuSMV (symbolic model checker)
#    https://nusmv.fbk.eu/
# =============================================================
ARG NUSMV_URL=https://nusmv.fbk.eu/distrib/${NUSMV_VERSION}/NuSMV-${NUSMV_VERSION}-linux64.tar.xz
RUN mkdir -p /tmp/nusmv && cd /tmp/nusmv \
    && wget -qO- "${NUSMV_URL}" | tar xJ --strip-components=1 \
    && cp bin/NuSMV /usr/local/bin/NuSMV \
    && cp -r share/nusmv /usr/local/share/nusmv 2>/dev/null || true \
    && cd / && rm -rf /tmp/nusmv \
    && NuSMV -help 2>&1 | head -3

# =============================================================
# 3. TLA+ / TLC (TLA+ model checker)
#    https://github.com/tlaplus/tlaplus
# =============================================================
ARG TLA_URL=https://github.com/tlaplus/tlaplus/releases/download/${TLA_VERSION}/tla2tools.jar
ENV TLA2TOOLS=/opt/tla/tla2tools.jar
RUN mkdir -p /opt/tla \
    && wget -qO "${TLA2TOOLS}" "${TLA_URL}" \
    && java -jar "${TLA2TOOLS}" -h 2>&1 | head -3 || true

# Convenience wrapper so users can just run: tlc MySpec.tla
RUN printf '#!/bin/sh\njava -XX:+UseParallelGC -jar %s "$@"\n' "${TLA2TOOLS}" \
        > /usr/local/bin/tlc \
    && chmod +x /usr/local/bin/tlc

# =============================================================
# 4. UPPAAL (timed automata model checker — CLI verifier)
#    https://uppaal.org/
#
#    UPPAAL requires license acceptance and cannot be downloaded
#    automatically. To include it:
#      1. Go to https://uppaal.org/downloads/
#      2. Accept the license and download the Linux archive
#      3. Place the .tar.gz in the Docker build context
#      4. Build with: docker build --build-arg UPPAAL_ARCHIVE=<filename> .
# =============================================================
ARG UPPAAL_ARCHIVE=""
COPY ${UPPAAL_ARCHIVE:-.dockerignore} /tmp/uppaal_archive
RUN if [ "$UPPAAL_ARCHIVE" != "" ]; then \
        mkdir -p /opt/uppaal \
        && tar xzf /tmp/uppaal_archive -C /opt/uppaal --strip-components=1 \
        && rm -f /tmp/uppaal_archive \
        && echo "UPPAAL installed"; \
    else \
        echo "UPPAAL skipped (no archive provided — see Dockerfile comments)"; \
    fi

ENV PATH="/opt/uppaal/bin:${PATH}"

# =============================================================
# Final setup
# =============================================================
WORKDIR /models

# Quick sanity check at build time
RUN echo "=== Installed tools ===" \
    && spin -V 2>&1 | head -1 \
    && (NuSMV -help 2>&1 | head -1 || echo "NuSMV: not available") \
    && java -jar "${TLA2TOOLS}" -h 2>&1 | head -1 || true \
    && (verifyta --version 2>&1 | head -1 || echo "UPPAAL: not available") \
    && echo "=== Ready ==="

CMD ["/bin/bash"]
