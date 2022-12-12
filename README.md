- install [homebrew](https://brew.sh/)
- run next command to create `devel` directory and clone repo into it
```
mkdir $HOME/devel && git -C $HOME/devel clone https://github.com/andres-gr/dotfiles.git
```

- run next command to `cd` into repo and run `init` script
```
cd $HOME/devel/dotfiles && chmod +x init.sh && ./init.sh
```
