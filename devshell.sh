#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE="pykdtree-dev-riscv64"

docker buildx build \
    --platform linux/riscv64 \
    --load \
    --build-arg "HOST_USER=$(whoami)" \
    --build-arg "HOST_UID=$(id -u)" \
    --build-arg "HOST_GID=$(id -g)" \
    -t "${IMAGE}" \
    "${SCRIPT_DIR}/docker"

RCFILE=$(mktemp --suffix=.sh)
trap 'rm -f "$RCFILE"' EXIT

# Derive container PS1 from host PS1:
#  - strip conda/venv prefix e.g. "(base) "
#  - replace \u with literal username
#  - replace \h / \H with manylinux_riscv64
CONTAINER_PS1="${PS1:-\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ }"
CONTAINER_PS1="${CONTAINER_PS1#\(*\) }"
CONTAINER_PS1="${CONTAINER_PS1//\\u/$(whoami)}"
CONTAINER_PS1="${CONTAINER_PS1//\\h/manylinux_riscv64}"
CONTAINER_PS1="${CONTAINER_PS1//\\H/manylinux_riscv64}"
# recolor user@host: replace green (32m) with magenta/purple (35m)
CONTAINER_PS1="${CONTAINER_PS1//01;32m/01;35m}"
CONTAINER_PS1="${CONTAINER_PS1//00;32m/00;35m}"

cat > "$RCFILE" << 'EOF'
[ -f /etc/bashrc ] && source /etc/bashrc
EOF
printf 'PS1=%q\n' "$CONTAINER_PS1" >> "$RCFILE"
cat >> "$RCFILE" << 'EOF'

# color support
command -v dircolors &>/dev/null && eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
EOF

docker run --rm -it \
    --platform linux/riscv64 \
    --user "$(id -u):$(id -g)" \
    -v "${HOME}:${HOME}" \
    -w "$(pwd)" \
    -e "HOME=${HOME}" \
    -e "TERM=${TERM:-xterm-256color}" \
    -e "COLORTERM=${COLORTERM:-truecolor}" \
    -v "${RCFILE}:/etc/devshell.rc:ro" \
    "${IMAGE}" \
    bash --rcfile /etc/devshell.rc
