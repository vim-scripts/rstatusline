"show the buffer list on status line.
"the only setting option is g:cur_anchor which is the middle position
"of the list-window.
"if you want to set buffer list to show N buffers,set g:statusline_size = N
"
"author:Ruoshan Huang (ruoshan.huang@gmail.com)
"
"20120501:the space between buffers is only one <space> now
"20140425:fix the long exists problem for not-showing enough buffer-list.
"         add a human-friendly option for user customization
"
if exists("g:rstatusline_instance")
    finish
endif
let g:rstatusline_instance = "exists"

if !exists("g:statusline_size")
    let g:statusline_size = 5
endif

set laststatus=2
"hi StatusLine term=bold,reverse cterm=bold,reverse ctermfg=238 ctermbg=253
"hi StatusLineNC term=reverse cterm=reverse ctermfg=238 ctermbg=253
"hi Hl_status term=bold,reverse cterm=bold,reverse ctermfg=238 ctermbg=199

if !exists("g:cur_anchor")
    let g:cur_anchor = 0
endif

function! MyStatusline()
    "        |=========|          -> window-size container
    "######## ######### ######### -> buffer list (longer),only the part
    "             ^--anchor          'below' the container is shown.
    "                                
    "by default,only show 9 (9/2+1=5) buflist at most,9 is the window-size.
    "buflist can be much longer than window-size,but just show the part that
    "fit in window-size.
    "when cur_idx is out of the window,it is called out-of-sight.
    "when outofsight,move a step (=g:statusline_size) to make cur_idx is in sight again.
    let last_buf_nr = bufnr('$')
    let cur_nr = bufnr('%')
    let hl_cur_buf = '%#Hl_status#'.fnamemodify(bufname('%'),':t').'%*'

    "get all the listed buffer into buflist[]
    "NOTE: the bufnr for some deleted buffer cannot be reclaim, so I have to
    "add a reverse `lookup` list to index to the real bufnr
    "unlisted buffer is replace by <NULL>
    let i = 1            "bufnr start from `1`, but the vim list start from index `0`
    let j = 0            "the default reverse lookup value
    let lookup = [j]     "lookup is the reverse dict for bufnumber to index in buflist
    let buflist = []
    while i <= last_buf_nr
        "if getbufvar(i, '&ma') == 0 || !buflisted(i)
        if buflisted(i)
            call add(buflist,fnamemodify(bufname(i),':t'))
            let j += 1
        endif
        call add(lookup, j)
        let i += 1
    endwhile

    "find the window.
    let cur_idx = lookup[cur_nr]
    while 1
        if g:cur_anchor - cur_idx >= 0
            "move to left buf and be out of sight,so move window-size a step left
            let g:cur_anchor -= g:statusline_size
        elseif cur_idx - g:cur_anchor > g:statusline_size
            "move to right buf and be out of sight,so move window-size a step right
            let g:cur_anchor += g:statusline_size
        else
            break
        endif
    endwhile

    "show the buffer name in the buflist[] if the buffer is in the
    "window-size container
    let buflist_str = ''
    let i=0
    while i < len(buflist)
        if i < g:cur_anchor
            let i += 1
            continue
        endif
        if i >= (g:cur_anchor + g:statusline_size)
            break
        endif
        if i != cur_idx - 1
            let buflist_str = buflist_str.' '.buflist[i]
        else
            let buflist_str = buflist_str.' '.hl_cur_buf
        endif
        let i += 1
    endwhile
    return '%< %m%r <'.buflist_str.' >'.'%= %l,%c%V/%L %P Total:'.len(buflist).' '
endfunction
au BufEnter,BufNew,BufDelete,BufWinEnter * let &l:statusline=MyStatusline()
