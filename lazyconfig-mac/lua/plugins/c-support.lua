-- c-support (Fritz Mehner) como plugin local.
-- El zip se extrae en  ~/.local/share/nvim/c-support
-- (= vim.fn.stdpath("data") .. "/c-support").  IMPORTANTE: fuera de lazy/ porque
-- lazy.nvim trata todo lo que esta dentro de su root como repo git y da error.
-- En macOS el directorio queda bajo $HOME, y c.vim detecta "local installation":
-- lee C_LocalTemplateFile. Definimos los dos para que funcione igual en todos los SO.
local root = vim.fn.stdpath("data") .. "/c-support"

return {
  dir = root,
  name = "c-support",
  lazy = false,
  init = function()
    vim.g.C_GlobalTemplateFile = root .. "/c-support/templates/Templates"
    vim.g.C_LocalTemplateFile = root .. "/c-support/templates/Templates"
    vim.g.C_SnippetDir = root .. "/c-support/codesnippets"
    vim.g.C_MapLeader = "\\"
    vim.g.C_OutputGvim = "buffer"
  end,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "c", "cpp" },
      callback = function()
        vim.keymap.set("n", "<LocalLeader>rt", function()
          -- en macOS el ejecutable no lleva extension: usa la ruta completa del
          -- archivo sin extensión y el mismo binario que genero C_Link().
          local exe = vim.fn.expand("%:p:r")
          vim.cmd("call C_Link()")
          if vim.fn.executable(exe) == 0 then
            vim.notify("no se pudo compilar / no existe: " .. exe, vim.log.levels.ERROR)
            return
          end
          vim.cmd("tab term " .. vim.fn.shellescape(exe))
          vim.cmd("startinsert")
        end, { buffer = true, desc = "Compile and run in terminal tab (interactive)" })
      end,
    })
  end,
}