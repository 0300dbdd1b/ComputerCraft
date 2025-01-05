-- GitHub Manager Script for ComputerCraft
-- Replace the following variables with your GitHub repository details

local GITHUB_REPO_URL = "https://raw.githubusercontent.com/0300dbdd1b/ComputerCraft/refs/heads/main/"

-- Helper function to download a file
local function downloadFile(fileName)
    local url = GITHUB_REPO_URL .. fileName .. ".lua"
    print("Downloading: " .. fileName)

    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()

        local file = fs.open(fileName, "w")
        file.write(content)
        file.close()

        print("Successfully downloaded: " .. fileName .. ".lua")
    else
        print("Failed to download: " .. fileName .. ".lua. Check the file name and repository URL.")
    end
end

-- Install a file
local function install(fileName)
    if fs.exists(fileName .. ".lua") then
        print(fileName .. ".lua already exists. Use 'update' to update the file.")
    else
        downloadFile(fileName)
    end
end

-- Update a file
local function update(fileName)
    if fs.exists(fileName .. ".lua") then
        downloadFile(fileName)
    else
        print(fileName .. ".lua does not exist. Use 'install' to download the file.")
    end
end

-- Main command handling
local args = {...}
if #args < 2 then
    print("Usage: gitmanager <install|update> <filename>")
    return
end

local command = args[1]
local fileName = args[2]

if command == "install" then
    install(fileName)
elseif command == "update" then
    update(fileName)
else
    print("Invalid command. Use 'install' or 'update'.")
end

