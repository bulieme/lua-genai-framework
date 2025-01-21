--[[
    This is an example of how to use the API client in a server script.
    This example demonstrates how to use the function call feature available in the API client.
    This example uses the Google's generative AI studio API.
    This script makes a part, then position at Vector3.new(0,2,0). and make it glow.
    use this script on a baseplate, and a spawnpoint positioned near 0,0 on x and z.
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get your api key from Google's generative AI studio
local apiKey = HttpService:GetSecret("google") or "your-api-key-here"

local genAI = require(ReplicatedStorage.APIClient)
local datatypes = genAI.datatype
local cli = genAI.new(apiKey)

local model = "models/gemini-2.0-flash-exp"

local ledPower = false

-- make a part
local led = Instance.new("Part")
led.BrickColor = BrickColor.Red()
led.Parent = workspace
led.Anchored = true
led.Size = Vector3.new(1,1,1)
led.CFrame = CFrame.new(0, 2, 0)

function setLEDPower(a)
    ledPower = a.power
    if ledPower then
        led.Material = Enum.Material.Neon
    else
        led.Material = Enum.Material.Plastic
    end
    return {
        power = ledPower
    }
end

local declaredFunction:datatypes.functionDeclare = {
    name = "setLEDState",
    description = "sets the LED state",
    args = {
        power = {
            type = "boolean",
            description = "Sets the current state of the LED",
            required = true
        }
    },
    callbackFunction = setLEDPower -- make sure its the right function
}

cli:RegisterFunction(declaredFunction)

local chat = cli:newChat()

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        chat:Chat(msg, "user")
        print(chat:GenerateResponse(model, true).candidates[1].content.parts[1].text)
    end)
end)