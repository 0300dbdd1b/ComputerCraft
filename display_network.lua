
-- Display connected computers and their services on a monitor

local modemSide = "top" -- Adjust based on your setup
local monitorSide = "right" -- Adjust based on your setup
local refreshInterval = 5 -- Refresh interval in seconds

rednet.open(modemSide)

-- Ensure a monitor is connected
if not peripheral.isPresent(monitorSide) or peripheral.getType(monitorSide) ~= "monitor" then
    print("No monitor found on side: " .. monitorSide)
    return
end

local monitor = peripheral.wrap(monitorSide)
monitor.setTextScale(1) -- Adjust text scale for better visibility

local computers = {} -- Stores information about connected computers

-- Function to refresh the list of computers
local function refreshComputers()
    computers = {}
    rednet.broadcast({ type = "discovery_request" })
    local timer = os.startTimer(2) -- Listen for 2 seconds
    while true do
        local event, senderId, message = os.pullEvent()
        if event == "rednet_message" and type(message) == "table" and message.type == "advertisement" then
            computers[message.label] = { id = senderId, services = message.services }
        elseif event == "timer" and senderId == timer then
            break
        end
    end
end

-- Function to draw the information on the monitor
local function drawMonitor()
    monitor.clear()
    monitor.setCursorPos(1, 1)

    monitor.write("=== Connected Computers ===")
    local line = 2

    if next(computers) then
        for label, info in pairs(computers) do
            monitor.setCursorPos(1, line)
            monitor.write("Label: " .. label)
            line = line + 1
            monitor.setCursorPos(1, line)
            monitor.write("  ID: " .. info.id)
            line = line + 1
            monitor.setCursorPos(1, line)
            monitor.write("  Services: " .. table.concat(info.services, ", "))
            line = line + 2
        end
    else
        monitor.setCursorPos(1, line)
        monitor.write("No computers discovered.")
    end
end

-- Main loop
while true do
    refreshComputers()
    drawMonitor()
    sleep(refreshInterval)
end
