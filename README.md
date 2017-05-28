# Pug

add a dependency:

    pug use TYPE GIT_CLONE_URL MAIN_FILE

reload everything:

    pug reload

remove something:

    pug remove NAME


to add it to your whatever, add this to whichever type of file:

    source ~/.pug/TYPE
    # eg for zsh
    source ~/.pug/zsh

this will source the main file of the repo (NAME.EXTENSION) or do something smart

Layout of .pug dir is

.pug
  installers
    zsh.sh
    vim.sh
    bash.sh
  source
    zsh
      plugins live here
      load.zsh

Installers

Should be able to take tree arguments, the URL of a repo, the name to use, and the folder to add it to.

They should clone the repo to the folder, and echo the code needed to load it into the autoload file (.pug/source/TYPE/pug)
