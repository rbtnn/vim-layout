
let g:loaded_layout = 1

command! -nargs=? -complete=file LayoutSave  :call layout#save(<q-args>)
command! -nargs=? -complete=file LayoutLoad  :call layout#load(<q-args>)

