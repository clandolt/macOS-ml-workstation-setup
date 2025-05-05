#!/usr/bin/env zsh

# macOS Developer Environment Setup Script
# Version: 1.0.0

# This script sets up a macOS machine with developer tools, preferred apps,
# macOS settings, and shell enhancements.
# Feel free to customize or fork.

# Single-line invocation:
# /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/clandolt/macOS-ml-workstation-setup/main/macOS/install.sh)"

# ---------------------------- #
#       Basic Utilities        #
# ---------------------------- #

log() {
  local log_level=$1
  local message=$2
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  
  # Output formatted log message
  echo "$timestamp [$log_level] $message" | tee -a "$LOGFILE"
}

confirm() {
  local message=$1
  read -r "response?$message [y/N]: "
  case "$response" in
    [yY][eE][sS]|[yY]) true ;;
    *) false ;;
  esac
}

VERSION=1.0.0
LOGFILE=$(mktemp ~/install-$VERSION.log.XXXXXXXX) || exit 1

PYTHON_VERSION=3.12.2
JAVA_VERSION=17.0.2-open

log "INFO" "Setup workspace - macOS"
log "INFO" "  Version: $VERSION"
log "INFO" "  Logfile: $LOGFILE"
log "INFO" ""

if ! confirm "Do you want to continue?"; then
  log "WARN" "User aborted setup."
  exit 1
fi
log "INFO" ""

# ---------------------------- #
#     Developer Essentials     #
# ---------------------------- #

# Prompt the user for their email address
read -r "email?Please enter your GitHub email address: "
log "INFO" "Creating an Ed25519 SSH key for GitHub user $email..."
ssh-keygen -t ed25519 -C "$email"

log "INFO" "Add this public key to GitHub: https://github.com/account/ssh"
read -p "Press [Enter] once done..."

log "INFO" "Installing Xcode Command Line Tools..."
xcode-select --install

# Install Homebrew
log "  Installing brew ..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOGFILE"

log "INFO" "Updating Homebrew..."
brew update >> "$LOGFILE" 2>&1

# Install CLI tools
log "INFO" "Installing command-line tools..."

log "INFO" "  Installing git..."
brew install git >> "$LOGFILE" 2>&1

log "INFO" "  Installing wget..."
brew install wget >> "$LOGFILE" 2>&1

log "INFO" "  Installing tree..."
brew install tree >> "$LOGFILE" 2>&1

log "INFO" "  Installing ghostscript..."
brew install ghostscript >> "$LOGFILE" 2>&1

# ---------------------------- #
#        Git Configuration     #
# ---------------------------- #

# Prompt for GitHub username and email
echo "Please enter your GitHub username:"
read -r GITHUB_USERNAME
echo "Please enter your GitHub email:"
read -r GITHUB_EMAIL

log "INFO" "Configuring Git with username: $GITHUB_USERNAME, email: $GITHUB_EMAIL..."
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"

log "INFO" "Installing git-extras, legit, and git-flow..."
brew install git-extras legit git-flow >> "$LOGFILE" 2>&1

# ---------------------------- #
#      Programming Tools       #
# ---------------------------- #

log "INFO" "Installing programming tools..."

log "INFO" "  Installing pyenv..."
brew install pyenv >> "$LOGFILE" 2>&1

log "INFO" "  Installing pyenv-update..."
git clone https://github.com/pyenv/pyenv-update.git "$HOME/.pyenv/plugins/pyenv-update" >> "$LOGFILE" 2>&1
if [[ $? -ne 0 ]]; then
  log "ERROR" "Failed to install pyenv-update."
  exit 1
fi

log "INFO" "  Installing Python $PYTHON_VERSION..."
pyenv install -s "$PYTHON_VERSION" >> "$LOGFILE" 2>&1

log "INFO" "Installing JDK & JVM tools..."

log "INFO" "  Installing sdkman..."
curl -s "https://get.sdkman.io" | bash >> "$LOGFILE" 2>&1
source "$HOME/.sdkman/bin/sdkman-init.sh"

log "INFO" "  Installing Java $JAVA_VERSION..."
sdk install java "$JAVA_VERSION" >> "$LOGFILE" 2>&1

log "INFO" "  Installing Kotlin..."
sdk install kotlin >> "$LOGFILE" 2>&1

log "INFO" "  Installing Maven..."
sdk install maven >> "$LOGFILE" 2>&1

log "INFO" "  Installing Gradle..."
sdk install gradle >> "$LOGFILE" 2>&1

# ---------------------------- #
#        Applications          #
# ---------------------------- #

log "INFO" "Installing applications..."

brew install --cask \
  jetbrains-toolbox \
  visual-studio-code \
  cyberduck \
  docker \
  google-chrome \
  grammarly-desktop \
  brave-browser \
  keepassxc \
  microsoft-office \
  drawio \
  onedrive >> "$LOGFILE" 2>&1

log "INFO" "  Installing Imagemagick..."
brew install imagemagick >> "$LOGFILE" 2>&1

# ---------------------------- #
#    Shell Setup  #
# ---------------------------- #

log "INFO" "Installing Oh My Zsh..."
curl -L http://install.ohmyz.sh | sh >> "$LOGFILE" 2>&1
log "INFO" "Cloning Zsh plugins..."
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git >> "$LOGFILE" 2>&1
git clone https://github.com/zsh-users/zsh-autosuggestions.git >> "$LOGFILE" 2>&1

log "INFO" "Changing shell to Zsh..."
chsh -s /bin/zsh

# ---------------------------- #
#     System Preferences       #
# ---------------------------- #

log "INFO" "Applying macOS system defaults..."

# General settings
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
defaults write NSGlobalDomain AppleFontSmoothing -int 2
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Finder settings
defaults write com.apple.finder QLEnableTextSelection -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder FXPreferredViewStyle Clmv
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Dock settings
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock expose-group-by-app -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock mru-spaces -bool false

# Terminal settings
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

# Safari settings
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Transmission settings
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

# Screenshot settings
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

# Prevent Time Machine prompts
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Reload Finder and Dock
killall Finder
killall Dock

# ---------------------------- #
#          Complete            #
# ---------------------------- #

log "INFO" "Setup complete 🎉"
log "INFO" "Please reboot to ensure all system settings take effect."
