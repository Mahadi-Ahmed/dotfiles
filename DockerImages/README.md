# Docker Images for Dotfiles Testing

This directory contains different Dockerfiles for testing dotfiles configurations in isolated environments.

## Available Images

### 1. Dockerfile-simple
**Purpose**: Minimal Ubuntu environment with dotfiles cloned from GitHub (committed changes only).

**Use when**: You want to test the committed version of your dotfiles in a clean environment.

```bash
docker build -f DockerImages/Dockerfile-simple -t 'dotfiles:simple' . && \
docker run -d --name dotfilesSimple -it dotfiles:simple && \
docker exec -it dotfilesSimple /bin/zsh
```

**Cleanup**:
```bash
docker stop dotfilesSimple && docker rm dotfilesSimple
```

---

### 2. Dockerfile-local
**Purpose**: Minimal Ubuntu environment with local dotfiles copied from your host machine.

**Use when**: You want to test uncommitted changes before committing them.

```bash
docker build -f DockerImages/Dockerfile-local -t 'dotfiles:local' . && \
docker run -d --name dotfilesLocal -it dotfiles:local && \
docker exec -it dotfilesLocal /bin/zsh
```

**Alternative with live mounting** (changes reflect immediately without rebuilding):
```bash
docker build -f DockerImages/Dockerfile-local -t 'dotfiles:local' . && \
docker run -d --name dotfilesLocal -it -v $(pwd):/home/developer/dotfiles dotfiles:local && \
docker exec -it dotfilesLocal /bin/zsh
```

**Cleanup**:
```bash
docker stop dotfilesLocal && docker rm dotfilesLocal
```

---

### 3. Dockerfile-ubuntu-zsh
**Purpose**: Full-featured development environment with Neovim, Python, Rust, Node.js, and all development tools.

**Use when**: You want to test a complete development setup with all dependencies installed.

**Features**:
- Neovim (built from source)
- Python 3 with pip and venv
- Node.js 20.x with npm
- Rust toolchain
- Development tools: ripgrep, fd, fzf, lazygit
- Oh My Zsh with Powerlevel10k theme
- FiraCode Nerd Font
- Tree-sitter CLI
- Perl with Neovim::Ext

```bash
docker build -f DockerImages/Dockerfile-ubuntu-zsh -t 'dotfiles:full' . && \
docker run -d --name dotfilesFull -it dotfiles:full && \
docker exec -it dotfilesFull /bin/zsh
```

**Cleanup**:
```bash
docker stop dotfilesFull && docker rm dotfilesFull
```

---

## Quick Commands

### Remove all dotfiles containers:
```bash
docker rm -f dotfilesSimple dotfilesLocal dotfilesFull
```

### Remove all dotfiles images:
```bash
docker rmi dotfiles:simple dotfiles:local dotfiles:full
```

### Build all images:
```bash
docker build -f DockerImages/Dockerfile-simple -t 'dotfiles:simple' . && \
docker build -f DockerImages/Dockerfile-local -t 'dotfiles:local' . && \
docker build -f DockerImages/Dockerfile-ubuntu-zsh -t 'dotfiles:full' .
```

---

## Notes

- All images create a non-root user `developer` with password `password` and sudo access
- The build context should be the dotfiles root directory (parent of DockerImages/)
- `.dockerignore` is configured to exclude unnecessary files from the build context
