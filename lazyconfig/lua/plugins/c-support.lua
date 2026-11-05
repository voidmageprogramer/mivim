return {
  dir = vim.fn.expand("~/.local/share/nvim/lazy/c-support"),
  name = "c-support",
  lazy = false,
  init = function()
    vim.g.C_GlobalTemplateFile = vim.fn.expand("~/.local/share/nvim/lazy/c-support/c-support/templates/Templates")
    vim.g.C_SnippetDir = vim.fn.expand("~/.local/share/nvim/lazy/c-support/c-support/codesnippets")
    vim.g.C_MapLeader = "\\"
    vim.g.C_OutputGvim = "buffer"
  end,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "c", "cpp" },
      callback = function()
        vim.keymap.set("n", "<LocalLeader>rt", function()
          local file = vim.fn.expand("%:r")
          if file and file ~= "" then
            vim.cmd("call C_Link()")
            vim.cmd("tab term ./" .. file)
          end
        end, { buffer = true, desc = "Compile and run in terminal tab (interactive)" })
      end,
    })
  end,
}
