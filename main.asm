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
; void DrawRectangle(int posX, int posY, int width, int height, Color color);                        // Draw a color-filled rectangle
extern DrawRectangle
; int GetMouseX(void);                                    // Get mouse position X
extern GetMouseX
; int GetMouseY(void);                                    // Get mouse position Y
extern GetMouseY
extern rand
extern srand
extern time

_start:
	mov rdi, 0
	call time
	mov rdi, rax
	call srand

	push 0
	push cells
randomize_cells:
	call rand

	pop rsi
	pop rcx

	and rax, 0x1
	inc rsi
	mov BYTE[rsi], al
	inc rcx
	push rcx
	push rsi
	cmp rcx, CELL_COUNT * CELL_COUNT
	jng randomize_cells
	pop rdx
	pop rdx

	mov rdi, WIDTH
	mov rsi, HEIGHT
	mov rdx, window_title
	call InitWindow

shoud_close:
	call WindowShouldClose
	cmp rax, 1
	je exit
begin_draw:
	call BeginDrawing
	mov rdi, 0
	call ClearBackground

	sub rsp, 8 * 2 ; allocate stack 
	mov QWORD[rsp + 8], 0 ; y
	mov QWORD[rsp + 8], 0 ; x
loop_y:
	mov QWORD[rsp + 8], 0
loop_x:
	; index = y * CELL_COUNT + x
	mov rax, QWORD[rsp]
	imul rax, CELL_COUNT
	add rax, QWORD[rsp + 8]

	mov rsi, cells
	add rsi, rax
	mov al, byte[rsi]

	mov r8d, 0x000000
	cmp al, 1
	je set_live_color
	jne draw_cell
set_live_color:
	mov r8d, 0xFFFFFFFF
draw_cell:
	mov rdi, QWORD[rsp + 8] ; x
	imul rdi, CELL_SIZE
	mov rsi, QWORD[rsp] ; y
	imul rsi, CELL_SIZE
	mov rdx, CELL_SIZE
	mov rcx, CELL_SIZE
	call DrawRectangle

	mov rdx, QWORD[rsp + 8]
	inc QWORD[rsp + 8]
	cmp rdx, CELL_COUNT
	jng loop_x

	mov rdx, QWORD[rsp]
	inc QWORD[rsp]
	cmp rdx, CELL_COUNT
	jng loop_y
	add rsp, 8 * 2; clean stack

	call EndDrawing
	jmp shoud_close
exit:
	call CloseWindow
	mov rax, 60       ; exit(
	mov rdi, 0        ;   EXIT_SUCCESS
	syscall           ; );

section .data
	WIDTH equ 800
	HEIGHT equ 800
	CELL_SIZE equ 20
	CELL_COUNT equ WIDTH / CELL_SIZE
	WHITE equ 0xFFFFFFFF

	cells: times CELL_COUNT * CELL_COUNT  db 1
	window_title: db "Raylib en ASM", 0
	text: db "Congrats! You created your first window!", 0

section .note.GNU-stack
