#!/bin/bash

eval "$(/opt/homebrew/bin/brew shellenv)"

# Colima Docker socket configuration
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE="/var/run/docker.sock"
