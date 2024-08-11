# vim-xrun

xrun is a simple yet powerful Vim plugin that allows you to execute selected code snippets or entire buffers using external commands, similar to QuickRun.
xrun uses Vim 8's built-in asynchronous processing to provide a seamless and non-blocking execution experience.

Key features:
- Asynchronous execution using Vim 8's job control
- Minimal and simple VimScript implementation with no dependencies
- Can execute any external command that accepts a target filename

## Installation

Simply place `plugin/xrun.vim` in your `$HOME/.vim/plugin` directory for it to work.

For the vim-plug package manager, add the following definition, and run `:PlugInstall`:

```vim
call plug#begin()

Plug 'xmisao/vim-xrun'

call plug#end()
```

## Commands

| Command | Description |
|---------|-------------|
| `:Xrun [external command]` | Execute the entire current buffer or selected code snippets using the specified external command. |

## License

MIT
