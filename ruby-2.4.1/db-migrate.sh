#!/bin/bash

cd /$_USER && if [[ -n $(find . -maxdepth 1 \( -iname 'rakefile' -o -iname 'rakefile.rb' \) -print -quit) ]]; then
  rake db:migrate
else
  echo "No rakefile found in '$PWD'"
fi
