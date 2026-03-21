---
applyTo: ".github/copilot-instructions.md,.github/instructions/**"
---

# Rule Generation and Maintenance Guidelines

## Official Documentation

When creating or modifying instruction files, use a subagent to fetch the
latest specification from the official documentation and return the relevant
specification details:

- [Add custom instructions - GitHub Docs](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)

## Project Policy

- Always specify `applyTo:` in the YAML frontmatter to limit target files when creating individual instruction files.
- Use direct language. Do not use hedging phrases like "It is recommended to..." or "You might want to...".
