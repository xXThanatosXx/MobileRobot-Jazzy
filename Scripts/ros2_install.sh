#!/usr/bin/env bash

# Install ROS 2 jazzy on Ubuntu 24.04 (Noble).
set -Eeuo pipefail

ROS_DISTRO="jazzy"
WORKSPACE_NAME="colcon_ws"
BASHRC_MARKER="# MobileRobot ROS 2 jazzy"

info() {
    printf '\n\033[34m>>>\033[0m %s\n' "$*"
}

fail() {
    printf '\nError: %s\n' "$*" >&2
    exit 1
}

use_main_ubuntu_mirror() {
    local sources_file="/etc/apt/sources.list"
    local backup_file="${sources_file}.mobile-robot-backup"

    if [[ ! -f "${sources_file}" ]] || ! grep -Eq 'https?://co\.archive\.ubuntu\.com/ubuntu' "${sources_file}"; then
        return 1
    fi

    if [[ ! -e "${backup_file}" ]]; then
        sudo cp "${sources_file}" "${backup_file}"
    fi

    sudo sed -Ei 's|https?://co\.archive\.ubuntu\.com/ubuntu|http://archive.ubuntu.com/ubuntu|g' "${sources_file}"
    info "The Colombia Ubuntu mirror was unavailable. Switched to archive.ubuntu.com."
}

apt_update() {
    if sudo apt-get update -o APT::Update::Error-Mode=any; then
        return
    fi

    if use_main_ubuntu_mirror && sudo apt-get update -o APT::Update::Error-Mode=any; then
        return
    fi

    fail "APT could not update every repository. Check your network connection and Ubuntu mirror."
}

if [[ "${EUID}" -eq 0 ]]; then
    fail "Run this script as a regular user. It will request sudo when needed."
fi

if [[ ! -r /etc/os-release ]]; then
    fail "This script must run on Ubuntu 24.04."
fi

# shellcheck disable=SC1091
source /etc/os-release
if [[ "${ID:-}" != "ubuntu" || "${VERSION_CODENAME:-}" != "noble" ]]; then
    fail "ROS 2 jazzy requires Ubuntu 24.04 Noble. Detected: ${PRETTY_NAME:-unknown}."
fi

info "ROS 2 jazzy will be installed in Ubuntu 24.04 Noble."
read -r -p "Press Enter to continue or Ctrl+C to cancel..."

info "Configuring locale and Ubuntu repositories"
apt_update
sudo apt install -y locales software-properties-common curl
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
sudo add-apt-repository -y universe
apt_update

info "Configuring the official ROS 2 apt repository"
ROS_APT_SOURCE_VERSION="$(curl -fsSL https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F '"tag_name"' | awk -F '"' '{print $4}')"
[[ -n "${ROS_APT_SOURCE_VERSION}" ]] || fail "Could not determine the ros2-apt-source version."

ROS_APT_SOURCE_DEB="/tmp/ros2-apt-source.deb"
curl -fL -o "${ROS_APT_SOURCE_DEB}" "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.${VERSION_CODENAME}_all.deb"
sudo dpkg -i "${ROS_APT_SOURCE_DEB}"
rm -f "${ROS_APT_SOURCE_DEB}"

info "Installing ROS 2 ${ROS_DISTRO} and development tools"
apt_update
sudo apt install -y \
    "ros-${ROS_DISTRO}-desktop" \
    python3-argcomplete \
    python3-colcon-common-extensions \
    python3-vcstool \
    python3-rosdep

if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
    info "Initializing rosdep"
    sudo rosdep init
fi
rosdep update

WORKSPACE_PATH="${HOME}/${WORKSPACE_NAME}"
mkdir -p "${WORKSPACE_PATH}/src"

if ! grep -Fqx "${BASHRC_MARKER}" "${HOME}/.bashrc" 2>/dev/null; then
    info "Adding ROS 2 environment setup to ${HOME}/.bashrc"
    cat >> "${HOME}/.bashrc" <<EOF

${BASHRC_MARKER}
source /opt/ros/${ROS_DISTRO}/setup.bash
if [ -f "${WORKSPACE_PATH}/install/setup.bash" ]; then
    source "${WORKSPACE_PATH}/install/setup.bash"
fi
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
export ROS_DOMAIN_ID=0
EOF
fi

info "Installation complete. Open a new terminal or run: source ~/.bashrc"
info "Workspace created at: ${WORKSPACE_PATH}"
