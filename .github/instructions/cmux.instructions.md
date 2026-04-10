---
applyTo: ".config/cmux/**"
---

# cmux Configuration

## Official Documentation

When working with cmux configuration, use a subagent to fetch the relevant
specification details from the official documentation:

- [GitHub - manaflow-ai/cmux](https://github.com/manaflow-ai/cmux)
- [Configuration](https://cmux.com/docs/configuration)
- [Custom commands](https://cmux.com/docs/custom-commands)
- [Keyboard shortcuts](https://cmux.com/docs/keyboard-shortcuts)
- [API Reference](https://cmux.com/docs/api)

## Keybindings

- All chord bindings use `ctrl+g` as the leader key.

## Shell Commands

- All cmux convenience functions use the `cx` prefix (short for cmux).

## Adding New Commands

1. Add the function to `.config/cmux/cmux-commands.sh`.
2. Follow the `cx` prefix naming convention.
3. Validate required arguments and external tool availability at function start.
4. Send diagnostic messages to stderr.
