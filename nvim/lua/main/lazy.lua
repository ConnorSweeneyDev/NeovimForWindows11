local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

map("n", "<LEADER>l", "<CMD>Lazy<CR>")
require("lazy").setup
{
  {"nvim-lua/plenary.nvim", commit = "a3e3bc8"},
  {"stevearc/oil.nvim", commit = "fcca212"},
  {"divagueame/lacasitos.nvim", commit = "ae324c4"},
  {"nvim-telescope/telescope.nvim", commit = "43c47eb"},
  {"theprimeagen/harpoon", branch = "harpoon2", commit = "0378a6c"},
  {"mbbill/undotree", commit = "56c684a"},
  {"gbprod/yanky.nvim", commit = "73215b7"},
  {"ggandor/leap.nvim", commit = "c6bfb19"},
  {"Sleepful/leap-by-word.nvim", commit = "efc27cd"},
  {"kevinhwang91/nvim-bqf", commit = "1b24dc6"},
  {"itchyny/vim-qfedit", commit = "d05f2f3"},

  {"MunifTanjim/nui.nvim", commit = "61574ce"},
  {"nvim-tree/nvim-web-devicons", commit = "3722e3d"},
  {"tribela/vim-transparent", commit = "7b34267"},
  {"Mofiqul/vscode.nvim", name = "vscode", commit = "7de58b7"},
  {"nvim-lualine/lualine.nvim", commit = "b431d22"},
  {"rcarriga/nvim-notify", commit = "d333b6f"},
  {"folke/noice.nvim", commit = "d9328ef"},

  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate", commit = "8e40904"},
  {"neoclide/coc.nvim", branch = "release", commit = "57d488a"},
  {"tpope/vim-fugitive", commit = "d4877e5"},
  {"github/copilot.vim", commit = "8703812"}
}
