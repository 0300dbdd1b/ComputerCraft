
-- Pocket Computer UI for Sending Commands and Listing Computers

local modemSide = "back"
rednet.open(modemSide)

local computers = {} -- Stores discovered computers
local selectedTargets = {} -- Selected target computers for commands

-- Helper function to refresh the list of computers
local function refreshComputers()
    computers = {}
    rednet.broadcast({ type = "discovery_request" })
    print("Refreshing computers... Listening for responses.")
    local timer = os.startTimer(2) -- Listen for 2 seconds
    while true do
        local event, senderId, message = os.pullEvent()
        if event == "rednet_message" and type(message) == "table" and message.type == "advertisement" then
            computers[message.label] = senderId
        elseif event == "timer" and senderId == timer then
            break
        end
    end
    print("Computers discovered:")
    for label, _ in pairs(computers) do
        print(" - " .. label)
    end
end

-- Helper function to draw the UI
local function drawUI()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== Pocket Computer Command Center ===")
    print("1. Refresh Computers")
    print("2. List Computers")
    print("3. Select Targets")
    print("4. Send Command")
    print("5. Exit")
end

-- Function to list discovered computers
local function listComputers()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== Discovered Computers ===")
    if next(computers) then
        for label, _ in pairs(computers) do
            print("- " .. label)
        end
    else
        print("No computers discovered.")
    end
    print("\nPress any key to return.")
    os.pullEvent("key")
end

-- Function to select target computers
local function selectTargets()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== Select Targets ===")
    print("Available Computers:")
    selectedTargets = {}
    local labels = {}
    local i = 1
    for label, _ in pairs(computers) do
        labels[i] = label
        print(i .. ". " .. label)
        i = i + 1
    end
    print("\nEnter the numbers of computers to target (comma-separated), or type 'all':")
    local input = read()
    if input == "all" then
        selectedTargets = "all"
    else
        for num in string.gmatch(input, "%d+") do
            local index = tonumber(num)
            if labels[index] then
                table.insert(selectedTargets, labels[index])
            end
        end
    end
    print("\nSelected Targets:")
    if selectedTargets == "all" then
        print("All Computers")
    else
        for _, label in ipairs(selectedTargets) do
            print("- " .. label)
        end
    end
    print("\nPress any key to return.")
    os.pullEvent("key")
end

-- Function to send a command
local function sendCommand()
    term.clear()
    term.setCursorPos(1, 1)
    print("=== Send Command ===")
    if not next(computers) then
        print("No computers available. Refresh first.")
        print("\nPress any key to return.")
        os.pullEvent("key")
        return
    end

    if not next(selectedTargets) and selectedTargets ~= "all" then
        print("No targets selected. Please select targets first.")
        print("\nPress any key to return.")
        os.pullEvent("key")
        return
    end

    print("Enter the command to send:")
    local command = read()
    local targets = selectedTargets == "all" and "all" or {}
    if selectedTargets ~= "all" then
        for _, label in ipairs(selectedTargets) do
            table.insert(targets, label)
        end
    end

    rednet.broadcast({
        type = "command",
        label = os.getComputerLabel() or "Pocket",
        id = os.getComputerID(),
        command = command,
        targets = targets
    })

    print("Command sent to targets:")
    if selectedTargets == "all" then
        print("All Computers")
    else
        for _, label in ipairs(selectedTargets) do
            print("- " .. label)
        end
    end
    print("\nPress any key to return.")
    os.pullEvent("key")
end

-- Main menu loop
local function main()
    while true do
        drawUI()
        local choice = read()
        if choice == "1" then
            refreshComputers()
        elseif choice == "2" then
            listComputers()
        elseif choice == "3" then
            selectTargets()
        elseif choice == "4" then
            sendCommand()
        elseif choice == "5" then
            break
        else
            print("Invalid choice. Please try again.")
            sleep(1)
        end
    end
end

-- Start the UI
main()
