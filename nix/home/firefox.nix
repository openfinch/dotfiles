{ config, pkgs, lib, inputs, ... }:
let
  # Fetch Cascade theme sources; replace sha256 after first build with the value Nix suggests
  cascadeSrc = pkgs.fetchFromGitHub {
    owner = "cascadefox";
    repo = "cascade";
    rev = "main";
    sha256 = "sha256-adhwQpPb69wT5SZTmu7VxBbFpM4NNAuz4258k46T4K0=";
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
          # Keep Safe Browsing protections
          "browser.safebrowsing.malware.enabled" = true;
          "browser.safebrowsing.phishing.enabled" = true;
        };
        search = {
          # Use engine IDs (ddg is DuckDuckGo)
          default = "ddg";
          engines = {
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
  home.activation.cleanCascadeChrome = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    rm -rf "${config.home.homeDirectory}/.mozilla/firefox/default/chrome"
  '';

  # Remove old search.json files that would be clobbered by HM
  home.activation.cleanFirefoxSearchJson = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    rm -f "${config.home.homeDirectory}/.mozilla/firefox/default"/search.json.mozlz4{,.backup}
  '';

  # Link Cascade's chrome assets into the managed profile
  home.file = {
    ".mozilla/firefox/default/chrome".source = cascadeSrc + "/chrome";
  };
}
