{ config, pkgs, lib, inputs, ... }:
let
  # Fetch Cascade theme sources; replace sha256 after first build with the value Nix suggests
  littlefoxSrc = pkgs.fetchFromGitHub {
    owner = "biglavis";
    repo = "LittleFox";
    rev = "main";
    sha256 = "sha256-qlLDR1GSWbB5WwSDv/Z8kdQ9ZVvazEmh3gjwYyXhqa4="; # replace after first build
  };
in {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    # Enterprise policies applied to all profiles
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DontCheckDefaultBrowser = true;
      PasswordManagerEnabled = false;
      EnableTrackingProtection = {
        Value = "strict";
        Cryptomining = true;
        Fingerprinting = true;
        Locked = true;
      };
      # Keep required extensions enabled
      Extensions = {
        Locked = [
          "uBlock0@raymondhill.net"
          "clearurls@kevinr"
        ];
      };
        # Set homepage/start page
        Homepage = {
          URL = "https://home.dip.sh/";
          StartPage = "homepage";
        };
      # Keep Safe Browsing on; omit DisableSafeBrowsing
      # Optionally enable DoH at policy level later if desired.
    };

    # Keep it simple; adjust as you like later
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        # Privacy-focused defaults; tune as needed
        settings = {
          "browser.contentblocking.category" = "strict";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.letterboxing" = true;
          "privacy.partition.serviceWorkers" = true;
          "privacy.partition.network_state" = true;
          "beacon.enabled" = false;
          "network.http.referer.XOriginPolicy" = 2;
          "network.http.referer.XOriginTrimmingPolicy" = 2;
          "signon.rememberSignons" = false; # built-in password storage off
          "dom.security.https_only_mode" = true;
          "dom.security.https_only_mode_pbm" = true;
          "media.autoplay.default" = 1; # block audible autoplay
          "media.autoplay.blocking_policy" = 2;
          # Ensure sideloaded (Nix-managed) extensions are enabled automatically
          # 0 = don't auto-disable; 15 enables all scopes
          "extensions.autoDisableScopes" = 0;
          "extensions.enabledScopes" = 15;
          # Avoid post-download prompts for third-party installs
          "extensions.postDownloadThirdPartyPrompt" = false;
          # Keep Safe Browsing protections
          "browser.safebrowsing.malware.enabled" = true;
          "browser.safebrowsing.phishing.enabled" = true;
          # Enable the compact mode
          "browser.compactmode.show" = true;
          "browser.uidensity" = 1;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "browser.startup.homepage_override.mstone" = "ignore";
          "trailhead.firstrun.branches" = "nofirstrun-empty";
          "browser.aboutwelcome.enabled" = false;
            # Start page / homepage
            "browser.startup.homepage" = "https://home.dip.sh/";
            "browser.startup.page" = 1; # 1 = show homepage on startup
        };
        search = {
          # Use engine IDs (ddg is DuckDuckGo)
          default = "ddgnoai";
          engines = {
            ddgnoai = {
              urls = [{ template = "https://duckduckgo.com/?q={searchTerms}&noai=1"; } { template = "https://noai.duckduckgo.com/?q={searchTerms}"; }];
              definedAliases = [ "ddg" ];
            };
            nixpkgs = {
              urls = [{ template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; }];
              definedAliases = [ "np" ];
            };
            nix-options = {
              urls = [{ template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}"; }];
              definedAliases = [ "no" ];
            };
          };
        };
        extensions = {
          packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            ublock-origin
            clearurls
          ];
        };
      };
    };
  };

  # Ensure old chrome dir doesn't block linking
  home.activation.cleanFirefoxChrome = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    rm -rf "${config.home.homeDirectory}/.mozilla/firefox/default/chrome"
  '';

  # Remove old search.json files that would be clobbered by HM
  home.activation.cleanFirefoxSearchJson = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    rm -f "${config.home.homeDirectory}/.mozilla/firefox/default"/search.json.mozlz4{,.backup}
  '';

  # Link LittleFox's chrome assets into the managed profile
  home.file = {
    ".mozilla/firefox/default/chrome".source = littlefoxSrc;
  };
}
