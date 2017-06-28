import os
import gslab_scons as gs


def main():
    log = 'log/make.log'
    if os.path.isfile(log):
        os.remove(log)

    scripts = ['insert_tag', 'center_estimates', 'select_observations',
               'testbad',    'save_data',        'preliminaries', 
               'testgood',   'aivreg',           'build_recode_template',
               'plotcoeffs', 'load_and_append',]
    for script in scripts:
        run_test('test/test_%s.do' % script, log)


def run_test(script, log):
    '''Run a test and append results to log.'''
    gs.build_stata(source = script, 
                   target = log, 
                   env    = {'user_flavor': None})
    log_dir = os.path.dirname(log)
    
    # Read the log for the script
    script_log = '%s/sconscript.log' % log_dir
    log_contents = open(script_log, 'rU').read()
    
    # Add log for individual script to the master log
    with open(log, 'ab') as f:
        f.write(log_contents)

    os.remove(script_log)


main()
