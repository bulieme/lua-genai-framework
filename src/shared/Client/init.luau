local HttpService = game:GetService("HttpService")
local datatype = require(script.datatypes)
local enums = require(script.enums)
local essentials = require(script.essentials)

type client = {
    api: Secret | string,
    baseUrl: string,
    generationConfig: datatype.generationConfig,
    systemInstructions: datatype.content,
    safetySettings: {datatype.safetySetting}
}

local cli = {}
cli.__index = cli
cli.datatype = datatype
cli.enums = enums
cli.essentials = essentials

--[[
Create a brand new client.
<code>api: (Secret | string) </code>: Your api key. for the client instance.
]]
function cli.new(api: Secret|string)
    local _cli:client = {
        api = api,
        baseUrl = "https://generativelanguage.googleapis.com/v1beta/",
        generationConfig = essentials:makeGenerationConfig(),
        systemInstructions = "",
    }
    setmetatable(_cli, cli)
    return _cli
end

-- endpoint: https://generativelanguage.googleapis.com/v1beta/{model=models/*}:generateContent

--[[
List all models.
]]
function cli:getModels():{datatype.model?}
    local endpoint = self.baseUrl .."models/"
    if type(self.api) == "string" then
        endpoint = endpoint .. "?key=" .. self.api
    else
        local api:Secret = self.api
        endpoint = api:AddPrefix(endpoint.."?key=")
    end
    local success, response = pcall(function()
        return HttpService:GetAsync(endpoint)
    end)
    if success then
        local resp:{models:{datatype.model?}} = HttpService:JSONDecode(response)
        return resp.models
    else
        error("Failed to get models: " .. response)
        return nil
    end
end

local function contains(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

function cli:_findModelInfo(modelID: string):datatype.model?
    local models = self:getModels()
    for _, model in ipairs(models) do
        if model.name == modelID:lower()  then
            return model
        end
    end
    return nil
end

local function makeGenerationConfigFromModelObject(generationConfig:datatype.generationConfig?, model:datatype.model
    ):datatype.generationConfig
    return {
        stopSequences = generationConfig.stopSequences,
        responseMimeType = generationConfig.responseMimeType,
        responseSchema = generationConfig.responseSchema,
        candidateCount = generationConfig.candidateCount,
        maxOutputTokens = generationConfig.maxOutputTokens and 
        math.min(math.max(generationConfig.maxOutputTokens, 0), model.outputTokenLimit) 
        or model.outputTokenLimit,
        temperature = math.min(math.max(generationConfig.temperature, 0), model.maxTemperature),
        topP = generationConfig.topP or model.topP,
        topK = generationConfig.topK or model.topK,
    }
end

--[[
Generate a new content.
<code>contents: string</code>: The text to be send with.
<code>model: string</code>: The model used for generating the content.
]]
function cli:GenerateContent(contents:string|datatype.content, model:string): datatype.generateContentResponse
    local modelInfo = self:_findModelInfo(model)
    if contains(modelInfo.supportedGenerationMethods, "generateContent") then
        local conf = makeGenerationConfigFromModelObject(self.generationConfig, modelInfo)
        local endpoint = self.baseUrl .. modelInfo.name .. ":generateContent"
        if type(self.api) == "string" then
            endpoint = endpoint .. "?key=" .. self.api
        else
            local api:Secret = self.api
            endpoint = api:AddPrefix(endpoint.."?key=")
        end

        -- Needed rework on content system
        local contents:datatype.content = {{
            parts = {
                {
                    text = text,
                }
            }
        }}

        local data = essentials:makeRequestData(contents, conf, self.systemInstructions, self.safetySettings)
        local success, response = pcall(function()
            return HttpService:PostAsync(endpoint, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
        end)
        if success then
            local resp:datatype.generateContentResponse = HttpService:JSONDecode(response)
            return resp
        else
            error("Failed to generate content: " .. response)
            return nil
        end
    else
        error("Model does not support generateContent: ".. model)
    end
end

return cli