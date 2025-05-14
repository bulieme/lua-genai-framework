local HttpService = game:GetService("HttpService")
local essentials = {}

local datatype = require(script.Parent.datatypes)
local enums = require(script.Parent.enums)

function essentials.countTable(t)
    local i = 0 for _ in pairs(t) do i += 1 end
    return i
end

function essentials:functionDeclaration2Schema(declaration: datatype.functionDeclare): {any}?
    local templateSchema:datatype.functionDeclare = {
        name = "",
        description = ""
    }
    
    templateSchema.name = declaration.name
    templateSchema.description = declaration.description

    if declaration.args and countTable(declaration.args) > 0 then
        templateSchema.parameters = { type = "object", properties = {}, required = {} }
        for argName, argData in pairs(declaration.args) do
            templateSchema.parameters.properties[argName] = {
                type = argData.type,
                description = argData.description
            }
            if argData.required then
                table.insert(templateSchema.parameters.required, argName)
            end
        end
    end
    return templateSchema
end

function essentials:makeGenerationConfig(temperature:number?, 
                                         topP:number?,
                                         topK:number?,
                                         stopSequences:{string?},
                                         responseSchema:{any}?,
                                         responseMimeType:string?,
                                         candidateCount:number?,
                                         maxOutputTokens:number?
                                     ): datatype.generationConfig
    return {
        stopSequences = stopSequences or nil,
        responseMimeType = responseMimeType or "text/plain",
        responseSchema = responseSchema or nil,
        candidateCount = candidateCount or 1,
        maxOutputTokens = maxOutputTokens or nil,
        temperature = temperature or 1.0,
        topP = topP or nil,
        topK = topK or nil,
    }
end

function essentials:SafetySetting(
    category:string,
    threshold:string
):datatype.safetySetting
    return {
        category = category,
        threshold = threshold
    }
end


function essentials:makeRequestData(
    contents:datatype.content,
    generationConfig:datatype.generationConfig?,
    systemInstructions:{datatype.content | string}?,
    safetySettings:{datatype.safetySetting}?,
    tools:{datatype.tool}?,
    toolConfig:{datatype.toolConfig}?
):datatype.requestData
    local data:datatype.requestData = {
        contents = contents,
        tools = tools or nil,
        toolConfig = toolConfig or nil,
        safetySettings = safetySettings or nil,
        generationConfig = generationConfig or nil,
        systemInstruction = systemInstructions and ((typeof(systemInstructions) == "string") and {parts = {{text = systemInstructions}} } or systemInstructions) or nil,
    }

    return data
end

return essentials