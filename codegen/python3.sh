#!/bin/bash
# codegen/python3.sh

echo "python3.sh:  Append the following to your taskrc{.md}:" >&2
cat <<- EOF
    ```bash
    py=\$(which python3.9 python3.8 python3.7 python3.6 | head -n 1 2>/dev/null)
    [[ -x \$py ]] || { echo "Cant find appropriate python3 version" >&2 ; false; return;  }
    scriptname='hello.py'
    function run_one {
        $py $scriptname "$@"
    }

    ```
EOF
