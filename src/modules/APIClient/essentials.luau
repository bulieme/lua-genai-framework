local essentials = {}

local datatype = require(script.Parent.datatypes)
local enums = require(script.Parent.enums)

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
    safetySettings:{datatype.safetySetting}?
):datatype.requestData
    local data:datatype.requestData = {
        contents = contents,
        generationConfig = generationConfig,
        systemInstruction = systemInstructions and ((typeof(systemInstructions) == "string") and {parts = {{text = systemInstructions}} } or systemInstructions) or nil,
    }

    return data
end

return essentials