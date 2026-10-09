-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function ()
  -- Launcher-Backend (Walker + Elephant)
  hl.exec_cmd("systemctl --user start elephant walker")

  -- Wallpaper
  hl.exec_cmd("awww-daemon & sleep 1 && awww img ~/.local/share/wallpapers/waifu-purple.png")

  -- Benachrichtigungen
  hl.exec_cmd("dunst")

  -- Statusleiste
  hl.exec_cmd("waybar")

  -- Tray & System-Icons
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

  -- Clipboard-Verlauf (Speicherung)
  hl.exec_cmd("wl-paste --watch cliphist store")

  -- Display-Aus (10 Min) & Bildschirm-Sperre (15 Min)
  hl.exec_cmd("hypridle")

  -- Performance-Profil (Gaming)
  hl.exec_cmd("powerprofilesctl set performance")

  -- GPU OC (330W + Clock-Lock ~1920 MHz sustained, gpu_burn-validiert)
  hl.exec_cmd("sleep 2 && ~/.local/bin/gpu-oc")

  -- RGB: Seducing Purple (warten bis SMBus/USB bereit)
  hl.exec_cmd("sleep 3 && ~/.local/bin/rgb-purple")
end)
