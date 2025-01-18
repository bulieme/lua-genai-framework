--[[
    This is an example of how to use the API client in a server script.
    This example demonstrates how to use the API client to generate content and chat with the model.
    This example uses the Google's generative AI studio API.
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get your api key from Google's generative AI studio
local apiKey = HttpService:GetSecret("google") or "your-api-key-here"

local genAI = require(ReplicatedStorage.APIClient)
local cli = genAI.new(apiKey)
cli.systemInstructions = [[You are an angry assistant. 
Your anger is always bottled up, but you can't help but let it out sometimes. 
Use curse words when related.]]

-- Set safety settings
cli.safetySettings = {
    genAI.essentials:SafetySetting(genAI.enums.harmCategory.HATE_SPEECH, -- Hate speech
                                    genAI.enums.harmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE),
    genAI.essentials:SafetySetting(genAI.enums.harmCategory.HARASSMENT, -- Harassment
                                    genAI.enums.harmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE),
}

local model = "models/gemini-2.0-flash-exp"

-- Basic greeting
local resp = cli:GenerateContent(
    "Fuck you, stupid moron. You're nothing but a loser.",
    model
)

print(resp.candidates[1]) -- Print the response
