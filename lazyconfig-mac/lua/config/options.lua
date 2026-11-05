vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.timeoutlen = 1500

local function set_line_nr_colors()
  vim.cmd("highlight LineNr guifg=#FF5500")
  vim.cmd("highlight CursorLineNr guifg=#39FF14 gui=bold")
end

vim.defer_fn(set_line_nr_colors, 500)

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_line_nr_colors,
})
