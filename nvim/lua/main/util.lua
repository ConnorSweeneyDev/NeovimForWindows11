map = vim.keymap.set
opt = vim.opt
api = vim.api
g = vim.g

----------------------------------------------------------------------------------------------------

general_util = {}
general_util.floating_window_exists = function()
  for _, winid in pairs(api.nvim_tabpage_list_wins(0)) do
    if api.nvim_win_get_config(winid).zindex then return true end
  end
  return false
end
general_util.make_relative_files = function(long_files, cwd)
  local files = {}
  for _, file in ipairs(long_files) do
    local new_file = string.gsub(file, cwd .. "\\", "")
    new_file = string.gsub(new_file, "\\", "/")
    table.insert(files, new_file)
  end
  return files
end

----------------------------------------------------------------------------------------------------

buffer_util = {}
buffer_util.open_buffers = function(folders, file_extensions, ignore_files)
  local original_buffer = api.nvim_get_current_buf()
  for _, folder in ipairs(folders) do
    for _, extension in ipairs(file_extensions) do
      local files = vim.fn.globpath(vim.fn.getcwd() .. folder, "**/" .. extension, 0, 1)
      for _, file in ipairs(files) do
        if not vim.tbl_contains(ignore_files, vim.fn.fnamemodify(file, ":t")) then
          vim.cmd("edit " .. file)
        end
      end
    end
  end
  api.nvim_set_current_buf(original_buffer)
end
buffer_util.close_buffers = function()
  local original_buffer = api.nvim_get_current_buf()
  local buffers = api.nvim_list_bufs()
  for _, buffer in ipairs(buffers) do
    if buffer ~= original_buffer then
      api.nvim_buf_delete(buffer, {force = true})
    end
  end
end
buffer_util.manual_open = function(folders, file_extensions, ignore_files, use_coc)
  buffer_util.open_buffers(folders, file_extensions, ignore_files)
  if use_coc then vim.cmd("silent CocRestart") end
  vim.notify("Buffers opened.")
end
buffer_util.manual_close = function(use_coc)
  buffer_util.close_buffers()
  if use_coc then vim.cmd("silent CocRestart") end
  vim.notify("Buffers closed.")
end
buffer_util.open_on_startup = function(folders, file_extensions, ignore_files)
  if general_util.floating_window_exists() then return end
  local original_buffer = api.nvim_get_current_buf()
  buffer_util.open_buffers(folders, file_extensions, ignore_files)
  api.nvim_set_current_buf(original_buffer)
end

----------------------------------------------------------------------------------------------------

color_util = {}
color_util.initialize_colors = function(scheme, highlights)
  vim.cmd.colorscheme(scheme)
  api.nvim_set_hl(0, "Normal", {bg = "none"})
  api.nvim_set_hl(0, "NormalFloat", {bg = "none"})
  for _, highlight in ipairs(highlights) do
    vim.cmd("highlight " .. highlight)
  end
end
color_util.line_number_handler = function(separator, line_colors)
  local status_column = ""
  for index, line_color in ipairs(line_colors) do
    local line_nr = index - 1
    local rel_or_l_num = "relnum.\""
    local operation = " == "
    if line_nr == 0 then rel_or_l_num = "lnum.\" " end
    if line_colors[index + 1] == nil then operation = " >= " end
    status_column = "%#LineNr" .. line_nr .. "#%{(v:relnum" .. operation .. line_nr ..
                    ")?v:" .. rel_or_l_num .. separator .. "\":\"\"}" .. status_column
    vim.cmd("highlight LineNr" .. line_nr .. " guifg=" .. line_color)
  end
  opt.statuscolumn = "%s%=" .. status_column
end

----------------------------------------------------------------------------------------------------

c_util = {}
c_util.get_files_in_compilation_unit = function(directory)
  local cwd = vim.fn.getcwd()
  local name = vim.fn.expand("%:t:r")
  local long_files = vim.fn.globpath(directory, "**/" .. name .. ".*", 0, 1)
  local files = general_util.make_relative_files(long_files, cwd)
  return files
end
c_util.assign_cxx_file_types = function(files)
  local source = ""
  local header = ""
  local inline = ""
  for _, file in ipairs(files) do
    if string.match(file, "%.cpp$") then source = file
    elseif string.match(file, "%.hpp$") then header = file
    elseif string.match(file, "%.inl$") then inline = file end
  end
  return source, header, inline
end
c_util.assign_cc_file_types = function(files)
  local source = ""
  local header = ""
  for _, file in ipairs(files) do
    if string.match(file, "%.c$") then source = file
    elseif string.match(file, "%.h$") then header = file end
  end
  return source, header
end
c_util.switch_file_in_compilation_unit = function(directory, target_file)
  local directory = vim.fn.getcwd() .. directory
  local current_extension = vim.fn.expand("%:e")
  local files = c_util.get_files_in_compilation_unit(directory)
  if string.match(current_extension, "cpp") or string.match(current_extension, "hpp") or string.match(current_extension, "inl") then
    local target_extension = ""
    if target_file == "source" then target_extension = "cpp"
    elseif target_file == "header" then target_extension = "hpp"
    elseif target_file == "inline" then target_extension = "inl"
    else
      vim.notify("Unexpected target file!", "error")
      return
    end
    if string.match(current_extension, target_extension) then
      vim.notify("Already in " .. target_extension .. " file!", "error")
      return
    end
    if #files == 0 then vim.notify("Problem reading filename!", "error")
    elseif #files == 1 then vim.notify("There is only one file in this compilation unit!", "error")
    elseif #files == 2 or #files == 3 then
      local source, header, inline = c_util.assign_cxx_file_types(files)
      if target_extension == "cpp" then
        if source ~= "" then vim.cmd("edit " .. source)
        else vim.notify("No cpp file found!", "error") end
      elseif target_extension == "hpp" then
        if header ~= "" then vim.cmd("edit " .. header)
        else vim.notify("No hpp file found!", "error") end
      elseif target_extension == "inl" then
        if inline ~= "" then vim.cmd("edit " .. inline)
        else vim.notify("No inl file found!", "error") end
      else vim.notify("Unexpected target file extension!", "error") end
    else vim.notify("Unexpectedly high amount of corresponding files found!", "error") end
  elseif string.match(current_extension, "c") or string.match(current_extension, "h") then
    local target_extension = ""
    if target_file == "source" then target_extension = "c"
    elseif target_file == "header" then target_extension = "h"
    else
      vim.notify("Unexpected target file!", "error")
      return
    end
    if string.match(current_extension, target_extension) then
      vim.notify("Already in " .. target_extension .. " file!", "error")
      return
    end
    if #files == 0 then vim.notify("Problem reading filename!", "error")
    elseif #files == 1 then vim.notify("There is only one file in this compilation unit!", "error")
    elseif #files == 2 then
      local source, header, inline = c_util.assign_cc_file_types(files)
      if target_extension == "c" then
        if source ~= "" then vim.cmd("edit " .. source)
        else vim.notify("No c file found!", "error") end
      elseif target_extension == "h" then
        if header ~= "" then vim.cmd("edit " .. header)
        else vim.notify("No h file found!", "error") end
      else vim.notify("Unexpected target file extension!", "error") end
    else vim.notify("Unexpectedly high amount of corresponding files found!", "error") end
  else vim.notify("Not a c, h, cpp, hpp or inl file!", "error") end
end

----------------------------------------------------------------------------------------------------

lazy_util = {}
lazy_util.bootstrap = function()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
    if vim.v.shell_error ~= 0 then
      api.nvim_echo({{"Failed to clone lazy.nvim:\n", "ErrorMsg"}, {out, "WarningMsg"}, {"\nPress any key to exit..."}}, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  opt.rtp:prepend(lazypath)
end

----------------------------------------------------------------------------------------------------

lualine_util = {}
lualine_util.dynamic_path = function()
  local filetype = vim.bo.filetype
  local path = vim.fn.expand("%:.")
  local cwd = vim.fn.getcwd()
  local root = cwd:match("^[^:]")
  local modified_symbol = " ⬤"
  if path == "" and filetype == "" then return "none"
  elseif string.match(filetype, "help") then path = "help\\" .. string.match(path, "\\doc\\(.*)")
  elseif string.match(filetype, "list") then path = string.gsub(path, "^list:///", "")
  elseif string.match(filetype, "qf") then path = "quickfix"
  elseif string.match(filetype, "lazy") then path = "lazy"
  elseif string.match(filetype, "harpoon") then path = "harpoon"
  elseif string.match(filetype, "notify") then path = "notify"
  elseif string.match(filetype, "TelescopePrompt") then path = "telescope"
  elseif string.match(filetype, "gitcommit") then path = "commit"
  elseif string.find(filetype, "Neogit") then path = "neogit\\" .. string.lower(string.gsub(filetype, "Neogit", ""))
  elseif string.find(filetype, "Diffview") then path = "diffview\\" .. string.lower(string.gsub(filetype, "Diffview", ""))
  elseif string.find(path, ".git/:0:/") then path = "diffview\\remote"
  elseif string.find(path, ".git/:2:/") then path = "diffview\\ours"
  elseif string.find(path, ".git/:3:/") then path = "diffview\\theirs"
  elseif string.find(path, "__coc_refactor__") then path = "refactor"
  elseif string.match(filetype, "netrw") then if not string.find(path, ":/") then path = cwd:match("^.*\\(.*)$") .. "\\" .. path end
  elseif string.match(filetype, "oil_preview") then path = "confirm"
  elseif string.match(filetype, "oil") then
    path = string.gsub(path, "^oil:///", "")
    path = string.sub(path, 0, 1) .. ":" .. string.sub(path, 2)
    path = string.gsub(path, "/", "\\")
    if cwd ~= root .. ":\\" then path = string.gsub(path, cwd, cwd:match("^.*\\(.*)$")) end
    if (vim.bo.modified) then path = path .. modified_symbol end
  else
    if cwd:match("^.*\\(.*)$") == nil or cwd:match("^.*\\(.*)$") == "" then
      if not string.find(path, root .. ":\\") then path = root .. ":\\" .. path end
    else
      if not string.find(path, root .. ":\\") then path = cwd:match("^.*\\(.*)$") .. "\\" .. path end
    end
    if (vim.bo.modified) then path = path .. modified_symbol end
  end
  if string.match(path, "^." .. root .. ":") then path = string.gsub(path, "^.", "") end
  if string.match(path, "^.\\" .. root .. ":\\") then path = string.gsub(path, "^.\\", "") end
  path = string.gsub(path, "\\", "/")
  return path
end
lualine_util.current_register = function()
  local recording_register = vim.fn.reg_recording()
  if recording_register ~= "" then
    return "@" .. recording_register
  end
  return "@~"
end

----------------------------------------------------------------------------------------------------

oil_util = {}
oil_util.open_on_startup = function() if not general_util.floating_window_exists() then vim.cmd("Oil") end end

----------------------------------------------------------------------------------------------------

treesitter_util = {}
treesitter_util.disable_for_large_files = function(max_size)
  local size = vim.fn.getfsize(vim.fn.expand("%"))
  if size > max_size then vim.cmd("TSBufDisable highlight")
  else vim.cmd("TSBufEnable highlight") end
end

----------------------------------------------------------------------------------------------------

coc_util = {}
coc_util.show_docs = function()
  local cw = vim.fn.expand("<cword>")
  if vim.fn.index({"vim", "help"}, vim.bo.filetype) >= 0 then
    api.nvim_command("h " .. cw)
  elseif api.nvim_eval("coc#rpc#ready()") then
    vim.fn.CocActionAsync("doHover")
  else
    api.nvim_command("!" .. opt.keywordprg .. " " .. cw)
  end
end
coc_util.refactor_handler = function()
  language = vim.fn.expand("%:e")
  if language ~= "" and language ~= nil then
    if language == "h" then language = "c" end
    if language == "hpp" or language == "inl" then language = "cpp" end
    vim.treesitter.language.register(language, "crf")
  end
  if string.find(vim.fn.expand("%"), "__coc_refactor__") then vim.cmd("set filetype=crf") end
end

----------------------------------------------------------------------------------------------------

neogit_util = {}
neogit_util.open_status_menu = function()
  local cwd = vim.fn.getcwd()
  vim.cmd("Neogit")
  vim.api.nvim_set_current_dir(cwd)
end

----------------------------------------------------------------------------------------------------

supermaven_util = {}
supermaven_util.disable_for_large_files = function(max_size)
  local size = vim.fn.getfsize(vim.fn.expand("%"))
  if size > max_size and require("supermaven-nvim.api").is_running() then vim.cmd("SupermavenStop")
  elseif size <= max_size and not require("supermaven-nvim.api").is_running() then vim.cmd("SupermavenStart") end
end
