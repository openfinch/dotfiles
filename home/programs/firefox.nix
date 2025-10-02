{ config, pkgs, lib, inputs, ... }:
let
  littlefoxSrc = pkgs.fetchFromGitHub {
    owner = "biglavis";
    repo = "LittleFox";
    rev = "main";
    sha256 = "sha256-qlLDR1GSWbB5WwSDv/Z8kdQ9ZVvazEmh3gjwYyXhqa4=";
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
          "newtaboverride@agenedia.com"
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

    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "browser.contentblocking.category" = "strict";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "privacy.donottrackheader.enabled" = true;
          "privacy.globalprivacycontrol.enabled" = true;
          "privacy.resistFingerprinting" = true;
          "privacy.resistFingerprinting.letterboxing" = false;
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
          "extensions.autoDisableScopes" = 0;
          "extensions.enabledScopes" = 15;
          "extensions.postDownloadThirdPartyPrompt" = false;
          "browser.safebrowsing.malware.enabled" = true;
          "browser.safebrowsing.phishing.enabled" = true;
          "browser.compactmode.show" = true;
          "browser.uidensity" = 1;
          "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
          "trailhead.firstrun.didSeeAboutWelcome" = true;
          "browser.startup.homepage_override.mstone" = "ignore";
          "trailhead.firstrun.branches" = "nofirstrun-empty";
          "browser.aboutwelcome.enabled" = false;
          "browser.startup.homepage" = "https://home.dip.sh/";
          "browser.startup.page" = 1;
        };
        search = {
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
          force = true;
          packages = with inputs.firefox-addons.packages.${pkgs.system}; [
            ublock-origin
            clearurls
            new-tab-override
          ];
          settings."uBlock0@raymondhill.net".settings = {
            selectedFilterLists = [
              "ublock-filters"
              "ublock-badware"
              "ublock-privacy"
              "ublock-unbreak"
              "ublock-quick-fixes"
            ];
          };
          settings."newtaboverride@agenedia.com".settings = {
            url = "https://home.dip.sh/";
          };
        };
      };
    };
  };

  home.activation.cleanFirefoxChrome = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    rm -rf "${config.home.homeDirectory}/.mozilla/firefox/default/chrome"
  '';
  home.activation.cleanFirefoxSearchJson = lib.hm.dag.entryBefore [ "linkGeneration" ] ''
    rm -f "${config.home.homeDirectory}/.mozilla/firefox/default"/search.json.mozlz4{,.backup}
  '';
  home.file = {
    ".mozilla/firefox/default/chrome".source = littlefoxSrc;
  };
}
