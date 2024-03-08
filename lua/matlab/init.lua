M = {}

M.test = function()
    print("Test Successful")
end


M.open_buffer = function()
    -- Get the current buffer number
    local current_buffer = vim.fn.bufnr('%')

    -- Open a new buffer
    vim.cmd('vnew')

    -- Resize the new buffer to take up 50% of the screen width
    vim.cmd('vertical resize 50')

    -- Get the buffer number of the newly opened buffer
    local new_buffer = vim.fn.bufnr('%')

    return new_buffer
end

M.open_matlab_window = function()
    local matlab_dir = "/usr/local/MATLAB/R2023b/bin/matlab"
    -- Define the command to execute MATLAB with the script
    local command = matlab_dir .. " -nodisplay -nosplash -nodesktop"
    -- local command = "ls"

    local mat_buffer = M.open_buffer()

    -- Execute commands in the terminal
    local job_id = vim.fn.termopen(command)
    if job_id <= 0 then
        print("Error opening terminal")
    end

    M._job_id = job_id
end

M.send_commands = function(command)
    vim.api.nvim_chan_send(M._job_id, command)
end

M.send_line_under_cursor = function()
    local line_content = vim.api.nvim_get_current_line()
    -- Print the captured line
    M.send_commands(line_content .. "\n")
end

M.send_visual_selection_lines = function()
    local vstart = vim.fn.getpos("'<")

    local vend = vim.fn.getpos("'>")

    local line_start = vstart[2]
    local line_end = vend[2]

    -- or use api.nvim_buf_get_lines
    local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)

    for _, line in ipairs(lines) do
        M.send_commands(line .. "\n")
    end
    return lines
end


M.send_block = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line_number = cursor[1]

    local above_line = nil
    local bellow_line = nil

    for i = line_number, 1, -1 do
        local local_line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]
        if local_line:find("^%%") then
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
            if local_line:find("^%%") then
                bellow_line = i
                break
            elseif i == line_count then
                bellow_line = line_count -- Beginning of buffer
            end
        end
    else
        bellow_line = line_count
    end
    lines = vim.api.nvim_buf_get_lines(0, above_line - 1, bellow_line, false)

    for _, line in ipairs(lines) do
        M.send_commands(line .. "\n")
    end

    return lines
end

local job_id = M.open_matlab_window()

return M
