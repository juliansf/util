# A two-line colored Bash prompt (PS1) with Git branch and a line decoration
# which adjusts automatically to the width of the terminal.
# Recognizes and shows Git, SVN and Fossil branch/revision.
# Screenshot: http://img194.imageshack.us/img194/2154/twolineprompt.png
# Michal Kottman, 2012

# color names for readibility
reset="\[$(tput sgr0)\]"
bold="\[$(tput bold)\]"
green="\[$(tput setaf 2)\]"
yellow="\[$(tput setaf 3)\]"
cyan="\[$(tput setaf 14)\]"
white="\[$(tput setaf 15)\]"
purple="\[$(tput setaf 13)\]"
orange="\[$(tput setaf 208)\]"

PS_LINE=`printf '─%.0s' {1..500}`

function parse_rep_branch {
    PS_BRANCH=''
    PS_VCS=''
    PS_FILL="${PS_LINE:0:$COLUMNS}"
    
    if [ -d .git ]; then
        ref=$(git symbolic-ref HEAD 2> /dev/null) || return
        PS_VCS='git'
        PS_BRANCH="${ref#refs/heads/}"
    elif [ -d .svn ]; then
        PS_VCS='svn'
        PS_BRANCH="r$(svn info|awk '/Revision/{print $2}')"
    elif [ -d .hg ]; then
        PS_VCS='hg'
        PS_BRANCH="$(hg branch)"
    elif [ -f _FOSSIL_ -o -f .fslckout ]; then
        PS_VCS='fossil'
        PS_BRANCH="$(fossil status|awk '/tags/{print $2}')"
    fi

    if [ -n "$PS_VCS" ]; then
	PS_REP="\[\033[\$((COLUMNS-\${#PS_VCS}-\${#PS_BRANCH}-6))G\]\]"
	PS_REP="$PS_REP$cyan{ $reset\$PS_VCS: $bold\$PS_BRANCH $reset$cyan}"
    fi
}

function prompt {
    parse_rep_branch

    PS_TIME="\[\033[2G\]\]$cyan( $purple\t $cyan)"
    PS_INFO="$bold$orange\u@\h"
    PS_PATH="\[\033[1C\]\]$cyan[ $yellow$bold\w$reset$cyan ]"
    ITERM="\[$(iterm2_prompt_mark)\]"
    
    PS1="\r\n$cyan\$PS_FILL${PS_TIME}${PS_PATH}${PS_REP}\r\n"
    PS1="$PS1$ITERM$PS_INFO$reset $bold$green#$reset "
}

PROMPT_COMMAND=prompt
