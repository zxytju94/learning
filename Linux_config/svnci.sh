#!/bin/bash

svn st | grep -v "^?" | grep -v "\.a" > o
vim -esS /home/xnli/scripts/svnci.esS o
gvim o