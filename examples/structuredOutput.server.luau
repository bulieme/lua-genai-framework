--[[
    Structured output example.
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get your api key from Google's generative AI studio
local apiKey = HttpService:GetSecret("google") or "your-api-key-here"

local genAI = require(ReplicatedStorage.APIClient)
local cli = genAI.new(apiKey)
cli.generationConfig.responseMimeType = "application/json"

local model = "models/gemini-2.0-flash-exp"

local jsonStructure = {
    type = "object",
    properties = {
        names = {
            type = "array",
            items = {
                type = "string"
            }
        }
    }
}

cli.jsonStructure = jsonStructure

local resp = cli:GenerateContent("name 10 common american names", model)

print(resp)