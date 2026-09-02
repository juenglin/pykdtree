FROM quay.io/pypa/manylinux_2_39_riscv64

# Build args supplied by devshell.sh so the image contains a user matching
# the host user (same uid/gid/username). This gives the container a real
# home directory with a proper /etc/passwd entry, so pip cache, ~, etc.
# all work naturally.
ARG HOST_USER
ARG HOST_UID
ARG HOST_GID

RUN groupadd -g "${HOST_GID}" "${HOST_USER}" \
    && useradd -m -u "${HOST_UID}" -g "${HOST_GID}" "${HOST_USER}"

# Install Python development headers needed to build C extensions
# (meson/Cython link-test requires python3.h)
RUN dnf install -y python3-devel && dnf clean all

# Configure pip system-wide to include the RISE riscv64 wheel index.
# This applies inside pip's build-isolation environments too, so packages
# like numpy are resolved as pre-built riscv64 wheels rather than source dists.
RUN printf '[global]\nextra-index-url = https://pypi.riseproject.dev/simple/\n' \
    > /etc/pip.conf
