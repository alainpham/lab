#!/bin/bash

if ! command -v git >/dev/null 2>&1; then
  if command -v zypper >/dev/null 2>&1; then
    sudo zypper install -y git
  elif command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y git-core
  else
    echo "Error: git is not installed and no supported package manager was found." >&2
    exit 1
  fi
fi

rm -rf lab

git clone https://github.com/alainpham/lab.git