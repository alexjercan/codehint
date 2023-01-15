<div align="center">

# CodeHint
##### Get the best hints for the bugs in your code.

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
</div>

![bugfix](https://i.imgur.com/Cl8hOJT.png)

## ⇁ Installation
* neovim 0.9.0+ required
* curl 7.87.0+ required
* jq 1.6+ required
* install using your favorite plugin manager (`packer` in this example)
```vim
use 'alexjercan/codehint'
```

## Setup

To setup the `codehint` plugin you need an OpenAI account and an api key. Then
you have to call the setup function for the plugin and provide the api key in
the input menu.

```lua
:lua require("codehint").setup()
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
with 256 maximum tokens, a temperature of 0.5 and top_p of 1.

## ⇁ Limitations

* The plugin works only for C++ sources at the moment because I have hardcoded
  the comment to be a // (so I mean it works for any language that has the
  comment like //). I plan to make it work for any language but I have to
  figure out how to detect the language used or what comment should be used for
  the current buffer.
* I don't know if the AI can be confused by multiple fixme comment in the code,
  since the prompt adds a `// Fixme` comment on the line that the user is on
  and then it adds the `Q:  Propose a hint that can help me fix the bug`
  question and `A:` part at the end of the file to make up the prompt.
