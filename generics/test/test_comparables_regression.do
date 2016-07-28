version 13
set more off
adopath + ../ado
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries, loadglob(../input_param.txt)

program main
    testgood test_baseline_regression, in_file(../data/test_regression_input) ///
                                       out_file(../data/coeffs_output.txt) ///
                                       coeffs_compare_file(../data/coeffs_docs_compare_clustering.txt) ///
                                       group_id(comparable_id) ///
                                       indep_vars(svy_college1 svy_pharmdoc1 svy_other_health1) ///
                                       generic_ind($generic_ind) hh_demos($hh_demos) ///
                                       analytic_weight($analytic_weight) main_fixed_effect($main_fixed_effect) ///
                                       mean_var(svy_college1) condition_var(svy_pharmdoc1) vce_cluster($vce_cluster)
                                       
    testgood test_baseline_regression, in_file(../data/test_regression_input) ///
                                       out_file(../data/coeffs_output.txt) ///
                                       coeffs_compare_file(../data/coeffs_docs_compare_noclustering.txt) ///
                                       group_id(comparable_id) ///
                                       indep_vars(svy_college1 svy_pharmdoc1 svy_other_health1) ///
                                       generic_ind($generic_ind) hh_demos($hh_demos) ///
                                       analytic_weight($analytic_weight) main_fixed_effect($main_fixed_effect) ///
                                       mean_var(svy_college1) condition_var(svy_pharmdoc1)
end

/*
When option vce_cluster is specified, we're asserting that we can match a subset of the results in
/analysis/Generics (All Categories)/output/coeffs_docs.txt.
When option vce_cluster is not specified, we're asserting we can match the results for the same subset
of regressions with standard errors given by OLS asymptotic theory instead of being robust to clustering. 
*/

program test_baseline_regression
    syntax, in_file(str) out_file(str) coeffs_compare_file(str) group_id(str) indep_vars(str) ///
        generic_ind(str) hh_demos(str) analytic_weight(str) main_fixed_effect(str) ///
        [ mean_var(str) condition_var(str) vce_cluster(str) ]
        
    baseline_regression, in_file(`in_file') out_file(`out_file') ///
                         group_id(`group_id') indep_vars(`indep_vars') ///
                         generic_ind(`generic_ind') hh_demos(`hh_demos') ///
                         analytic_weight(`analytic_weight') main_fixed_effect(`main_fixed_effect') ///
                         mean_var(`mean_var') condition_var(`condition_var') vce_cluster(`vce_cluster')
                         
    quietly insheet using `out_file', clear
    quietly save ../data/coeffs_output, replace
    
    quietly insheet using `coeffs_compare_file', clear
    quietly save ../data/coeffs_compare, replace
    
    quietly use ../data/coeffs_output, clear
    capture cf _all using ../data/coeffs_compare
    assert _rc == 0
    
    quietly erase `out_file'
    quietly erase ../data/coeffs_output.dta
    quietly erase ../data/coeffs_compare.dta
end

* EXECUTE
main


