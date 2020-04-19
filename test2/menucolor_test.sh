#!/bin/bash
#menucolor_test.sh

sourceMe=1
source ../bin/dev-loop.sh


echo "textcolor test: $(textcolor 32 this is 32)"

menucolor 31 33 "[A]pply here,[W]hatever it takes, you [M]ust do so: "

echo


