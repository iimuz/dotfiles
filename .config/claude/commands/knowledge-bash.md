# Bash Script Best Practices Knowledge

When writing or reviewing bash scripts, follow these comprehensive best practices:

## 1. Script Header and Setup

### Shebang

```bash
#!/usr/bin/env bash
# Use env for better cross-platform compatibility
```

### Essential Options

```bash
set -Eeuo pipefail
# -E: ERR trap is inherited by shell functions
# -e: Exit immediately if a command exits with a non-zero status
# -u: Treat unset variables as an error when substituting
# -o pipefail: Return exit status of the last command in the pipe that failed
```

### Additional Safety Options

```bash
set -C  # Prevent accidental file overwriting (noclobber)
```

## 2. Naming Conventions

- **Files**: kebab-case (`my-script.sh`)
- **Constants**: UPPER_SNAKE_CASE with `readonly`
- **Global variables**: lower_snake_case
- **Local variables**: \_lower_snake_case with `local`
- **Functions**: lower_snake_case

```bash
# Correct way to declare readonly variables to avoid ShellCheck warnings
SCRIPT_NAME="my-script"
readonly SCRIPT_NAME

CONFIG_FILE="/etc/myapp.conf"
readonly CONFIG_FILE

global_var="value"

function my_function() {
    local _local_var="local_value"
}
```

## 3. Script Structure

### Template Structure

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

# Script description and usage
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_DIR
SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

# Constants
DEFAULT_TIMEOUT=30
readonly DEFAULT_TIMEOUT

# Error handling
function err() {
    echo "[ERROR] Line $1: $2" >&2
    exit 1
}

function cleanup() {
    local _exit_code=$?
    if [[ $_exit_code -eq 0 ]]; then
        log_info "Script completed successfully"
    else
        log_error "Script failed with exit code $_exit_code"
    fi
    # Additional cleanup code here
}

# Set up error handling
trap 'err ${LINENO} "$BASH_COMMAND"' ERR
trap cleanup EXIT

function usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] COMMAND

Description of the script.

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output

COMMANDS:
    start           Start the service
    stop            Stop the service
EOF
}

function main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Main logic here
    log_info "Starting ${SCRIPT_NAME}..."

    # Your script logic
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## 4. Error Handling Patterns

### Custom Error Functions

```bash
function raise() {
    local _message="$1"
    local _exit_code="${2:-1}"
    echo "[ERROR] ${_message}" >&2
    exit "${_exit_code}"
}

function warn() {
    local _message="$1"
    echo "[WARN] ${_message}" >&2
}

function info() {
    local _message="$1"
    echo "[INFO] ${_message}"
}
```

### Loop Error Handling

```bash
for file in *.txt; do
    set +e  # Temporarily disable exit on error
    process_file "$file"
    local _exit_code=$?
    set -e  # Re-enable exit on error

    if [[ $_exit_code -ne 0 ]]; then
        warn "Failed to process $file, continuing..."
        continue
    fi
done
```

## 5. Coding Best Practices

### Conditional Testing

```bash
# Use [[ ]] instead of [ ]
if [[ -f "$file" && -r "$file" ]]; then
    echo "File exists and is readable"
fi

# For arithmetic comparisons
if (( count > 10 )); then
    echo "Count is greater than 10"
fi
```

### Command Substitution

```bash
# Use $() instead of backticks
current_date=$(date +%Y-%m-%d)
file_count=$(find . -name "*.txt" | wc -l)
```

### Variable Handling

```bash
# Quote variables to prevent word splitting
echo "Processing file: $filename"
cp "$source" "$destination"

# Array handling
files=("*.txt" "*.log")
for file in "${files[@]}"; do
    echo "Processing: $file"
done

# Use "$@" for all arguments
function process_files() {
    local _files=("$@")
    for file in "${_files[@]}"; do
        echo "Processing: $file"
    done
}
```

### Arithmetic Operations

```bash
# Use (( )) for arithmetic
((count++))
result=$((a + b * c))

# For arithmetic tests
if (( result > threshold )); then
    echo "Threshold exceeded"
fi
```

## 6. Input Validation

```bash
function validate_input() {
    local _input="$1"

    if [[ -z "$_input" ]]; then
        raise "Input cannot be empty"
    fi

    if [[ ! "$_input" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        raise "Input contains invalid characters"
    fi
}
```

## 7. Logging and Monitoring

```bash
function log_info() {
    local _message="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $_message" >&2
}

function log_error() {
    local _message="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $_message" >&2
}

function log_warn() {
    local _message="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARN] $_message" >&2
}

# Backward compatibility wrapper
function log_with_timestamp() {
    local _level="$1"
    local _message="$2"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$_level] $_message" >&2
}
```

## 8. Resource Management

```bash
function setup_workspace() {
    WORK_DIR=$(mktemp -d)
    readonly WORK_DIR
    if [[ ! -d "$WORK_DIR" ]]; then
        raise "Failed to create temporary directory"
    fi
    echo "Created workspace: $WORK_DIR"
}

function cleanup_workspace() {
    if [[ -n "$WORK_DIR" && -d "$WORK_DIR" ]]; then
        rm -rf "$WORK_DIR"
        echo "Cleaned up workspace: $WORK_DIR"
    fi
}

trap cleanup_workspace EXIT
```

## 9. Performance Considerations

### Avoid Unnecessary Subshells

```bash
# Good: Use built-in parameter expansion
filename="${path##*/}"

# Avoid: Unnecessary external command
filename=$(basename "$path")
```

### Use Arrays for Multiple Values

```bash
# Good: Use arrays
files=("file1.txt" "file2.txt" "file3.txt")
for file in "${files[@]}"; do
    process_file "$file"
done

# Avoid: Multiple variables
file1="file1.txt"
file2="file2.txt"
file3="file3.txt"
```

## 10. Validation and Testing

### Use External Tools

- **ShellCheck**: Static analysis tool for shell scripts
- **shfmt**: Shell script formatter
- **bats**: Bash Automated Testing System

### Syntax Validation

```bash
# Check syntax without execution
bash -n script.sh
```

### Common ShellCheck Issues and Solutions

#### Readonly Variable Declaration

```bash
# ❌ This triggers ShellCheck warning SC2155
readonly SCRIPT_NAME=$(basename "${0}")

# ✅ Correct approach - separate declaration and assignment
SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME
```

### Runtime Testing

- **Always test scripts after ShellCheck fixes** - static analysis doesn't catch all runtime issues
- **Test with actual execution environment** - some fixes may work in testing but fail in production
- **Validate with different input scenarios** - edge cases often reveal problems

### Unused Variable Management

```bash
# ❌ Don't keep unused variables just because they're in templates
readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)  # Unused

# ✅ Only define variables you actually use
# SCRIPT_DIR removed since it's not used in this script
```

## 11. Common Pitfalls to Avoid

1. **Don't use `eval`** - Security risk and hard to debug
2. **Don't use `which`** - Use `command -v` instead
3. **Don't parse `ls` output** - Use glob patterns or `find`
4. **Don't use `cat` for single files** - Use input redirection
5. **Don't use `echo` for user input** - Use `printf` instead

## 12. Security Considerations

- Always quote variables containing user input
- Validate all input parameters
- Use absolute paths when possible
- Set restrictive file permissions (umask)
- Avoid passing sensitive data through command line arguments

## 13. Documentation

- Add comments explaining complex logic
- Document function parameters and return values
- Include usage examples
- Document any external dependencies

## 11. Project Integration Patterns

### Build/Test/Lint Script Pattern

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

function log_info() {
    local _message="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $_message" >&2
}

function log_error() {
    local _message="$1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $_message" >&2
}

function err() {
    log_error "Line $1: $2"
    exit 1
}

function cleanup() {
    local _exit_code=$?
    if [[ $_exit_code -eq 0 ]]; then
        log_info "Process completed successfully"
    else
        log_error "Process failed with exit code $_exit_code"
    fi
}

trap 'err ${LINENO} "$BASH_COMMAND"' ERR
trap cleanup EXIT

function usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Process project files (build/test/lint).

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output
EOF
}

function run_formatting() {
    log_info "Checking code formatting..."
    # Add your formatting commands here
}

function run_linting() {
    log_info "Running code linting..."
    # Add your linting commands here
}

function run_tests() {
    log_info "Running tests..."
    # Add your test commands here
}

function main() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help) usage; exit 0 ;;
            -v|--verbose) set -x; shift ;;
            *) log_error "Unknown option: $1"; usage; exit 1 ;;
        esac
    done

    run_formatting
    run_linting
    run_tests
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### stderr vs stdout Best Practices

```bash
# ✅ Logs and errors go to stderr (can be filtered/redirected)
log_info "Processing file..." >&2
echo "actual_result_data"  # Only results to stdout

# ❌ Everything mixed in stdout
echo "Processing file..."
echo "actual_result_data"

# Usage example:
# script.sh > results.txt 2> logs.txt  # Separate data from logs
```

## 12. Advanced Error Handling

### Multi-stage Error Recovery

```bash
function process_with_retry() {
    local _file="$1"
    local _max_attempts=3
    local _attempt=1

    while [[ $_attempt -le $_max_attempts ]]; do
        set +e  # Temporarily disable exit on error
        process_file "$_file"
        local _exit_code=$?
        set -e  # Re-enable exit on error

        if [[ $_exit_code -eq 0 ]]; then
            log_info "Successfully processed $_file on attempt $_attempt"
            return 0
        else
            log_warn "Attempt $_attempt failed for $_file (exit code: $_exit_code)"
            ((_attempt++))
            sleep 1
        fi
    done

    log_error "Failed to process $_file after $_max_attempts attempts"
    return 1
}
```

### Conditional Error Handling

```bash
function safe_operation() {
    local _critical="${1:-false}"

    set +e
    risky_command
    local _exit_code=$?
    set -e

    if [[ $_exit_code -ne 0 ]]; then
        if [[ "$_critical" == "true" ]]; then
            log_error "Critical operation failed"
            exit $_exit_code
        else
            log_warn "Non-critical operation failed, continuing..."
            return $_exit_code
        fi
    fi
}
```

## 13. Practical Troubleshooting

### Common ShellCheck Issues and Solutions

#### SC2034: Variable appears unused

```bash
# ❌ Unused variable triggers warning
LOG_FILE="/tmp/app.log"  # Never used

# ✅ Remove unused variables
# LOG_FILE removed since it's not used

# ✅ Or mark as intentionally unused
# shellcheck disable=SC2034
LOG_FILE="/tmp/app.log"  # Reserved for future use
```

#### SC2086: Double quote to prevent globbing

```bash
# ❌ Unquoted variable
cp $source $destination

# ✅ Properly quoted
cp "$source" "$destination"
```

#### SC2015: Use && and || carefully

```bash
# ❌ Problematic pattern
[[ -f "$file" ]] && process_file "$file" || log_error "File not found"

# ✅ Clearer pattern
if [[ -f "$file" ]]; then
    process_file "$file"
else
    log_error "File not found"
fi
```

### Runtime Debugging

```bash
# Enable debug mode conditionally
if [[ "${DEBUG:-}" == "true" ]]; then
    set -x
fi

# Debug logging
function debug() {
    if [[ "${DEBUG:-}" == "true" ]]; then
        log_info "DEBUG: $1"
    fi
}
```

## 14. Complete Best Practices Modification Checklist

When modifying existing bash scripts to follow best practices, use this comprehensive checklist to ensure ALL elements are included in a single modification:

### Essential Elements Checklist

**Required in ALL scripts (check every item):**

1. **Script Header & Setup**
   - [ ] `#!/usr/bin/env bash`
   - [ ] `set -Eeuo pipefail`
   - [ ] `SCRIPT_NAME=$(basename "${0}")` + `readonly SCRIPT_NAME`

2. **Error Handling (ALL required)**
   - [ ] `function err() { log_error "Line $1: $2"; exit 1; }`
   - [ ] `function cleanup() { /* cleanup logic */ }`
   - [ ] `trap 'err ${LINENO} "$BASH_COMMAND"' ERR`
   - [ ] `trap cleanup EXIT`

3. **Logging Functions (ALL required)**
   - [ ] `function log_info() { echo "[INFO] $1"; }`
   - [ ] `function log_error() { echo "[ERROR] $1" >&2; }`
   - [ ] Optional: `function log_warn() { echo "[WARN] $1" >&2; }`

4. **Usage & Argument Parsing**
   - [ ] `function usage() { /* detailed help */ }`
   - [ ] **IMPORTANT**: Argument parsing MUST be inside `main()` function, NOT in separate `parse_args()` function

5. **Main Function Structure**
   - [ ] `function main() { /* args parsing + logic */ }`
   - [ ] `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`

### One-Pass Modification Strategy

**Step 1: Analyze Original Script**

- Identify the core functionality
- Note which constants/arrays are needed
- Determine what arguments the script should accept

**Step 2: Apply Complete Template (All At Once)**

```bash
#!/usr/bin/env bash
# MISE/Script description here

set -Eeuo pipefail

SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_NAME

# Constants (if needed)
readonly CONSTANT_ARRAY=(
    "item1"
    "item2"
)

function log_info() {
    local _message="$1"
    echo "[INFO] $_message"
}

function log_error() {
    local _message="$1"
    echo "[ERROR] $_message" >&2
}

function err() {
    log_error "Line $1: $2"
    exit 1
}

function cleanup() {
    log_info "Cleanup completed"
}

function usage() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Description of what the script does.

OPTIONS:
    -h, --help      Show this help message
    -v, --verbose   Enable verbose output

DESCRIPTION:
    Detailed description of the script's purpose and behavior.
EOF
}

function core_function() {
    local _param="$1"
    # Core logic here
}

function main() {
    # Parse command line arguments (DO NOT create separate parse_args function)
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    log_info "Starting script execution..."

    # Main logic here
    local _failed_count=0
    for item in "${CONSTANT_ARRAY[@]}"; do
        if ! core_function "$item"; then
            ((_failed_count++))
        fi
    done

    if ((_failed_count > 0)); then
        log_error "Failed to process $_failed_count items"
        exit 1
    fi

    log_info "Script completed successfully"
}

# Set up error handling
trap 'err ${LINENO} "$BASH_COMMAND"' ERR
trap cleanup EXIT

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Critical Mistakes to Avoid

1. **❌ DO NOT create separate `parse_args()` function**

   ```bash
   # WRONG - separate function
   function parse_args() { /* ... */ }
   function main() { parse_args "$@"; /* ... */ }
   ```

2. **✅ DO parse arguments directly in main()**

   ```bash
   # CORRECT - inline parsing
   function main() {
       while [[ $# -gt 0 ]]; do
           case $1 in /* ... */ esac
       done
       # main logic
   }
   ```

3. **❌ DO NOT forget error handling setup**
   - Must have both `trap 'err ${LINENO} "$BASH_COMMAND"' ERR` and `trap cleanup EXIT`

4. **❌ DO NOT mix stdout/stderr inappropriately**
   - Info/error logs should go to stderr or stdout consistently
   - Results/data should go to stdout only

### Quick Validation Checklist

After modification, verify these elements exist:

- [ ] All 5 essential elements from checklist above
- [ ] No separate `parse_args()` function
- [ ] Arguments parsed directly in `main()`
- [ ] Both ERR and EXIT traps set up
- [ ] All variables properly quoted
- [ ] Arrays used for multiple related values
- [ ] Proper arithmetic operations with `(( ))`

This comprehensive approach ensures complete best practices compliance in a single modification pass.

This knowledge should guide the creation of robust, maintainable, and secure bash scripts.
