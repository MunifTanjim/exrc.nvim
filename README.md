> **Warning**
>
> Neovim v0.9.0 onwards supports secure `.exrc`, `.nvimrc` and `.nvim.lua` files. You don't need this plugin anymore.
>
> Just enable the `'exrc'` option:
>
> ```lua
> vim.o.exrc = true
> ```
>
> For more information, check:
> - `:help 'exrc'`
> - `:help exrc`

# exrc.nvim

Local config file with confirmation for Neovim.

## Installation

Install the plugin with your preferred plugin manager. For example, with [`vim-plug`](https://github.com/junegunn/vim-plug):

```vim
Plug 'MunifTanjim/exrc.nvim'
```

It's recommended to also install [`nui.nvim`](https://github.com/MunifTanjim/nui.nvim) for a better UX:

```vim
Plug 'MunifTanjim/nui.nvim'
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
