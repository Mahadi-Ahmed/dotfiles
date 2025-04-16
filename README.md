# dotfiles

[nvim config](https://github.com/Mahadi-Ahmed/nvim)

### Manage dotfiles with [gnu stow](https://www.gnu.org/software/stow/)

Greate article on stow:
#### [Managage dotfiles with GNU Stow](https://dr563105.github.io/blog/manage-dotfiles-with-gnu-stow/)

[Sync your .dotfiles with git and GNU #Stow like a pro!](https://www.youtube.com/watch?v=CFzEuBGPPPg)

### stow commands

##### stow --dotfiles [folder i want to link]

##### stow -n (n stand for no) it is used to preview what it would do without actually doing it.

##### stow -v (v stands for verbose)

##### stow -S (S stands for stow)

##### stow -D for unstow for unlinking

##### stow t (t stands for target directory)
t ~ (means target directory) it's not usually taught since it's the default, but it's better to specify.

##### stow -nvSt ~ * (* stands for everything)
Use this when you want to restore a file from the repo when setting up a new env, remove the **-n** after you've tried it once 

##### stow --adopt -nvt ~ * (running a test) since -n is still stating "no"

##### stow --adopt -vt ~ *
be careful with the --adopt flag, it's only needed at the beginning it's not needed later
showing how the original file becomes a symlink

##### stow -vDt ~ (insert directory) this would unlink the desired dot file,s yet it won't delete them.

stow has problems understanding slashes/for/paths
using ls -al in the terminal to see where symblinks are connected to.

#### [Your unofficial guide to dotfiles on GitHub](https://dotfiles.github.io)
