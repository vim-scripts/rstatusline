"show the buffer list on status line.
"the only setting option is g:cur_anchor which is the middle position
"of the list-window.
"if you want to set buffer list to show N buffers,set g:cur_anchor=N/2+1
"currently,N should be an odd number.
"
"author:Ruoshan Huang (ruoshan.huang@gmail.com)
"

set laststatus=2
hi StatusLine term=bold,reverse cterm=bold,reverse ctermfg=238 ctermbg=253
hi StatusLineNC term=reverse cterm=reverse ctermfg=238 ctermbg=253
hi Hl_status term=bold,reverse cterm=bold,reverse ctermfg=238 ctermbg=199

if !exists("g:cur_anchor")
    let g:cur_anchor=5
endif
let g:half_winsize=g:cur_anchor-1
function! MyStatusline()
    "        |=========|          -> window
    "######## ######### ######### -> buffer list (longer),only the part
    "             ^--anchor          'below' the window is shown.
    "                                
    "by default,only show 9 (9/2+1=5) buflist at most,9 is the window size.
    "buflist can be much longer than window size,but just show the part that
    "fit in window size.
    "when cur_nr is out of the window,it is called out-of-sight.
    "when outofsight,move a step (=g:half_winsize) to make cur_nr is in sight again.
    let last_buf_nr=bufnr('$')
    let cur_nr=bufnr('%')
    let hl_cur_buf='%#Hl_status#'.fnamemodify(bufname('%'),':t').'%*'
    let buflist_str='<'
    while 1
        if g:cur_anchor-cur_nr > g:half_winsize
            "move to left buf and be out of sight,so move window a step left
            let g:cur_anchor-=g:half_winsize+1
        elseif cur_nr-g:cur_anchor > g:half_winsize
            "move to right buf and be out of sight,so move window a step right
            let g:cur_anchor+=g:half_winsize+1
        else
            break
        endif
    endwhile
    let i=1
    let buflist_list=[]
    while i <= last_buf_nr
        if getbufvar(i, '&ma') == 0
            call add(buflist_list,'')
        else
            call add(buflist_list,fnamemodify(bufname(i),':t'))
        endif
        let i+=1
    endwhile
    let i=0
    while i < last_buf_nr
        if abs(g:cur_anchor-i-1) > g:half_winsize
            let i+=1
            continue
        endif
        if i != cur_nr-1
            let buflist_str=buflist_str.' '.buflist_list[i]
        else
            let buflist_str=buflist_str.' '.hl_cur_buf
        endif
        let i+=1
    endwhile
    return '%< %m%r '.buflist_str.' >'.'%= %l,%c%V/%L %P %n/%{bufnr("$")} '
endfunction
set statusline=%!MyStatusline()
