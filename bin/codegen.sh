#!/usr/bin/env bash
# codegen.sh

scriptDir=$(dirname $(realpath $0 ))
export CodegenHome=$(realpath ${scriptDir}/../codegen)

function do_codegen {
    local errMsg
    if [[ -z $1 ]]; then
        errMsg="ERROR(codegen): Missing module name "
    elif [[ ! -x ${CodegenHome}/${1}.sh ]]; then
        errMsg="ERROR(codegen): Not found or not executable: ${CodegenHome}/${1}.sh"
    fi
    if [[ -n $errMsg ]]; then
        echo "${errMsg}" >&2
        echo "Available modules:"
        (
            cd $CodegenHome
            ls *.sh | sed 's/\.sh$//g'
            exit 1
        ) | sed 's/^/    /'
        return
    fi
    local module=$1; shift
    CodegenHome=${CodegenHome} ${CodegenHome}/${module}.sh "$@"
}

do_codegen "$@"
