Maltybrew
=========

Maltybrew allows you to install multiple instances of [Homebrew] and switch between them ease.


Requirements
------------

Same as Homebrew. Intel CPU Mac, OS X 10.5 or higher and Xcode command line tools.


Installation
------------

Just download maltybrew.sh in anywhere in PATH and make it executable. If ~/bin is in your PATH, type these.

```shell
cd ~/bin
curl -o maltybrew https://raw.github.com/webos-goodies/Maltybrew/master/maltybrew.sh
chmod a+x maltybrew
```

How to use
----------

You can install any number of homebrew instance with a particular name using "new" subcommand. The following example installs an instance named "dev".

```shell
maltybrew new dev
```

Once a homebrew instance is installed, you can activate it using "switch" subcommand. It invoke subshell and modify its environment appropriately.

```shell
maltybrew switch dev
```

Now you can install any formula and use it.

```shell
brew install mysql
mysql --version
-> mysql  Ver 14.14 Distrib 5.5.29, for osx10.8 (i386) using readline 5.1
```

If you exit the subshell, the homebrew instance is deactivated.

```shell
exit
mysql --version
-> -bash: mysql: command not found
```

The actual homebrew instance is placed at ~/.maltybrew/<name>. If you no longer need it, just remove the directory.


maltyrc
-------

~/.maltybrew/<name>/maltyrc is a shell script executed when the instance is activated / deactivated. See comments in this file for details.

[Homebrew]: http://mxcl.github.com/homebrew/
