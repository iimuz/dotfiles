#!/bin/bash
# mac環境でhomebrewとbrew-caskをまとめて更新するためのスクリプト

# homebrewの更新
#brew update;
#brew upgrade;

# brew-caskの更新
#brew cask update;
# ソフトウェアの更新
apps=($(brew cask list));
for a in ${apps[@]};
do
  echo <$(brew cask info $a)
  if grep -q "Not installed" < <$(brew cask info $a);
  then
    #brew cask install $a;
    echo $a
  fi
done
# 古いバージョンのソフトウェアの削除
for c in /opt/homebrew-cask/Caskroom/*;
do
  vl=(`ls -t $c`) && for v in "${vl[@]:1}";
  do
    #rm -rf "$c/$v";
  done
done
