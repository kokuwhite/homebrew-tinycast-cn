cask "tinycast-cn" do
  # `version` and `sha256` are bumped automatically by the tinycast-cn Release CN workflow.
  version "0.11.19-cn.2"
  sha256 "9c3519d508ac6a671f10ef268875e035e57d59ee74280e50bd58973b6c09ab21"

  url "https://github.com/kokuwhite/tinycast-cn/releases/download/v#{version}/Tinycast-CN-#{version}.dmg"
  name "Tinycast CN"
  desc "Tiny, fully native launcher (Simplified Chinese build)"
  homepage "https://github.com/kokuwhite/tinycast-cn"

  # Ships as Tinycast.app, so it owns the same path as every upstream non-beta cask.
  conflicts_with cask: [
    "abue-ammar/tinycast/tinycast",
    "abue-ammar/tinycast/tinycast-sequoia",
  ]
  depends_on macos: :tahoe

  app "Tinycast.app"

  # Preflight runs before the bundle is staged, so a copy already in appdir means an upgrade.
  # The marker is how postflight learns which one this is: the two step blocks share no state.
  preflight_steps do
    unless_path_exists "{{appdir}}/Tinycast.app" do
      touch ".fresh-install"
    end
  end

  # Self-signed, not notarized: strip quarantine on install and upgrade so Gatekeeper lets it
  # launch without a manual xattr. Auto-launch only on a fresh install; upgrades stay silent.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/Tinycast.app"]
    if_path_exists ".fresh-install" do
      # Launching is a courtesy, not part of the install: LaunchServices occasionally refuses a
      # bundle it has only just seen, and that must not fail the install.
      run "/usr/bin/open", args: ["-g", "{{appdir}}/Tinycast.app"], must_succeed: false
      remove ".fresh-install"
    end
  end

  # Quit the running copy before Homebrew replaces the bundle, or the upgrade clobbers a live
  # process. postflight relaunches it after an upgrade, never after an uninstall.
  uninstall quit: "com.kokuwhite.tinycast-cn"

  zap login_item: "Tinycast",
      trash:      [
        "~/Library/Application Support/com.kokuwhite.tinycast-cn",
        "~/Library/Caches/com.kokuwhite.tinycast-cn",
        "~/Library/Preferences/com.kokuwhite.tinycast-cn.plist",
        "~/Library/Saved Application State/com.kokuwhite.tinycast-cn.savedState",
      ]
end
