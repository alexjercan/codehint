<div align="center">

# CodeHint
##### Get the best hints for the bugs in your code.

[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.9+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)
</div>

![bugfix](./resources/example.png)

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

To setup the `codehint` plugin you need to specify the provider.

### OpenAI

In case you want to use openai (chatgpt) you need an OpenAI account
and an api key. Then you have to call the setup function for the plugin and
provide the api key in the input menu. Here is an example with the config:

```lua
require("codehint").setup({
    provider = "openai",
    args = {
        use_env = false,
        model = "gpt-3.5-turbo",
    },
})
```

- `use_env`: if true the plugin will attempt to read the api key from the
  `OPENAI_API_KEY` environment variable.
- `model`: can be `gpt-3.5-turbo` or `gpt4`

> **_NOTE:_** When using the OpenAI provider you will require to enter the
OpenAI API key. This will be requested the first time you call the hint
function. The key will be saved on the nvim path at
`~/.local/share/nvim/.openairc`. You could also set `use_env` to true to use
the `OPENAI_API_KEY` environment variable.

### Llama 2

In case you want to use an open source alternative you can use the `llama2`
provider.

```lua
require("codehint").setup({
    provider = "llama2",
    args = {
        use_eval = false,
    },
})
```

- `use_eval`: will attempt to execute the python code directly from the shell.

With `use_eval` **true** you will have to install `gradio_client` for Python.
This is a current limitation of using hf spaces instead of a dedicated server
for hosting llama2, but it is free.

```console
pip install gradio_client
```

With `use_eval` **false**, the way to use llama2 is to setup a wrapper server
using huggingface's spaces and `gradio_client`. I provide the code for it here

```python
from flask import Flask, request
from gradio_client import Client

app = Flask(__name__)


@app.route("/api/completions", methods=["POST"])
def completion():
    data = request.get_json()
    prompt = data["prompt"]

    client = Client("https://ysharma-explore-llamav2-with-tgi.hf.space/")
    result = client.predict(prompt, api_name="/chat_1")

    return result


if __name__ == "__main__":
    app.run()
```

To run the server you need to install the requirements and then run the script

```console
pip install flask gradio_client
python main.py
```

Then you will be able to use the server. Future plans include deploying such a
server to a hosting service.

## ⇁ Code Hints

To get the code hints open up the buggy source code file and call the `hint`
function:

```lua
:lua require("codehint").hint()
```

This should provide you with a diagnostic message that displays the hint for
your problem.

## ⇁ Vim Config

An example of config can be seen below. It just maps the `leader` + `h` keys to
call the hint function.

```lua
local codehint = require("codehint")

codehint.setup({
    provider = "openai",
    args = {
        use_env = false,
        model = "gpt-3.5-turbo",
    },
})

vim.keymap.set("n", "<leader>h", codehint.hint)
```
