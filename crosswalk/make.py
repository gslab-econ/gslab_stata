#! /usr/bin/env python
#****************************************************
# GET LIBRARY
#****************************************************
import subprocess, shutil, os
gslab_make_path = os.getenv('gslab_make_path')
subprocess.call('svn export --force -r 35000 ' + gslab_make_path + ' gslab_make', shell = True)
from gslab_make.py.get_externals import *
from gslab_make.py.make_log import *
from gslab_make.py.run_program import *
from gslab_make.py.dir_mod import *

#****************************************************
# MAKE.PY STARTS
#****************************************************

# SET DEFAULT OPTIONS
set_option(makelog = 'log/make.log', output_dir = './log', temp_dir = './test/temp')

start_make_logging()

# GET EXTERNALS
get_externals('externals.txt', './external')

# RUN ALL TESTS
run_stata(program = 'test/test_save_crosswalk.do', changedir = True)
run_stata(program = 'test/test_merge_manual_input.do', changedir = True)
run_stata(program = 'test/test_make_input_template.do', changedir = True)

end_make_logging()

shutil.rmtree('gslab_make')
raw_input('\n Press <Enter> to exit.')
