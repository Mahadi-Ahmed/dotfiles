#!/usr/bin/env bash

# Close any open System Settings panes, to prevent them from overriding
# settings we're about to change
osascript -e 'tell application "System Settings" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


### Finder

echo "Show Path bar in Finder"
defaults write com.apple.finder ShowPathbar -bool true

echo "Show Status bar in Finder"
defaults write com.apple.finder ShowStatusBar -bool true

echo "Set Finder default view to column view"
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Finder Sidebar favorites
echo "Configuring Finder sidebar favorites"

echo "Show AirDrop in sidebar"
defaults write com.apple.finder SidebarShowAirDrop -bool true

echo "Show Applications folder in sidebar"
defaults write com.apple.finder SidebarShowApplications -bool true

echo "Show Desktop folder in sidebar"
defaults write com.apple.finder SidebarShowDesktop -bool true

echo "Show Downloads folder in sidebar"
defaults write com.apple.finder SidebarShowDownloads -bool true

echo "Show Home folder in sidebar"
defaults write com.apple.finder SidebarShowHome -bool true

echo "Hide Recents, documents, icloud, movies & pictures from sidebar"
defaults write com.apple.finder SidebarShowRecents -bool false
defaults write com.apple.finder SidebarShowDocuments -bool false
defaults write com.apple.finder SidebarShowiCloudDrive -bool false
defaults write com.apple.finder SidebarShowMovies -bool false
defaults write com.apple.finder SidebarShowMusic -bool false
defaults write com.apple.finder SidebarShowPictures -bool false

echo "Hide Tags from sidebar"
defaults write com.apple.finder ShowRecentTags -bool false

### Dock

echo "Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true

echo "Don't animate opening applications from the Dock"
defaults write com.apple.dock launchanim -bool false

echo "Remove the auto-hiding Dock delay"
defaults write com.apple.dock autohide-delay -float 0

echo "Remove the animation when hiding/showing the Dock"
defaults write com.apple.dock autohide-time-modifier -float 0

echo "Don't show recent applications in Dock"
defaults write com.apple.dock show-recents -bool false

echo "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true

echo "Remove unwanted apps from Dock"
# Remove Messages, Apple TV, FaceTime, Maps, Contacts, Photos, Reminders, Notes, Freeform, Music, App Store
# Using dockutil for reliable dock management
for app in \
  "Messages" \
  "TV" \
  "FaceTime" \
  "Maps" \
  "Contacts" \
  "Photos" \
  "Reminders" \
  "Notes" \
  "Freeform" \
  "Music" \
  "App Store"; do
  if dockutil --list | grep -q "$app"; then
    echo "  Removing $app from Dock"
    dockutil --remove "$app" --no-restart 2>/dev/null || true
  fi
done

### Menu Bar

echo "Show WiFi in menu bar"
defaults write com.apple.controlcenter "NSStatusItem Visible WiFi" -bool true

echo "Show Sound in menu bar"
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool true

echo "Show Input/Language menu in menu bar"
defaults write com.apple.TextInputMenu visible -bool true

echo "Hide Spotlight from menu bar"
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

echo "Disable Spotlight keyboard shortcuts (Cmd+Space and Option+Cmd+Space)"
# Disable Cmd+Space for Spotlight
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:64:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:64:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
# Disable Option+Cmd+Space for Finder search
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:65:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys:65:enabled bool false" ~/Library/Preferences/com.apple.symbolichotkeys.plist

### Power Management

echo "Set display sleep to 1 hour on battery"
sudo pmset -b displaysleep 60

echo "Set display sleep to 1 hour on power adapter"
sudo pmset -c displaysleep 60

echo "Set screensaver to start after 1 hour of inactivity"
defaults -currentHost write com.apple.screensaver idleTime -int 3600

# Disable Resume system-wide (apps start fresh instead of restoring previous windows)
echo "Disable Resume system-wide"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

### Misc

echo "Group windows by application in Mission Control"
defaults write com.apple.dock expose-group-apps -bool true

# Set a blazingly fast keyboard repeat rate
echo "Set a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Save to disk (not to iCloud) by default
echo "Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Increase sound quality for Bluetooth headphones/headsets
echo "Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Show language menu in the top right corner of the boot screen
echo "Show language menu in the top right corner of the boot screen"
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool true

### Kill
echo "Kill affected applications"

killall Finder
killall Dock
killall SystemUIServer
killall ControlCenter

echo "Restart for settings to take effect"
