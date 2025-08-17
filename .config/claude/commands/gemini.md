## Use Gemini

By using Gemini, you can:

- Research internet articles
- Check different opinions
- Explore entire projects
- Summarize long content

## Notes

- Use the gemini command without relying on web search or web fetch tools.
- When conducting research, always obtain reference links.
  Also, present the links alongside your answers when responding to users.
- Gemini does not retain previous context.
  If answers need to refer to previous content, include the prior content in the prompt.
- Input to Gemini should be in English.

## How to Use the Tool

```sh
gemini -p "Investigate and summarize about dummy. - Summarize based on research content; do not add personal opinions. - Include reference links, clearly indicating the referenced sections."

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
