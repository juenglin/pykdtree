#!/usr/bin/env bash
# Usage: envshell.sh [python_executable]
#   python_executable defaults to "python3"
#   Inside the manylinux container, you can pass a specific interpreter, e.g.:
#     envshell.sh /opt/python/cp313-cp313/bin/python3
set -euo pipefail

PYTHON="${1:-python3}"
RISE_INDEX="https://pypi.riseproject.dev/simple/"

echo "Using Python: $("$PYTHON" --version)"

"$PYTHON" -m venv .venv
source .venv/bin/activate

# riscv64 wheel support in pip requires >= 24.1
pip install --quiet --upgrade pip

# Install build and test dependencies.
# --extra-index-url adds RISE alongside PyPI: binary riscv64 wheels are
# served from RISE while pure-Python packages (setuptools, pytest, etc.)
# fall through to PyPI as normal.
pip install \
    --extra-index-url "$RISE_INDEX" \
    "numpy>=2.0.0,<3" \
    "Cython>=3.1" \
    "setuptools" \
    "build" \
    "pytest" \
    "mypy" \
    "typing-extensions>=4.15"

# Reuse the rcfile that devshell.sh mounted at /etc/devshell.rc, then
# activate the venv so the prompt gets the "(.venv) " prefix.
bash --rcfile <(echo 'source /etc/devshell.rc; source .venv/bin/activate')
