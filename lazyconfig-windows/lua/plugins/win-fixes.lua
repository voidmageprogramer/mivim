-- Arreglos especificos de Windows. En Linux/RPi este archivo no hace nada.
if vim.fn.has("win32") == 0 then
  return {}
end

return {
  -- nvim-lint / golangci-lint
  --
  -- lint/linters/golangcilint.lua decide si el archivo pertenece a un modulo
  -- comparando `go env GOMOD` contra '/dev/null'. En Windows Go devuelve 'NUL',
  -- asi que esa deteccion nunca acierta: si el cwd de nvim esta fuera del
  -- modulo, golangci-lint se ejecuta desde ahi y aborta con
  --   exit code 5: "no go files to analyze"
  -- en cada guardado de un .go.
  --
  -- Lo resolvemos envolviendo el linter en una funcion (nvim-lint acepta que
  -- linters[name] sea una funcion y la llama en cada ejecucion): fijamos cwd en
  -- la raiz del modulo del buffer, y si el archivo no tiene go.mod le pasamos el
  -- archivo en vez del directorio (que es lo que hace la rama de Linux).
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters.golangcilint = function()
        local linter = vim.deepcopy(require("lint.linters.golangcilint"))
        local fname = vim.api.nvim_buf_get_name(0)
        local dir = vim.fs.dirname(fname)
        local gomod = vim.fs.find("go.mod", { path = dir, upward = true })[1]
        linter.cwd = gomod and vim.fs.dirname(gomod) or dir
        if type(linter.args) == "table" and #linter.args > 0 then
          linter.args[#linter.args] = function()
            return gomod and dir or fname
          end
        end
        return linter
      end
    end,
  },
}
