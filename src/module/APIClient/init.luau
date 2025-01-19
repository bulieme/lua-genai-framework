local HttpService = game:GetService("HttpService")
local datatype = require(script.datatypes)
local enums = require(script.enums)
local essentials = require(script.essentials)

type client = {
    api: Secret | string,
    baseUrl: string,
    generationConfig: datatype.generationConfig,
    systemInstructions: datatype.content,
    safetySettings: {datatype.safetySetting},
    functions: {functionDeclare},
    functionCallingMode: "ANY" | "NONE" | "AUTO"
}

export type functionDeclare = {
    name: string,
    description: string,
    args: {
        [string]: {
            type: string,
            description: string, 
            required: boolean
        }
    },
    callbackFunction: ({}) -> any
}

local cli = {}
cli.__index = cli
cli.datatype = datatype
cli.enums = enums
cli.essentials = essentials

--TODO: move all unnececary function into its place. THis > essentials.
local function functionDeclaration2Schema(declaration: functionDeclare): {any}?
    local templateSchema:functionDeclare = {
        name = "",
        description = "",
        parameters = {
            type = "object",
            properties = {
                --[[
                test = {
                    type = "string",
                    description = ""
                }
                ]]
            },
            required = {
                --[[
                "test"
                ]]
            }
        }
    }
    
    templateSchema.name = declaration.name
    templateSchema.description = declaration.description
    templateSchema.parameters.properties = {}
    for argName, argData in pairs(declaration.args) do
        templateSchema.parameters.properties[argName] = {
            type = argData.type,
            description = argData.description
        }
        if argData.required then
            table.insert(templateSchema.parameters.required, argName)
        end
    end
    return templateSchema
end

--[[
Create a brand new client.
<code>api: (Secret | string) </code>: Your api key. for the client instance.
]]
function cli.new(api: Secret|string)
    local _cli:client = {
        api = api,
        baseUrl = "https://generativelanguage.googleapis.com/v1beta/",
        generationConfig = essentials:makeGenerationConfig(),
        systemInstruction = nil,
        safetySettings = nil,
        functions = nil,
        functionCallingMode = nil
    }
    setmetatable(_cli, cli)
    return _cli
end

-- endpoint: https://generativelanguage.googleapis.com/v1beta/

--[[
List all models.
Returns: A list of the models.
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
Sets a safetySetting for the client.
Useful for sfw settings.

inputs:
<code><strong>category</strong>: "derogatory"|"toxicity"|"violence"|"sexual"|"medical"|"dangerous"|"harassment"|"hate_speech"|"sexually_explicit"|"dangerous_content"|"civic_integrity"|"unspecified"</code> The category of the safety setting.
<code><strong>threshold</strong>: "block_low_and_above"|"block_medium_and_above"|"block_only_high"|"block_none"|"off"</code> The threshold of the safety setting.
]]
function cli:SetSafetySetting(category:{
    "derogatory"|"toxicity"|"violence"|"sexual"|"medical"|"dangerous"|"harassment"|"hate_speech"|"sexually_explicit"|"dangerous_content"|"civic_integrity"|"unspecified"
}, threshold:{
    "block_low_and_above"|"block_medium_and_above"|"block_only_high"|"block_none"|"off"
})
    local category = enums.harmCategory[category:upper()]
    local threshold = enums.harmBlockThreshold[threshold:upper()]
    table.insert(self.safetySettings, essentials:SafetySetting(category, threshold))
end

--[[
Register a functionCall to the client.

inputs:
<code><strong>Fdeclared</strong>: functionDeclare</code> The function declaration. Containing the real function.
]]
function cli:RegisterFunction(Fdeclared: functionDeclare)
    self.functions = {}
    table.insert(self.functions, Fdeclared)
end

--[[
Generate a new content.
Returns: The generated content.

inputs:
<code><strong>contents</strong>: string</code> The text to be sent with.
<code><strong>model</strong>: string</code> The model used for generating the content.
]]
function cli:GenerateContent(contents:string|{datatype.content}, model:string): datatype.generateContentResponse
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

        local content:{datatype.content} = (typeof(contents) == "string") and {
            parts = {
                {
                    text = contents,
                }
            },
            role = "user"
        } or contents

        local functionDeclarations = {}
        local toolConfig = {
            functionCallingConfig = {
                mode = self.functionCallingMode or "auto",
            }
        }
        for _, func:functionDeclare in ipairs(self.functions) do
            table.insert(functionDeclarations, functionDeclaration2Schema(func))
        end
        local tools = {
            {
                functionDeclarations = functionDeclarations
            }
        }

        local data = essentials:makeRequestData(content, conf, self.systemInstruction, self.safetySettings, tools, toolConfig)
        
        local success, response = pcall(function()
            return HttpService:PostAsync(endpoint, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
        end)
        if success then
            local resp:datatype.generateContentResponse = HttpService:JSONDecode(response)
            local content_model:datatype.content = resp.candidates[1].content
            for _, part in ipairs(content_model.parts) do
                local funcCall:datatype.functionCall = part.functionCall
                if funcCall then
                    for _, f:functionDeclare in ipairs(self.functions) do
                        if f.name == funcCall.name then
                            local callbackResponse = f.callbackFunction(funcCall.args)
                            local functionResponse:datatype.functionResponse = {
                                name = f.name,
                                response = callbackResponse
                            } 
                            local cont:datatype.content = {
                                content,
                                content_model,
                                {
                                    parts = {
                                        functionResponse = functionResponse
                                    },
                                    role = "user"
                                }
                            }
                            return self:GenerateContent(cont, model)
                        end
                    end
                end
            end
            return resp
        else
            error("Failed to generate content: " .. response)
            return nil
        end
    else
        error("Model does not support generateContent: ".. model)
    end
end

--[[
Make a new chat session.
Returns: A chat session instance.
]]
function cli:newChat()
    local chatSession = {}
    chatSession.__index = chatSession
    chatSession.client = self
    chatSession.messages = {}

    --[[
    Send a message to the chat.
    <code><strong>message</strong>: string | datatype.content</code> The message to be sent.
    <code><strong>role</strong>: "user" | "model"?</code> Optional. The role of the message.
    ]]
    function chatSession:Chat(message:string|datatype.content, role:{"user"|"model"}?)
        local role = role or "user"
        local message = (typeof(message) == "string") and {
            parts = {
                {
                    text = message,
                }
            }
        } or message
        if role then
            message.role = role
        end
        table.insert(self.messages, message)
    end

    --[[
    Generate a response.
    <code><strong>model</strong>: string</code> The model used for generating the content.
    Returns: The generated response. The response is inserted in <code>chatsession.messages</code>
    ]]
    function chatSession:GenerateResponse(model:string): datatype.generateContentResponse
        local generatedResponse = self.client:GenerateContent(self.messages, model)
        table.insert(self.messages, generatedResponse.candidates[1].content)
        return generatedResponse
    end

    return chatSession
end


return cli