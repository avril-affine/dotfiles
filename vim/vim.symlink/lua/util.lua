local M = {}

M.project_dir = function()
    local current_dir = vim.fs.dirname(string.sub(debug.getinfo(1).source, 2))
    local realpath = io.popen("realpath " .. current_dir):read("a")
    local git_path = vim.fs.find(".git", {
        upward = true,
        stop = vim.loop.os_homedir(),
        path = realpath,
        type = "directory",
    })[1]
    return vim.fs.dirname(git_path)
end

M.print_table = function(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent+1)
        elseif type(v) == 'boolean' then
            print(formatting .. tostring(v))
        else
            print(formatting .. v)
        end
    end
end

return M
