
function! layout#save(path) abort
	let xs = map(range(1, tabpagenr('$')), { i, x -> winlayout(x) })
	call s:replace_winid2path(xs)
	call writefile([json_encode(xs)], a:path)
endfunction

function! layout#load(path) abort
	let tagpage_layouts = json_decode(join(readfile(a:path), ''))
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
			execute printf('edit %s', fnameescape(a:layout[1]))
		endif
	endif
endfunction

function! s:replace_winid2path(xs) abort
	for x in a:xs
		if x[0] == 'leaf'
			let bname = bufname(winbufnr(x[1]))
			if !empty(bname) && filereadable(bname)
				let x[1] = fnamemodify(bname, ':p')
			else
				let x[1] = ''
			endif
		else
			call s:replace_winid2path(x[1])
		endif
	endfor
endfunction

