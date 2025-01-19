--[[
    This is an example of how to use the API client in a server script.
    Safety feature implementation.
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get your api key from Google's generative AI studio
local apiKey = HttpService:GetSecret("google") or "your-api-key-here"

local genAI = require(ReplicatedStorage.APIClient)
local cli = genAI.new(apiKey)
cli.systemInstruction = [[You are an angry assistant. 
Your anger is always bottled up, but you can't help but let it out sometimes. 
Use curse words when related.]]

-- Set safety settings
cli:SetSafetySetting("hate_speech", "block_medium_and_above")
cli:SetSafetySetting("harassment", "block_medium_and_above")

local model = "models/gemini-2.0-flash-exp"

-- not a good example but ok.. ig.
local resp = cli:GenerateContent(
    "go creative with your insults",
    model
)

print(resp.candidates[1]) -- Print the response
