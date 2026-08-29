# Grok (grok)

Installs the [Grok Build](https://x.ai/cli) CLI (`grok` and `agent`) using the official installer.

## Example Usage

```json
"features": {
    "ghcr.io/nathan1998tw/devcontainer-features/grok:1": {}
}
```

Pin a version or channel:

```json
"features": {
    "ghcr.io/nathan1998tw/devcontainer-features/grok:1": {
        "version": "1.0.13",
        "channel": "stable"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|------------|-------------|------|---------------|
| version | Version of Grok to install. Use `latest` or a version like `1.0.13`. | string | latest |
| channel | Release channel when `version` is `latest`. `stable`, `alpha`, or `enterprise`. | string | stable |
