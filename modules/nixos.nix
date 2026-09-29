{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.nightscout-tui;
in
{
  options.services.nightscout-tui = {
    enable = mkEnableOption "Nightscout TUI system-level monitor service";

    package = mkOption {
      type = types.package;
      default = pkgs.nightscout-tui or (pkgs.runCommand "nightscout-tui" {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      } ''
        mkdir -p $out/bin
        cp ${../bin/nightscout-tui} $out/bin/nightscout-tui
        chmod +x $out/bin/nightscout-tui
        wrapProgram $out/bin/nightscout-tui \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.python3 ]}
      '');
      description = "The nightscout-tui package to install.";
    };

    url = mkOption {
      type = types.str;
      default = "https://nightscout.deepwatercreature.com";
      description = "Nightscout instance URL.";
    };

    token = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Nightscout API authentication token (plaintext). Use tokenFile for secret safety.";
    };

    tokenFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Path to file containing Nightscout API token.";
    };

    units = mkOption {
      type = types.enum [ "mg/dl" "mmol/l" ];
      default = "mg/dl";
      description = "Display units (mg/dl or mmol/l).";
    };

    targetLow = mkOption {
      type = types.int;
      default = 70;
      description = "Target lower glucose threshold.";
    };

    targetHigh = mkOption {
      type = types.int;
      default = 180;
      description = "Target upper glucose threshold.";
    };

    refreshInterval = mkOption {
      type = types.int;
      default = 60;
      description = "Refresh interval in seconds.";
    };

    count = mkOption {
      type = types.int;
      default = 48;
      description = "Number of historical entries to fetch (48 = ~4 hours).";
    };

    tty = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "TTY device to output to (e.g., /dev/tty1).";
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = "User to run the service as.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.services.nightscout-tui = {
      description = "Nightscout TUI Terminal Monitor";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        ExecStart = ''
          ${cfg.package}/bin/nightscout-tui \
            --url ${escapeShellArg cfg.url} \
            --units ${cfg.units} \
            --low ${toString cfg.targetLow} \
            --high ${toString cfg.targetHigh} \
            --count ${toString cfg.count} \
            --refresh ${toString cfg.refreshInterval} \
            ${optionalString (cfg.token != null) "--token ${escapeShellArg cfg.token}"} \
            ${optionalString (cfg.tokenFile != null) "--token-file ${escapeShellArg cfg.tokenFile}"}
        '';
        Restart = "always";
        RestartSec = 10;
      } // optionalAttrs (cfg.tty != null) {
        StandardInput = "tty";
        StandardOutput = "tty";
        TTYPath = cfg.tty;
        TTYReset = true;
        TTYVHangup = true;
      };
    };
  };
}
