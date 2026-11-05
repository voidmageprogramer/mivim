return {
  {
    dir = vim.fn.stdpath("config") .. "/lua/go-snippets",
    name = "go-snippets",
    lazy = false,
    config = function()
      require("go-snippets").setup()
    end,
  },
}