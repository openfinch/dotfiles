{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      terminal = {
        vt = "next"; # Use a VT other than tty1 to avoid boot/getty messages on the greeter
      };
      default_session = {
          # Clear VT, then run a minimal, tasteful tuigreet
          command = ''
            ${pkgs.bash}/bin/bash -lc "printf '\033c'; exec ${pkgs.greetd.tuigreet}/bin/tuigreet \
              --time \
              --greeting 'Welcome' \
              --asterisks \
              --remember \
              --cmd sway"
          '';
      };
    };
  };
}