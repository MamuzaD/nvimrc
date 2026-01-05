local opt = vim.opt

opt.clipboard = "unnamedplus"

opt.number = true
opt.relativenumber = true 
opt.tabstop = 2 
opt.shiftwidth = 2 -- Size of an indent

opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.mouse = "a" -- Enable mouse mode

opt.termguicolors = true 
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mod
opt.wrap = false -- Disable line wrap

