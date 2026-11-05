local M = {}

local snippets = {
  main       = { "func main() {", "", "}" },
  func       = { "func name() {", "", "}" },
  ["if"]     = { "if  {", "", "}" },
  iferr      = { "if err != nil {", "\treturn err", "}" },
  ifelse     = { "if  {", "", "} else {", "", "}" },
  ["elseif"] = { "} else if  {", "", "}" },
  ["else"]   = { "else {", "", "}" },
  forrange   = { "for i, v := range items {", "", "}" },
  fori       = { "for i := 0; i < n; i++ {", "", "}" },
  ["while"]  = { "for  {", "", "}" },
  switch     = { "switch  {", "", "}" },
  ["case"]   = { "case " },
  block      = { "{", "", "}" },
  struct     = { "type Name struct {", "\tField Type", "}" },
  interface  = { "type Name interface {", "\tMethod()", "}" },
  goroutine  = { "go func() {", "", "}()" },
  defer      = { "defer " },
  handler    = {
    'http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {',
    "",
    "})",
  },
  httpserver = { 'http.ListenAndServe(":8080", nil)' },
  channel    = { "ch := make(chan Type, 10)" },
  mutex      = { "var mu sync.Mutex" },
  test       = { "func TestName(t *testing.T) {", "", "}" },
  benchmark  = { "func BenchmarkName(b *testing.B) {", "", "}" },
  ["json"]   = { "json.Marshal(v)" },
  printf     = { 'fmt.Printf("\\n")' },
  scanf      = { "fmt.Scan(&val)" },
}

local cursors = {
  main = { 1, -1 }, func = { 0, 5 }, ["if"] = { 0, 4 }, iferr = { 1, -2 },
  ifelse = { 0, 4 }, ["elseif"] = { 0, 10 }, ["else"] = { 1, -1 },
  forrange = { 1, -1 }, fori = { 1, -1 }, ["while"] = { 0, 4 },
  switch = { 0, 7 }, ["case"] = { 0, 5 }, block = { 1, -1 },
  struct = { 0, 5 }, interface = { 0, 5 }, goroutine = { 1, -1 },
  defer = { 0, -2 }, handler = { 1, -1 }, httpserver = { 0, -2 },
  channel = { 0, 16 }, mutex = { 0, 4 }, test = { 0, 5 },
  benchmark = { 0, 5 }, ["json"] = { 0, 13 }, printf = { 0, 12 },
  scanf = { 0, 9 },
}

local maps = {
  sm = "main", sf = "func", se = "iferr", sif = "if", sie = "ifelse",
  sei = "elseif", sel = "else", sfo = "fori", sfr = "forrange",
  sr = "forrange", so = "fori", sw = "while", ss = "switch",
  sc = "case", sb = "block", si = "interface", sg = "goroutine",
  sd = "defer", sh = "handler", shs = "httpserver", schan = "channel",
  smu = "mutex", stt = "test", sbm = "benchmark", sj = "json",
  ["if"] = "func", im = "main", is = "struct", ipr = "printf",
  isc = "scanf",
}

local visual = {
  sif = { "if  {", "}" },
  sw = { "for  {", "}" },
  ss = { "switch  {", "}" },
  sg = { "go func() {", "}()" },
}

function M.insert(name)
  local lines = snippets[name]
  if not lines then return end
  local crow, ccol = unpack(cursors[name])
  local base = vim.fn.indent(".")
  local pref = string.rep(" ", base)
  local ln = vim.fn.line(".")

  local function insert_after(ln1, text)
    vim.api.nvim_buf_set_lines(0, ln1, ln1, false, { text })
  end
  local function replace_line(ln1, text)
    vim.api.nvim_buf_set_lines(0, ln1 - 1, ln1, false, { text })
  end

  local cur = vim.fn.getline(".")
  if cur:match("^%s*$") then
    replace_line(ln, pref .. lines[1])
  else
    insert_after(ln, pref .. lines[1])
    ln = ln + 1
  end
  for i = 2, #lines do
    insert_after(ln, pref .. lines[i])
    ln = ln + 1
  end

  local r = ln - (#lines - 1 - crow)
  local line = vim.fn.getline(r)
  local col
  if ccol >= 0 then
    col = ccol + base
  elseif ccol == -1 then
    local m = line:find("%S")
    col = m and (m - 1) or 0
  else
    col = #line
  end
  vim.api.nvim_win_set_cursor(0, { r, math.max(col, 0) })
  vim.cmd("startinsert")
end

function M.wrap(header, footer)
  local ln1 = math.min(vim.fn.getpos("v")[2], vim.fn.getpos(".")[2])
  local ln2 = math.max(vim.fn.getpos("v")[2], vim.fn.getpos(".")[2])
  local base = vim.fn.indent(ln1)
  local pref = string.rep(" ", base)
  local sel = vim.fn.getline(ln1, ln2)
  local new = { pref .. header }
  for _, l in ipairs(sel) do
    table.insert(new, pref .. l)
  end
  table.insert(new, pref .. footer)
  vim.api.nvim_buf_set_lines(0, ln1 - 1, ln2, false, new)
  vim.api.nvim_win_set_cursor(0, { ln1, #header })
  vim.cmd("startinsert")
end

local function setup()
  for k, v in pairs(maps) do
    vim.keymap.set({ "n", "i" }, "\\" .. k, function()
      M.insert(v)
    end, { buffer = true, desc = "Go snippet " .. v })
  end
  for k, v in pairs(visual) do
    vim.keymap.set("x", "\\" .. k, function()
      M.wrap(v[1], v[2])
    end, { buffer = true })
  end
end

function M.setup()
  if vim.o.timeoutlen > 400 then
    vim.opt.timeoutlen = 400
  end
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = setup,
  })
end

return M