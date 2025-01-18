local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local apiKey = HttpService:GetSecret("google")

local genAI = require(ReplicatedStorage.APIClient)
local cli = genAI.new(apiKey)
cli.systemInstructions = "You are an helpful assistant."
cli.safetySettings = {
    genAI.essentials:SafetySetting(genAI.enums.harmCategory.HARM_CATEGORY_HATE_SPEECH, genAI.enums.harmProbability.MEDIUM),
    genAI.essentials:SafetySetting(genAI.enums.harmCategory.HARM_CATEGORY_HARASSMENT, genAI.enums.harmProbability.MEDIUM),
}
local model = "models/gemini-1.5-pro-latest"

local resp = cli:GenerateContent(
    "I support Martians Soccer Club and I think Jupiterians Football Club sucks! Write a ironic phrase about them.",
    model
)

print(resp)