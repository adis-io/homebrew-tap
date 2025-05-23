# Homebrew Tap

If you would like to use formulas in this repository, start by tapping it.

```bash
brew tap adis-io/homebrew-tap
```

## Setup AMD64 Homebrew on your Apple Silicon Mac

Some software that we use may only support AMD64 architecture. Therefore if
you use a Mac with Apple Silicon you must also install one version of Homebrew
for AMD64 if you need to use any software here that does not have support for
ARM64.

```bash
softwareupdate --install-rosetta --agree-to-license
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```
Then to use the AMD64 version of brew you should add an alias to ~/.zshrc. Use this command for that.

*If you use bash, change ~/.zshrc to ~/.bashrc*

```bash
echo 'alias axbrew="arch -x86_64 /usr/local/homebrew/bin/brew"' >> ~/.zshrc
```

## Formulas

### Elasticsearch@6.8

Will install Elasticsearch version 6.8

#### Using AMD64

```bash
brew install elasticsearch@6.8
brew services start elasticsearch@6.8
```

#### Using ARM64 (Apple Silicon)

```bash
axbrew install elasticsearch@6.8
axbrew services start elasticsearch@6.8
```

### Elasticsearch@7.10.2

Will install Elasticsearch version 7.10.2

#### Using AMD64

```bash
brew install elasticsearch@7.10.2
brew services start elasticsearch@7.10.2
```

#### Using ARM64 (Apple Silicon)

```bash
axbrew install elasticsearch@7.10.2
axbrew services start elasticsearch@7.10.2
```
