-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Cursor
hl.env("XCURSOR_SIZE", "28")
hl.env("HYPRCURSOR_SIZE", "28")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")

-- Qt auf Wayland, ohne doppelte Fensterleisten
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- GTK bevorzugt Wayland
hl.env("GDK_BACKEND", "wayland,x11")

-- NVIDIA Video-Beschleunigung (libva-nvidia-driver)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
