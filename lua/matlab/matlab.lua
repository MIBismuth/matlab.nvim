-- Lua script to send commands to MATLAB CLI

-- Define your MATLAB script
local matlabScript = [[
disp('Hello from MATLAB');
]]

-- Define your MATLAB commands
local matlabCommands = [[
a = 10
b = 20;
c = a + b;
disp(['The sum is: ', num2str(c)]);
]]

local matlabcommand2 = [[
d = c ^2;
disp(['d is: ', num2str(d)]);
]]

local exit = [[
exit
]]

local matlab_dir = "/usr/local/MATLAB/R2023b/bin/matlab"
-- Define the command to execute MATLAB with the script
local command = matlab_dir .. " -nodisplay -nosplash -nodesktop"

local handle = io.popen(command, "w")

local output = handle:write(matlabCommands)
local output = handle:write(matlabcommand2)
-- local output = handle:write(exit)
-- handle:close()
-- print(output)
--
--
-- Keep the handler open for further commands
while true do
    -- Read input command from the user
    local user_command = io.read()

    -- Break the loop if the command is "exit"
    if command == "exit" then
        break
    end

    -- Send the command to MATLAB
    handle:write(user_command .. "\n")
    handle:flush()
end

-- Close the handler and terminate MATLAB
handle:close()
