-- Global settings
vim.g.markdown_recommended_style = 0
vim.g.mapleader = " "
vim.g.clipboard = {
  name = "osc52-copy-only",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = function()
      return {}
    end,
    ["*"] = function()
      return {}
    end,
  },
}

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fixendofline = false
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.mouse = ""
vim.opt.exrc = true
vim.opt.signcolumn = "yes"
vim.opt.showcmdloc = "statusline"
vim.opt.jumpoptions:append("view")

-- pandoc
vim.api.nvim_create_autocmd(
  { 'BufNewFile', 'BufRead' },
  {
    pattern  = { '*.md' },
    callback = function()
      vim.api.nvim_buf_set_keymap(0, 'n', '<f5>', [[<cmd>lua pandoc_convert(vim.fn.expand('%'))<cr>]],
        { noremap = true, silent = true })
    end
  }
)
function _G.pandoc_convert(filename)
  local args
  local path = vim.fn.fnamemodify(filename, ':p:h')
  local name = vim.fn.fnamemodify(filename, ':t')
  if vim.fn.filereadable(path .. '/config/default.yaml') == 1 then
    args = '--defaults config/default.yaml'
  else
    args = '-s --mathjax --citeproc'
  end
  local cmd = 'env --chdir=' .. path .. ' pandoc ' .. args .. ' "' .. name .. '" -o output.html'
  print(cmd)
  print(vim.fn.system(cmd))
end

-- general key map
local default_opt = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '-', 'ddp', default_opt)
vim.api.nvim_set_keymap('n', '<c-l>', '<cmd>nohlsearch<cr><c-l>', default_opt)
vim.api.nvim_set_keymap('c', '%%', "getcmdtype() == ':' ? expand('%:p:h') : '%%'", { expr = true, noremap = true })

-- config for cjk character
--   m : break at multibyte character
--   B : don't add space between multibyte character when joining lines
vim.api.nvim_create_autocmd(
  { "BufNew" },
  {
    pattern = '*',
    callback =
        function()
          local op = vim.api.nvim_get_option_value('formatoptions', { scope = 'local' })
          vim.api.nvim_set_option_value('formatoptions', op .. 'B', { scope = 'local' })
        end
  })


-- Set filetype associations
vim.filetype.add({
  extension = {
    dj = "djot",
    sdoc = "sdoc",
    bean = "beancount",
    beancount = "beancount",
    dhall = "dhall",
    fst = "fstar",
    agda = "agda",
    plumb = "plumb",
  }
})

-- Autocmds
vim.api.nvim_create_autocmd("FileType", {
  pattern = "nix",
  callback = function()
    vim.opt_local.iskeyword:append('-')
  end
})

require('vim._core.ui2').enable({})

-- Prefer LSP folding when a buffer has a capable client, otherwise use
-- tree-sitter. Folding options are window-local, so update every window that
-- displays the buffer and re-evaluate when windows or clients change.
local treesitter_foldexpr = 'v:lua.vim.treesitter.foldexpr()'
local lsp_foldexpr = 'v:lua.vim.lsp.foldexpr()'
local default_foldtext = 'foldtext()'
local lsp_foldtext = 'v:lua.vim.lsp.foldtext()'
local plumb_foldtext = "v:lua.require'plumb'.foldtext()"

vim.o.foldmethod = 'expr'
vim.o.foldexpr = treesitter_foldexpr
vim.o.foldtext = default_foldtext
vim.opt.foldminlines = 0

local function has_lsp_folding(bufnr)
  return vim.iter(vim.lsp.get_clients({ bufnr = bufnr })):any(function(client)
    return client:supports_method('textDocument/foldingRange')
  end)
end

local function configure_folding(bufnr, winid)
  if not vim.api.nvim_win_is_valid(winid) or vim.api.nvim_win_get_buf(winid) ~= bufnr then
    return
  end

  local window = vim.wo[winid][0]
  window.foldmethod = 'expr'
  if has_lsp_folding(bufnr) then
    window.foldexpr = lsp_foldexpr
    window.foldtext = vim.bo[bufnr].filetype == 'plumb' and plumb_foldtext or lsp_foldtext
  else
    window.foldexpr = treesitter_foldexpr
    window.foldtext = default_foldtext
  end
end

local function configure_buffer_folding(bufnr)
  for _, winid in ipairs(vim.fn.win_findbuf(bufnr)) do
    configure_folding(bufnr, winid)
  end
end

local folding_group = vim.api.nvim_create_augroup('LspFolding', { clear = true })

vim.api.nvim_create_autocmd({ 'LspAttach', 'BufWinEnter' }, {
  group = folding_group,
  callback = function(event)
    if event.event == 'BufWinEnter' then
      configure_folding(event.buf, vim.api.nvim_get_current_win())
    else
      configure_buffer_folding(event.buf)
    end
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = folding_group,
  callback = function(event)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(event.buf) then
        configure_buffer_folding(event.buf)
      end
    end)
  end,
})
