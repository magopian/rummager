
DATE:=$(shell date "+%Y%m%d%H%M")
SHORT_DATE:=$(shell date "+%Y%m%d")

update_version:
	sed -i '' 's/config\/version=".*"/config\/version="$(DATE)"/' project.godot
	sed -i '' 's/version\/code=.*/version\/code=$(SHORT_DATE)/' export_presets.cfg

git_bump_version:
	git add project.godot export_presets.cfg && git commit -m "Bump version number"

export_from_godot:
	/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "Rummager" ../exports/index.html
	/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "Android" ../export_android/rummager.aab
	/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "Android APK" ../export_android/rummager.apk
	rm -rf ../export_ios && mkdir ../export_ios
	/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "iOS" ../export_ios/rummager.ipa
	/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "macOS" ../export_macos/rummager.dmg

export: update_version git_bump_version export_from_godot
	cd ../exports && rm -rf Archive.zip && zip Archive *

upload: export
	../../butler-darwin-amd64/butler push ../exports/Archive.zip magopian/rummager:html
	../../butler-darwin-amd64/butler push ../export_android/rummager.apk magopian/rummager:android
	echo "*** Open https://appstoreconnect.apple.com/apps/6737626586/distribution/ios/version/inflight and add a new version"
	echo "*** Open https://play.google.com/console/u/0/developers/6835995711892807257/app-list, select Rummager, browse the left pannel to 'Production' > 'Créer une version'"

macos_specific:
	# https://alicegg.tech/2024/09/12/godot-mac
	# https://medium.com/the-bkpt/godot-tutorial-exporting-for-macos-e82a04856db7
	# Find list of valid certificates
	# security find-identity -v -p codesigning
	#
	# echo "Password is app specific password in https://account.apple.com/account/manage :  Makefile export macos app"
	## Check notarification requests
	# xcrun notarytool history --apple-id mathieu-icloud@agopian.info --team-id D4JA25UPZB
	#
	# xcrun altool --validate-app -f ../export_macos/rummager.dmg -t macOS -u mathieu-icloud@agopian.info
	# xcrun altool --upload-app -f file -t platform -u username [-p password] [—output-format xml]
	#
	# xcrun stapler staple ../export_macos/rummager.dmg

itch_status:
	../../butler-darwin-amd64/butler status magopian/rummager:html

export_to_itch: export upload_to_itch
	@echo "Version uploaded to itch:" $(DATE)
