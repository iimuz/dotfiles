## Use Gemini

By using Gemini, you can do the following:

- Research internet articles
- Check different opinions
- Explore across entire projects
- Summarize long content

## Notes

Please actively use it when available.
Especially, use Gemini instead of the fetch tool.

When researching, be sure to obtain reference links.
Also, when responding to users, present the links together with your answers.

Set prompts so that Claude can process them when newly input as instructions.
Note that previous context is not retained.

## How to Use the Tool

```sh
gemini -p "Please read the document and summarize it. https://github.com/google-gemini/gemini-cli"

gemini -p "Please check if the information about dummy is correct."

gemini -p "Read @long-context.md and summarize the necessary points."
```

## Model Selection

You can change the model used as follows.
If a command fails due to rate limiting, try using a different model.

- gemini-2.5-pro: Smart, but prone to rate limiting.
- gemini-2.5-flush: Faster than pro and less likely to be rate limited.

```sh
gemini --model gemini-2.5-pro -p "Summarize."

gemini --model gemini-2.5-flush -p "Summarize."
```
