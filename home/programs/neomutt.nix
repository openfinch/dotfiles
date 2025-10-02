{ config, pkgs, lib, ... }:
{
  programs.mutt = {
    enable = true;
    package = pkgs.neomutt; # use neomutt variant

    # Basic maildir layout assumptions; adjust paths to your setup.
    settings = {
      folder = "~/Mail";
      spoolfile = "~/Mail/INBOX";
      record = "+Sent";
      postponed = "+Drafts";
      mbox_type = "Maildir";
      timeout = 15; # seconds for new mail check
      sort = "threads";
      sort_aux = "last-date-received";
      editor = "${pkgs.neovim}/bin/nvim"; # change if you prefer another
      ssl_starttls = "yes";
      ssl_force_tls = "yes";
    };

    sidebar = {
      enable = true;
      width = 28;
      visible = true;
      shortPath = false;
    };

    extraConfig = ''
      color status brightwhite blue
      color sidebar_new yellow default
      bind index,pager <C-p> sidebar-prev
      bind index,pager <C-n> sidebar-next
      bind index,pager <C-o> sidebar-open
      macro index gi "<change-folder>=INBOX<enter>" "Go to INBOX"
      macro index gs "<change-folder>=Sent<enter>" "Go to Sent"
      macro index gd "<change-folder>=Drafts<enter>" "Go to Drafts"
    '';
  };

  home.persistence."/nix/persist/home/jf" = {
    allowOther = false;
    directories = [ 
      ".Mail/"
    ];
    files = [ ];
  };
}
