# Create Project Command

Create new Android projects from templates.

## Usage

```bash
android create [template-name] --name=<AppName> [--output=<path>] [--minSdk=<api>]
```

## Options

| Option | Description |
|--------|-------------|
| `--name` | Application name (required) |
| `--output` | Destination directory (default: current) |
| `--minSdk` | Minimum SDK version |
| `--list` | List available templates |
| `--verbose` | Enable verbose output |

## Available Templates

| Template | Description | Tags |
|----------|-------------|------|
| `empty-activity` | Empty Activity (default) | compose, activity, agp-9 |

## Examples

```bash
# Create with default template
android create --name="My App"

# Create in specific directory
android create --name="My App" --output=./projects

# List available templates
android create --list

# Set minimum SDK
android create --name="My App" --minSdk=24
```
