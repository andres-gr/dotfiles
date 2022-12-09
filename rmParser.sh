#!/bin/bash

parser=$HOME/neovim/lib/nvim/parser

if [ ! -d $parser ]; then
  echo "no parser dir"
else
  rm -rf $parser
  echo "removed parser dir"
fi

