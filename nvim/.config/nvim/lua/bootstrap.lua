local fn = vim.fn

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  local out = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  
  print(out)
  print("Installed packer.nvim")
  print(" ( Please restart nvim ) ")
  vim.cmd [[qa]]
end