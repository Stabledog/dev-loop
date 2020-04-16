#!/bin/bash
#vim: filetype=sh :
#
# dev-loop.sh:
# This runs in two modes: "outer" vs. "inner"
#
# The outer instance launches a unique tmux session, and starts an inner instance with 2 new windows
# in that session.  The inner instance runs a dev loop of (debug/run/shell) in the left pane, and a diag watcher
#  (e.g. tail_log()) in the right pane.
#
# Usage:
#   dev-loop.sh [args]
#    - There must be an active ./taskrc{.md}.
#    - The taskrc can redefine debug_one(), run_one(), shell_one(), and/or tail_log() to customize behavior within
#         each of those loops.  The default versions of debug_one() and run_one() just print error messages,
#         while the default version of shell_one() runs a bash shell with a taskrc+.bashrc loader in current dir.
#         The default version of tail_log() prints its tty and then prompts the user for logfile path and then runs
#         'tail -F [path]'
#    - Any [args] not eaten by dev-loop.sh are forwarded to the *_one() functions
#
which realpath >/dev/null || { echo "ERROR: realpath not found">&2; exit 1; }
scriptName=$(realpath $0)
org_args="$@"

function stub {
    #return # Comment this out to enable stubs
    echo -e "\033[;31mdev-loop.sh:stub(\033[;33m$@\033[;31m)\033[;0m" >&2
}
stub "org_args=[$org_args]"

source ~/.bashrc

function run_one {
    stub "ERROR: run_one() should be defined in taskrc" >&2
}

function debug_one {
    stub "ERROR: debug_one() should be defined in taskrc" >&2
}

function tail_log {
    echo -e "\033[;32mtail_log() default:\033[;0m tty=$(tty)"
    while true; do
        read -p "Enter logfile path to watch, or redirect your program's diagnostic output to $(tty): "
        if [[ $REPLY != "" ]]; then
            if [[ ! -f $REPLY ]]; then
                echo "Error: file not found -- $REPLY"
                continue
            fi
        else
            continue
        fi
        echo "tail -F $REPLY:"
        tail -F $REPLY
    done
}

function shell_one {
    stub "shell_one() default:"
    /bin/bash --login --rcfile  <(cat << EOF
source ~/.bashrc
taskrc_v3
echo "Default shell_one() + taskrc + .bashrc loaded OK"
EOF
    )
    stub "shell_one default exit"
}



function run_loop {
    # runs a run_one() function repeatedly with restart prompt
    local again=true
    while $again; do
        again=false
        run_one "$@"
        read -n 1 -p "[A]gain or [Q]uit?"
        if [[ $REPLY =~ [aA] ]]; then
            echo
            again=true
        fi
    done
}


function debug_loop {
    # runs a debug_one() function repeatedly with restart prompt
    local again=true
    while $again; do
        again=false
        debug_one "$@"
        read -n 1 -p "[A]gain or [Q]uit?"
        if [[ $REPLY =~ [aA] ]]; then
            echo
            again=true
        fi
    done
}


function make_inner_shrc {
    # Creates temp startup files named .devloop_inner_shrc{.1,.2} for the inner shells to set up environment
    cat > ./.devloop_inner_shrc.1 << EOF
# .devloop_inner_shrc.1, created by dev-loop.sh $(date)
#  You should add this to .gitignore -- '.devloop_inner_shrc*'
echo ".devloop_inner_shrc.1($@) loading:"
source ~/.bashrc
export devloop_window_1=true
tmux split-window -h 'bash --rcfile .devloop_inner_shrc.2'
${scriptName} --inner $@
rm .devloop_inner_shrc.1
tmux kill-session
exit
EOF
    cat > ./.devloop_inner_shrc.2 << EOF
# .devloop_inner_shrc.2, created by dev-loop.sh $(date)
#  You should add this to .gitignore -- '.devloop_inner_shrc*'
echo ".devloop_inner_shrc.2($@) loading:"
source ~/.bashrc
export devloop_window_2=true
sourceMe=1 source ${scriptName}
inner_diagloop "$@"
rm .devloop_inner_shrc.2
exit
EOF
}

function tmux_outer {
    local tmx_sess=devloop$(tty | tr '/' '_')
    stub tmx_sess=$tmx_sess
    make_inner_shrc "$@"
    stub tmux new-session -s $tmx_sess '/bin/bash --rcfile ./.devloop_inner_shrc.1'
    tmux new-session -s $tmx_sess '/bin/bash --rcfile ./.devloop_inner_shrc.1'
    stub $(tmux ls)
    stub tmux result=$?
}

function inner_diagloop {
    while true; do
        read -p "You're in the diag loop now."
    done
}

function inner_devloop {
    # This function runs the left-pane run/debug/shell loop
    stub "inner_devloop($@): pwd=$PWD..."

    local again_main=true
    while $again_main; do
        again_main=false
        echo
        echo "-----------------"
        read -n 1 -p "[D]ebug, [R]un, [S]hell, or [Q]uit?"
        case $REPLY in
            [dD])
                echo
                debug_loop "$@"
                again_main=true
                ;;
            [rR])
                echo
                run_loop "$@"
                again_main=true
                ;;
            [qQ])
                #set -x
                echo "exit"
                exit
                ;;
            [sS])
                shell_one "$@"
                again_main=true
                ;;

            *)
                echo
                again_main=true
                ;;
        esac
    done
}


if [[ -z $sourceMe ]]; then
    if ! (shopt -s extglob; ls taskrc?(.md) &>/dev/null ); then
        read -p "Error: No .taskrc{.md} present in $PWD. Hit enter to quit."
        exit
    fi
    if [[ $1 == "--inner" ]]; then
        shift

        # AFTER we have defined default run/debug/start_one() functions, we'll give the local
        # project a shot at redefining them:
        taskrc_v3  # Load ./taskrc.md
        inner_devloop "$@"
    elif [[ -z $DEVLOOP_OUTER ]]; then
        if [[ -n $TMUX ]]; then
            read -p "ERROR: you cant start dev-loop inside tmux.  Try 'dev-loop.sh --inner'"
            echo
            exit
        fi
        export DEVLOOP_OUTER=$$
        stub calling tmux_outer
        tmux_outer "$@"
    else
        stub "Cant run nested dev-loop.sh instances, DEVLOOP_OUTER=$DEVLOOP_OUTER"
    fi
fi

