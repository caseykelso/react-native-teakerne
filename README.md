# Teakerne - A Makefile project for building, deploying, and debugging react-native android and ios applications from the CLI using macos or linux. This project unifies the workflow for both target platforms.
Mobile app for setting up, configuring, and testing the sensors

## Ubuntu 22.04 Environment Setup
```bash
sudo apt-get install git npm exuberant-ctags xclip ideviceinstaller
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
```

## Macos Ventura 13.4 Environment Setup
* Install Homebrew
```bash
brew install ctags git cgrep wget macvim npm nvm md5sha1sum mas bash-completion watchman zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting jq gsed xclip ideviceinstaller fastlane
echo '[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"' >> ~/.bash_profile
source ~/.bash_profile
brew tap AdoptOpenJDK/openjdk
brew install --cask adoptopenjdk11
brew uninstall --ignore-dependencies node 
brew uninstall --force node 
mkdir ~/.nvm
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh
nvm install 12.22.9
mas install 497799835
sudo xcode-select --switch /Applications/Xcode.app
sudo gem install activesupport -v 6.1.7.4
sudo gem install cocoapods xcode-install
```
* Add your apple id to xcode -> https://www.idownloadblog.com/2015/12/24/how-to-create-a-free-apple-developer-account-xcode/
(note that Xcode->Preferences is now XCode->Settings)

* Open Applications -> XCode
* Accept the terms of use and complete the install.

## Macos Optional
* Add this snippet to your ~.zshrc
```bash
 plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
  zsh-autocomplete
 )
zstyle ':completion:*:*:make:*' tag-order 'targets'
autoload -U compinit && compinit
```
* restart your terminal

## How To Generate Helloworld Project
```bash
make create.project
```

## How-to Build Android Initially
```bash
git clone git@github.com:caseykelso/react-native-template.git
cd reat-native-template
make ci.android
```

## How-to Build IOS Initially
```bash
git clone git@github.com:caseykelso/react-native-template.git
cd reat-native-template
make ci.ios
```

## Generate CTAG Symbols for Editor/IDE
```bash
make ctags
```

# Android Dev Cycle

## Typical Android Build & Deployment - Connect Device over USB
### Install and Run on Device with ADB
```bash
make build.debug.and.run
```

### Observe Android Device Logs
```bash
make logs.android
```

### Observe React-Native Logs
```bash
make logs.android.react-native
```

## Testing

### Build and Run Detox End to End Testsuite for Android
```bash
make build.release.and.run detox.release
```


# IOS Dev Cycle

## Apple App Store Keys
```bash
Keys are encrypted and stored on the apple-keys branch of this repo.
```

## Build, Deploy, and Run on simulator
```bash
make build.ios.debug xcode.run.simulator
```

## Build, Deploy, and Run on device
```
make build.ios.and.run
```

### Observe IOS React-Native Logs
```bash
make logs.ios.react-native
```

### Observe IOS Device Logs
```bash
make logs.ios
```

## Show connected IOS devices
```
make ios.devices
```

## Checking if an app is signed
```
make ios.check.signature
```

## Signing an app with developer keys

## Signing an app with release keys

TBD

# Android App Store / Google Play




