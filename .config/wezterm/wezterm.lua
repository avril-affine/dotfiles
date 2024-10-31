local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

config.leader = { key = "F13", timeout_milliseconds = 400 }
-- config.leader = { key = "`", timeout_milliseconds = 400 }

config.scrollback_lines = 50000
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

wezterm.on("update-right-status", function(window, pane)
    local name = window:active_key_table()
    if name then
        name = "TABLE: " .. name
    end
    window:set_right_status(name or "")
end)

local action_resize_pane = act.ActivateKeyTable({
    name = "resize_pane",
    timeout_milliseconds = 400,
    until_unknown = true,
})

config.keys = {
    {
        key = "[",
        mods = "LEADER",
        action = act.Multiple({
            act.ActivateKeyTable({ name = "copy_mode" }),
            act.ActivateCopyMode,
        }),
    },

    -- split pane
    {
        key = "|",
        mods = "LEADER",
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
        key = "-",
        mods = "LEADER",
        action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
    },

    -- move pane
    { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

    -- resize pane
    {
        key = "H",
        mods = "LEADER",
        action = act.Multiple({
            act.AdjustPaneSize({ "Left", 1 }),
            action_resize_pane,
        }),
    },
    {
        key = "J",
        mods = "LEADER",
        action = act.Multiple({
            act.AdjustPaneSize({ "Down", 1 }),
            action_resize_pane,
        }),
    },
    {
        key = "K",
        mods = "LEADER",
        action = act.Multiple({
            act.AdjustPaneSize({ "Up", 1 }),
            action_resize_pane,
        }),
    },
    {
        key = "L",
        mods = "LEADER",
        action = act.Multiple({
            act.AdjustPaneSize({ "Right", 1 }),
            action_resize_pane,
        }),
    },

    -- zoom pane
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
}

config.key_tables = {
    resize_pane = {
        { key = "Escape", mods = "NONE", action = act.PopKeyTable },
        {
            key = "H",
            mods = "NONE",
            action = act.Multiple({
                act.AdjustPaneSize({ "Left", 1 }),
                action_resize_pane, -- hack since AdjustPaneSize pops key table?
            }),
        },
        {
            key = "J",
            mods = "NONE",
            action = act.Multiple({
                act.AdjustPaneSize({ "Down", 1 }),
                action_resize_pane,
            }),
        },
        {
            key = "K",
            mods = "NONE",
            action = act.Multiple({
                act.AdjustPaneSize({ "Up", 1 }),
                action_resize_pane,
            }),
        },
        {
            key = "L",
            mods = "NONE",
            action = act.Multiple({
                act.AdjustPaneSize({ "Right", 1 }),
                action_resize_pane,
            }),
        },
    },
    search_mode = {
        { key = "Enter", mods = "NONE", action = act.ActivateCopyMode },
        -- TODO: how to default to regex match type?
        { key = "Escape", mods = "NONE", action = act.CopyMode("CycleMatchType") },
    },
    copy_mode = {
        {
            key = "Escape",
            mods = "NONE",
            action = act.Multiple({
                act.CopyMode("Close"),
                act.PopKeyTable,
            }),
        },
        {
            key = "?",
            mods = "NONE",
            action = act.Multiple({
                act.CopyMode("ClearPattern"),
                act.CopyMode("EditPattern"),
            }),
        },
        -- { key = "Enter", mods = "NONE", action = act.CopyMode("AcceptPattern") },
        -- {
        --     key = "Enter",
        --     mods = "NONE",
        --     action = act.Multiple({
        --         act.CopyMode("AcceptPattern"),
        --         act.CopyMode("ClearSelectionMode"),
        --         -- act.CopyMode("Close"),
        --         -- act.ActivateCopyMode,
        --     }),
        -- },

        -- copy_mode selection
        { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Block" }) },
        { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
        {
            key = "y",
            mods = "NONE",
            action = act.Multiple({
                act.CopyTo("PrimarySelection"),
                act.ClearSelection,
                act.CopyMode("ClearSelectionMode"),
            }),
        },

        -- copy_mode next/prev
        { key = "n", mods = "NONE", action = act.CopyMode("NextMatch") },
        { key = "N", mods = "NONE", action = act.CopyMode("PriorMatch") },

        -- copy_mode movement
        { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
        { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
        { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
        { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
        { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
        { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
        { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
        { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
        { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
        { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
        { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
        { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
        { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
        { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
        { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
    },
}

return config
