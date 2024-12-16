map("n", " ", "<NOP>")
map("n", "<C-f>", "<NOP>")
map("n", "<LEADER>w", "<CMD>w<CR>")
map("n", "<LEADER>tw", "<CMD>set wrap!<CR>")
map("n", "J", "mzJ`z")
map("n", "gJ", "mzgJ`z")
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")
map({"n", "v"}, "j", "gj")
map({"n", "v"}, "k", "gk")
map("n", "<A-h>", "<C-w>h")
map("n", "<A-j>", "<C-w>j")
map("n", "<A-k>", "<C-w>k")
map("n", "<A-l>", "<C-w>l")
map({"n", "v"}, "<LEADER>y", [["+y]])
map("n", "<LEADER>Y", [["+Y]])
map({"x", "v"}, "<LEADER>p", [["_dP]])
map({"n", "v"}, "<LEADER>d", [["_d]])
map({"n", "v"}, "<LEADER>c", [["_c]])
map({"n", "v"}, "<LEADER>x", [["_x]])
map("n", "<LEADER>s", ":%s/<C-r><C-w>/<C-r><C-w>/g<Left><Left>")
map("n", "<C-s>", ":%s//g<Left><Left>")
map("v", "<LEADER>s", "\"hy:%s/<C-r>h/<C-r>h/g<Left><Left>")
map("v", "<C-s>", ":s//g<Left><Left>")
map("v", "<C-n>", ":normal ")
map("n", "<LEADER>qg", function() quickfix_util.grep_search() end)
map("n", "<LEADER>qw", function() quickfix_util.grep_word() end)
map("n", "<LEADER>qW", function() quickfix_util.grep_full_word() end)
map("v", "<LEADER>q", function() quickfix_util.grep_selection() end)
map("n", "<LEADER>qo", "<CMD>copen<CR>")
map("n", "<LEADER>qr", ":cdo s//g<Left><Left>")
map("n", "<C-w>e", "<CMD>!e<CR>")
map("n", "<C-f>d", "<CMD>!fd<CR>")
map("n", "<C-f>u", "<CMD>!fu<CR>")
map("n", "<LEADER>v", "<CMD>!sh script/clean.sh<CR>")
map("n", "<LEADER>b", "<CMD>!wezterm cli spawn --cwd . pwsh -NoExit -Command \"sh script/build.sh\"<CR>")
map("n", "<LEADER>n", "<CMD>!wezterm cli spawn --cwd . pwsh -NoExit -Command \"sh script/run.sh\"<CR>")
map("n", "<LEADER>m", "<CMD>!wezterm cli spawn --cwd . pwsh -Command \"sh script/debug.sh\"<CR>")
