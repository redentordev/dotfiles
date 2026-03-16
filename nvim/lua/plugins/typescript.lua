return {
  -- Ensure TypeScript tooling is installed via Mason
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "typescript-language-server",
      },
    },
  },
}
