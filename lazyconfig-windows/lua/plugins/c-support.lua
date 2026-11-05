-- c-support (Fritz Mehner) como plugin local.
-- El zip se extrae en  %LOCALAPPDATA%/nvim-data/c-support
-- (= vim.fn.stdpath("data") .. "/c-support").  IMPORTANTE: fuera de lazy/ porque
-- lazy.nvim trata todo lo que esta dentro de su root como repo git y da error.
local root = vim.fn.stdpath("data") .. "/c-support"
local is_win = vim.fn.has("win32") == 1

return {
  dir = root,
  name = "c-support",
  lazy = false,
  init = function()
    -- En Windows c.vim detecta "local installation" porque root está bajo $HOME,
    -- y entonces lee C_LocalTemplateFile. En Linux (fuera de $HOME) lee el global.
    -- Definimos los dos para que funcione igual en ambos.
    vim.g.C_GlobalTemplateFile = root .. "/c-support/templates/Templates"
    vim.g.C_LocalTemplateFile = root .. "/c-support/templates/Templates"
    vim.g.C_SnippetDir = root .. "/c-support/codesnippets"
    vim.g.C_MapLeader = "\\"
    vim.g.C_OutputGvim = "buffer"
    if is_win then
      -- gcc/g++ de WinLibs (mingw64); c.vim ya agrega .exe/.obj solo en Windows
      vim.g.C_CCompiler = "gcc.exe"
      vim.g.C_CplusCompiler = "g++.exe"
    end
  end,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "c", "cpp" },
      callback = function()
        vim.keymap.set("n", "<LocalLeader>rt", function()
          local exe = vim.fn.expand("%:p:r") .. (is_win and ".exe" or "")
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
