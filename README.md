# Pug

_General utility plugin management_

Pug is a general-purpose plugin manager for command-line utilities. This currently includes Vim and ZSH plugins, but can be expanded easily for other shells or programs.

## But why?

Previously I used git submodules for things that I cared about - but this made it difficult to add and remove dependencies. Other solutions like [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh), [Pathogen](https://github.com/tpope/vim-pathogen), and [Vundle](https://github.com/VundleVim/Vundle.vim) allow for managing plugins but include more features than I am looking for. This makes the goals for Pug basically:

+ Self contained: Only require a shell and git.
+ Minimal magic: Do what's expected.
+ Non-destructive: Don't break how config files and other plugins function.
+ Quick experimentation: Allow for quickly adding/ removing plugins.
+ Consistent: Install plugins from a config file reliably without user interaction.

## Install

Install Pug automatically:

```shell
curl https://raw.githubusercontent.com/willhbr/pug/master/install.sh | bash
```

Or if you don't like piping into Bash:

```shell
git clone https://github.com/willhbr/pug.git
cd pug
./install.sh
```

This adds the `pug` script into `/usr/local/bin` - you can put it anywhere in your `$PATH` if that suits you better. Installers for Vim and ZSH are copied to `~/.pug/installers`. This is where you can add your own installers (for another utility), just make sure it's named `UTILITY-install`.

## Manual Usage

Add a dependency:

```shell
pug get TYPE GIT_CLONE_URL [MAIN_FILE?]
# eg to install ctrlp.vim:
pug get vim https://github.com/ctrlpvim/ctrlp.vim.git
```

The `MAIN_FILE` argument is only needed if the file to be sourced is not in the format `$PLUGIN_NAME.$TYPE` - e.g: `zsh-autosuggestions.zsh`.

The first time you install a dependency of a certain type, you will need to add a snippet to load the _Pug file_ for that type. For example for ZSH this needs to be added to your `.zshrc` file:

```shell
# Somewhere in ~/.zshrc
source "$HOME/.pug/source/zsh/pug"
```

You can update all plugins with:

```shell
pug update
```

All of your sources - everything stored in `.pug/source` - can be removed with:

```shell
pug wipe
```

# Remove plugins

To remove a plugin (you may have to restart you shell/tmux/editor) to unload it:

```shell
pug remove vim-tmux-navigator
```

## Installers

An installer should take the name of a plugin as an argument and echo the code necessary to load it into the correct _Pug file_ in the `.pug/source` directory. Look at the default installers for examples of how they work.
