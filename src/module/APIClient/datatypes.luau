local datatype = {}
datatype.__index = datatype
local enums = require(script.Parent.enums)

export type blob = {
    mimeType: string,
    data:string, -- base 64 encoded
}

export type functionResponse = {
    name: string,
    response: {
        any
    },
}

export type functionCall = {
    name: string,
    args: {
        any
    }
}

export type functionDeclaration = {
    name: string,
    description: string,
    parameters: {
        any -- schema
    }?,
}

export type part = {
    text: string,
    inlineData: {
        blob
    },
    functionCall: {
        functionCall
    },
    functionResponse: {
        functionResponse
    },
}

export type content = {
    parts: {
        part
    },
    role: {"user" | "model"}?
}

export type generationConfig = {
    stopSequences: {string}?,
    responseMimeType: string?,
    responseSchema: {
        any
    }?,
    candidateCount: number?,
    maxOutputTokens: number?,
    temperature: number?,
    topP: number?,
    topK: number?,
    presencePenalty: number?,
    frequencyPenalty: number?,
    responseLogprobs: boolean?,
    logprobs: number?,
    enableEnhancedCivicAnswers: boolean?
}

export type model = {
    name: string,
    version: string,
    displayName: string,
    description: string,
    inputTokenLimit: number,
    outputTokenLimit: number,
    supportedGenerationMethods: {string},
    temperature: number,
    maxTemperature: number,
    topP: number,
    topK: number
}


export type functionCallingConfig = {
    mode: {"AUTO" | "ANY" | "NONE"},
    allowedFunctionNames: {string}?,
}

export type toolConfig = {
    functionCallingConfig: functionCallingConfig
}

export type tool = {
    functionDeclarations: {functionDeclaration},
}

export type requestData = {
    contents: {content},
    tools: {tool},
    toolConfig: {toolConfig},
    safetySettings: {safetySetting},
    systemInstruction: content,
    generationConfig: generationConfig,
}

export type usageMetadata = {
    promptTokenCount: number,
    cachedContentTokenCount: number,
    candidatesTokenCount: number,
    totalTokenCount: number
}

export type safetyRating = {
    category: enums.harmCategory,
    probability: enums.harmProbability,
    blocked: boolean,
}

export type safetySetting = {
    category: enums.harmCategory,
    threshold: enums.harmBlockThreshold,
}

export type promptFeedback = {
    blockReason: enums.blockReason?,
    safetyRatings: {safetyRating},
}

export type candidate = {
    content:  content,
    finishReason: enums.finishReason,
    safetyRatings: {safetyRating},
    tokenCount: number,
    avgLogProbs: number,
    index: number,
}

export type generateContentResponse = {
    candidates: {candidate},
    promptFeedback: promptFeedback,
    usageMetadata: usageMetadata,
    modelVersion: string,
}

export type functionDeclare = {-- non official structure type for lua usability
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

return datatype