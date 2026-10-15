---
title: ai-marketplace
description: Marketplace for AVEVA skills and agents across products and workflows.
---

## ai-marketplace

An AVEVA plugin marketplace for skills and agents across AVEVA products and
workflows. The marketplace is not limited to Unified Engineering; each plugin
groups capabilities for a product or area of work.

## Available Plugins

| Plugin | Purpose |
| --- | --- |
| [unified-engineering](./plugins/unified-engineering/README.md) | Skills and agents for AVEVA Unified Engineering customization and add-in development |

The `unified-engineering` plugin includes eight skills, the Unified Engineering
Customization Manager agent, add-in templates, skill-owned PowerShell scripts, and
UE API examples. Its prerequisites and development workflows are documented in
the [plugin README](./plugins/unified-engineering/README.md).

## Getting Started

1. Add this repository as a plugin marketplace in your supported client.
2. Select and install the plugin for your workflow, such as `unified-engineering`.
3. Follow that plugin's README for prerequisites and available skills and agents.

The marketplace identifier is `ai-marketplace`. Plugin registration is maintained
in the [Copilot marketplace manifest](./.github/plugin/marketplace.json) and the
[Claude Code marketplace manifest](./.claude-plugin/marketplace.json).

### Claude Code

Start Claude Code in this repository, then run:

```text
/plugin marketplace add .
/plugin install unified-engineering@ai-marketplace
```

Both clients use the same bundled skills and agents. The Unified Engineering
plugin's Windows, PowerShell, and UE prerequisites still apply.

## Repository Structure

```text
ai-marketplace/
  .claude-plugin/marketplace.json
  .github/plugin/marketplace.json
  plugins/
    unified-engineering/
      .claude-plugin/plugin.json
      .github/plugin/plugin.json
      README.md
      agents/
      skills/
  tests/
    Invoke-PesterTests.ps1
    unified-engineering/
      skills/
```

## Adding Plugins

Place each plugin under `plugins/`, register it in both marketplace manifests, and
provide both `.github/plugin/plugin.json` and `.claude-plugin/plugin.json`.
Keep each plugin's name, description, and version consistent across its manifests
and matching marketplace metadata. Claude Code discovers the standard `skills/`
and `agents/` directories without Copilot's `skills` or `agents`
manifest fields.

Document each plugin's skills, agents, and prerequisites in its own README. Keep
product-specific workflows inside the owning plugin so the marketplace can host
capabilities from across AVEVA. Mirror plugin test folders under `tests/` and
update [CODEOWNERS](./CODEOWNERS) for new plugin and test paths.

## Running Tests

With PowerShell 7 and Pester 5 installed, run the repository's unit tests:

```powershell
./tests/Invoke-PesterTests.ps1
```

## License

See [LICENSE](./LICENSE).