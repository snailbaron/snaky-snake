
" Colors and syntax rules
function! SetColors()
    highlight clear
    syntax clear

    set nocursorline

    syntax match SnakeHead /H/
    syntax match SnakeBody /S/
    syntax match Wall /#/

    syntax match ArrowBody /[.:']\+/ contained
    syntax match Chosen /{.*}/ contains=ArrowBody
    syntax match Quotes /[{}]/

    highlight SnakeHead guibg=DarkRed guifg=DarkRed
    highlight SnakeBody guibg=Blue guifg=Blue
    highlight Wall guibg=Gray guifg=Gray
    highlight ArrowBody guifg=Blue
    "highlight Quotes guibg=Gray20 guifg=Gray20
endfunction

" Common parameters
let s:fieldWidth = 60
let s:fieldHeight = 30
let s:panelHeight = 10


function! PutSign(x, y, c)
    call cursor(a:y + 1, 2*a:x + 1)
    exec "normal R" . a:c . a:c
endfunction

function! DrawLine(x, y, dx, dy, l, c)
    for i in range(0, a:l - 1)
        call PutSign(a:x + a:dx*i, a:y + a:dy*i, a:c)
    endfor
endfunction


let s:upArrow = [
\   "        {   .   }         ",
\   "        { .:::. }         ",
\   "        {  :::  }         ",
\   "    .   {  :::  }    .    ",
\   "  .:::::::     ::::::::.  ",
\   "   ':''''' ... '''''':'   ",
\   "           :::            ",
\   "           :::            ",
\   "          ':::'           ",
\   "            '             "
\]

let s:downArrow = [
\   "            .             ",
\   "          .:::.           ",
\   "           :::            ",
\   "    .      :::       .    ",
\   "  .:::::::     ::::::::.  ",
\   "   ':''''' ... '''''':'   ",
\   "        {  :::  }         ",
\   "        {  :::  }         ",
\   "        { ':::' }         ",
\   "        {   '   }         "
\]


let s:leftArrow = [
\   "            .             ",
\   "          .:::.           ",
\   "           :::            ",
\   " {  .     }:::       .    ",
\   " {.:::::::}    ::::::::.  ",
\   " { ':'''''}... '''''':'   ",
\   "           :::            ",
\   "           :::            ",
\   "          ':::'           ",
\   "            '             "
\]


let s:rightArrow = [
\   "            .             ",
\   "          .:::.           ",
\   "           :::            ",
\   "    .      :::{      .  } ",
\   "  .:::::::    {::::::::.} ",
\   "   ':''''' ...{'''''':' } ",
\   "           :::            ",
\   "           :::            ",
\   "          ':::'           ",
\   "            '             "
\]

function! DrawBlock(x, y, block)
    for i in range(0, len(a:block)-1)
        call cursor(a:y+i, a:x)
        exec "normal R" . a:block[i]
    endfor
endfunction


function! DrawDirection(dir)
    if a:dir == [ -1, 0 ]
        let arrow = s:leftArrow
    elseif a:dir == [ 1, 0 ]
        let arrow = s:rightArrow
    elseif a:dir == [ 0, -1 ]
        let arrow = s:upArrow
    elseif a:dir == [ 0, 1 ]
        let arrow = s:downArrow
    endif
        
    call DrawBlock(3, s:fieldHeight+3, arrow)
endfunction


function! PrepareField()
    " Clear field
    exec "normal ggVGd"
    let line = repeat("  ", s:fieldWidth + 2)
    for i in range(1, s:fieldHeight+s:panelHeight+3)
        call setline(i, line)
    endfor

    " Draw borders
    call DrawLine(0, 0, 1, 0, s:fieldWidth+2, "#")
    call DrawLine(0, s:fieldHeight + 1, 1, 0, s:fieldWidth+2, "#")
    call DrawLine(0, s:fieldHeight + s:panelHeight + 2, 1, 0, s:fieldWidth+2, "#")
    call DrawLine(0, 0, 0, 1, s:fieldHeight+s:panelHeight+3, "#")
    call DrawLine(s:fieldWidth + 1, 0, 0, 1, s:fieldHeight+s:panelHeight+2, "#")
endfunction

function! ClearField()
    let line = "##" . repeat("  ", s:fieldWidth) . "##"
    for i in range(2, s:fieldHeight+1)
        call setline(i, line)
    endfor
endfunction


function! DrawSnake(snake)
    call PutSign(a:snake[0], a:snake[1], "H")
    for i in range(2, len(a:snake)-1, 2)
        call PutSign(a:snake[i], a:snake[i+1], "S")
    endfor
endfunction

function! DrawDir(dir)
endfunction


function! Run()
    call SetColors()

    call PrepareField()


    let snake = [ 3, 3, 2, 3, 1, 3 ]
    let dir = [ 1, 0 ]

    call DrawSnake(snake)
    call DrawDirection(dir)
    redraw

    let finished = 0
    while finished == 0

        while getchar(1)
            let input = getchar(0)

            " Read input
            if nr2char(input) == "q"
                let finished = 1
                break
            elseif input == "\<Left>"
                let newDir = [ -1, 0 ]
            elseif input == "\<Right>"
                let newDir = [ 1, 0 ]
            elseif input == "\<Up>"
                let newDir = [ 0, -1 ]
            elseif input == "\<Down>"
                let newDir = [ 0, 1 ]
            endif

            " Change snake direction, if required
            if dir[0] + newDir[0] != 0 || dir[1] + newDir[1] != 0
                let dir = newDir
                call DrawDirection(dir)
                redraw
            endif
        endwhile


        "call PutSign(snake[len(snake)-2], snake[len(snake)-1], " ")

        " Move snake logically
        for i in range(len(snake)-1, 2, -1)
            let snake[i] = snake[i-2]
        endfor
        let snake[0] = snake[0] + dir[0]
        let snake[1] = snake[1] + dir[1]

        call ClearField()
        call DrawSnake(snake)

        redraw

        " Sleep
        sleep 1

    endwhile


endfunction








