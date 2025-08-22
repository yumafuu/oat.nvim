# oat.nvim

Custom operators for opening files and URLs in Neovim.

## Features

- `go{motion}` - Open URL directly or search text on Google
- `gg{motion}` - Open GitHub repository or search repositories
- `goo` / `ggg` - Operate on word under cursor
- Visual mode support
- Fully customizable operators
- Built-in smart URL detection

## Installation

### lazy.nvim
```lua
{
  'yumafuu/oat.nvim',
  config = function()
    require('oat').setup()
  end
}
```

### packer.nvim
```lua
use {
  'yumafuu/oat.nvim',
  config = function()
    require('oat').setup()
  end
}
```

## Usage

- `go{motion}` - Open URL directly or search on Google (e.g., `goiw` for word, `go$` for line end)
- `goo` - Open URL or search word under cursor on Google
- `gg{motion}` - Open GitHub repo or search (e.g., `ggiw` for word)
- `ggg` - Open GitHub repo or search word under cursor

**Smart URL Detection:**
- URLs (http/https) are opened directly
- Other text is searched on Google/GitHub

In visual mode, just use `go` or `gg` on selected text.

## Configuration

```lua
require('oat').setup({
  prefix = "g",  -- Change prefix key (default: "g")
  operators = {
    o = {
      name = "search",
      command = function(text)
        return "open 'https://www.google.com/search?q=" .. text .. "'"
      end,
      description = "Search on Google"
    },
    g = {
      name = "github",
      command = function(text)
        return "open https://github.com/" .. text
      end,
      description = "Open GitHub repository"
    },
    c = {
      name = "gpt",
      interactive = true,  -- Enable interactive mode
      command = function(text)
        local encoded_text = vim.fn.substitute(text, ' ', '%20', 'g')
        local url = "https://chat.com/?q=" .. encoded_text
        return "open " .. vim.fn.shellescape(url)
      end,
      description = "Chat with GPT"
    }
  }
})
```

### Interactive Operators

Set `interactive = true` to show a popup for additional input:

```lua
require('oat').add_operator('s', {
  name = "search",
  interactive = true,
  command = function(text)
    return "open 'https://google.com/search?q=" .. vim.fn.shellescape(text) .. "'"
  end,
  description = "Interactive search"
})
```

### Custom Prefix

```lua
-- Use <leader> as prefix instead of "g"
require('oat').setup({
  prefix = "<leader>",
})

-- Now use <leader>o{motion} and <leader>g{motion}
```

### Adding Custom Operators

```lua
-- Add file open operator
require('oat').add_operator('f', {
  name = "file",
  command = "open",
  description = "Open file with system default"
})

-- Now you can use gf{motion} or gff
```

## License

MIT

https://github.com/folke/flash.nvim/releases/tag/v2.1.0
