#!/usr/bin/env zsh

# macOS Developer Environment Setup Script
# Version: 1.0.1

# This script sets up a macOS machine with developer tools, preferred apps,
# macOS settings, and shell enhancements.
# Feel free to customize or fork.

# ---------------------------- #
#       Basic Utilities        #
# ---------------------------- #

log() {
  echo "$1" | tee -a "$LOGFILE"
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
PYTHON_VERSION=3.10.6
JAVA_VERSION=17.0.2-open

log "Setup workspace - macOS"
log "  Version: $VERSION"
log "  Logfile: $LOGFILE"
log ""

if ! confirm "Do you want to continue?"; then
  log "User abort"
  exit 1
fi
log ""

# ---------------------------- #
#     Developer Essentials     #
# ---------------------------- #

echo "Creating an SSH key..."
ssh-keygen -t rsa

echo "Add this public key to GitHub:"
echo "https://github.com/account/ssh"
read -p "Press [Enter] once done..."

echo "Installing Xcode Command Line Tools..."
xcode-select --install

# Install Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Updating Homebrew..."
brew update

# Install CLI tools
brew install git
brew install wget
brew install tree
brew install python
brew install imagemagick
brew install ghostscript
brew install --cask brave-browser
brew tap heroku/brew && brew install heroku

# ---------------------------- #
#        Git Configuration     #
# ---------------------------- #

# Prompt for GitHub username and email
echo "Please enter your GitHub username:"
read -r GITHUB_USERNAME
echo "Please enter your GitHub email:"
read -r GITHUB_EMAIL

# Configure Git with user input
git config --global user.name "$GITHUB_USERNAME"
git config --global user.email "$GITHUB_EMAIL"

brew install git-extras legit git-flow

# ---------------------------- #
#      Programming Tools       #
# ---------------------------- #

brew install pyenv
git clone https://github.com/pyenv/pyenv-update.git ~/.pyenv/plugins/pyenv-update
pyenv install -s "$PYTHON_VERSION"

curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java "$JAVA_VERSION"
sdk install kotlin
sdk install maven
sdk install gradle

# ---------------------------- #
#        Applications          #
# ---------------------------- #

brew install --cask \
  jetbrains-toolbox \
  visual-studio-code \
  cyberduck \
  docker \
  google-chrome \
  grammarly-desktop \
  1password \
  1password-cli \
  brave-browser

# ---------------------------- #
#    Shell and Dotfiles Setup  #
# ---------------------------- #

curl -L http://install.ohmyz.sh | sh
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
chsh -s /bin/zsh

cd ~
git clone git@github.com:bradp/dotfiles.git .dotfiles
cd .dotfiles && sh symdotfiles

npm install -g grunt-cli

# ---------------------------- #
#     System Preferences       #
# ---------------------------- #

echo "Applying macOS system defaults..."

# General
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

# Finder
defaults write com.apple.finder QLEnableTextSelection -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle Clmv
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Dock
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock expose-group-by-app -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock mru-spaces -bool false

# Terminal
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

# Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari ShowFavoritesBar -bool false
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Transmission
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"
defaults write org.m0k.transmission DownloadAsk -bool false
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true
defaults write org.m0k.transmission WarningDonate -bool false
defaults write org.m0k.transmission WarningLegal -bool false

# Screenshot
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

# Trackpad & Mouse
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

# Gatekeeper
sudo spctl --master-disable
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Prevent Time Machine prompts
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# SSD optimizations
sudo pmset -a sms 0
sudo pmset -a standbydelay 86400

# Reload Finder and Dock
killall Finder
killall Dock

# ---------------------------- #
#          Complete            #
# ---------------------------- #

log "Setup complete 🎉"
log "Please reboot to ensure all system settings take effect."
