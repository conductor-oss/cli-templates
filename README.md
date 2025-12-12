# CLI Templates

This repository contains different templates which are used by the Conductor CLI and other tools.

The templates are written in [Mustache](https://mustache.github.io/mustache.5.html).

The CLI template repository is configurable, so you can fork this repo and create your own templates.

## How It Works

Template discovery is done via the **manifest** (`manifest.json` file) and the **project descriptor** file `bp.json` (bp as in "boilerplate" :)).

## Repository Structure

### manifest.json

The manifest file defines the available templates organized by language and framework. It serves as the catalog that tools use to discover and present available templates to users.

**Structure:**
```json
{
  "languages": [
    {
      "name": "Language Name",
      "frameworks": [
        {
          "name": "Framework Name",
          "templates": [
            {
              "name": "template-name",
              "description": "Template description",
              "path": "path/to/template"
            }
          ]
        }
      ]
    }
  ]
}
```

**Fields:**
- `languages`: Array of supported programming languages
  - `name`: Display name of the language (e.g., "Go", "Java", "Python", "Javascript")
  - `frameworks`: Array of frameworks for this language
    - `name`: Framework name (e.g., "core", "spring")
    - `templates`: Array of available templates
      - `name`: Template identifier (e.g., "basic-worker")
      - `description`: Human-readable description of what the template provides
      - `path`: Relative path to the template directory from the repository root

### bp.json (Boilerplate Descriptor)

Each template directory contains a `bp.json` file that defines the template's structure and required variables. This file tells the CLI which files to process and what information to collect from the user.

**Structure:**
```json
{
  "files": [
    {
      "name": "filename.ext",
      "fields": [
        {
          "name": "variable_name",
          "prompt": "Question to ask the user:"
        }
      ],
      "mode": "0755"
    }
  ]
}
```

**Fields:**
- `files`: Array of files in the template
  - `name`: Filename (can include subdirectories, e.g., "src/main/App.java")
  - `fields`: (Optional) Array of variables used in this file
    - `name`: Variable name (used in Mustache template as `{{variable_name}}`)
    - `prompt`: The question to ask the user when collecting this value
  - `mode`: (Optional) Unix file permissions in octal format (e.g., "0755" for executable files)

**Note:** Files without a `fields` array are copied as-is without any variable substitution.

## Template Variable Syntax

Templates use Mustache syntax for variable substitution. Variables are defined in the `bp.json` file and replaced during template instantiation.

**Syntax:** `{{variable_name}}`

**Example:**
```javascript
const taskName = "{{taskname}}";
const apiKey = "{{auth_key}}";
```

When the user instantiates this template and provides values:
- `taskname` = "my_task"
- `auth_key` = "abc123"

The result will be:
```javascript
const taskName = "my_task";
const apiKey = "abc123";
```

## Common Variables

The templates in this repository commonly use these variables:

- `appname`: Application or project name
- `taskname`: Task definition name for Conductor workers
- `server_url`: Conductor server URL
- `auth_key`: Authentication key ID
- `auth_secret`: Authentication secret

## Creating Your Own Templates

1. **Fork this repository**
2. **Create a new template directory** following the structure: `language/type/framework/`
3. **Add your template files** with Mustache variables where needed
4. **Create a `bp.json`** file describing your template's files and variables
5. **Update `manifest.json`** to include your new template
6. **Configure your CLI** to point to your forked repository

## Example Template Structure

```
python/worker/core/
├── bp.json              # Template descriptor
├── main.py              # File with {{server_url}}, {{auth_key}}, etc.
├── worker.py            # File with {{taskname}}
├── requirements.txt     # Static file (no variables)
└── README.md            # Static file (no variables)
```
