# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

export TOOLS_DIR="$HOME/tools"
PATH=$PATH:$TOOLS_DIR

alias cls='clear'
alias ds='du -h --max-depth=1 | sort -hr'
alias dl='cd /mnt/d/0-Complete'

export mp4recode='find . -maxdepth 1 -type f \( -iname '\''*.mp4'\'' -o -iname '\''*.MP4'\'' \) -exec bash -c '\''for f; do ffmpeg -i "$f" -c:v libx264 -crf 28 -c:a aac -b:a 128k "${f%.*}_.mp4"; done'\'' bash {} +'
