{ pkgs, lib, ... }:
let
  inherit (lib) versions getVersion;
in
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [ cnijfilter2 cups-dymo ];
  };

# TODO: I'll fix this later... printers are hard
#   hardware.printers = {
#     ensureDefaultPrinter = "Brother MFC-L3730CDN";
#     ensurePrinters = [
#       {
#         description = "Multi-Function Laser Printer";
#         deviceUri = "dnssd://EPSON%20EW-M754T%20Series._ipp._tcp.local/?uuid=cfe92100-67c4-11d4-a45f-381a526218ab";
#         model = "epson-inkjet-printer-escpr2/Epson-EW-M754T_Series-epson-escpr2-en.ppd";
#         name = "Brother MFC-L3730CDN";
#       }
#       {
#         description = "Production Printer";
#         deviceUri = "dnssd://EPSON%20EW-M754T%20Series._ipp._tcp.local/?uuid=cfe92100-67c4-11d4-a45f-381a526218ab";
#         model = "epson-inkjet-printer-escpr2/Epson-EW-M754T_Series-epson-escpr2-en.ppd";
#         name = "Canon Pixma Pro-200";
#       }
#       {
#         description = "Label Printer";
#         deviceUri = "dnssd://EPSON%20EW-M754T%20Series._ipp._tcp.local/?uuid=cfe92100-67c4-11d4-a45f-381a526218ab";
#         model = "epson-inkjet-printer-escpr2/Epson-EW-M754T_Series-epson-escpr2-en.ppd";
#         name = "DYMO LabelWriter 5XL";
#       }
#     ];
#   };
  programs.system-config-printer.enable = true;

  # Scanner support
  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };

  users.users.jf.extraGroups = [
    "scanner"
    "lp"
  ];
}
