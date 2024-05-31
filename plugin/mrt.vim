if exists('g:loaded_mrt_vim') | finish | endif

command! -nargs=0 MrtBuildWorkspace lua require'mrt'.build_workspace()
command! -nargs=0 MrtBuildCurrentPackage lua require'mrt'.build_current_package()
command! -nargs=0 MrtBuildCurrentPackageTests lua require'mrt'.build_current_package_tests()
command! -nargs=0 MrtSwitchCatkinProfile lua require'mrt'.switch_catkin_profile()

let g:loaded_mrt_vim = 1
