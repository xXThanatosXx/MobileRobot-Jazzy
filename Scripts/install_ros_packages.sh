#!/usr/bin/env bash

# Install the additional ROS 2 jazzy packages used by this project.
set -Eeuo pipefail

ROS_DISTRO="jazzy"

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

if [[ ! -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
    fail "ROS 2 jazzy is not installed. Run ros2_install.sh first."
fi

if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    if [[ "${ID:-}" != "ubuntu" || "${VERSION_CODENAME:-}" != "noble" ]]; then
        fail "These packages target ROS 2 jazzy on Ubuntu 24.04 Noble."
    fi
fi

info "Installing additional ROS 2 jazzy packages"
apt_update
sudo apt install -y \
    "ros-${ROS_DISTRO}-ros2-controllers" \
    "ros-${ROS_DISTRO}-ros-gz" \
    "ros-${ROS_DISTRO}-ros2-control" \
    "ros-${ROS_DISTRO}-gz-ros2-control" \
    "ros-${ROS_DISTRO}-joint-state-publisher" \
    "ros-${ROS_DISTRO}-joint-state-publisher-gui" \
    "ros-${ROS_DISTRO}-xacro" \
    "ros-${ROS_DISTRO}-tf2-ros" \
    "ros-${ROS_DISTRO}-tf2-tools" \
    "ros-${ROS_DISTRO}-rviz2" \
    "ros-${ROS_DISTRO}-rviz-default-plugins" \
    "ros-${ROS_DISTRO}-turtlesim" \
    "ros-${ROS_DISTRO}-robot-localization" \
    "ros-${ROS_DISTRO}-joy" \
    "ros-${ROS_DISTRO}-joy-teleop" \
    "ros-${ROS_DISTRO}-tf-transformations" \
    "ros-${ROS_DISTRO}-plotjuggler" \
    "ros-${ROS_DISTRO}-plotjuggler-ros" \
    python3-numpy python3-transforms3d python3-serial libeigen3-dev libserial-dev



printf '\nAdditional ROS 2 jazzy packages installed successfully.\n'
