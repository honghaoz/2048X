bootstrap:
	git submodule update --init --recursive
	@./Scripts/install-git-hooks

# Install pods and open project.
pod:
	@pod install
	@open ./*.xcworkspace

# Generate Xcode project and open it.
xcode:
	@perl ./Scripts/sort-Xcode-project-file *.xcodeproj
	@open ./*.xcodeproj

# Run swiftformat.
format:
	@./Pods/SwiftFormat/CommandLineTool/swiftformat . --verbose

console:
	@open https://console.firebase.google.com/u/0/project/com-chouti-i-hate-tip/overview
