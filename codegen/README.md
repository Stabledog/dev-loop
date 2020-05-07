# Codegen templates

Each module has a script that generates code, potentially dependent on taskrc.

Example:
```bash
dev-loop codegen python3
```
Invokes the script `dev-loop/codegen/python3.module/init.sh`, which should spit out code that can populate run_one(), debug_one(), and supporting elements for generation of a taskrc{.md}, as well as possibly generating a hello.py with logging enabled, etc.
