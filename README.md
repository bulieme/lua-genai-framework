# Lua GenAI framework for roblox
Made with [Rojo](https://github.com/rojo-rbx/rojo) 7.4.4.

## Getting Started
Install rojo, and clone this repo.

After that, Build the module with this command: 
```shell
rojo build -o APIClient.rbxm  model.project.json
```

Drag the `APIClient.rbxm` into roblox studio and move it to Replicated storage.

After that, you're good to go.

## Todo's
- [x] Implement safety features
- [x] implement function call
  - [x] fixing some stuff, fixed the issue: not be able to remember past function calls.
- [x] json mode (structured output)
  - already fix some function calling issues when it not used. (no functions declared returns a bad 400 http request)
- use in production.