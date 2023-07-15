<div align="center">

# CodeHint
##### Get the best hints for the bugs in your code.

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
</div>

![bugfix](example)

<div align="center">

[![IMAGE ALT TEXT](http://img.youtube.com/vi/0rjjgwFgHLU/0.jpg)](http://www.youtube.com/watch?v=0rjjgwFgHLU "AI Fixes Bugs")

The demo for the plugin is available on my [YouTube](https://www.youtube.com/channel/UCQfbjXwtGuJ-7hDMmAm1-rA) channel.

Note that the demo uses an older OpenAI model.

</div>

## ⇁ Installation
* neovim 0.9.0+ required
* curl 7.87.0+ required
* install using your favorite plugin manager (`packer` in this example)
```lua
use({'alexjercan/codehint'})
```

## ⇁ Setup

To setup the `codehint` plugin you need an OpenAI account and an api key. Then
you have to call the setup function for the plugin and provide the api key in
the input menu. Here is an example with the default values of the config:

```lua
require("codehint").setup({
    api = {
        model = "gpt-3.5-turbo",
        endpoint = "https://api.openai.com/v1/chat/completions",
        system_prompt = "Propose a hint that can help me fix the bug"
    },
    use_env = false,
})
```

## ⇁ Code Hints

To get the code hints open up the buggy source code file and call the `hint`
function:

```lua
:lua require("codehint").hint()
```

This should provide you with a diagnostic message that displays the hint for
your problem.

## ⇁ Tech

This plugin makes use of the Chat API from OpenAI and can use the
gpt-4, gpt-3.5-turbo models. We use the default values in the config, but this
can change in the future to allow users to tweak their experience.

The plugin works by using a system prompt on the Assistant to set the mood
_blushes_ as a debugger. Then it takes the text from the current buffer.  It
then uses the Chat API to get a response and shows it using the diagnostics
api.

## ⇁ Vim Config

An example of config can be seen below. It just maps the `leader` +
`h` keys to call the hint function. And it calls for setup on, which will
require the OpenAI API key to be entered. The key will be saved on the nvim
path at `~/.local/share/nvim/.codexrc`.

```lua
local codehint = require("codehint")

codehint.setup({
    api = {
        model = "gpt-3.5-turbo",
        endpoint = "https://api.openai.com/v1/chat/completions",
        system_prompt = "Propose a hint that can help me fix the bug"
    },
    use_env = false,
})

vim.keymap.set("n", "<leader>h", codehint.hint)
```

## ⇁ Limitations

* Tested only with gpt-3.5-turbo
* The hint does not contain information about the line/column yet
