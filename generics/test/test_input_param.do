version 13
set more off
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries, loadglob(../input_param.txt)

program main
    display "Generic indicator = $generic_ind"
    display "Household demographics = $hh_demos"
    display "Baseline controls = $base_controls"
    display "Analytic weight = $analytic_weight"
    display "VCE Cluster = $vce_cluster"
    display "Main fixed effect = $main_fixed_effect" 
end

main
