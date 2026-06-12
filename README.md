dotfiles
========

A batteries-included macOS shell setup: zsh + oh-my-zsh, an oh-my-posh prompt,
[herdr](https://herdr.dev) as the terminal multiplexer, git superpowers
(template hooks, ctags indexing, branch-lifecycle commands), and a clean
override layer for personal customization. Based on
[thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles).

Install
-------

On a fresh macOS machine, clone the repo and run the bootstrap script:

    git clone https://github.com/DavidTWhitlatch/dotfiles-template.git ~/dotfiles
    ~/dotfiles/install.sh

Then set your git identity in `~/.gitconfig.local` (the repo's `gitconfig`
deliberately ships without one):

    [user]
      name = Your Name
      email = you@example.com

`install.sh` is idempotent — safe to re-run; each step is skipped if already
done. It will:

1. Install [Homebrew](https://brew.sh) if it is missing.
2. Install every package dependency from the [`Brewfile`](Brewfile) via `brew bundle`.
3. Configure `fzf` key bindings, install [oh-my-zsh](https://ohmyz.sh) plus the
   `zsh-autosuggestions` plugin, and install [nvm](https://github.com/nvm-sh/nvm)
   into `~/.nvm`.
4. Set `zsh` as your login shell.
5. Symlink every dotfile into `$HOME` with [rcm](https://github.com/thoughtbot/rcm)
   (`env RCRC=$HOME/dotfiles/rcrc rcup`).

### What gets installed

Homebrew packages (see [`Brewfile`](Brewfile)): `rcm`, `oh-my-posh`,
`zsh-syntax-highlighting`, `fzf`, [`herdr`](https://herdr.dev), `pyenv`, `asdf`,
`the_silver_searcher` (`ag`), `universal-ctags`, `git`, `git-lfs`, and a Nerd Font.

Bootstrapped outside Homebrew: oh-my-zsh + `zsh-autosuggestions`, and nvm (`~/.nvm`).

Everything the zsh configs reference is installed by the script — machine-specific
tools (extra CLIs, editors, runtimes) belong in the `~/dotfiles-local` override
layer, e.g. `~/dotfiles-local/zshrc.local`.

### Manual install (without the script)

    brew tap thoughtbot/formulae
    brew bundle --file=~/dotfiles/Brewfile
    env RCRC=$HOME/dotfiles/rcrc rcup

After the first run you can invoke `rcup` on its own — it symlinks the repo's
`rcrc` to `~/.rcrc` for future runs. `rcup` creates symlinks for config files in
your home directory; the [`rcrc`](rcrc) file controls which files are excluded
(`README*`, `LICENSE`, `install.sh`, `Brewfile`, …) and gives precedence to
personal overrides placed in `~/dotfiles-local`.


Update
------

From time to time you should pull down any updates to these dotfiles, and run

    rcup

to link any new files. **Note** You can safely run `rcup` multiple times so
update early and update often!

Make your own customizations
----------------------------

Create a directory for your personal customizations:

    mkdir ~/dotfiles-local

Put your customizations in `~/dotfiles-local` appended with `.local`:

* `~/dotfiles-local/aliases.local`
* `~/dotfiles-local/git_template.local/*`
* `~/dotfiles-local/gitconfig.local`
* `~/dotfiles-local/psqlrc.local` (we supply a blank `.psqlrc.local` to prevent `psql` from
  throwing an error, but you should overwrite the file with your own copy)
* `~/dotfiles-local/zshrc.local`
* `~/dotfiles-local/zsh/configs/*`

For example, your `~/dotfiles-local/aliases.local` might look like this:

    # Productivity
    alias todo='$EDITOR ~/.todo'

Your `~/dotfiles-local/gitconfig.local` might look like this:

    [alias]
      l = log --pretty=colored
    [pretty]
      colored = format:%Cred%h%Creset %s %Cgreen(%cr) %C(bold blue)%an%Creset
    [user]
      name = Dan Croak
      email = dan@thoughtbot.com

To extend your `git` hooks, create executable scripts in
`~/dotfiles-local/git_template.local/hooks/*` files.

Your `~/dotfiles-local/zshrc.local` might look like this:

    # load pyenv if available
    if which pyenv &>/dev/null ; then
      eval "$(pyenv init -)"
    fi

zsh Configurations
------------------

Additional zsh configuration can go under the `~/dotfiles-local/zsh/configs` directory. This
has two special subdirectories: `pre` for files that must be loaded first, and
`post` for files that must be loaded last.

For example, `~/dotfiles-local/zsh/configs/pre/virtualenv` makes use of various shell
features which may be affected by your settings, so load it first:

    # Load the virtualenv wrapper
    . /usr/local/bin/virtualenvwrapper.sh

Setting a key binding can happen in `~/dotfiles-local/zsh/configs/keys`:

    # Grep anywhere with ^G
    bindkey -s '^G' ' | grep '

Some changes, like `chpwd`, must happen in `~/dotfiles-local/zsh/configs/post/chpwd`:

    # Show the entries in a directory whenever you cd in
    function chpwd {
      ls
    }

This directory is handy for combining dotfiles from multiple teams; one team
can add the `virtualenv` file, another `keys`, and a third `chpwd`.

The `~/dotfiles-local/zshrc.local` is loaded after `~/dotfiles-local/zsh/configs`.

What's in it?
-------------

[herdr](https://herdr.dev) configuration:

* Autostarts on interactive terminals (skip with `HERDR_NO_AUTOSTART=1`).
* tmux-style keymap: `Ctrl+a` prefix, `prefix+arrows` to focus panes,
  `prefix+%` / `prefix+"` splits, `prefix+x` close, `prefix+f` zoom,
  `prefix+shift+arrows` for workspace and tab cycling.

[git](http://git-scm.com/) configuration:

* Adds a `create-branch` alias to create feature branches.
* Adds a `delete-branch` alias to delete feature branches.
* Adds a `merge-branch` alias to merge feature branches into master.
* Adds an `up` alias to fetch and rebase `origin/master` into the feature
  branch. Use `git up -i` for interactive rebases.
* Adds `post-{checkout,commit,merge}` hooks to re-index your ctags.
* Adds `pre-commit` and `prepare-commit-msg` stubs that delegate to your local
  config.
* Adds `trust-bin` alias to append a project's `bin/` directory to `$PATH`.

Runtime / version management:

* Add trusted binstubs to the `PATH`.
* Load the ASDF version manager.

Shell aliases and scripts:

* `g` with no arguments is `git status` and with arguments acts like `git`.
* `mcd` to make a directory and change into it.
* `replace foo bar **/*.rb` to find and replace within a given list of files.
* `v` for `$VISUAL`.

Thanks
------

Thank you, [contributors](https://github.com/thoughtbot/dotfiles/contributors)!
Also, thank you to Corey Haines, Gary Bernhardt, and others for sharing your
dotfiles and other shell scripts from which we derived inspiration for items
in this project.

License
-------

dotfiles is copyright © 2009-2018 thoughtbot. It is free software, and may be
redistributed under the terms specified in the [`LICENSE`] file.

[`LICENSE`]: /LICENSE

About thoughtbot
----------------

![thoughtbot](http://presskit.thoughtbot.com/images/thoughtbot-logo-for-readmes.svg)

dotfiles is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software!
See [our other projects][community].
We are [available for hire][hire].

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com/hire-us?utm_source=github
