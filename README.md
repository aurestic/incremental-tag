# Create an incremental tag

It automatically create the tag of the latest version incrementally.

For example, in our case for each module our versions correspond to [framework version number]. [Major version]. [Minor Version]: '8.0.15.45' or '11.0.56.23'or '13.0.1.4'.

This action incrementally updates the minor version so that '8.0.15.45' becomes '8.0.15.46'.

## Input parameters

These are the parameters you can use with the action:

- `flag_branch`: [optional] Flag indicating that the script should look for the lastest tag depending on the branch to which the merge is made. That is, if we are in the branch '8.0' and a merge of a PR is made, it will take the last tag '8.0.15.45' and not '11.0.56.23'.
- `message`: [optional] Message for the tag
- `prev_tag`: [optional] String to be added before the final tag, for example this parameter takes the value 'v' the final tag will be 'v8.0.15.45'.

## Usage

You can use a workflow like this:

```yaml
name: Add latest tag to new release
on:
  push:
    branches: ['8.0', '9.0', '10.0', 11.0', 12.0', 13.0', 14.0', 15.0', 16.0']

jobs: 
  run:
    name: Bump tag
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Create an incremental tag
      uses: aurestic/incremental-create-tag@1.0.7
      with:
        flag_branch: true
        message: Bump version
        prev_tag: 'v'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

