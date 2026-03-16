-- File management with oil.nvim
return {
  -- Disable nvim-tree
  { "nvim-tree/nvim-tree.lua", enabled = false },

  -- Configure oil.nvim
  {
    "stevearc/oil.nvim",
    opts = {
      -- Set oil as the default file explorer
      default_file_explorer = true,
      -- Keymaps in oil
      keymaps = {
        ["-"] = "actions.parent",
      },
      -- Show hidden files
      view_options = {
        show_hidden = true,
      },
    },
    -- Set up keymaps
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
  },
}