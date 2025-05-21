global _start

section .text

extern printf
extern InitWindow
extern WindowShouldClose
extern CloseWindow
extern BeginDrawing
extern EndDrawing
extern ClearBackground
extern DrawText
extern DrawRectangle
extern GetMouseX
extern GetMouseY
extern rand
extern srand
extern time
extern memcpy
extern IsMouseButtonPressed
extern GetMouseX
extern GetMouseY

_start:
	call r_randomize_cells
	mov rdi, WIDTH
	mov rsi, HEIGHT
	mov rdx, window_title
	call InitWindow
	call r_game_of_life 
	call CloseWindow
	mov rax, 60       ; exit(
	mov rdi, 0        ;   EXIT_SUCCESS
	syscall           ; );

r_game_of_life:
        push rbp
        mov rbp, rsp
	sub rsp, 16   
game_draw_loop:
	call WindowShouldClose
	cmp rax, 1
	je exit_game_of_life
	call BeginDrawing
	mov rdi, 0
	call ClearBackground

	call put_cell_from_mouse
	call r_copy_cells_state

	mov QWORD[rbp - 8], 1 ; y
	mov QWORD[rbp - 16], 1 ; x
loop_y:
	mov QWORD[rbp - 16], 1
loop_x:
	; mov rdi, QWORD[rbp - 16]
	; mov rsi, QWORD[rbp - 8]
	; call r_get_index
underpopulation:
next_generation:
overpopulation:
reproduction:
	mov rdi, QWORD[rbp - 16]
	sub rdi, 1
	mov rsi, QWORD[rbp - 8]
	sub rsi, 1
	call r_get_index

	mov rsi, cells_copy
	add rsi, rax

	mov al, byte[rsi] ; cell state
	mov r8d, 0x000000 ; color
	cmp al, 1
	je set_live_color
	jne draw_cell
set_live_color:
	mov r8d, 0xFFFFFFFF
draw_cell:
	mov rdi, QWORD[rbp - 16] ; x
	sub rdi, 1
	imul rdi, CELL_SIZE
	mov rsi, QWORD[rbp - 8] ; y
	sub rsi, 1
	imul rsi, CELL_SIZE
	mov rdx, CELL_SIZE
	mov rcx, CELL_SIZE
	call DrawRectangle

	mov rdx, QWORD[rbp - 16]
	inc QWORD[rbp - 16]
	cmp rdx, CELL_COUNT
	jng loop_x

	mov rdx, QWORD[rbp - 8]
	inc QWORD[rbp - 8]
	cmp rdx, CELL_COUNT
	jng loop_y

	call EndDrawing
	jmp game_draw_loop
exit_game_of_life:
	leave
	ret

r_copy_cells_state:
	push rbp
	mov rbp, rsp

	mov rdi, cells_copy
	mov rsi, cells
	mov rdx, CELLS_SIZE
	call memcpy

	pop rbp
	ret

put_cell_from_mouse:
	mov rdi, MOUSE_BUTTON_LEFT
	call IsMouseButtonPressed

	cmp rax, 1
	je put_cell
	ret
put_cell:
	call GetMouseX
	mov rdx, 0
	mov rcx, CELL_SIZE 
	idiv rcx
	push rax

	call GetMouseY
	mov rdx, 0
	mov rcx, CELL_SIZE 
	div rcx

	pop rdi ; x
	mov rsi, rax ; y 
	call r_get_index

	mov rsi, cells
	add rsi, rax
	mov byte[rsi], 1 
	ret


r_randomize_cells:
        push rbp
        mov rbp, rsp
	sub rsp, 16
	mov QWORD [rbp-8], 0 ; counter
	mov rdi, 0 ; get time
	call time
	mov rdi, rax ; use time as seed
	call srand ; init random
randomize_cells_loop:
	call rand 
	and rax, 0x1
	mov rsi, cells
	add rsi, [rbp-8]
	mov BYTE [rsi], al ; move to random bool to cell
	add QWORD [rbp-8], 1 ; increment
	cmp QWORD [rbp-8], CELLS_SIZE
	jl randomize_cells_loop
	leave
        ret

r_get_index: ; x, y -> int
	; index = y * CELL_COUNT + x
	imul rsi, CELL_COUNT
	add rsi, rdi
	mov rax, rsi
	ret

section .data
	WIDTH equ 800
	HEIGHT equ 800
	CELL_SIZE equ 20
	CELL_COUNT equ WIDTH / CELL_SIZE
	CELLS_SIZE equ CELL_COUNT * CELL_COUNT 
	WHITE equ 0xFFFFFFFF
	MOUSE_BUTTON_LEFT equ 0

	cells: times CELLS_SIZE db 1
	cells_copy: times CELLS_SIZE  db 1
	window_title: db "Raylib en ASM", 0
	text: db "Congrats! You created your first window!", 0
	printxd: db "xd", 10, 0

section .note.GNU-stack
