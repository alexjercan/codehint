<div align="center">

# CodeHint
##### Get the best hints for the bugs in your code.

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
</div>

![bugfix](https://i.imgur.com/Cl8hOJT.png)

<div align="center">

[![IMAGE ALT TEXT](http://img.youtube.com/vi/0rjjgwFgHLU/0.jpg)](http://www.youtube.com/watch?v=0rjjgwFgHLU "AI Fixes Bugs")

The demo for the plugin is available on my [YouTube](https://www.youtube.com/channel/UCQfbjXwtGuJ-7hDMmAm1-rA) channel.

</div>

## ⇁ Installation
* neovim 0.9.0+ required
* curl 7.87.0+ required
* install using your favorite plugin manager (`packer` in this example)
```lua
use({
    'alexjercan/codehint',
    requires = { { 'nvim-treesitter/nvim-treesitter' } }
})
```

## ⇁ Setup

To setup the `codehint` plugin you need an OpenAI account and an api key. Then
you have to call the setup function for the plugin and provide the api key in
the input menu. Here is an example with the default values of the config:

```lua
require("codehint").setup({
    max_tokens = 256,
    temperature = 0.5,
    top_p = 1,
    use_print = false,
})
```

## ⇁ Code Hints

To get the code hints open up the buggy source code file, go to the line that
causes the problems and call the `hint` function:

```lua
:lua require("codehint").hint()
```

This should provide you with a Q&A message that displays the hint for your problem.

## ⇁ Tech

This plugin makes use of the Codex API from OpenAI and uses the
code-davinci-002 model. I have setup the default parameters from the playground,
with 256 maximum tokens, a temperature of 0.5 and top_p of 1. The `use_print`
option is used to decide wheater to use the print call and show the output in
the command window or to use floats and show the option similar to LSP
messages.

The plugin works by taking the text from the current buffer. Then it adds a
comment with the string `Fixme` on the line where the cursor is. And then it
adds the `Q:  Propose a hint that can help me fix the bug` question and `A:`
part at the end of the file to make up the prompt. It then uses the CodexAPI to
get a response and shows it.

The plugin uses [tree-sitter](https://tree-sitter.github.io/tree-sitter/) to
identify the programming langauge and use the correct comment.

## ⇁ Vim Config

An example of config can be seen below. It just maps the `leader` +
`h` keys to call the hint function. And it calls for setup on, which will
require the OpenAI API key to be entered. The key will be saved on the nvim
path at `~/.local/share/nvim/.codexrc`.

```lua
local codehint = require("codehint")

codehint.setup({
    max_tokens = 256,
    temperature = 0.5,
    top_p = 1,
    use_print = false,
})

vim.keymap.set("n", "<leader>h", codehint.hint)
```

## ⇁ Limitations

* I don't know if the AI can be confused by multiple fixme comment in the code,
  since the prompt adds a `// Fixme` comment in the code as part of the prompt.
