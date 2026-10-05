cask "tinycast-cn" do
  # `version` and `sha256` are bumped automatically by the tinycast-cn Release CN workflow.
  version "0.11.12-cn.1"
  sha256 "dca005be08ec7ec9e6d09b4519d0f5f663dec02de4f6a8acb33970aaadc9e8cd"

  url "https://github.com/kokuwhite/tinycast-cn/releases/download/v#{version}/Tinycast-CN-#{version}.dmg",
      verified: "github.com/kokuwhite/tinycast-cn/"
  name "Tinycast CN"
  desc "Tiny, fully native launcher, hotkeys, and clipboard history (Simplified Chinese build)"
  homepage "https://github.com/kokuwhite/tinycast-cn"

  # Ships as Tinycast.app, so it owns the same path as every upstream non-beta cask.
  conflicts_with cask: [
    "abue-ammar/tinycast/tinycast",
    "abue-ammar/tinycast/tinycast-sequoia",
  ]
  depends_on macos: :tahoe

  app "Tinycast.app"

  # preflight runs before the new bundle is staged, so an app already in appdir means upgrade.
  # The two DSL objects share no state, hence the marker file.
  preflight do
    FileUtils.touch("#{staged_path}/.upgrade") if File.exist?("#{appdir}/Tinycast.app")
  end

  # Self-signed, not notarized: strip quarantine on install and upgrade so Gatekeeper lets it
  # launch without a manual xattr. Auto-launch only on a fresh install; upgrades stay silent.
  postflight do
    upgrade = File.exist?("#{staged_path}/.upgrade")
    FileUtils.rm_f("#{staged_path}/.upgrade")

    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/Tinycast.app"]

    unless upgrade
      system_command "/usr/bin/open",
                     args: ["-g", "#{appdir}/Tinycast.app"]
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
