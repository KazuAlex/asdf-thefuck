<div align="center">

# asdf-thefuck [![Build](https://github.com/KazuAlex/asdf-thefuck/actions/workflows/build.yml/badge.svg)](https://github.com/KazuAlex/asdf-thefuck/actions/workflows/build.yml) [![Lint](https://github.com/KazuAlex/asdf-thefuck/actions/workflows/lint.yml/badge.svg)](https://github.com/KazuAlex/asdf-thefuck/actions/workflows/lint.yml)


[thefuck](https://gitlab.com/KazuAlex/asdf-thefuck) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add thefuck
# or
asdf plugin add thefuck https://github.com/KazuAlex/asdf-thefuck.git
```

thefuck:

```shell
# Show all installable versions
asdf list-all thefuck

# Install specific version
asdf install thefuck latest

# Set a version globally (on your ~/.tool-versions file)
asdf global thefuck latest

# Now thefuck commands are available
thefuck --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/KazuAlex/asdf-thefuck/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [KazuAlex](https://github.com/KazuAlex/)
