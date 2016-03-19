#!/usr/bin/env bash

cd

(find $HOME -type d -print0 | xargs -0 chmod 700) 2>/dev/null
(find $HOME -type f -print0 | xargs -0 chmod 600) 2>/dev/null
chmod 755 $HOME

function make_public {
    find $DIR -type d -print0 | xargs -0 chmod 755
    find $DIR -type f -print0 | xargs -0 chmod 644
}

DIR=$HOME/.virtualenvs
make_public
chmod u+x ~/.virtualenvs/**/bin/*

DIR=$HOME/projects
make_public

DIR=$HOME/q
make_public

DIR=$HOME/bin
make_public

cd
chmod 644 .bash_prompt .bashrc* .gitconfig .screenrc .tmux.conf .vimrc acd_func.sh virtualenv.sh

(find $HOME/bin -type f -print0 | xargs -0 chmod 755) 2>/dev/null

cd ~/projects/reddit_images_and_comments
chmod u+x setjog.sh
./setjog.sh

cd
chmod u+x $0
