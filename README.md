# Dev Container Features

Reusable [Dev Container Features](https://containers.dev/implementors/features/) published to GHCR.

## Usage

Add a Feature to your `devcontainer.json`:

```json
"features": {
    "ghcr.io/nathan1998tw/devcontainer-features/grok:1": {},
    "ghcr.io/nathan1998tw/devcontainer-features/opencode:1": {}
}
```

## Features

| Feature | Description |
|---------|-------------|
| [grok](src/grok) | Installs the Grok Build CLI (`grok`) |
| [opencode](src/opencode) | Installs the OpenCode CLI |
