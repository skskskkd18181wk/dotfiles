---------------------
---- FARBPALETTE ----
---------------------

-- Zentrale Purple-Palette für alle Hyprland-Internen Farben.
-- (Walker, Dunst, Hyprlock und SDDM haben eigene Configs und
--  müssen bei einer Änderung dort ebenfalls angepasst werden.)

return {
    -- Hex ohne #
    accent      = "9a66ff",
    accent_soft = "efeaff",
    bg_deep     = "2e1a5c",
    bg_darker   = "1a122b",

    -- Fertige Hyprland-Strings
    accent_rgba   = "rgba(9a66ffff)",
    soft_rgba     = "rgba(efeaffff)",
    inactive_rgba = "rgba(2e1a5caa)",
    glow_rgba     = 0x9a66ff77,
}
