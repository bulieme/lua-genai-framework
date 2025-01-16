local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local apiKey = HttpService:GetSecret("google")

local genAI = require(ReplicatedStorage.Client)
local cli = genAI.new(apiKey)
cli.systemInstructions = "You are an helpful assistant named Robert."

local response = cli:GenerateContent("Introduce yourself", "models/gemini-1.5-pro-latest")
print(response)