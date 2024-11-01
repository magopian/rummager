
DATE:=$(shell date "+%Y-%m-%d %H:%M")

update_version:
	sed -i '' 's/config\/version=".*"/config\/version="$(DATE)"/' project.godot

git_bump_version:
	git add project.godot && git commit -m "Bump version number"

export_from_godot:
	/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "Rummager" ../exports/index.html
	/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "Android" ../export_android/rummager.aab
	/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "Android APK" ../export_android/rummager.apk
	/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "iOS" ../export_ios/rummager.ipa

export: update_version git_bump_version export_from_godot
	cd ../exports && rm -rf Archive.zip && zip Archive *

upload_to_itch: export
	../../butler-darwin-amd64/butler push ../exports/Archive.zip magopian/rummager:html
	../../butler-darwin-amd64/butler push ../export_android/rummager.apk magopian/rummager:android

itch_status:
	../../butler-darwin-amd64/butler status magopian/rummager:html

export_to_itch: export upload_to_itch
	@echo "Version uploaded to itch:" $(DATE)
