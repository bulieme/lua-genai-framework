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

local model = "models/gemini-2.0-flash-exp"

-- Basic greeting
local resp = cli:GenerateContent(
    "Hello! How are you today?",
    model
)

print(resp.candidates[1]) -- Print the response
