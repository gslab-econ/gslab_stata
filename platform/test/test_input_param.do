version 13
set more off
adopath + ../external/lib/stata/gslab_misc/ado
preliminaries, loadglob(../input_param.txt)

program main
    display "cbb10 cbb13 cbc05 cbd01 cbd02 cbf01 cbf02 cbf03 cbg01 cbj08 cbt03 cbe08 cbe14 cbg05 cbh01 cbh02 cbl01 cbp02 = $all_issues"
    display "cbb10 cbb13 cbc05 cbd01 cbd02 cbe08 cbe14 cbh01 cbh02 cbp02 = $econ_issues"
    display "cbf01 cbf02 cbf03 cbg01 cbj08 cbg05 cbl01 cbt03 = $soc_issues"
    display "cbc05 cbd01 cbd02 cbf01 cbf02 cbg01 cbe08 cbe14 cbg05 cbh01 cbh02 cbl01 = $subset_issues"
    display "cbc05 cbd01 cbd02 cbe08 cbe14 cbh01 cbh02 = $subsecon_issues" 
    display "cbf01 cbf02 cbg01 cbg05 cbl01 = $subssoc_issues"
end

main


