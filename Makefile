SHELL := /bin/bash
ifndef ORG_NAME
$(error ORG_NAME must be defined.)
else
ORG.NAME=$(ORG_NAME)
endif

ifndef APP_NAME
$(error APP_NAME must be defined.)
else
APP.NAME=$(APP_NAME)
endif

ifndef BASE_DIR
$(error BASE_DIR must be defined.)
else
BASE.DIR=$(BASE_DIR)
endif



CONTACT.EMAIL=yourname@$(ORG.NAME).com
APP.ID=com.$(ORG.NAME).$(APP.NAME)
PROJECT.DIR=$(BASE.DIR)/$(APP.NAME)
GIT.ORG=caseykelso
GIT.REPO=react-native-template
1PASSWORD.SECRETS.URL="https://1password.com/secretslinkfordecrypt"
CURRENT_DIR := ${CURDIR}
HASH := $(shell git rev-parse --short=10 HEAD)
TAG := $(shell git describe --exact-match --tags 2>/dev/null)
ifeq ($(TAG),) #if tag is empty use hash
VERSION = $(HASH)
else
VERSION = $(TAG)
endif
OS := $(shell uname)
INSTALLED.HOST.DIR=$(BASE.DIR)/installed.host
DOWNLOADS.DIR=$(BASE.DIR)/downloads
NODE.MODULES.DIR=$(BASE.DIR)/node_modules
NODE.BUILD.DIR=$(BASE.DIR)/build
SHELL := /bin/bash
ANDROID.DIR=$(PROJECT.DIR)/android
ifeq ($(OS),Darwin)
SED=gsed
ANDROID.SDK.ARCHIVE=commandlinetools-mac-9477386_latest.zip
SIMULATOR_UID:=$(shell xcrun simctl list | cgrep "myiphone14promax" | head -1 | cut -f6 -d " " | tr -d "()" )
endif
ifeq ($(OS),Linux)
ANDROID.SDK.ARCHIVE=commandlinetools-linux-9477386_latest.zip
SED=sed
endif
ANDROID.SDK.URL=https://buildroot-sources.s3.amazonaws.com/$(ANDROID.SDK.ARCHIVE)
ANDROID.HOME=$(ANDROID.SDK.DIR)/platforms
ANDROID.SDK.DIR=$(DOWNLOADS.DIR)/cmdline-tools
SDKMANAGER.BIN=$(ANDROID.SDK.DIR)/bin/sdkmanager
AVDMANAGER.BIN=$(ANDROID.SDK.DIR)/bin/avdmanager
ANDROID.BIN=$(ANDROID.SDK.DIR)/platforms/tools/android
EMULATOR.BIN=$(ANDROID.SDK.DIR)/platforms/tools/emulator
LOCAL.PROPERTIES=$(ANDROID.DIR)/local.properties
AVD.DIR=$(DOWNLOADS.DIR)/avds
BREW.PREFIX=/usr/local/opt/nvm
IOS.DIR=$(PROJECT.DIR)/ios
IOS.WORKSPACE=$(IOS.DIR)/$(APP.NAME).xcworkspace
IOS.PROJECT=$(IOS.DIR)/$(APP.NAME).xcodeproj
IOS.OUTPUT=$(IOS.DIR)/output
IOS.XCARCHIVE=$(IOS.OUTPUT)/$(APP.NAME).xcarchive
IOS.ARCHIVE=$(APP.NAME)-$(HASH).tar.gz
IOS.APP.PATH=$(BASE.DIR)/ios/output/$(APP.NAME).xcarchive/Products/Applications/$(APP.NAME).app
IOS.CERTIFICATE.DISTRIBUTION="Apple Distribution: TODO"
IOS.CERTIFICATE.DEVELOPMENT="Apple Development: TODO"

ifeq ($(OS),Darwin)
$(info MacOS Detected)
JAVA.HOME=/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home
$(info source $(BREW.PREFIX)/nvm.sh && npm config get prefix)
NODE.PREFIX=$(shell source $(BREW.PREFIX)/nvm.sh && npm config get prefix)
NODE.BINARY.MACOS=$(NODE.PREFIX)/bin/node
XCODEBUILD.BIN=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
endif
ifeq ($(OS),Linux)
JAVA.HOME=/usr/lib/jvm/java-11-openjdk-amd64/
endif
ENV.VARS.ROOT=export JAVA_HOME=$(JAVA.HOME) && export ANDROID_HOME=$(ANDROID.SDK.DIR)/platforms && export PATH=$(ANDROID.HOME)/tools:$(ANDROID.HOME)/platform-tools:$(ANDROID.SDK.DIR)/bin:$(PROJECT.DIR)/node_modules/.bin:$(PATH)  && export ANDROID_SDK_ROOT=$(ANDROID.SDK.DIR)/platforms
NPM.GLOBAL.PATH=$(npm config get prefix)
ifeq ($(OS), Darwin)
ENV.VARS=$(ENV.VARS.ROOT) && export NVM_DIR=~/.nvm && source $(BREW.PREFIX)/nvm.sh && export NODE_BINARY=$(NODE.BINARY.MACOS) #&& $(info $(ENV.VARS))
endif
ifeq ($(OS), Linux)
ENV.VARS=$(ENV.VARS.ROOT)
endif
SCRIPTS.DIR=$(BASE.DIR)/scripts
DECRYPT.SCRIPT=$(SCRIPTS.DIR)/decrypt.sh
ENCRYPT.SCRIPT=$(SCRIPTS.DIR)/encrypt.sh
DECRYPT.SIGNING.SCRIPT=$(SCRIPTS.DIR)/decrypt_signing_key.sh
ENCRYPT.SIGNING.SCRIPT=$(SCRIPTS.DIR)/encrypt_signing_key.sh
ci: ci.android
ci.android.common: nvm.install nvm update.build.number decrypt.secrets android.sdk install.node build.apk.release build.apk.debug build.android.bundle.debug build.android.bundle.release 
ci.android: ci.android.common package.android
ci.android.signed: ci.android.common decrypt.signing sign.android.upload.key package.android
ci.ios: ios.get.certificates.development ios.automatic.code.signing.disable nvm.install nvm update.build.number decrypt.secrets install.node install.pods build.ios.debug  package.ios
PACKAGE.NAME=$(APP.ID)
DIST.DIR=$(BASE.DIR)/dist
APK.DEBUG.ORIG=$(PROJECT.DIR)/android/app/build/outputs/apk/debug/app-debug.apk
ANDROID.BUNDLE.DEBUG.ORIG=$(PROJECT.DIR)/android/app/build/outputs/bundle/debug/app-debug.aab
ANDROID.BUNDLE.RELEASE.ORIG=$(PROJECT.DIR)/android/app/build/outputs/bundle/release/app-release.aab
ANDROID.BUNDLE.DEBUG=$(APP.NAME)-debug-$(VERSION).aab

ifndef ANDROID_SIGNED_BUILD
ANDROID.BUNDLE.RELEASE=$(APP.NAME)-release-unsigned-$(VERSION).aab
else
ANDROID.BUNDLE.RELEASE=$(APP.NAME)-release-signed-$(VERSION).aab
endif

ANDROID.UPLOAD.KEY.ALIAS=key0
ANDROID.UPLOAD.KEY.KEYSTORE=$(BASE.DIR)/keystore.jks
APK.DEBUG=$(APP.NAME)-debug-$(VERSION).apk
APK.RELEASE.ORIG=$(PROJECT.DIR)/android/app/build/outputs/apk/release/app-release.apk
APK.RELEASE=$(APP.NAME)-release-$(VERSION).apk

ifndef ANDROID_SIGNED_BUILD
ANDROID.ARCHIVE=$(APP.NAME)-unsigned-$(VERSION).tar.gz
else
ANDROID.ARCHIVE=$(APP.NAME)-signed-$(VERSION).tar.gz
endif

AWS.BIN=aws
KEYSTORE.PATH=$(BASE.DIR)
BUILD.NUMBER.MAGIC.NUMBER=0000001
SCREENSHOTS.DIR=$(BASE.DIR)/screenshots
DATETIME:=$(shell date +%Y%m%d%H%M%S)
#ifneq (,$(wildcard $(BASE.DIR)/package.json))
#NODE.VERSION=$(shell cat package.json  | jq .engines.node | tr -d \")
#else
NODE.VERSION=18.17.1
#endif
NVM.VARS=NVM_DIR="$(HOME)/.nvm" && . "$${NVM_DIR}/nvm.sh" && nvm use $(NODE.VERSION)
REACT.NATIVE.INSTALL.VERSION=0.68.7

create.project: nvmrc
	$(ENV.VARS) && $(NVM.VARS) && yes | npx react-native@0.68.7 init $(APP.NAME) && cd $(PROJECT.DIR) && npm install react-native-cli

detox.debug: detox.build.debug.android detox.run.debug.android
detox.release: detox.build.release.android detox.run.release.android
detox.recorder.release: detox.build.release.android detox.recorder.release.android

detox.build.debug.android: .FORCE
	$(ENV.VARS) && $(NVM.VARS) && detox build --configuration android.debug

detox.run.debug.android: .FORCE
	$(ENV.VARS) && $(NVM.VARS) && detox test --configuration android.debug

detox.build.release.android: .FORCE
	$(ENV.VARS) && $(NVM.VARS) && detox build --configuration android.release 

detox.run.release.android: .FORCE #log levels info, verbose, trace
	$(ENV.VARS) && $(NVM.VARS) && detox test --loglevel verbose --configuration android.release

nvm.install: nvmrc
	. ${HOME}/.nvm/nvm.sh --no-use && nvm install $(NODE.VERSION)
	$(NVM.VARS) && nvm use --delete-prefix $(NODE.VERSION) --silent
ifeq ($(OS), Darwin)
	$(info $(NODE.VERSION))
	$(NVM.VARS) && nvm alias default $(NODE.VERSION)
endif # Darwin

nvm.use: .FORCE
	$(NVM.VARS) && node -v

nvm: nvm.install nvm.use

nvmrc: .FORCE 
	$(info $(NODE.VERSION))
	echo $(NODE.VERSION) > $(BASE.DIR)/.nvmrc

sign.android.upload.key: .FORCE
	zip -d $(DIST.DIR)/$(ANDROID.BUNDLE.RELEASE)  META-INF/\*
ifndef ACME_ANDROID_KEYSTORE_PASSWORD
	jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore $(ANDROID.UPLOAD.KEY.KEYSTORE) $(DIST.DIR)/$(ANDROID.BUNDLE.RELEASE) $(ANDROID.UPLOAD.KEY.ALIAS) # password for keystore is here $(1PASSWORD.SECRETS.URL) 
else #ACME_ANDROID_KEYSTORE_PASSWORD
	jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore $(ANDROID.UPLOAD.KEY.KEYSTORE) $(DIST.DIR)/$(ANDROID.BUNDLE.RELEASE) $(ANDROID.UPLOAD.KEY.ALIAS) -storepass $(ACME_ANDROID_KEYSTORE_PASSWORD) # password for keystore is here $(1PASSWORD.SECRETS.URL) 
endif


install.node: .FORCE
	$(info $(ENV.VARS))
	$(ENV.VARS) && $(NVM.VARS) && $(MAKE) nvm.use && cd $(PROJECT.DIR) && npm install react-native-cli npm install
ifeq ($(OS), Darwin)
	$(ENV.VARS) && $(NVM.VARS) && $(MAKE) nvm.use && cd $(PROJECT.DIR) && npm install ios-deploy
#	gsed -i  "/$ios-deploy/d" package.json #remove ios-deploy from package.json
endif

env: .FORCE
	echo $(ENV.VARS)

update.build.number: .FORCE
ifdef CIRCLE_BUILD_NUM # enter the CRICLECI build number for the build counter
	$(SED) -i "s/$(BUILD.NUMBER.MAGIC.NUMBER)/$(CIRCLE_BUILD_NUM)/g" $(ANDROID.DIR)/app/build.gradle
	$(SED) -i "s/$(BUILD.NUMBER.MAGIC.NUMBER)/$(CIRCLE_BUILD_NUM)/g" $(IOS.DIR)/$(APP.NAME).xcodeproj/project.pbxproj
endif

package.android: .FORCE
	cd $(DIST.DIR) && md5sum $(APK.DEBUG) > $(APK.DEBUG).md5
	cd $(DIST.DIR) && md5sum $(APK.RELEASE) > $(APK.RELEASE).md5 && tar czvf $(ANDROID.ARCHIVE) $(APK.RELEASE) $(APK.RELEASE).md5 && md5sum $(ANDROID.ARCHIVE) > $(ANDROID.ARCHIVE).md5
	cd $(DIST.DIR) && md5sum $(ANDROID.BUNDLE.DEBUG) > $(ANDROID.BUNDLE.DEBUG).md5
	cd $(DIST.DIR) && md5sum $(ANDROID.BUNDLE.RELEASE) > $(ANDROID.BUNDLE.RELEASE).md5
	cd $(DIST.DIR) && tar czvf $(ANDROID.ARCHIVE) $(APK.DEBUG) $(APK.DEBUG).md5 $(APK.RELEASE) $(APK.RELEASE).md5 $(ANDROID.BUNDLE.DEBUG) $(ANDROID.BUNDLE.DEBUG).md5 $(ANDROID.BUNDLE.RELEASE) $(ANDROID.BUNDLE.RELEASE).md5 && md5sum $(ANDROID.ARCHIVE) > $(ANDROID.ARCHIVE).md5

package.ios: dist.directory
	cd $(DIST.DIR) && tar czvf $(IOS.ARCHIVE) $(IOS.XCARCHIVE) && md5sum $(IOS.ARCHIVE) > $(IOS.ARCHIVE).md5

upload.android: .FORCE
	PATH=$(HOME)/.local/bin:$(PATH) $(AWS.BIN) s3 cp $(DIST.DIR)/$(ANDROID.ARCHIVE) s3://acme-linux-artifacts --acl public-read --no-progress
	PATH=$(HOME)/.local/bin:$(PATH) $(AWS.BIN) s3 cp $(DIST.DIR)/$(ANDROID.ARCHIVE).md5 s3://acme-linux-artifacts --acl public-read --no-progress
	@echo https://acme-linux-artifacts.s3.amazonaws.com/$(ANDROID.ARCHIVE)
	@echo https://acme-linux-artifacts.s3.amazonaws.com/$(ANDROID.ARCHIVE).md5

upload.ios: .FORCE
	PATH=$(HOME)/.local/bin:$(PATH) $(AWS.BIN) s3 cp $(DIST.DIR)/$(IOS.ARCHIVE) s3://acme-linux-artifacts --acl public-read --no-progress
	PATH=$(HOME)/.local/bin:$(PATH) $(AWS.BIN) s3 cp $(DIST.DIR)/$(IOS.ARCHIVE).md5 s3://acme-linux-artifacts --acl public-read --no-progress
	@echo https://acme-linux-artifacts.s3.amazonaws.com/$(IOS.ARCHIVE)
	@echo https://acme-linux-artifacts.s3.amazonaws.com/$(IOS.ARCHIVE).md5

decrypt.secrets: .FORCE
ifndef ACME_ANDROID_SECRETS
	@echo "decrypting build secrets, enter password found here: $(1PASSWORD.SECRETS.URL)"
#	$(DECRYPT.SCRIPT)
else #ACME_ANDROID_SECRETS
#	export MOBILE_KEY=$(ACME_ANDROID_SECRETS) && $(DECRYPT.SCRIPT)
endif #ACME_ANDROID_SECRETS

decrypt.signing: .FORCE
ifndef ACME_ANDROID_SIGNING
	@echo "decrypting signing secrets, enter password found here: $(1PASSWORD.SECRETS.URL)"
	$(DECRYPT.SIGNING.SCRIPT)
else #ACME_ANDROID_SIGNING
	export SIGNING_KEY=$(ACME_ANDROID_SIGNING) && $(DECRYPT.SIGNING.SCRIPT)
endif #ACME_ANDROID_SIGNING

encrypt.secrets: .FORCE
	$(ENCRYPT.SCRIPT)

encrypt.signing: .FORCE
	$(ENCRYPT.SIGNING.SCRIPT)

run: .FORCE
	$(ENV.VARS) && $(MAKE) nvm.use && npm start && react-native start && react-native run-android

react.native.run: .FORCE
	$(ENV.VARS) && $(MAKE) nvm.use && npm run android

z: .FORCE
	$(ENV.VARS) && $(MAKE) nvm.use && npm start

adb.connect: .FORCE
ifndef MOBILE_IP
	$(error ********** Please set MOBILE_IP environment variable and run again ************)
endif #MOBILE_IP
ifndef MOBILE_PORT
	$(error ********** Please set MOBILE_PORT environment variable and run again ************)
endif #MOBILE_PORT
	$(ENV.VARS) && adb connect $(MOBILE_IP):$(MOBILE_PORT)

adb.pair: adb.kill.server
ifndef MOBILE_IP
	$(error ********** Please set MOBILE_IP environment variable and run again ************)
endif #MOBILE_IP
ifndef MOBILE_PORT
	$(error ********** Please set MOBILE_PORT environment variable and run again ************)
endif #MOBILE_PORT
	$(ENV.VARS) && adb pair $(MOBILE_IP):$(MOBILE_PORT)

adb.debug: .FORCE
	$(ENV.VARS) && adb reverse tcp:8081 tcp:8081

adb.reactdevmenu: .FORCE
	$(ENV.VARS) && adb shell input keyevent 82

adb.which: .FORCE # quick test to make sure the paths are set properly
	$(ENV.VARS) && which adb

adb.uninstall: .FORCE
	$(ENV.VARS) && adb uninstall $(PACKAGE.NAME)

adb.install: .FORCE #adb.uninstall
	$(ENV.VARS) && adb install -r -d $(APK.DEBUG.ORIG)

adb.kill.app: .FORCE
	$(ENV.VARS) && adb shell am kill $(PACKAGE.NAME)

adb.kill.server: .FORCE
	$(ENV.VARS) && adb kill-server

logs.android: .FORCE
	$(ENV.VARS) && adb shell logcat | grep $(PACKAGE.NAME)

adb.devices: .FORCE
	$(ENV.VARS) && adb devices

logs.android.react-native: .FORCE
	adb reverse tcp:8081 tcp:8081 # forward android device port over USB so that react-native debug tools can access the logs
	$(ENV.VARS) && $(MAKE) nvm.use && react-native log-android
	adb reverse --remove-all

logs.ios.react-native: .FORCE
	$(ENV.VARS) && $(MAKE) nvm.use && react-native log-ios

logs.ios.springboard: .FORCE # filter only the springboard launcher/home screen process
	idevicesyslog --process SpringBoard

react.run: .FORCE
	$(ENV.VARS) && react-native run-ios --verbose

logs.ios.acme: .FORCE # filter only the acme app
	idevicesyslog --process "$(APP.NAME)"

logs.ios: .FORCE
	idevicesyslog

adb.run: .FORCE
	$(ENV.VARS) && adb shell am start  -a android.intent.action.MAIN -n  $(PACKAGE.NAME)/.MainActivity

adb.screenshot: .FORCE # copies screenshot to clipboard
	mkdir -p $(SCREENSHOTS.DIR)
	adb exec-out screencap -p > $(SCREENSHOTS.DIR)/$(DATETIME).png

adb.build.and.run: adb.kill.app build.apk.debug adb.install adb.run

android.sdk: android.sdk.download android.sdk.licenses android.sdk.platform 

android.sdk.download: .FORCE
	mkdir -p $(DOWNLOADS.DIR)
	rm -f $(DOWNLOADS.DIR)/$(ANDROID.SDK.ARCHIVE)
	cd $(DOWNLOADS.DIR) && wget $(ANDROID.SDK.URL)
	cd $(DOWNLOADS.DIR) && unzip $(ANDROID.SDK.ARCHIVE)
	cd $(ANDROID.SDK.DIR)

avdmanager.create.android.28: .FORCE
	mkdir -p $(AVD.DIR)
	$(ENV.VARS) && cd $(ANDROID.SDK.DIR) && $(AVDMANAGER.BIN) --verbose create avd --name "pixel_4a" --tag 27 --package "system-images;android-28;google_apis_playstore;x86_64" #--path $(AVD.DIR) --force

emulator.create.android.28: .FORCE
	mkdir -p $(AVD.DIR)
	$(ENV.VARS) && cd $(ANDROID.SDK.DIR) &&  $(ANDROID.BIN) update sdk -u --filter platform-tools,android-28
	$(ENV.VARS) && $(SDKMANAGER.BIN) --use-sdk-wrapper --verbose "system-images;android-28;default;x86_64" 

emulator.android.28: .FORCE
	$(ENV.VARS) && $(EMULATOR.BIN) -avd test28

emulator.default: .FORCE
	$(ENV.VARS) && $(EMULATOR.BIN) -avd Pixel_3a_API_34_extension_level_7_x86_64 -netdelay none -netspeed full

emulator.list: .FORCE
	$(ENV.VARS) && $(EMULATOR.BIN) -list-avds

avdmanager.help: .FORCE
	$(ENV.VARS) && $(AVDMANAGER.BIN) --help

avdmanager.help.create: .FORCE
	$(ENV.VARS) && $(AVDMANAGER.BIN) --help create

avdmanager.list.avd: .FORCE
	$(ENV.VARS) && $(AVDMANAGER.BIN) list avd

avdmanager.list.target: .FORCE
	$(ENV.VARS) && $(AVDMANAGER.BIN) list target

avdmanager.list.device: .FORCE
	$(ENV.VARS) && $(AVDMANAGER.BIN) list device

sdkmanager.list: .FORCE
	$(ENV.VARS) && $(SDKMANAGER.BIN) --list --sdk_root=$(ANDROID.SDK.DIR)

sdkmanager.install.28.x86_64: .FORCE
	$(ENV.VARS) && $(SDKMANAGER.BIN) "platforms;android-28" "system-images;android-28;google_apis_playstore;x86_64" "platform-tools" --sdk_root=$(ANDROID.SDK.DIR)/platforms

sdkmanager.install.31.x86_64: .FORCE
	$(ENV.VARS) && $(SDKMANAGER.BIN) "platforms;android-31" "system-images;android-31;google_apis_playstore;x86_64" "platform-tools" --sdk_root=$(ANDROID.SDK.DIR)/platforms

sdkmanager.install.30.x86_64: .FORCE
	$(ENV.VARS) && $(SDKMANAGER.BIN) --install "system-images;android-30;default;x86_64" --sdk_root=$(ANDROID.SDK.DIR)/platforms

android.sdk.licenses: .FORCE
	$(ENV.VARS) && cd $(ANDROID.SDK.DIR) && yes | $(SDKMANAGER.BIN) --licenses --sdk_root=$(ANDROID.SDK.DIR)/platforms

android.sdk.platform: .FORCE
	$(ENV.VARS) && cd $(ANDROID.SDK.DIR) && yes | $(SDKMANAGER.BIN) --install "platform-tools" "platforms;android-30" --sdk_root=$(ANDROID.SDK.DIR)/platforms

build.android.react.bundle: install.node
	mkdir -p $(PROJECT.DIR)/android/app/src/main/assets
	$(ENV.VARS) && $(MAKE) nvm.use && cd $(PROJECT.DIR) && react-native bundle --verbose --platform android --dev false --entry-file $(PROJECT.DIR)/index.js --bundle-output $(PROJECT.DIR)/android/app/src/main/assets/index.android.bundle --assets-dest $(PROJECT.DIR)/android/app/src/main/res

dist.directory: .FORCE
	mkdir -p $(DIST.DIR)

build.android.bundle.debug: dist.directory build.android.react.bundle
	$(ENV.VARS) && $(NVM.VARS) && cd $(ANDROID.DIR) && ./gradlew bundleDebug
	$(MAKE) deploy.android.bundle.debug

build.android.bundle.release: dist.directory build.android.react.bundle
	$(ENV.VARS) && $(NVM.VARS) && cd $(ANDROID.DIR) && ./gradlew bundleRelease
	$(MAKE) deploy.android.bundle.release

deploy.android.bundle.debug: dist.directory
	cd $(DIST.DIR) && cp $(ANDROID.BUNDLE.DEBUG.ORIG) $(DIST.DIR)/$(ANDROID.BUNDLE.DEBUG)

deploy.android.bundle.release: dist.directory
	cd $(DIST.DIR) && cp $(ANDROID.BUNDLE.RELEASE.ORIG) $(DIST.DIR)/$(ANDROID.BUNDLE.RELEASE)

deploy.apk.release: dist.directory
	cd $(DIST.DIR) && cp $(APK.RELEASE.ORIG) $(DIST.DIR)/$(APK.RELEASE)

deploy.apk.debug: dist.directory
	cd $(DIST.DIR) && cp $(APK.DEBUG.ORIG) $(DIST.DIR)/$(APK.DEBUG)

android.remove.duplicate.assets: .FORCE
	rm -f $(ANDROID.DIR)/app/build/generated/res/createBundleReleaseJsAndAssets/drawable-mdpi/node_modules_reactnative_libraries_newappscreen_components_logo.png
	rm -f $(ANDROID.DIR)/app/src/main/res/drawable-mdpi/node_modules_reactnative_libraries_newappscreen_components_logo.png

build.apk.release:  build.android.react.bundle android.remove.duplicate.assets
	$(ENV.VARS) && $(NVM.VARS) && cd $(ANDROID.DIR) && ./gradlew assembleRelease
	$(MAKE) deploy.apk.release

build.apk.debug: build.android.react.bundle
	$(ENV.VARS) && $(NVM.VARS) && cd $(ANDROID.DIR) && ./gradlew assembleDebug
	$(MAKE) deploy.apk.debug

build.apk.test.debug: build.android.react.bundle
	$(ENV.VARS) && cd $(ANDROID.DIR) && ./gradlew assembleDebug assembleAndroidTest  -DtestBuildType=debug

build.apk.test.release: build.android.react.bundle
	$(ENV.VARS) && cd $(ANDROID.DIR) && ./gradlew assembleRelease assembleAndroidTest -DtestBuildType=release

build.android.debug.and.run: build.android.react.bundle # build and run using gradle's installDebug target
	$(ENV.VARS) && cd $(ANDROID.DIR) && ./gradlew installDebug --stacktrace --debug --info
	$(MAKE) deploy.apk.debug # update the dist directory for house keeping purposes
	$(MAKE) adb.kill.app adb.run

build.android.release.and.run: build.android.react.bundle # build and run using gradle's installRelease target
	$(ENV.VARS) &&  cd $(ANDROID.DIR) && ./gradlew installRelease
	$(MAKE) deploy.apk.release # update the dist directory for house keeping purposes
	$(MAKE) adb.kill.app adb.run

build.ios.react.bundle: install.node
	$(ENV.VARS) &&  $(NVM.VARS) && cd $(PROJECT.DIR) && react-native --help #bundle --verbose --platform ios --dev false --entry-file index.js --bundle-output $(IOS.DIR)/main.jsbundle --assets-dest $(IOS.DIR)

install.pods: .FORCE
	$(ENV.VARS) && $(NVM.VARS) && cd $(IOS.DIR) && pod repo update && pod update && pod install --verbose --repo-update

ios.show.build.targets: .FORCE
	cd $(IOS.DIR) && $(XCODEBUILD.BIN) -list -workspace $(IOS.WORKSPACE)
	cd $(IOS.DIR) && $(XCODEBUILD.BIN) -list -project $(IOS.PROJECT)
	cd $(IOS.DIR) && $(XCODEBUILD.BIN) -list -project $(IOS.DIR)/Pods/Pods.xcodeproj

clean.ios: .FORCE
	rm -rf $(IOS.DIR)/build
	rm -rf $(IOS.DIR)/Pods
#	cd $(IOS.DIR) && $(XCODEBUILD.BIN) clean

build.ios.debug.and.run: build.ios.debug ios.install.device

build.ios.release.and.run: build.ios.release ios.install.device

build.ios.debug: build.ios.react.bundle
	$(info $(NODE.PREFIX))
	$(info $(NODE.BINARY.MACOS) )
ifdef MACOS_KEYCHAIN_PASSWORD
#	security unlock-keychain -p $(MACOS_KEYCHAIN_PASSWORD)
else
	@echo "************note that this prompt can be avoided by exporting MACOS_KEYCHAIN_PASSWORD environment variable in your ~/.zshrc"
#	security unlock-keychain
endif
	$(ENV.VARS) && $(NVM.VARS) && fastlane run setup_circle_ci && cd $(IOS.DIR) && $(XCODEBUILD.BIN)  -workspace $(IOS.WORKSPACE) -configuration Debug archive -sdk iphoneos -scheme $(APP.NAME) -archivePath $(IOS.XCARCHIVE)

build.ios.release: build.ios.react.bundle
	$(info $(NODE.PREFIX))
	$(info $(NODE.BINARY.MACOS) )
ifdef MACOS_KEYCHAIN_PASSWORD
	security unlock-keychain -p $(MACOS_KEYCHAIN_PASSWORD)
else
	@echo "************note that this prompt can be avoided by exporting MACOS_KEYCHAIN_PASSWORD environment variable in your ~/.zshrc"
	security unlock-keychain
endif
	$(ENV.VARS) && $(NVM.VARS) && fastlane run setup_circle_ci && cd $(IOS.DIR) && $(XCODEBUILD.BIN)  -workspace $(IOS.WORKSPACE) -configuration Release archive -sdk iphoneos -scheme $(APP.NAME) -archivePath $(IOS.XCARCHIVE)


xcode.install.simulator: .FORCE
	xcodebuild -downloadPlatform iOS
	xcrun simctl create myiphone14promax com.apple.CoreSimulator.SimDeviceType.iPhone-14-Pro-Max com.apple.CoreSimulator.SimRuntime.iOS-16-4 

xcode.list.simulators: .FORCE
	xcrun simctl list

xcode.simulator.boot: .FORCE
	xcrun simctl boot $(SIMULATOR_UID)

xcode.simulator.shutdown: .FORCE
	xcrun simctl erase $(SIMULATOR_UID)

xcode.simulator.erase: .FORCE
	xcrun simctl erase $(SIMULATOR_UID)

xcode.list.connected.devices: .FORCE
	xcrun xctrace list devices

ios.run.simulator: .FORCE
	xcrun simctl install booted $(BASE.DIR)/ios/output/$(APP.NAME).xcarchive/Products/Applications/$(APP.NAME).app
#	xcrun simctl launch booted app.id

keys: .FORCE
	$(ENV.VARS) && yarn cp:list:android

ctags: .FORCE
	cd $(BASE.DIR) && ctags -R --exclude=.git --exclude=downloads --exclude=installed.host --exclude=installed.target --exclude=documents  --exclude=node_modules --exclude=build  .

npmrc: .FORCE
	echo "npm.pkg.github.com/:_authToken=$(GITHUB_PACKAGES_TOKEN)" > ~/.npmrc
	echo "@acmeco:registry=https://npm.pkg.github.com/" >> ~/.npmrc

ios.check.signature: .FORCE
	codesign -dv "$(IOS.APP.PATH)"

ios.sign.development: ios.authenticate.keystore ios.trust.developer.signing.key
	codesign --force --deep -s $(IOS.CERTIFICATE.DEVELOPMENT) "$(IOS.APP.PATH)"

ios.sign.distribution: ios.authenticate.keystore ios.trust.developer.signing.key
	codesign --force --deep -s $(IOS.CERTIFICATE.DISTRIBUTION) "$(IOS.APP.PATH)"

#ios.sign.adhoc:.FORCE 
#	codesign --force --deep -s - $(IOS.XCARCHIVE)
#	codesign --force --deep -s - "$(BASE.DIR)/ios/output/$(APP.NAME).xcarchive/Products/Applications/$(APP.NAME).app"

ios.authenticate.keystore: .FORCE
	sudo security authorizationdb write com.apple.trust-settings.admin allow

ios.trust.developer.signing.key: .FORCE
	security add-trusted-cert -d -r trustRoot -k acme ios/development.cer

ios.available.certificates: .FORCE
#	security find-certificate
	security find-identity -p codesigning -v

ios.fastlane: .FORCE
	fastlane cert --username $(CONTACT.EMAIL)
	fastlane sigh --username $(CONTACT.EMAIL)

ios.fastlane.nuke: .FORCE #nuke your ios certificates
	cd $(IOS.DIR) && export FASTLANE_USER="$(CONTACT.EMAIL)" && export MATCH_GIT_BRANCH="apple-keys" && export MATCH_GIT_URL="git@github.com:$(GIT.ORG)/$(GIT.REPO).git" && fastlane run match_nuke

ios.install.device: .FORCE
	$(ENV.VARS) && $(NVM.VARS) && ios-deploy --verbose --uninstall --bundle "$(IOS.APP.PATH)"

ios.devices: .FORCE
	$(ENV.VARS) && $(NVM.VARS) && ios-deploy --detect

ios.create.development.provisioning.profile.generate.certificates: .FORCE # note that before you do this you want to delete the keys in git repo $(GIT.ORG)/$(GIT.REPO) and delete the development certificate from the apple app dashboard under account "youraccount@acme.com"
	cd $(IOS.DIR) && export FASTLANE_USER="$(CONTACT.EMAIL)" && export MATCH_GIT_BRANCH="apple-keys" && export MATCH_GIT_URL="git@github.com:$(GIT.ORG)/$(GIT.REPO).git" && fastlane match development --app_identifier "$(APP.ID)" --username "$(CONTACT.EMAIL)"

ios.create.appstore.provisioning.profile.generate.certificates: .FORCE # note that before you do this you want to delete the keys in git repo $(GIT.ORG)/$(GIT.REPO) and delete the development certificate from the apple app dashboard under account "$(CONTACT.EMAIL)"
	@echo "encrypting ios secrets with this key , enter password found here: $(1PASSWORD.SECRETS.URL)"
	cd $(IOS.DIR) && export FASTLANE_USER="$(CONTACT.EMAIL)" && export MATCH_GIT_BRANCH="apple-keys" && export MATCH_GIT_URL="git@github.com:$(GIT.ORG)/$(GIT.REPO).git" && fastlane match appstore --app_identifier "$(APP.ID)" --username "$(CONTACT.EMAIL)"

ios.get.certificates.development: .FORCE
	@echo "decrypting ios secrets, enter password found here: $(1PASSWORD.SECRETS.URL)"
#	cd $(IOS.DIR) && fastlane run setup_circle_ci && export FASTLANE_USER="$(CONTACT.EMAIL)" && export MATCH_GIT_BRANCH="apple-keys" && export MATCH_GIT_URL="git@github.com:$(GIT.ORG)/$(GIT.REPO).git" && fastlane match development --readonly --app_identifier "$(APP.ID)" --username "$(CONTACT.EMAIL)"

ios.get.certificates.appstore: .FORCE
	@echo "decrypting ios secrets, enter password found here: $(1PASSWORD.SECRETS.URL)"
	cd $(IOS.DIR) && export FASTLANE_USER="$(CONTACT.EMAIL)" export MATCH_GIT_BRANCH="apple-keys" && && export MATCH_GIT_URL="git@github.com:$(GIT.ORG)/$(GIT.REPO).git" && fastlane match appstore --readonly --app_identifier "$(APP.ID)" --username "$(CONTACT.EMAIL)"

ios.automatic.code.signing.disable: .FORCE
	fastlane run automatic_code_signing path:"$(IOS.DIR)/$(APP.NAME).xcodeproj" use_automatic_signing:"false"

ios.provisioning.profile.install: .FORCE
	fastlane run install_provisioning_profile path:"$(BASE.DIR)/AppStore_$(APP.ID).mobileprovision"

xcode.launch: .FORCE
	open $(BASE.DIR)/ios/$(APP.NAME).xcodeproj

clean.node.modules: .FORCE
	rm -rf $(NODE.MODULES.DIR)

clean: clean.node.modules clean.ios
#	cd android && ./gradlew clean
	rm -rf $(DOWNLOADS.DIR)
	rm -rf $(INSTALLED.HOST.DIR)
	rm -rf $(NODE.BUILD.DIR)
	rm -f $(BASE.DIR)/yarn.lock
	rm -f $(BASE.DIR)/package-lock.json
	rm -rf $(BASE.DIR)/android/.gradle
	rm -f $(LOCAL.PROPERTIES)
	rm -f $(BASE.DIR)/android/app/src/main/assets/index.android.bundle
	rm -rf $(BASE.DIR)/android/app/build
	rm -rf $(DIST.DIR)
	rm -f $(BASE.DIR)/android/app/src/main/assets/index.android.bundle
	rm -rf $(IOS.OUTPUT)
	rm -rf $(PROJECT.DIR)
	rm -f $(BASE.DIR)/yarn-error.log

.FORCE:

