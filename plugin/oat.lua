if vim.g.loaded_oat then
  return
end
vim.g.loaded_oat = 1

require('oat').setup()