# Zshrc inspired from zshuery.sh

# Checks
is_mac() { [[ $OSTYPE == darwin* ]] }
is_freebsd() { [[ $OSTYPE == freebsd* ]] }
is_linux() { [[ $OSTYPE == linux-gnu ]] }

has_brew() { [[ -n ${commands[brew]} ]] }
has_apt() { [[ -n ${commands[apt-get]} ]] }
has_yum() { [[ -n ${commands[yum]} ]] }

autoload colors; colors;
export LSCOLORS="Gxfxcxdxbxegedabagacad"
setopt prompt_subst

# Settings borrowed from https://github.com/twe4ked/dotfiles/blob/master/shell/zsh/zshrc
load_defaults() {

setopt no_beep                      # i hate beeps
setopt transient_rprompt
setopt cdablevarS
setopt interactive_comments         # escape commands so i can use them later (allow comments after commands)
setopt rm_star_wait                 # if `rm *` wait 10 seconds before performing it!
setopt list_types                   # show types in completion
setopt auto_cd                      # if a command is not in the hash table, and there exists an executable directory by that name, perform the cd command to that directory.
setopt prompt_subst                 # allow to use color variables in themes
setopt multios
setopt cd_able_vars                 # if the argument to cd is the name of a parameter whose value is a valid directory, it will become the current directory.
setopt no_auto_name_dirs            # see: http://www.neactar.com/shell/fix-for-wrong-prompt-dir-when-using-zsh-project-rvmrc-and-oh-my-zsh
setopt hist_ignore_dups             # ignore duplication command history list
setopt hist_verify                  # expand history onto the current line instead of executing it
setopt hist_expire_dups_first       # remove oldest duplicate commands from the history first
setopt hist_ignore_space            # don't save commands beginning with spaces to history
setopt hist_reduce_blanks
setopt extended_history             # save beginning time and elapsed time before commands in history
setopt append_history               # append to the end of the history file
setopt share_history                # Share history
setopt inc_append_history           # always be saving history (not just when the shell exits)
setopt magic_equal_subst            # all unquoted arguments of the form identifier=expression appearing after the command name have file expansion
setopt auto_menu                    # show completion menu on succesive tab press
setopt auto_pushd                   # make cd push the old directory onto the directory stack
setopt pushd_ignore_dups            # Don't push multiple copies of the same directory onto the directory stack.
setopt glob_complete                # complete globs instead of expanding
setopt extended_glob                # Treat the '#', '~' and '^' characters as part of patterns for filename generation, etc. (An initial unquoted '~' always produces named directory expansion.)
setopt complete_in_word
setopt always_to_end
setopt no_flowcontrol

autoload -U url-quote-magic edit-command-line

zle -N self-insert url-quote-magic
autoload -U zmv
bindkey "^[m" copy-prev-shell-word
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

WORDCHARS=''

# history
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# show time a command took if over 4 sec
export REPORTTIME=4
export TIMEFMT="%*Es total, %U user, %S system, %P cpu"

# I don't like correction
unsetopt correct_all
}

# Plug and play
if [[ -f /etc/zsh_command_not_found ]]; then
    source /etc/zsh_command_not_found # installed in Ubuntu
fi
if [[ -n ${commands[hub]} ]]; then
    function git(){hub $@}
fi
if [[ -n ${commands[jump]} ]]; then
    jump() {
        cd $(JUMPPROFILE=1 command jump $@)
    }
    alias j="jump -a"
fi
if [[ -d /var/lib/gems/1.8/bin ]]; then # oh Debian/Ubuntu
    export PATH=$PATH:/var/lib/gems/1.8/bin
fi
# RVM or rbenv
if [[ -s $HOME/.rvm/scripts/rvm ]]; then
    source $HOME/.rvm/scripts/rvm
    RUBY_VERSION_PREFIX='r'
    ruby_version() {
        if [[ $RUBY_VERSION != "" ]]; then
            echo $RUBY_VERSION_PREFIX$RUBY_VERSION | sed s/ruby-//
        else echo ''; fi
    }
elif [[ -d $HOME/.rbenv ]]; then
    export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH
    source $HOME/.rbenv/completions/rbenv.zsh
    rbenv rehash 2>/dev/null
    ruby_version() { rbenv version-name }
else
    ruby_version() { echo '' }
fi
# Current directory in title
if [[ $TERM_PROGRAM == "Apple_Terminal" ]]; then
    update_terminal_cwd() {
        printf '\e]7;%s\a' "file://$HOST$(pwd | sed -e 's/ /%20/g')"
    }
else
    case $TERM in
        sun-cmd)
            update_terminal_cwd() { print -Pn "\e]l%~\e\\" };;
        *xterm*|rxvt|(dt|k|E)term)
            update_terminal_cwd() { print -Pn "\e]2;%~\a" };;
        *)
            update_terminal_cwd() {};;
    esac
fi
# Prompt aliases for readability
USER_NAME='%n'
HOST_NAME='%m'
DIR='%~'
COLLAPSED_DIR() { # by Steve Losh
    echo $(pwd | sed -e "s,^$HOME,~,")
    local PWD_URL="file://$HOST_NAME${PWD// /%20}"
}

# Functions
last_modified() { # by Ryan Bates
    ls -t $* 2> /dev/null | head -n 1
}
ex() {
    if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xvjf $1;;
          *.tar.gz) tar xvzf $1;;
          *.tar.xz) tar xvJf $1;;
          *.tar.lzma) tar --lzma xvf $1;;
          *.bz2) bunzip $1;;
          *.rar) unrar $1;;
          *.gz) gunzip $1;;
          *.tar) tar xvf $1;;
          *.tbz2) tar xvjf $1;;
          *.tgz) tar xvzf $1;;
          *.zip) unzip $1;;
          *.Z) uncompress $1;;
          *.7z) 7z x $1;;
          *.dmg) hdiutul mount $1;; # mount OS X disk images
          *) echo "'$1' cannot be extracted via >ex<";;
    esac
    else
        echo "'$1' is not a valid file"
    fi
}
mcd() { mkdir -p "$1" && cd "$1"; }
pj() { python -mjson.tool } # pretty-print JSON
cj() { curl -sS $@ | pj } # curl JSON
md5() { echo -n $1 | openssl md5 /dev/stdin }
sha1() { echo -n $1 | openssl sha1 /dev/stdin }
sha256() { echo -n $1 | openssl dgst -sha256 /dev/stdin }
sha512() { echo -n $1 | openssl dgst -sha512 /dev/stdin }
rot13() { echo $1 | tr "A-Za-z" "N-ZA-Mn-za-m" }
rot47() { echo $1 | tr "\!-~" "P-~\!-O" }
latrus() { echo $1 | tr "qwertyuiop[]asdfghjkl;'zxcvbnm,.QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM" "йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ" }
ruslat() { echo $1 | tr "йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ" "qwertyuiop[]asdfghjkl;'zxcvbnm,.QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM" }
urlencode() { python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1])" $1 }
urldecode() { python -c "import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])" $1 }
path() {
  echo $PATH | tr ":" "\n" | \
    awk "{ sub(\"/usr\",   \"$fg_no_bold[green]/usr$reset_color\"); \
           sub(\"/bin\",   \"$fg_no_bold[blue]/bin$reset_color\"); \
           sub(\"/opt\",   \"$fg_no_bold[cyan]/opt$reset_color\"); \
           sub(\"/sbin\",  \"$fg_no_bold[magenta]/sbin$reset_color\"); \
           sub(\"/local\", \"$fg_no_bold[yellow]/local$reset_color\"); \
           print }"
}
up() { # https://gist.github.com/1474072
    if [ "$1" != "" -a "$2" != "" ]; then
        local DIR=$1
        local TARGET=$2
    elif [ "$1" ]; then
        local DIR=$PWD
        local TARGET=$1
    fi
    while [ ! -e $DIR/$TARGET -a $DIR != "/" ]; do
        DIR=$(dirname $DIR)
    done
    test $DIR != "/" && echo $DIR/$TARGET
}
if has_brew; then
    gimme() { brew install $1 }
    _gimme() { reply=(`brew search`) }
elif has_apt; then
    gimme() { sudo apt-get install $1 }
elif has_yum; then
    gimme() { su -c 'yum install $1' }
fi
if is_mac; then
    pman() { man $1 -t | open -f -a Preview } # open man pages in Preview
    cdf() { eval cd "`osascript -e 'tell app "Finder" to return the quoted form of the POSIX path of (target of window 1 as alias)' 2>/dev/null`" }
    vol() {
        if [[ -n $1 ]]; then osascript -e "set volume output volume $1"
        else osascript -e "output volume of (get volume settings)"
        fi
    }
    locatemd() { mdfind "kMDItemDisplayName == '$@'wc" }
    mailapp() {
        if [[ -n $1 ]]; then msg=$1
        else msg=$(cat | sed -e 's/\\/\\\\/g' -e 's/\"/\\\"/g')
        fi
        osascript -e 'tell application "Mail" to make new outgoing message with properties { Content: "'$msg'", visible: true }' -e 'tell application "Mail" to activate'
    }
    sparrow() {
        if [[ -n $1 ]]; then msg=$1
        else msg=$(cat | sed -e 's/\\/\\\\/g' -e 's/\"/\\\"/g')
        fi
        osascript -e 'tell application "Sparrow" to compose (make new outgoing message with properties { content: "'$msg'" })' -e 'tell application "Sparrow" to activate'
    }
    evernote() {
        if [[ -n $1 ]]; then msg=$1
        else msg=$(cat | sed -e 's/\\/\\\\/g' -e 's/\"/\\\"/g')
        fi
        osascript -e 'tell application "Evernote" to open note window with (create note with text "'$msg'")' -e 'tell application "Evernote" to activate'
    }
    # http://apple.stackexchange.com/questions/5435/got-any-tips-or-tricks-for-terminal-in-mac-os-x?page=2&tab=votes#tab-top
    quit() {
        for app in $*; do
            osascript -e 'quit app "'$app'"'
        done
    }
    relaunch() {
        for app in $*; do
            osascript -e 'quit app "'$app'"';
            sleep 2;
            open -a $app
        done
    }
    selected() {
      osascript <<EOT
        tell application "Finder"
          set theFiles to selection
          set theList to ""
          repeat with aFile in theFiles
            set theList to theList & POSIX path of (aFile as alias) & "\n"
          end repeat
          theList
        end tell
EOT
    }
fi

# Aliases
load_aliases() {
    alias ..='cd ..'
    alias ....='cd ../..'
    alias la='ls -la'
    if is_mac; then
        alias ql='qlmanage -p 2>/dev/null' # OS X Quick Look
        alias oo='open .' # open current dir in OS X Finder
    fi
    alias clr='clear'
    alias s_http='python -m SimpleHTTPServer' # serve current folder via HTTP
    alias s_smtp='python -m smtpd -n -c DebuggingServer localhost:1025' # SMTP test server, outputs to console
    alias wget='wget --no-check-certificate'
    alias pinst='sudo python setup.py install && sudo rm -r build && sudo rm -r dist && sudo rm -r *egg-info' # install a Python package
    alias beep='echo -n "\a"'
    alias lst="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"
    export EDITOR=emacs
    export GIT_EDITOR=emacs
    alias e='emacsclient -t'
    alias ec='emacsclient --no-wait -c'
}

# Completion
load_completion() {
    # http://www.reddit.com/r/commandline/comments/kbeoe/you_can_make_readline_and_bash_much_more_user/
    # https://wiki.archlinux.org/index.php/Zsh
    autoload -U compinit
    fpath=($* $fpath)
    fignore=(.DS_Store $fignore)
    compinit -i
    zmodload -i zsh/complist
    setopt complete_in_word
    setopt auto_remove_slash
    unsetopt always_to_end
    has_brew && compctl -K _gimme gimme
    [[ -f ~/.ssh/known_hosts ]] && hosts=(`awk '{print $1}' ~/.ssh/known_hosts | tr ',' '\n' `)
    [[ -f ~/.ssh/config ]] && hosts=($hosts `grep '^Host' ~/.ssh/config | sed s/Host\ // | egrep -v '^\*$'`)
    [[ -f /var/lib/misc/ssh_known_hosts ]] && hosts=($hosts `awk -F "[, ]" '{print $1}' /var/lib/misc/ssh_known_hosts | sort -u`)
    zstyle ':completion:*' insert-tab pending
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
    highlights='${PREFIX:+=(#bi)($PREFIX:t)(?)*==31=1;32}':${(s.:.)LS_COLORS}}
    highlights2='=(#bi) #([0-9]#) #([^ ]#) #([^ ]#) ##*($PREFIX)*==1;31=1;35=1;33=1;32=}'
    zstyle -e ':completion:*' list-colors 'if [[ $words[1] != kill && $words[1] != strace ]]; then reply=( "'$highlights'" ); else reply=( "'$highlights2'" ); fi'
    unset highlights
    zstyle ':completion:*' completer _complete _match _approximate
    zstyle ':completion:*' squeeze-slashes true
    zstyle ':completion:*' expand 'yes'
    zstyle ':completion:*:match:*' original only
    zstyle ':completion:*:approximate:*' max-errors 1 numeric
    zstyle ':completion:*:hosts' hosts $hosts
    zstyle ':completion::complete:*' use-cache 1
    zstyle ':completion::complete:*' cache-path ./cache/
    zstyle ':completion:*:cd:*' ignore-parents parent pwd
    zstyle ':completion:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
    zstyle ':completion:*:ogg123:*' file-patterns '*.(ogg|OGG):ogg\ files *(-/):directories'
    zstyle ':completion:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
    zstyle ':completion:*:*:*:processes' command "ps -u `whoami` -o pid,user,comm -w -w"

}

# Correction
load_correction() {
    setopt correct_all
    alias man='nocorrect man'
    alias mv='nocorrect mv'
    alias mysql='nocorrect mysql'
    alias mkdir='nocorrect mkdir'
    alias erl='nocorrect erl'
    alias curl='nocorrect curl'
    alias rake='nocorrect rake'
    alias make='nocorrect make'
    alias cake='nocorrect cake'
    alias lessc='nocorrect lessc'
    alias lunchy='nocorrect lunchy'
    SPROMPT="$fg[red]%R →$reset_color $fg[green]%r?$reset_color (Yes, No, Abort, Edit) "
}

# Options and alias
load_defaults;
load_aliases;

# Syntax highlight like Fish
source ~/.fresh/build/zsh/zsh-syntax-highlighting.zsh

# Completions
fpath=(~/.fresh/build/zsh/zsh-completions $fpath)

# Correct some annoying corrections
#load_correction; #disabled

# Theme
#source ~/.fresh/build/zsh/git.zsh 
#source ~/.fresh/build/zsh/re5et.zsh-theme

if is_linux; then
  # Remove annoying keyring warning when using git
  unset GNOME_KEYRING_CONTROL
fi

# Additional config starts here
export MAVEN_OPTS='-Xms256M -XX:MaxPermSize=1024M -Xmx1024M'

# put fancy stuff on the right
#if which rbenv &> /dev/null; then
#  RPS1='$(git_custom_status)%{$fg[red]%}$(rbenv_version_status)%{$reset_color%} $EPS1'
#else
#  RPS1='$(git_custom_status) $EPS1'
#fi
 
source ~/.fresh/build/shell.sh

export MAVEN_OPTS="-XX:MaxPermSize=384m -Xmx1512m -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n"

# Pimp the shell
source ~/.liquidprompt