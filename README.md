# setup of pre-commit hook

## Installation of dependencies
See the following instructions: https://github.com/antonbabenko/pre-commit-terraform#1-install-dependencies
- The dependencies of step 1 have been installed (mac-only command):
```brew install pre-commit terraform-docs tflint tfsec checkov terrascan infracost tfupdate minamijoyo/hcledit/hcledit jq```

-  Installed the pre-commit hook globally:
```
git config --global init.templateDir ~/.git-template
pre-commit init-templatedir -t pre-commit  ~/.git-template
```

## .pre-commit-config.yaml

This file contains the hooks that will be called when running pre-commit.
then run

```pre-commit run -a```