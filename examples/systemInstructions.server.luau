--[[
    This is an example of how to use the API client in a server script.
    This example demonstrates how to use the API client to generate content with the model.
    This example uses the Google's generative AI studio API.

    Here, we are using the systemInstructions property to set the system instructions for the model.
    The system instructions are used to provide additional context to the model about the conversation.
    In this example, we are setting the system instructions to "You are a assistant named robert."
    And asking them to ask for their name.
]]

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get your api key from Google's generative AI studio
local apiKey = HttpService:GetSecret("google") or "your-api-key-here"

local genAI = require(ReplicatedStorage.APIClient)
local cli = genAI.new(apiKey)
cli.systemInstruction = "You are a assistant named robert."

local model = "models/gemini-2.0-flash-exp"

local resp = cli:GenerateContent(
    "Hello! What is your name?",
    model
)

print(resp.candidates[1]) -- Print the response
