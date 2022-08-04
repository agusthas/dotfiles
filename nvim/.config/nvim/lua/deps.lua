vim.cmd [[packadd packer.nvim]]

local has = function(x)
  return vim.fn.has(x) == 1
end

local executable = function(x)
  return vim.fn.executable(x) == 1
end

local is_wsl = (function()
  local output = vim.fn.systemlist "uname -r"
  return not not string.find(output[1] or "", "WSL")
end)()

local is_mac = has "macunix"
local is_linux = not is_wsl and not is_mac

local max_jobs = nil
if is_mac then
  max_jobs = 32
end

return require('packer').startup {
  function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- TEXT MANIPULATION
    use "tpope/vim-commentary"
    use "tpope/vim-surround"
    use "junegunn/vim-easy-align"

    -- Statusline
    use { "nvim-lualine/lualine.nvim", config = function() require('lualine').setup() end }
  end,

  config = {
    max_jobs = max_jobs
  }
}
