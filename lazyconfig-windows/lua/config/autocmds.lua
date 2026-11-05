-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- F3: correr `go vet` sobre el paquete (directorio) del archivo que se esta
-- editando y mostrarlo en la quickfix list. Funciona igual en Linux/RPi/Windows,
-- solo depende de tener `go` en el PATH.
local function go_vet()
  if vim.fn.executable("go") == 0 then
    vim.notify("go vet: no se encontro 'go' en el PATH", vim.log.levels.ERROR)
    return
  end

  vim.cmd("silent! update") -- guarda el archivo si tiene cambios

  local file = vim.api.nvim_buf_get_name(0)
  local dir = vim.fs.dirname(file)

  vim.notify("go vet: analizando paquete...", vim.log.levels.INFO)

  vim.system({ "go", "vet", "." }, { cwd = dir, text = true }, function(res)
    vim.schedule(function()
      local raw = {}
      for _, s in ipairs({ res.stdout, res.stderr }) do
        if s and s ~= "" then
          for line in s:gmatch("[^\r\n]+") do
            raw[#raw + 1] = line
          end
        end
      end

      -- `go vet .` reporta rutas relativas al cwd del proceso (./archivo.go:l:c: msg).
      -- Las volvemos absolutas para que la quickfix list pueda saltar al archivo
      -- sin importar cual sea el cwd de Neovim.
      local lines = {}
      for _, line in ipairs(raw) do
        local relfile, lnum, col, msg = line:match("^%.?[/\\]?([^:]+):(%d+):(%d+):%s*(.*)$")
        if relfile then
          lines[#lines + 1] = dir .. "/" .. relfile .. ":" .. lnum .. ":" .. col .. ": " .. msg
        end
      end

      vim.fn.setqflist({}, " ", { title = "go vet", lines = lines, efm = "%f:%l:%c: %m" })

      local items = vim.fn.getqflist()
      if #items == 0 then
        if res.code == 0 then
          vim.notify("go vet: sin problemas", vim.log.levels.INFO)
        else
          vim.notify("go vet: fallo (code " .. res.code .. ")\n" .. table.concat(raw, "\n"), vim.log.levels.ERROR)
        end
      else
        vim.cmd("copen")
        vim.notify(("go vet: %d problema(s)"):format(#items), vim.log.levels.WARN)
      end
    end)
  end)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("go-vet-f3", { clear = true }),
  pattern = "go",
  callback = function(ev)
    vim.keymap.set("n", "<F3>", go_vet, { buffer = ev.buf, desc = "go vet (paquete actual)" })
    vim.keymap.set("i", "<F3>", function()
      vim.cmd("stopinsert")
      go_vet()
    end, { buffer = ev.buf, desc = "go vet (paquete actual)" })
  end,
})
