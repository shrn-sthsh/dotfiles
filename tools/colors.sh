#!/bin/bash

awk 'BEGIN \
{
  # color seperation pattern
  s="/\\/\\/\\/\\/\\";
  s=s s s s s s s;

  # print color in 76 columns
  for (column = 0; column < 77; ++column)
  {
    r = 255 - (column * 255 / 76);
    g = (column * 510 / 76);
    b = (column * 255 / 76);
    if (g > 255) g = 510 - g;

    printf "\033[48;2;%d;%d;%dm", r, g, b;
    printf "\033[38;2;%d;%d;%dm", 255 - r, 255 - g, 255 - b;
    printf "%s\033[0m", substr(s, column + 1, 1);
  }

  printf "\n";
}'
