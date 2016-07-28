#! /usr/bin/env python
#****************************************************
# GET LIBRARY
#****************************************************
import subprocess, shutil, os
gslab_make_path = os.getenv('gslab_make_path')
subprocess.call('svn export --force -r 33502 ' + gslab_make_path + ' gslab_make', shell = True)
from gslab_make.py.get_externals import *
from gslab_make.py.make_log import *
from gslab_make.py.run_program import *
from gslab_make.py.dir_mod import *

#****************************************************
# MAKE.PY STARTS
#****************************************************

# DEFINE FILE/DIRECTORY LOCATIONS
set_option(makelog = 'log/make.log', output_dir = './log', temp_dir = '', external_dir = './external')

clear_dirs('./external/', './log/')
start_make_logging()

get_externals('externals.txt')

# RUN ALL TESTS
run_stata(program = 'test/test_testgood.do', changedir = True)
run_stata(program = 'test/test_testbad.do', changedir = True)
run_stata(program = 'test/test_save_data.do', changedir = True)
run_stata(program = 'test/test_preliminaries.do', changedir = True)
run_stata(program = 'test/test_select_observations.do', changedir = True)
run_stata(program = 'test/test_build_recode_template.do', changedir = True)
run_stata(program = 'test/test_insert_tag.do', changedir = True)
run_stata(program = 'test/test_load_and_append.do', changedir = True)
run_stata(program = 'test/test_plotcoeffs.do', changedir = True)
run_stata(program = 'test/test_center_estimates.do', changedir = True)
run_stata(program = 'test/test_aivreg.do', changedir = True)

shutil.rmtree('test/temp')

end_make_logging()

shutil.rmtree('gslab_make')
raw_input('\n Press <Enter> to exit.')
