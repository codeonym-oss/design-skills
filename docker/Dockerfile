# syntax=docker/dockerfile:1
#
# design-skills sandbox: a headless, reproducible design toolchain.
#
#   core  CLI toolkit — ImageMagick 7, Inkscape 1.4, ffmpeg 8, Ghostscript, Poppler,
#         potrace, web-image optimizers, exiftool, FontForge, curated fonts   (~1.3 GB)
#   full  core + Blender 5, GIMP 3.2, Krita 6, Scribus 1.6, darktable 5, MLT/melt,
#         G'MIC, Mesa (software GL + VAAPI), Xvfb, CJK fonts                  (~4 GB)
#
# Build from the repo root:  docker build -f docker/Dockerfile --target core -t design-skills:dev-core .

ARG UBUNTU_IMAGE=ubuntu:26.04@sha256:da6fc2be547864451aa253836dd926da33623312df4a9a243e35dc877c378a78

# ---------------------------------------------------------------------------
FROM ${UBUNTU_IMAGE} AS core-tools
ARG TARGETARCH
ARG OXIPNG_VERSION=10.2.1
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash ca-certificates curl file bc gawk procps less bats \
      python3 \
      imagemagick libmagickcore-7.q16-10-extra librsvg2-bin inkscape scour resvg potrace \
      pngquant optipng jpegoptim webp libavif-bin libjxl-tools \
      ghostscript poppler-utils \
      ffmpeg \
      libimage-exiftool-perl \
      fontconfig fontforge python3-fontforge woff2 \
      icc-profiles-free colord-data \
      fonts-inter fonts-ibm-plex fonts-jetbrains-mono fonts-firacode fonts-roboto fonts-open-sans \
      fonts-adobe-sourcesans3 fonts-noto-core fonts-noto-color-emoji fonts-liberation \
      fonts-dejavu-core fonts-crosextra-carlito \
    && rm -rf /var/lib/apt/lists/*

# oxipng is not packaged for Ubuntu: pinned upstream static build, checksum-verified.
RUN set -eu; \
    case "${TARGETARCH:-amd64}" in \
      amd64) triple=x86_64;  sum=1813750ef592c5350ca79c88f98b2c0876d05c826dc7156245256d4255c1ad17 ;; \
      arm64) triple=aarch64; sum=ff21aa2a005b324c8dfbdf13cd2f469fb6728b27dacded82635824ecd12e3b35 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    name="oxipng-${OXIPNG_VERSION}-${triple}-unknown-linux-musl"; \
    curl -fsSL -o /tmp/oxipng.tgz "https://github.com/oxipng/oxipng/releases/download/v${OXIPNG_VERSION}/${name}.tar.gz"; \
    echo "${sum}  /tmp/oxipng.tgz" | sha256sum -c -; \
    tar xzf /tmp/oxipng.tgz -C /tmp; install -m 0755 "/tmp/${name}/oxipng" /usr/local/bin/oxipng; \
    rm -rf /tmp/oxipng.tgz "/tmp/${name}"

# Any UID can run the image (docker run --user "$(id -u):$(id -g)"), so HOME must be world-writable.
RUN mkdir -p /home/designer /work && chmod 1777 /home/designer /work && fc-cache -f >/dev/null
ENV HOME=/home/designer \
    DS_IN_CONTAINER=1 \
    QT_QPA_PLATFORM=offscreen
WORKDIR /work

# ---------------------------------------------------------------------------
FROM core-tools AS full-tools
RUN apt-get update && apt-get install -y --no-install-recommends \
      blender python3-numpy \
      gimp gmic \
      krita \
      scribus hunspell-en-us \
      darktable \
      melt frei0r-plugins \
      mesa-libgallium libegl1 libgl1 libgles2 va-driver-all vainfo \
      xvfb xauth \
      fonts-noto-cjk fonts-noto-extra \
    && rm -rf /var/lib/apt/lists/* \
    && fc-cache -f >/dev/null
# Ubuntu ships Blender's Draco encoder under its CPython-tagged name, but the glTF add-on loads
# "libextern_draco.so" — without this link, GLB Draco compression silently does nothing.
RUN d=/usr/lib/blender/scripts/addons_core/io_scene_gltf2 \
    && ln -s "$(cd "$d" && ls libextern_draco.cpython-*.so)" "$d/libextern_draco.so"

# ---------------------------------------------------------------------------
# The skills themselves go in last, so editing a script never rebuilds the tool layers.
FROM core-tools AS core
ARG VERSION=dev
LABEL org.opencontainers.image.title="design-skills (core)" \
      org.opencontainers.image.description="Headless design toolchain for the codeonym-oss design skills: ImageMagick, Inkscape, ffmpeg, Ghostscript, Poppler, FontForge, optimizers, fonts." \
      org.opencontainers.image.source="https://github.com/codeonym-oss/design-skills" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}"
ENV DS_VARIANT=core DS_VERSION=${VERSION}
COPY --chmod=0755 bin/ /opt/design-skills/bin/
COPY lib/ /opt/design-skills/lib/
COPY skills/ /opt/design-skills/skills/
COPY tests/ /opt/design-skills/tests/
COPY VERSION /opt/design-skills/VERSION
RUN ln -s /opt/design-skills/bin/ds /usr/local/bin/ds
CMD ["bash"]

FROM full-tools AS full
ARG VERSION=dev
LABEL org.opencontainers.image.title="design-skills (full)" \
      org.opencontainers.image.description="Headless design toolchain for the codeonym-oss design skills: core + Blender, GIMP, Krita, Scribus, darktable, MLT." \
      org.opencontainers.image.source="https://github.com/codeonym-oss/design-skills" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}"
ENV DS_VARIANT=full DS_VERSION=${VERSION}
COPY --chmod=0755 bin/ /opt/design-skills/bin/
COPY lib/ /opt/design-skills/lib/
COPY skills/ /opt/design-skills/skills/
COPY tests/ /opt/design-skills/tests/
COPY VERSION /opt/design-skills/VERSION
RUN ln -s /opt/design-skills/bin/ds /usr/local/bin/ds
CMD ["bash"]
