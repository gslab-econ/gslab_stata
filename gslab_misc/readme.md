This library contains commonly-used gslab stata tools.

## Prerequisites
- `mmerge`. Install by entering the following at the
  Stata console.
```stata
net from http://www.stata.com
net cd stb
net cd stb53
net describe dm75
net install dm75, replace
```


## Installation

Enter the following at the Stata console.

```stata
net from https://raw.githubusercontent.com/gslab-econ/gslab_stata/master/gslab_misc/ado          
net install benchmark,             replace
net install build_recode_template, replace
net install cf_mg,                 replace
net install checkdta,              replace
net install cutby,                 replace
net install dta_to_txt,            replace
net install dummy_missings,        replace
net install fillby,                replace
net install genlistvar,            replace
net install insert_tag,            replace
net install leaveout,              replace
net install load_and_append,       replace
net install loadglob,              replace
net install matrix_to_txt,         replace
net install oo,                    replace
net install ooo,                   replace
net install oooo,                  replace
net install plotcoeffs_nolab,      replace
net install plotcoeffs,            replace
net install predict_list,          replace
net install preliminaries,         replace
net install rankunique,            replace
net install ren_lab_file,          replace
net install save_data,             replace
net install select_observations,   replace
net install sortunique,            replace
net install testbad,               replace
net install testgood,              replace
```
