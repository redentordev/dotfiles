-- Flutter/Dart development support
-- Requires: Flutter SDK installed (set FLUTTER_SDK env var or install to ~/.flutter-sdk/flutter)
local flutter_sdk = os.getenv("FLUTTER_SDK") or (os.getenv("HOME") .. "/.flutter-sdk/flutter")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        dartls = function()
          local dart_bin = flutter_sdk .. "/bin/cache/dart-sdk/bin/dart"
          if vim.fn.executable(dart_bin) == 0 then
            return false
          end
          require("lspconfig").dartls.setup({
            cmd = { dart_bin, "language-server", "--protocol=lsp" },
            settings = {
              dart = {
                analysisExcludedFolders = { ".pub-cache", "build", ".dart_tool" },
                updateImportsOnRename = true,
                completeFunctionComments = true,
                showTodos = true,
              },
            },
          })
          return true
        end,
      },
    },
  },
  {
    "akinsho/flutter-tools.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    ft = { "dart" },
    opts = {
      ui = {
        notification_title = "Flutter",
      },
      debugger = {
        enabled = true,
      },
      flutter_path = flutter_sdk .. "/bin/flutter",
      flutter_widgets = {
        enabled = true,
      },
      closing_tags = {
        highlight = "TodoFg",
      },
      dev_log = {
        enabled = true,
        open_cmd = "tabedit",
      },
    },
    keys = {
      { "<leader>Fr", "<cmd>FlutterRun<cr>", desc = "Flutter Run" },
      { "<leader>Fd", "<cmd>FlutterDevices<cr>", desc = "Flutter Devices" },
      { "<leader>Fp", "<cmd>FlutterPubGet<cr>", desc = "Flutter Pub Get" },
      { "<leader>Fb", "<cmd>FlutterBuild<cr>", desc = "Flutter Build" },
      { "<leader>FR", "<cmd>FlutterRestart<cr>", desc = "Flutter Restart" },
      { "<leader>Fc", "<cmd>FlutterClean<cr>", desc = "Flutter Clean" },
    },
  },
  {
    "dart-lang/dart-vim-plugin",
    ft = { "dart" },
  },
}
