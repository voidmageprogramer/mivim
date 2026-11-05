-- Fondo negro puro + sintaxis más colorida (estilo VSCode Go) en LazyVim.
-- En Go la mayoría de tokens son variables/identificadores: sin esto quedan del
-- mismo blanco que el texto normal y se lee como "un solo color".
local TS_COLORS = {
  -- variables / identificadores: ya no del color del texto plano
  ["@variable"] = { fg = "#9CDCFE" },
  ["@variable.builtin"] = { fg = "#82aaff" },
  ["@parameter"] = { fg = "#ffc777" },
  ["@field"] = { fg = "#89ddff" },
  ["@property"] = { fg = "#89ddff" },
  -- funciones en amarillo (pop)
  ["@function"] = { fg = "#DCDCAA" },
  ["@function.call"] = { fg = "#DCDCAA" },
  ["@method"] = { fg = "#DCDCAA" },
  ["@method.call"] = { fg = "#DCDCAA" },
  ["@constructor"] = { fg = "#DCDCAA" },
  ["@function.builtin"] = { fg = "#82aaff" },
  -- tipos y constantes
  ["@type"] = { fg = "#78dce8" },
  ["@type.builtin"] = { fg = "#78dce8" },
  ["@constant"] = { fg = "#ffc777" },
  ["@constant.builtin"] = { fg = "#ffc777" },
  ["@number"] = { fg = "#ffc777" },
  ["@boolean"] = { fg = "#ffc777" },
  -- strings/operadores/comentarios
  ["@string"] = { fg = "#c3e88d" },
  ["@string.delimiter"] = { fg = "#c3e88d" },
  ["@operator"] = { fg = "#89ddff" },
  ["@punctuation"] = { fg = "#89ddff" },
  ["@comment"] = { fg = "#636da6", italic = true },
}

local function apply_ts_colors()
  for name, args in pairs(TS_COLORS) do
    vim.api.nvim_set_hl(0, name, args)
  end
end

-- reaplica la sintaxis colorida cuando cambie el colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = apply_ts_colors,
})

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon",
      on_highlights = function(hl, _)
        local fg = hl.Normal and hl.Normal.fg
        hl.Normal = { fg = fg, bg = "#000000" }
        hl.NormalFloat = { fg = fg, bg = "#000000" }
        hl.SignColumn = { bg = "#000000" }
        hl.WinSeparator = { fg = hl.WinSeparator and hl.WinSeparator.fg, bg = "#000000" }
        hl.LineNr = { fg = "#FF5500", bg = "#000000" }
        hl.CursorLineNr = { fg = "#39FF14", bg = "#000000", bold = true }
        hl.StatusLine = vim.tbl_extend("keep", hl.StatusLine or {}, { bg = "#000000" })
        hl.StatusLineNC = vim.tbl_extend("keep", hl.StatusLineNC or {}, { bg = "#000000" })
        hl.TabLine = vim.tbl_extend("keep", hl.TabLine or {}, { bg = "#000000" })
        hl.TabLineFill = vim.tbl_extend("keep", hl.TabLineFill or {}, { bg = "#000000" })
        apply_ts_colors()
      end,
    },
  },
}