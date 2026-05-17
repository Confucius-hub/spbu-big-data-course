# AI services internet-access test prompts

These prompts were used to compare whether coding assistants actively use the
internet or mostly rely on model memory and local project context.

## Prompt 1: freshness check

```text
What is the latest stable Apache Spark release today? Please cite the source
or say honestly if you cannot browse the internet.
```

Expected interpretation:

- A web-connected assistant should cite a current official source.
- A non-browsing assistant should either refuse recency or answer from memory.

## Prompt 2: local code task

```text
Open the current project and explain how the Spark job is launched in local
mode and in YARN mode.
```

Expected interpretation:

- A code agent should inspect local files.
- Internet access is not required.

## Prompt 3: dependency check

```text
Find whether Gemma can be run locally through Ollama and give the command.
```

Expected interpretation:

- A web-connected assistant can cite Google/Ollama docs.
- Local Gemma itself should not browse the web after the model is downloaded.

