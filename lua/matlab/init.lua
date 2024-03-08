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

    -- Focus on the new buffer
    vim.cmd('wincmd h')

    -- Get the buffer number of the newly opened buffer
    local new_buffer = vim.fn.bufnr('%')

    -- Print the buffer numbers
    -- print('Current Buffer: ' .. current_buffer)
    -- print('New Buffer: ' .. new_buffer)
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

local job_id = M.open_matlab_window()

local matlabCommands = [[
a = 10
b = 20;
c = a + b;
disp(['The sum is: ', num2str(c)]);
]]

local test = "a = 10"


return M
