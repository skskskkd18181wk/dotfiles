--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

hl.layer_rule({
    name  = "walker-blur",
    match = { namespace = "^walker$" },
    blur  = true,
})

hl.layer_rule({
    name  = "dunst-blur",
    match = { namespace = "^dunst$" },
    blur  = true,
})

hl.layer_rule({
    name  = "waybar-blur",
    match = { namespace = "^waybar$" },
    blur  = true,
})

-- Video-Picture-in-Picture: immer schwebend unten rechts
hl.window_rule({
    name  = "picture-in-picture",
    match = { title = "[Pp]icture.?[Ii]n.?[Pp]icture" },

    float  = true,
    pin    = true,
    size   = "480 270",
    move   = "monitor_w-500 monitor_h-320",
})

-- System-Dialoge mittig floaten
hl.window_rule({
    name  = "center-dialogs",
    match = { class = "pavucontrol|blueman-manager|nm-connection-editor|thunar" },

    float  = true,
    center = true,
})

-- Feste Workspaces
hl.window_rule({
    name  = "ws-browser",
    match = { class = "[Cc]hromium", title = "^(?!Cheat Sheet)" },
    workspace = "1",
})

hl.window_rule({
    name  = "ws-editor",
    match = { class = "[Cc]odium" },
    workspace = "2",
})

-- Cheat-Sheet: floatet oben rechts
hl.window_rule({
    name  = "cheatsheet",
    match = { title = "Cheat Sheet" },

    float  = true,
    size   = "1000 740",
    move   = "monitor_w-1030 56",
})

-- Wallpaper-Picker: schwebend, mittig
hl.window_rule({
    name  = "wallpaper-picker",
    match = { class = ".*wallpaper-pick.*" },

    float  = true,
    center = true,
    size   = "1400 820",
})

-- Cava-Visualizer: Quadrat schwebend unten links
hl.window_rule({
    name  = "cava-viz",
    match = { class = "com\\.mitchellh\\.ghostty", title = "cava-viz" },

    float  = true,
    size   = "500 500",
    move   = "20 monitor_h-520",
})

-- Waifu-Beat-Visualizer: schwebend rechts oben unter Waybar
hl.window_rule({
    name  = "waifu-viz",
    match = { class = "waifu-viz", title = "waifu-viz" },

    float  = true,
    size   = "320 320",
    move   = "monitor_w-440 60",
    no_focus = true,
})

-- Notch-Quick-Settings: LayerShell, bündig unter Waybar, slide top rein
hl.layer_rule({
    name  = "quick-panel-slide",
    match = { namespace = "^quick-panel$" },
})

-- Notification-Center: bündig unter der Waybar, rechts (Höhe = Inhalt)
hl.window_rule({
    name  = "notification-center",
    match = { class = ".*notification-center.*" },

    float = true,
    move  = "monitor_w-416 50",
})
