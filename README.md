# exrc.nvim

Local config file with confirmation for Neovim.

## Requirements

- [`MunifTanjim/nui.nvim`](https://github.com/MunifTanjim/nui.nvim)

## Installation

Install the plugins with your preferred plugin manager. For example, with [`vim-plug`](https://github.com/junegunn/vim-plug):

```vim
Plug 'MunifTanjim/nui.nvim'
Plug 'MunifTanjim/exrc.nvim'
```

## Setup

`exrc.nvim` needs to be initialized with the `require("exrc").setup()` function.

For example:

```lua
-- disable built-in local config file support
vim.o.exrc = false

require("exrc").setup({
  files = {
    ".nvimrc.lua",
    ".nvimrc",
    ".exrc.lua",
    ".exrc",
  },
})
```

## Commands

### `ExrcSource`

Re-source exrc file:

```vim
:ExrcSource
```

Reset state and re-source exrc file:

```vim
:ExrcSource!
```

## Similar Projects

- [`ii14/exrc.vim`](https://github.com/ii14/exrc.vim)
- [`jenterkin/vim-autosource`](https://github.com/jenterkin/vim-autosource)
- [`krisajenkins/vim-projectlocal`](https://github.com/krisajenkins/vim-projectlocal)
- [`LucHermitte/local_vimrc`](https://github.com/LucHermitte/local_vimrc)
- [`windwp/nvim-projectconfig`](https://github.com/windwp/nvim-projectconfig)

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.
