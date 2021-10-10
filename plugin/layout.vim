
let g:loaded_layout = 1

let s:layout_path_def = expand('~/layout.json')

command! -bar -nargs=0 LayoutSave  :call layout#save(get(g:, 'layout_path', s:layout_path_def))
command! -bar -nargs=0 LayoutLoad  :call layout#load(get(g:, 'layout_path', s:layout_path_def))

