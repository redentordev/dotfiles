-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, desc)
  local opts = { noremap = true, silent = true, desc = desc }
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- =====================================================
-- LazyVim already provides these out of the box:
--   <leader>ff  Find files
--   <leader>fg  Live grep
--   <leader>fb  Buffers
--   <leader>fh  Help tags (via Snacks.picker)
--   <leader>fr  Recent files
--   <leader>fs  Search symbols
--   gd          Go to definition
--   gD          Go to declaration
--   gi          Go to implementation
--   gr          References
--   gO          Document symbols (outline)
--   K           Hover documentation
--   <leader>ca  Code action
--   <leader>cr  Rename
--   <leader>cd  Line diagnostics
--   [d / ]d     Prev/next diagnostic
--   <leader>e   Explorer (file tree)
-- =====================================================

-- Extra Snacks.picker keymaps not in LazyVim defaults
map("n", "<leader>fc", function()
  Snacks.picker.colorschemes()
end, "Colorscheme")

map("n", "<leader>fw", function()
  Snacks.picker.grep_word()
end, "Find Word")

map("n", "<leader>ft", function()
  Snacks.picker.treesitter()
end, "Treesitter Symbols")

-- Split window management
map("n", "<leader>sh", ":split<CR>", "Horizontal split")
map("n", "<leader>sv", ":vsplit<CR>", "Vertical split")

-- Buffer navigation
map("n", "<leader>bd", ":bdelete<CR>", "Delete buffer")
map("n", "<leader>bn", ":bnext<CR>", "Next buffer")
map("n", "<leader>bp", ":bprevious<CR>", "Previous buffer")

-- Stay in indent mode (visual)
map("v", "<", "<gv", "Indent left")
map("v", ">", ">gv", "Indent right")

-- Move text up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", "Move text down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move text up")

-- Save and quit
map("n", "<leader>w", ":w<CR>", "Save")
map("n", "<leader>q", ":q<CR>", "Quit")
