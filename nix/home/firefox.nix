{ config, pkgs, lib, ... }:
{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;

    # Keep it simple; adjust as you like later
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        # Handy defaults
        settings = {
          "browser.startup.homepage" = "https://duckduckgo.com";
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "browser.shell.checkDefaultBrowser" = false;
          "browser.download.useDownloadDir" = true;
          "gfx.webrender.all" = true;
          "media.ffmpeg.vaapi.enabled" = true;
        };
        search = {
          default = "DuckDuckGo";
          engines = {
            "DuckDuckGo" = {
              urls = [{ template = "https://duckduckgo.com/?q={searchTerms}"; }];
              icon = pkgs.fetchurl {
                url = "https://duckduckgo.com/favicon.ico";
                sha256 = "sha256-Hc0gKI6q2OQkEsTQxk3Ny0uSZwz0Lr4Uqv0S7kGk2V4=";
              };
              definedAliases = [ "ddg" ];
            };
            "Nix Packages" = {
              urls = [{ template = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}"; }];
              definedAliases = [ "np" ];
            };
            "Nix Options" = {
              urls = [{ template = "https://search.nixos.org/options?channel=unstable&query={searchTerms}"; }];
              definedAliases = [ "no" ];
            };
            "Wikipedia" = {
              urls = [{ template = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}"; }];
              definedAliases = [ "w" ];
            };
          };
        };
        extensions = with pkgs.firefox-addons; [
          ublock-origin
          bitwarden
          multi-account-containers
          privacy-badger
          clearurls
        ];
      };
    };
  };
}
