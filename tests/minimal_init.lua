vim.cmd([[set runtimepath=$VIMRUNTIME]])
vim.cmd([[set packpath=/tmp/nvim/site]])

local package_root = "/tmp/nvim/site/pack"
local install_path = package_root .. "/packer/start/packer.nvim"

local function load_plugins()
  require("packer").startup({
    {
      "wbthomason/packer.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = {
      package_root = package_root,
      compile_path = install_path .. "/plugin/packer_compiled.lua",
    },
  })
end

if vim.fn.isdirectory(install_path) == 0 then
  vim.fn.system({ "git", "clone", "https://github.com/wbthomason/packer.nvim", install_path })
  load_plugins()
  require("packer").sync()
  vim.cmd([[autocmd User PackerComplete ++once lua load_plugins()]])
else
  load_plugins()
end

-- Add current plugin to runtimepath
vim.opt.rtp:append(".")