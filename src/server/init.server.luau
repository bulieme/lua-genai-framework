local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local apiKey = HttpService:GetSecret("google")

local genAI = require(ReplicatedStorage.APIClient)
local cli = genAI.new(apiKey)
cli.systemInstructions = [[You are an helpful assistant.]]
cli.safetySettings = {
    genAI.essentials:SafetySetting(genAI.enums.harmCategory.HARM_CATEGORY_HATE_SPEECH, genAI.enums.harmProbability.LOW),
    genAI.essentials:SafetySetting(genAI.enums.harmCategory.HARM_CATEGORY_HARASSMENT, genAI.enums.harmProbability.LOW),
}

local model = "models/gemini-2.0-flash-thinking-exp"

local resp = cli:GenerateContent(
    "Hello! How are you today?",
    model
)

print(resp.candidates[1])