#Usage
# Most of the key mappings in the search window are the default fzf ones. The most relevant ones are:
#
# Enter to accept a match.
# ctrl-c do nothing.
# ctrl-f recursively jump into selection.
# ctrl-b recursively jump into the parent directory (..).
# ctrl-g flip to the next directory on the pushd stack.
# ctrl-h jump into the directory being listed, not the selection.
# ctrl-x change to the directory exactly as typed
# In Bash, the script creates a commands:
#
# jump to jump to a given bookmark using fzf.
# You can bind this to a shortcut in your configuration files, for example using bind '"\C-g":" jump\n"' . I recommend prefixing the command with a space, so jump will not appear in your history if you have HISTCONTROL=ignorespace set. Bookmarks

[ -n "$1" ] && bind "\"$1\":\" jump\n\""

function dirs() {
    case "$1" in
        --dedupe)  ;;
        *)
            builtin dirs $*
            return
    esac

    #dedup directory stack
    local -A seen=()
    local i=0
    local d=''
    # reads dirs -p into array by line. IFS=$'\n' will split by newline, $'\n' will escape correctly.
    IFS=$'\n' GLOBIGNORE='*' command eval  'local -a ODIRS=($(dirs -p))'
    # below *must* use for loop, while loops run in subshells and popd will not
    # affect outer shell.
    for d in "${ODIRS[@]}" ; do
        if test "${seen[$d]}"; then
            popd -n +$i >/dev/null ;
        else ((i++));
        fi
        seen[$d]=1
    done;

}

function jump() {

    local FZF_ARGS='-e +x --print-query --expect=ctrl-x,ctrl-i,ctrl-f,ctrl-c,ctrl-b,ctrl-h,ctrl-g'

    local F=$(
    { dirs -v | tail -n +2 ; ls -d "$1"*/ ; D=`pwd`; while [ "$D" != / ]; do D=`dirname $D`; echo "$D"; done; } 2>/dev/null | \
        fzf $FZF_ARGS --preview="echo {}; [ -d {} ] && ls -latrh {}" | {
      read query;
      read expect;
      IFS='' read dir; #read whole line w/ whitespace.
      cat  2>/dev/null #flush rest of input

      case "$expect" in
          ctrl-h) echo "$1./";;
          ctrl-b) jump "$1../";;
          ctrl-c) echo "exit";;
          ctrl-x) echo "$query";;
          ctrl-[if])
              if dirs -v | grep -q "^$dir\$"; then
                  dir="$(echo "$dir" | sed -E 's/^ *([0-9]+) *//')"
              fi
              jump "$dir"
              ;;
          ctrl-g);&
          "")
              if dirs -v | grep -q "^$dir\$"; then echo "$dir" | sed -E 's/^ *([0-9]+) *.*$/+\1/';
              elif test "$dir"; then echo "$dir";
              elif test "$query"; then echo "$query";
              else echo ""
              fi
              ;;
      esac
    }
    )

    if test "$1"; then
        echo "$F"
        return 0
    fi

    if test "$F" = "exit"; then
        return 0
    fi

    if test "$DEBUG"; then
        dirs -v >&2
        echo -e "F=$F\n" >&2
        echo "pushd \"$F\" >/dev/null"  >&2
    fi
    
    pushd "$F" >/dev/null

    dirs --dedupe

}
