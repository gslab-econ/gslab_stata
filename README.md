# Overview

This repository contains the stata tools used by GSLab. The code in this repository is originally drawn from `trunk/lib/stata` and `trunk/lib/third_party/stata_tools` of the SVN repository `econ-gentzkow-stanford, revision 34,755`.

## Installation

You can install this repository's packages by:
1. Moving their .ado and .hlp files to your `PERSONAL` Stata path. You can find
   the location of your `PERSONAL` path by entering `sysdir` at the Stata 
   console. 

2. Adding a gslab_stata clone's `/ado/` subdirectories to your
   ado-file path. You can do this by adding a line like 
   `adopath + /Users/mrsull/gslab_stata/gslab_misc/ado`
   to your [profile.do](http://www.stata.com/support/faqs/programming/profile-do-file/) script. If you install the gslab_stata packages this way, changing the location 
   or contents of ado files in your clone will change your installation.
