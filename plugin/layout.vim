
let g:loaded_layout = 1

let s:layout_path_def = expand('~/Desktop/layout.json')

command! -bar -nargs=0 LayoutSave  :call s:save_layout()
command! -bar -nargs=0 LayoutLoad  :call s:load_layout()

function! s:replace_winid2path(xs) abort
	for x in a:xs
		if x[0] == 'leaf'
			let bname = bufname(winbufnr(x[1]))
			if !empty(bname)
				let x[1] = fnamemodify(bname, ':p')
			else
				let x[1] = ''
			endif
		else
			call s:replace_winid2path(x[1])
		endif
	endfor
endfunction

function! s:save_layout() abort
	let xs = map(range(1, tabpagenr('$')), { i, x -> winlayout(x) })
	call s:replace_winid2path(xs)
	call writefile([json_encode(xs)], get(g:, 'layout_path', s:layout_path_def))
endfunction

function! s:load_layout() abort
	let tagpage_layouts = json_decode(join(readfile(get(g:, 'layout_path', s:layout_path_def)), ''))
	" keep only one window and one tabpage.
	for n in range(2, tabpagenr('$'))
		only!
		tabclose
	endfor
	only!
	enew
	" restore tabpages and windows
	for n in range(1, len(tagpage_layouts))
		if 1 < n
			tabnew
		endif
		call s:restore_layout(tagpage_layouts[n - 1])
	endfor
	" goto first tabpage
	tabfirst
	execute 1 'wincmd w'
endfunction

function! s:restore_layout(layout) abort
	let id = a:layout[0]
	if (id == 'row') || (id == 'col')
		let winids = [win_getid()]
		for n in range(1, len(a:layout[1]))
			if n < len(a:layout[1])
				if id == 'row'
					rightbelow vnew
				else
					rightbelow new
				endif
				let winids += [win_getid()]
			endif
		endfor
		for n in range(1, len(a:layout[1]))
			call win_gotoid(winids[n - 1])
			call s:restore_layout(a:layout[1][n - 1])
		endfor
	elseif id == 'leaf'
		if filereadable(a:layout[1])
			execute 'edit' a:layout[1]
		endif
	endif
endfunction

