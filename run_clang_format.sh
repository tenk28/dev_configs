#!/bin/bash

find main components -iname *.h -o -iname *.c | xargs clang-format-16 -i
