
-- Universal ComputerCraft Script with Label-Based Targeting
local modemSide = "top" -- Adjust based on your setup
rednet.open(modemSide)

-- Define the services supported by this computer
local services = { "serviceA", "serviceB" } -- Add "emitter" here if this computer can broadcast commands

-- Ensure the computer has a label
local label = os.getComputerLabel()
if not label then
    print("Please set a label for this computer using 'os.setComputerLabel(label)'")
    return
end

-- Function to advertise services
local function advertiseServices()
    local message = {
        type = "advertisement",
        label = label,
        id = os.getComputerID(),
        services = services
    }
    rednet.broadcast(message)
end

-- Function to broadcast a command (only for emitters)
local function broadcastCommand(command, targets)
    if not table.concat(services):find("emitter") then
        print("This computer does not support the 'emitter' service.")
        return
    end
    local message = {
        type = "command",
        label = label,
        id = os.getComputerID(),
        command = command,
        targets = targets -- List of target labels, "all" for all, or empty for none
    }
    rednet.broadcast(message)
    print("Command broadcasted to:", targets == "all" and "all computers" or table.concat(targets, ", "))
end

-- Function to handle incoming messages
local function handleMessage(senderId, message)
    if type(message) ~= "table" then return end

    if message.type == "advertisement" then
        -- Print advertisement info (optional)
        print("Received advertisement from:", message.label, "(ID:", senderId .. ")")
        print("Services:", table.concat(message.services, ", "))
    elseif message.type == "command" then
        -- Check if this computer is a target
        local isTargeted = message.targets == "all" or (type(message.targets) == "table" and table.concat(message.targets):find(label))
        if isTargeted then
            print("Executing command from emitter:", message.label)
            local success, err = pcall(load(message.command))
            if not success then
                print("Error executing command:", err)
            end
        else
            print("Command not intended for this computer. Ignoring...")
        end
    end
end

-- Main loop
local function main()
    print("Starting...")
    -- Advertise services periodically
    parallel.waitForAny(
        function() -- Periodic advertisement
            while true do
                advertiseServices()
                sleep(5) -- Adjust the interval for service broadcasts
            end
        end,
        function() -- Listen for messages
            while true do
                local event, senderId, message, _ = os.pullEvent("rednet_message")
                if event == "rednet_message" then
                    handleMessage(senderId, message)
                end
            end
        end,
        function() -- Emitter mode (optional)
            if table.concat(services):find("emitter") then
                print("Emitter mode enabled. Type commands to broadcast.")
                while true do
                    io.write("Enter command: ")
                    local command = read()
                    io.write("Enter target labels (comma-separated, or 'all', or 'none'): ")
                    local targetsInput = read()

                    -- Parse targets
                    local targets
                    if targetsInput == "all" then
                        targets = "all"
                    elseif targetsInput == "none" then
                        targets = {}
                    else
                        targets = {}
                        for targetLabel in string.gmatch(targetsInput, "[^,]+") do
                            table.insert(targets, targetLabel:match("^%s*(.-)%s*$")) -- Trim spaces
                        end
                    end

                    -- Broadcast the command
                    if command and #command > 0 then
                        broadcastCommand(command, targets)
                    end
                end
            end
        end
    )
end

main()
