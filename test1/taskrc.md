## taskrc.md for test1

```bash

function run_one {
    echo "this is run_one in test1/"
}

function debug_one {
    echo "this is debug_one in test1/"
}

function tail_log {
    while true; do
        echo "this is tail_log in test1/ $(date)"
        sleep 3
    done
}

```
