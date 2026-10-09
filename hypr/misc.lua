----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(

        -- Display sicher aufwecken (hypridle schaltet DPMS nach 10 Min aus)
        mouse_move_enables_dpms = true,
        key_press_enables_dpms  = true,

        -- FreeSync nur im Vollbild (Spiele), Desktop unverändert
        vrr = 2,

        -- Neues Fenster während Vollbild: Vollbild wird aufgelöst statt zu verstecken
        on_focus_under_fullscreen = 2,
    },
})
