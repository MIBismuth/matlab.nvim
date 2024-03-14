M = {}
local _defaults = {
    matlab_dir = "/usr/local/MATLAB/R2023b/bin/matlab"
}

local _config = {}

M.setup = function(user_opts)
    -- Merge user configuration with defaults
    _config = vim.tbl_deep_extend("keep", user_opts or {}, _defaults)


    -- Create User Commands

    vim.api.nvim_create_user_command("MatlabCliOpen", M.matlab_cli_open, {})
    vim.api.nvim_create_user_command("MatlabCliRunLine", M.matlab_cli_run_line, {})
    vim.api.nvim_create_user_command("MatlabCliRunSelection", M.matlab_cli_run_selection, {})
    vim.api.nvim_create_user_command("MatlabCliRunCell", M.matlab_cli_run_cell, {})
    vim.api.nvim_create_user_command("MatlabOpenWorkspace", M.matlab_open_workspace, {})
    vim.api.nvim_create_user_command("MatlabOpenEditor", M.matlab_open_editor, {})
    vim.api.nvim_create_user_command("MatlabCliClear", M.matlab_cli_clear, {})
    vim.api.nvim_create_user_command("MatlabCliCancelOperation", M.matlab_cli_cancel_operation, {})

    return _config
end

M._matlab_open_buffer = function()
    -- Get the current buffer number
    local current_buffer = vim.fn.bufnr('%')

    -- Open a new buffer
    vim.cmd('vnew')

    -- Resize the new buffer to take up 50% of the screen width
    vim.cmd('vertical resize 50')

    -- Get the buffer number of the newly opened buffer
    M._cli_buff = vim.fn.bufnr('%')

    return M._cli_buff
end

M.matlab_cli_open = function()
    local matlab_dir = _config.matlab_dir
    -- Define the command to execute MATLAB with the script
    local command = matlab_dir .. " -nosplash -nodesktop"
    -- local command = "ls"

    local mat_buffer = M._matlab_open_buffer()

    -- Execute commands in the terminal
    local job_id = vim.fn.termopen(command)
    if job_id <= 0 then
        print("Error opening terminal")
    end

    M._job_id = job_id
end

M.matlab_cli_run_command = function(command)
    vim.api.nvim_chan_send(M._job_id, command)
end

M.matlab_cli_run_line = function()
    local line_content = vim.api.nvim_get_current_line()
    -- Print the captured line
    M.matlab_cli_run_command(line_content .. "\n")
end

M.matlab_cli_run_selection = function()
    local vstart = vim.fn.getpos("'<")

    local vend = vim.fn.getpos("'>")

    local line_start = vstart[2]
    local line_end = vend[2]

    -- or use api.nvim_buf_get_lines
    local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)

    for _, line in ipairs(lines) do
        M.matlab_cli_run_command(line .. "\n")
    end
    return lines
end


M.matlab_cli_run_cell = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_number = cursor[1]

    local above_line = nil
    local bellow_line = nil

    for i = line_number, 1, -1 do
        local local_line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        if local_line:find("^%%%%") then
            above_line = i
            break
        elseif i == 1 then
            above_line = 1 -- Beginning of buffer
        end
    end

    local line_count = vim.api.nvim_buf_line_count(0)
    if line_number ~= line_count then
        for i = line_number + 1, line_count do
            local local_line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
            if local_line:find("^%%%%") then
                bellow_line = i
                break
            elseif i == line_count then
                bellow_line = line_count -- Beginning of buffer
            end
        end
    else
        bellow_line = line_count
    end
    local lines = vim.api.nvim_buf_get_lines(0, above_line - 1, bellow_line, false)

    for _, line in ipairs(lines) do
        M.matlab_cli_run_command(line .. "\n")
    end

    return lines
end

M.matlab_open_workspace = function()
    M.matlab_cli_run_command("workspace;\n")
end

M.matlab_open_editor = function()
    -- Get the current buffer number
    local current_buffer = vim.fn.bufnr('%')
    local buffer_location = vim.api.nvim_buf_get_name(current_buffer)


    M.matlab_cli_run_command("edit('" .. buffer_location .. "');\n")
end

M.matlab_cli_clear = function()
    M.matlab_cli_run_command("clear;\n")
end

-- Function to check if the terminal buffer is closed
M._matlab_cli_running = function()
    return vim.api.nvim_buf_is_valid(M._cli_buff)
end


M.matlab_cli_cancel_operation = function()
    M.matlab_cli_run_command('\x03')
end


return M
