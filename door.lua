-- Door Control Script

-- Configuration
local redstoneSide = "back" -- Side where the redstone is connected
local openIsOn = true -- Set to true if "open" corresponds to "on", false otherwise

-- Function to set the redstone output
local function setRedstone(state)
    redstone.setOutput(redstoneSide, state)
end

-- Function to control the door
local function controlDoor(action)
    if action == "open" then
        setRedstone(openIsOn)
        print("Door is now open.")
    elseif action == "close" then
        setRedstone(not openIsOn)
        print("Door is now closed.")
    else
        print("Invalid action. Use 'open' or 'close'.")
    end
end

-- Main script execution
local args = { ... }
if #args ~= 1 then
    print("Usage: open_door <open|close>")
    return
end

local action = args[1]
controlDoor(action)
 
