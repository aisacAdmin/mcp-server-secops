# To force a full rebuild, use: `docker build --no-cache .`

# Etapa 1: instalar dependencias del proyecto con uv
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS uv

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev --no-editable

ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev --no-editable

# Etapa 2: imagen final con todas las tools instaladas
FROM --platform=linux/arm64 python:3.12-slim-bookworm

ARG CACHEBUST=1

WORKDIR /app

# Instala herramientas del sistema necesarias para pentesting
RUN apt-get update && apt-get install -y \
    nmap \
    hashcat \
    git \
    curl \
    wget \
    unzip \
    build-essential \
    default-jdk \
    libpcap-dev \
    p7zip-full \
    && apt-get clean

# Set up tools directory
RUN mkdir -p /tools
ENV PATH="/tools:${PATH}"

# Install Nuclei
RUN wget -q https://github.com/projectdiscovery/nuclei/releases/download/v2.9.10/nuclei_2.9.10_linux_arm64.zip && \
    unzip -o nuclei_2.9.10_linux_arm64.zip -d /tools && \
    rm nuclei_2.9.10_linux_arm64.zip && \
    chmod +x /tools/nuclei

# Install FFUF
RUN wget -q https://github.com/ffuf/ffuf/releases/download/v2.0.0/ffuf_2.0.0_linux_arm64.tar.gz && \
    tar -xzf ffuf_2.0.0_linux_arm64.tar.gz -C /tools && \
    rm ffuf_2.0.0_linux_arm64.tar.gz && \
    chmod +x /tools/ffuf

# Install HTTPX
RUN wget -q https://github.com/projectdiscovery/httpx/releases/download/v1.3.4/httpx_1.3.4_linux_arm64.zip && \
    unzip -o httpx_1.3.4_linux_arm64.zip -d /tools && \
    rm httpx_1.3.4_linux_arm64.zip && \
    chmod +x /tools/httpx

# Install Subfinder
RUN wget -q https://github.com/projectdiscovery/subfinder/releases/download/v2.6.2/subfinder_2.6.2_linux_arm64.zip && \
    unzip -o subfinder_2.6.2_linux_arm64.zip -d /tools && \
    rm subfinder_2.6.2_linux_arm64.zip && \
    chmod +x /tools/subfinder

# Install TLSX
RUN wget -q https://github.com/projectdiscovery/tlsx/releases/download/v1.1.2/tlsx_1.1.2_linux_arm64.zip && \
    unzip -o tlsx_1.1.2_linux_arm64.zip -d /tools && \
    rm tlsx_1.1.2_linux_arm64.zip && \
    chmod +x /tools/tlsx

# Install XSStrike
RUN git clone https://github.com/s0md3v/XSStrike.git /tools/XSStrike && \
    chmod +x /tools/XSStrike/xsstrike.py && \
    ln -s /tools/XSStrike/xsstrike.py /tools/xsstrike

# Install Dirsearch
RUN git clone https://github.com/maurosoria/dirsearch.git --depth 1 /tools/Dirsearch && \
    ln -sf /tools/Dirsearch/dirsearch.py /tools/dirsearch

# Install Amass (manual download for arm64 compatibility)
RUN wget -q https://github.com/OWASP/Amass/releases/download/v3.23.3/amass_Linux_arm64.zip && \
    unzip -o amass_Linux_arm64.zip -d /tmp && \
    mv /tmp/amass_Linux_arm64/amass /tools/ && \
    rm -rf /tmp/amass_Linux_arm64 amass_Linux_arm64.zip && \
    chmod +x /tools/amass

# Install Hashcat (ARM64: no oficial ARM64 release; comment out for now, or compile from source if needed)
# RUN wget -q https://hashcat.net/files/hashcat-6.2.6.7z && \
#     7z x hashcat-6.2.6.7z && \
#     mv hashcat-6.2.6 /tools/hashcat && \
#     rm hashcat-6.2.6.7z && \
#     chmod +x /tools/hashcat/hashcat.bin

RUN pip install --no-cache-dir setuptools && \
    pip install --no-cache-dir \
    requests \
    beautifulsoup4 \
    lxml \
    python-nmap \
    paramiko \
    cryptography

# Copia el entorno y los paquetes instalados
COPY --from=uv /root/.local /root/.local
COPY --from=uv --chown=app:app /app/.venv /app/.venv

ENV PATH="/app/.venv/bin:$PATH"

COPY . /app
# Ejecuta el servidor MCP (ajústalo si cambias el nombre del entrypoint)
ENTRYPOINT ["mcp-server-secops"]