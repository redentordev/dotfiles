-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.clipboard = "unnamedplus"
vim.opt.foldenable = false
vim.opt.foldcolumn = "0"

-- Platform-aware clipboard provider
if vim.fn.has("mac") == 1 then
  -- macOS: pbcopy/pbpaste (works out of the box with unnamedplus)
elseif vim.fn.executable("wl-copy") == 1 then
  -- Wayland
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy",
      ["*"] = "wl-copy",
    },
    paste = {
      ["+"] = "wl-paste",
      ["*"] = "wl-paste",
    },
    cache_enabled = 0,
  }
elseif vim.fn.executable("xclip") == 1 then
  -- X11
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -selection clipboard",
      ["*"] = "xclip -selection primary",
    },
    paste = {
      ["+"] = "xclip -selection clipboard -o",
      ["*"] = "xclip -selection primary -o",
    },
    cache_enabled = 0,
  }
end
