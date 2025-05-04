# macOS ML Workstation Setup

> 📦 This repository contains my personal automated setup script for a macOS machine learning and software engineering workstation.

## 🧰 Overview

This repository contains a setup script to bootstrap a macOS machine with all essential tools, applications, and settings needed for a productive development workflow. It includes:

- Developer tools (Xcode CLI, Homebrew, Git, SDKMAN, pyenv)
- Programming environments (Python, Java, Kotlin, Maven, Gradle)
- Essential applications (VS Code, JetBrains Toolbox, Docker, Chrome, etc.)
- System preferences tuning
- Shell customization (Oh My Zsh + plugins)
- GitHub SSH key setup

Designed for reproducible, quick setups of clean macOS environments—ideal for new machines or reinstalls.

---

## 🚀 Quick Setup

Run the following in your terminal on a macOS system:

```bash
/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/clandolt/macOS-ml-workstation-setup/main/macOS/install.sh)"
