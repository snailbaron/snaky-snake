
" Colors and syntax rules
function! SetColors()
    highlight clear
    syntax clear

    set nocursorline

    syntax match SnakeHead /H/
    syntax match SnakeBody /S/
    syntax match Wall /#/
    syntax match Food /F/

    syntax match Quotes /[{}]/ contained
    syntax match ArrowBody /[\.:']\+/ contained
    syntax match Chosen /{.*}/ contains=ArrowBody,Quotes
    syntax match Note /\*/

    highlight SnakeHead guibg=DarkRed guifg=DarkRed
    highlight SnakeBody guibg=Blue guifg=Blue
    highlight Wall guibg=Gray guifg=Gray
    highlight ArrowBody guifg=Blue
    highlight Chosen guifg=Blue
    highlight ArrowBody guifg=Green
    highlight Quotes guibg=Gray20 guifg=Gray20
    highlight Note guifg=Gray50 guibg=Gray50
    highlight Food guifg=Red guibg=Red
endfunction

" Common parameters
let s:fieldWidth = 60
let s:fieldHeight = 30
let s:panelHeight = 10
let s:screenWidth = (s:fieldWidth+2) * 2
let s:screenHeight = s:fieldHeight + s:panelHeight + 3

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" System functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! Rand()
    return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:])
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions for drawind/output on screen
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Put character on screen
function! PutChar(x, y, c)
    call cursor(a:y+1, a:x+1)
    exec "normal R" . a:c
endfunction

" Put line on screen
function! PutLine(x1, y1, x2, y2, c)
    let x1 = min([a:x1, a:x2])
    let x2 = max([a:x1, a:x2])
    let y1 = min([a:y1, a:y2])
    let y2 = max([a:y1, a:y2])

    if (x2 - x1) >= (y2 - y1)
        for x in range(x1, x2)
            call PutChar(x, y1 + (x-x1) * (y2-y1) / (x2-x1), a:c)
        endfor
    else
        for y in range(y1, y2)
            call PutChar(x1 + (y-y1) * (x2-x1) / (y2-y1), y, a:c)
        endfor
    endif
endfunction

" Put rectangle on screen
function! PutRect(x, y, w, h, c)
    call PutLine(a:x, a:y, a:x + a:w - 1, a:y, a:c)
    call PutLine(a:x + a:w - 1, a:y, a:x + a:w - 1, a:y + a:h - 1, a:c)
    call PutLine(a:x + a:w - 1, a:y + a:h - 1, a:x, a:y + a:h - 1, a:c)
    call PutLine(a:x, a:y + a:h - 1, a:x, a:y, a:c)
endfunction

" Put sided rectangle (rectangle with double vertical sides)
function! PutSidedRect(x, y, w, h, c)
    call PutRect(a:x, a:y, a:w, a:h, a:c)
    call PutLine(a:x+1, a:y, a:x+1, a:y+a:h-1, a:c)
    call PutLine(a:x+a:w-2, a:y, a:x+a:w-2, a:y+a:h-1, a:c)
endfunction

" Put full rectangle on screen
function! PutFullRect(x, y, w, h, c)
    for y in range(a:y, a:y + a:h - 1)
        call PutLine(a:x, y, a:x + a:w - 1, y, a:c)
    endfor
endfunction
    
" Put a block of text on screen
function! PutBlock(x, y, block)
    for i in range(len(a:block))
        call cursor(a:y+1+i, a:x+1)
        exec "normal R" . a:block[i]
    endfor
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Field manipulation
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Put an object on the field
function! PutFieldObject(x, y, o)
    call cursor(a:y + 1, 2*a:x + 1)
    exec "normal R" . a:o . a:o
endfunction

" Clear field
function! ClearField()
    let line = "##" . repeat("  ", s:fieldWidth) . "##"
    for i in range(2, s:fieldHeight+1)
        call setline(i, line)
    endfor
endfunction

" Draw the snake inside the field
function! DrawSnake(snake)
    call PutFieldObject(a:snake[0], a:snake[1], "H")
    for i in range(2, len(a:snake)-1, 2)
        call PutFieldObject(a:snake[i], a:snake[i+1], "S")
    endfor
endfunction

" Draw food on the field
function! DrawFood(food)
    call PutFieldObject(a:food[0], a:food[1], "F")
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UI elements
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Arrow images
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
\   "   ':'''''{...}'''''':'   ",
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

" Draw arrow (current snake direction)
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
        
    call PutBlock(2, s:fieldHeight+2, arrow)
endfunction

" Prepare all fields (separate screen into zones, draw borders)
function! PrepareUi()
    " Clear buffer
    exec "normal ggVGd"
    let line = repeat("  ", s:fieldWidth + 2)
    for i in range(1, s:fieldHeight+s:panelHeight+3)
        call setline(i, line)
    endfor

    " Draw borders
    call PutSidedRect(0, 0, (s:fieldWidth+2)*2, (s:fieldHeight+s:panelHeight+3), "#")
    call PutFullRect(0, (s:fieldHeight+2) - 1, (s:fieldWidth+2)*2, 1, "#")
endfunction

" Draw a message in center of screen
function! DrawMessage(msg)
    let msgW = float2nr(s:screenWidth * 0.8 + 0.5)
    let msgX = float2nr(s:screenWidth * 0.1 + 0.5)
    let msgY = float2nr(s:screenHeight * 0.4 + 0.5)

    let textWidth = msgW - 6
    let words = split(a:msg)
    let lines = [ remove(words, 0) ]

    let i = 0
    for w in words
        if strlen(lines[i]) + strlen(w) + 1 <= textWidth
            let lines[i] = lines[i] . " " . w
        else
            let i = i + 1
            call add(lines, w)
        endif
    endfor
    let h = len(lines) + 4

    call PutLine(msgX, msgY, msgX, msgY + h - 1, "*")
    call PutRect(msgX+1, msgY, msgW-2, h, "*")
    call PutLine(msgX + msgW - 1, msgY, msgX + msgW - 1, msgY + h - 1, "*")
    call PutBlock(msgX + 3, msgY + 2, lines)
endfunction



function! Run()
    call SetColors()
    call PrepareUi()

    let snake = [ 3, 3, 2, 3, 1, 3 ]
    let dir = [ 1, 0 ]

    let food = [ 10, 10 ]

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
        
        let tail = [ snake[len(snake)-2], snake[len(snake)-1] ]

        " Move snake logically
        for i in range(len(snake)-1, 2, -1)
            let snake[i] = snake[i-2]
        endfor
        let snake[0] = snake[0] + dir[0]
        let snake[1] = snake[1] + dir[1]

        " Check collisions
        if snake[0] < 0 || snake[0] >= s:fieldWidth || snake[1] < 0 || snake[1] >= s:fieldHeight
            call DrawMessage("You lose")
            let finished = 1
            break
        endif
        
        " Check food
        if snake[0] == food[0] && snake[1] == food[1]
            call add(snake, tail[0])
            call add(snake, tail[1])
            let food = [ Rand() % s:fieldWidth, Rand() % s:fieldHeight ]
        endif

        call ClearField()
        call DrawSnake(snake)
        call DrawFood(food)

        redraw

        " Sleep
        sleep 1

    endwhile


endfunction








