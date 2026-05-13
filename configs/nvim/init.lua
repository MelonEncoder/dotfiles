-- SETTINGS
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 5

-- PLUGIN MANAGER
vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/folke/tokyonight.nvim" }
})

-- COLOR SCHEME
vim.cmd('colorscheme default')

-- TREESITTER CONFIG
require("nvim-treesitter.config").setup({
    ensure_installed = { "c", "cpp", "qmljs", "python", "go", "qmlls6", "lua" },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
})

-- LSP CONFIGS
vim.lsp.config('lua_ls', {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".luarc.json", ".git" },
})

vim.lsp.config('qmlls6', {
    cmd = { "qmlls6" },
    filetypes = { "qml", "qmljs" },
    single_file_support = true,
})

vim.o.updatetime = 250

vim.diagnostic.config({
    underline = true,
    virtual_text = false,
    float = {
        border = "rounded",
        source = "if_many",
    },
})
