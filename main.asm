extern ExitProcess ; Declaration of the function (symbol for the `extern` keyword) `ExitProcess`, 
; which will be used in the program. `ExitProcess` terminates the current process.

extern GetStdHandle ;  Declaration  of the function (symbol for the extern command) GetStdHandle.
; GetStdHandle retrieves the handle for the standard input, standard output, or standard error device.

extern WriteConsoleA ; Declaration of the function (symbol for the extern command) WriteConsoleA, 
; which will be used in the program. WriteConsoleA outputs a message to the console.
extern ReadConsoleA

ZERO_ASCII EQU 0x30 ; We define the constant ZERO_ASCII. It will be equal to 0x30 ('0').
NINE_ASCII EQU 0x39 ; We define the constant NINE_ASCII. It will be equal to 0x39 ('9').
STD_INPUT_HANDLE EQU -10 ; Assign the value -10 to the constant STD_INPUT_HANDLE.
STD_OUTPUT_HANDLE EQU -11 ; Assign the value -11 to the constant STD_OUTPUT_HANDLE.
lpReserved EQU 0 ; Assign the value 0 to the constant lpReserved.
EXIT_CODE EQU 0 ; Assign the value 0 to the constant EXIT_CODE.

section .text ; We declare the .text section (the code segment) and everything it contains.
global _start ; We use the `global` tag to tell the linker that the `_start` tag and the data
; it contains will be exported (and available to all other object files).

_start: ; The _start label. This will be the entry point of the program (the point where it starts).

push STD_OUTPUT_HANDLE ; Pass the argument to the GetStdHandle function.
call GetStdHandle ; We call the GetStdHandle function.
mov [h_out], eax ; move the result (output descriptor) of GetStdHandle to 
; an uninitialized double-word variable h_out.

push STD_INPUT_HANDLE ; Pass the argument to the GetStdHandle function.
call GetStdHandle 
mov [h_in], eax ; move the result (input descriptor) of GetStdHandle to 
; an uninitialized double-word variable h_in.


jmp menu_loop ; Go to the menu.

menu_loop:
call print_newline_if_needed

push lpReserved ; We pass the last argument, lpReserved. This parameter can be set to NULL 
push written ; We pass the address of the variable that will store the number of characters printed.
push menu_title_len ; We pass the length of the output characters.
push menu_title ; We pass the address of the variable that stores the string.
push [h_out] ; We pass the output descriptor.
call WriteConsoleA ; We call the WriteConsoleA function.

; Printing menu items
push lpReserved
push written
push menu_add_len
push menu_add
push [h_out]
call WriteConsoleA

push lpReserved
push written
push menu_sub_len
push menu_sub
push [h_out]
call WriteConsoleA

push lpReserved
push written
push menu_mul_len
push menu_mul
push [h_out]
call WriteConsoleA

push lpReserved
push written
push menu_div_len
push menu_div
push [h_out]
call WriteConsoleA

push lpReserved
push written
push menu_exit_len
push menu_exit
push [h_out]
call WriteConsoleA

; Printing a prompt to enter one of the menu items
push lpReserved
push written
push menu_prompt_len
push menu_prompt
push [h_out]
call WriteConsoleA

; We read the user's selection into an uninitialized 8-byte variable named `choice_buf`
push lpReserved
push bytes_read
push 8
push choice_buf
push [h_in]
call ReadConsoleA

; We take only the first character
mov al, [choice_buf] ; Move the value from memory to the lower half of the AX register. 
; AL is the low 8-bit part of EAX

cmp al, '1' ; We compare the value in `al` with the ASCII code for the digit '1' (0x31) 
; and set the flags in the FLAGS register based on the result.
je add_label ; If ZF = 1, jump to add_label
cmp al, '2'
je sub_label ; If ZF = 1, jump to the sub_label

cmp al, '3'
je mul_label ; If ZF = 1, jump to the mul_label


cmp al, '4'
je div_label ; If ZF = 1, jump to the div_label

cmp al, '0'
je exit_program ; If ZF = 1, jump to the exit_program label

; If none of the options work, display an error message
jmp invalid_option



add_label:
; Addition operation selected.
push lpReserved
push written
push msg_add_selected_len
push msg_add_selected
push [h_out]
call WriteConsoleA

; Let's read both numbers.
call read_first_operand
call read_second_operand

; result = first_operand + second_operand
mov eax, [first_operand]
add eax, [second_operand]
mov [result_value], eax

; Print the result.
call print_result_integer
jmp menu_loop


sub_label:
; Subtraction operation selected.
push lpReserved
push written
push msg_sub_selected_len
push msg_sub_selected
push [h_out]
call WriteConsoleA

; Let's read both numbers.
call read_first_operand
call read_second_operand

; result = first_operand - second_operand
mov eax, [first_operand]
sub eax, [second_operand]
mov [result_value], eax

; Print the result
call print_result_integer
jmp menu_loop


; Multiply
mul_label:
; Multiply operation selected.
push lpReserved
push written
push msg_mul_selected_len
push msg_mul_selected
push [h_out]
call WriteConsoleA

; Let's read both numbers.
call read_first_operand
call read_second_operand

; result = first_operand * second_operand
mov eax, [first_operand]
imul eax, [second_operand]
mov [result_value], eax

; Print the result.
call print_result_integer
jmp menu_loop

; Division
; Here's how the logic works:
; 5 / 2 = 2 with a remainder of 1
; remainder 1 * 10 = 10
; 10 / 2 = 5
; print 2.5
div_label:
; Division operation selected.
push lpReserved
push written
push msg_div_selected_len
push msg_div_selected
push [h_out]
call WriteConsoleA

; Let's read both numbers.
call read_first_operand
call read_second_operand

; Checking for division by zero.
cmp dword [second_operand], 0
je division_by_zero

; EAX = dividend.
mov eax, [first_operand]

; You need to expand the symbol before idiv. 
cdq

; Divide by second_operand
; After idiv:
; EAX = integer part
; EDX = remainder
idiv dword [second_operand]

; We save the integer part and the remainder.
mov [result_value], eax
mov [div_remainder], edx

; First, print "Result: ".
push lpReserved
push written
push msg_result_len
push msg_result
push [h_out]
call WriteConsoleA

; Print the integer part of the division result.
mov eax, [result_value]
call int_to_string

push lpReserved
push written
push dword [result_len]
push dword [result_ptr]
push [h_out]
call WriteConsoleA

; If the remainder is 0, there is no fractional part.
cmp dword [div_remainder], 0
je div_print_newline

; Print a period.
push lpReserved
push written
push dot_len
push dot
push [h_out]
call WriteConsoleA

; decimal_digit = (remainder * 10) / divisor.
mov eax, [div_remainder]
imul eax, 10
cdq
idiv dword [second_operand]

; EAX now contains a digit after the decimal point: 0–9.
add al, '0'
mov [decimal_digit_buf], al

; Print one digit after the decimal point.
push lpReserved
push written
push 1
push decimal_digit_buf
push [h_out]
call WriteConsoleA

div_print_newline:
; Line break
push lpReserved
push written
push newline_len
push newline
push [h_out]
call WriteConsoleA

mov dword [need_blank_line], 1
jmp menu_loop


; Reading the first operand, If an error occurs, please enter it again.
read_first_operand:
.first_input:
; Please enter the first number.
push lpReserved
push written
push msg_enter_first_operand_len
push msg_enter_first_operand
push [h_out]
call WriteConsoleA

; Read a line into a buffer.
push lpReserved
push bytes_read
push 32
push first_operand_buf
push [h_in]
call ReadConsoleA

; Converting an ASCII string to a number
call my_atoi_first

; If edx != 1, then there is an input error.
cmp edx, 1
jne .first_error
ret

.first_error:
push lpReserved
push written
push msg_incorrect_input_len
push msg_incorrect_input
push [h_out]
call WriteConsoleA
jmp .first_input


;Reading the second operand, if an error occurs, please enter it again,
read_second_operand:
.second_input:
; Please enter the second number.
push lpReserved
push written
push msg_enter_second_operand_len
push msg_enter_second_operand
push [h_out]
call WriteConsoleA

; Read a line into a buffer.
push lpReserved
push bytes_read
push 32
push second_operand_buf
push [h_in]
call ReadConsoleA

; Converting an ASCII string to a number
call my_atoi_second

; If edx != 1, then there is an input error.
cmp edx, 1
jne .second_error
ret

.second_error:
push lpReserved
push written
push msg_incorrect_input_len
push msg_incorrect_input
push [h_out]
call WriteConsoleA
jmp .second_input



; Convert first_operand_buf -> first_operand
; Input: buffer containing ASCII characters
; Output:
; EAX = parsed number
; EDX = 1 if success
; EDX = 0 if error
; Example:
; '1''2''3' -> 123
my_atoi_first:
xor eax, eax ; Set the EAX register to zero.
xor edx, edx ; Set the EDX register to zero.
mov dword [first_operand], 0
mov dword [digit_count], 0

; ECX will be an index: 0, 1, 2, 3...
mov ecx, -1

atoi_first_loop:
inc ecx

mov ebx, first_operand_buf ; EBX = buffer address

mov al, [ebx+ecx] ; AL = the current character from the buffer

; If an Enter key (\r or \n) or 0 is encountered, the input is complete
cmp al, 0x0D
je atoi_first_done

cmp al, 0x0A
je atoi_first_done

cmp al, 0
je atoi_first_done

; Check that the character is not less than '0'
cmp al, ZERO_ASCII
jb atoi_first_fail

; Check that the character is not greater than '9'
cmp al, NINE_ASCII
ja atoi_first_fail

; Convert ASCII to a digit for example ->'7' 0x37 - 0x30 -> 0x7
sub al, 0x30
movzx ebx, al ; We load the byte from the AL register into EBX, then pad the value to 4 bytes 
; by adding leading zeros.
mov [digit_temp], ebx ; assign to the variable `digit_temp`, which is used to store the digit of the number, 
;value from  EBX

; first_operand = first_operand * 10 + digit
mov eax, [first_operand] ; We retrieve the current value of the number from memory and store it in the EAX register.
imul eax, 10 ; multiply the number by 10 to shift it to the left (to make room for a new digit).
add eax, [digit_temp] ; add a new digit to the number.
mov [first_operand], eax

; increment the digit counter (meaning at least one digit has been found)
inc dword [digit_count]

jmp atoi_first_loop

atoi_first_done:
; If there were no numbers at all, that's a mistake.
cmp dword [digit_count], 0
je atoi_first_fail

mov eax, [first_operand]
mov edx, 1
ret

; this is where we end up if the input is incorrect.
atoi_first_fail:
xor eax, eax ; result = 0.
xor edx, edx ; EDX = 0 -> error.
mov [first_operand], eax ; reset the value
ret ; return


;  Convert second_operand_buf -> second_operand.
my_atoi_second:
xor eax, eax
xor edx, edx
mov dword [second_operand], 0
mov dword [digit_count], 0

mov ecx, -1

atoi_second_loop:
inc ecx

mov ebx, second_operand_buf
mov al, [ebx+ecx]

cmp al, 0x0D
je atoi_second_done

cmp al, 0x0A
je atoi_second_done

cmp al, 0
je atoi_second_done

cmp al, ZERO_ASCII
jb atoi_second_fail

cmp al, NINE_ASCII
ja atoi_second_fail

sub al, 0x30
movzx ebx, al
mov [digit_temp], ebx

mov eax, [second_operand]
imul eax, 10
add eax, [digit_temp]
mov [second_operand], eax

inc dword [digit_count]

jmp atoi_second_loop

; if there were no digits -> input error
atoi_second_done:
cmp dword [digit_count], 0
je atoi_second_fail

mov eax, [second_operand]
mov edx, 1
ret

atoi_second_fail:
xor eax, eax
xor edx, edx
mov [second_operand], eax
ret


; Print the whole result. Used for +, -, *
print_result_integer:
push lpReserved
push written
push msg_result_len
push msg_result
push [h_out]
call WriteConsoleA

; EAX = result_value
mov eax, [result_value]

; Converting a number to a string
call int_to_string

; Print a string containing a number.
push lpReserved
push written
push dword [result_len]
push dword [result_ptr]
push [h_out]
call WriteConsoleA

; Print newline
push lpReserved
push written
push newline_len
push newline
push [h_out]
call WriteConsoleA

mov dword [need_blank_line], 1
ret

; Converting a number from EAX to a string.
int_to_string:
; sign_flag = 0 -> the number is non-negative
mov dword [sign_flag], 0

; We start writing numbers to the `result_buf` buffer from the end
mov ecx, 15

; Special case: number == 0
cmp eax, 0
jne .check_negative

mov byte [result_buf+15], '0'
mov dword [result_ptr], result_buf+15
mov dword [result_len], 1
ret

.check_negative:
; If the number is negative, remember the sign
cmp eax, 0
jge .convert_digits

mov dword [sign_flag], 1
neg eax

.convert_digits:
mov ebx, 10

.convert_loop:
; Divide the number by 10
; Remainder = last digit
xor edx, edx
div ebx

; Converting the remainder to ASCII.
add dl, '0'

; Write a character to the buffer from right to left.
mov [result_buf+ecx], dl
dec ecx

; As long as eax is not 0, we continue.
cmp eax, 0
jne .convert_loop

; If the number was negative, add a minus sign.
cmp dword [sign_flag], 1
jne .prepare_result

mov byte [result_buf+ecx], '-'
dec ecx

.prepare_result:
; The ECX register is currently positioned one character to the left of the start of the line.
inc ecx

; result_ptr = the starting address of the string.
lea eax, [result_buf+ecx]
mov [result_ptr], eax

; result_len = the number of characters to be printed.
mov eax, 16
sub eax, ecx
mov [result_len], eax

ret


; incorrect menu item
invalid_option:
push lpReserved
push written
push msg_invalid_len
push msg_invalid
push [h_out]
call WriteConsoleA

mov dword [need_blank_line], 1
jmp menu_loop


; Division by zero
division_by_zero:
push lpReserved
push written
push msg_div_zero_len
push msg_div_zero
push [h_out]
call WriteConsoleA

mov dword [need_blank_line], 1
jmp menu_loop

; Print an empty line between menu iterations
print_newline_if_needed:
cmp dword [need_blank_line], 1
jne .done

push lpReserved
push written
push newline_len
push newline
push [h_out]
call WriteConsoleA

mov dword [need_blank_line], 0

.done:
ret


; Exit the program
exit_program:
push EXIT_CODE
call ExitProcess


section .bss
written RESD 1 ; How many characters are actually stored.
h_in RESD 1 ; input handle
h_out RESD 1 ; output handle
bytes_read RESD 1 ; How many characters did ReadConsoleA read?

first_operand RESD 1 ; First number.
second_operand RESD 1 ; Second number
result_value RESD 1 ; The integer result of the operation
digit_temp RESD 1 ; Single-digit temporary storage
digit_count RESD 1 ; How many digits were actually entered?

div_remainder RESD 1 ; remainder

result_ptr RESD 1 ; The address of the line containing the number
result_len RESD 1 ; The length of the string containing the number
sign_flag RESD 1 ; Negative flag
choice_buf RESB 8 ; Menu selection buffer
first_operand_buf RESB 32 ; Buffer for the first number
second_operand_buf RESB 32 ; Buffer for the second number

result_buf RESB 16 ; a buffer for converting a number to a string
decimal_digit_buf RESB 1 ; one digit after the decimal point

need_blank_line RESD 1 ; Is a line break required before the new menu?


section .data
menu_title DB '=== ASM CALCULATOR ===', 0x0D, 0x0A
menu_title_len EQU $ - menu_title

menu_add DB '1. Addition', 0x0D, 0x0A
menu_add_len EQU $ - menu_add

menu_sub DB '2. Subtract', 0x0D, 0x0A
menu_sub_len EQU $ - menu_sub

menu_mul DB '3. Multiply', 0x0D, 0x0A
menu_mul_len EQU $ - menu_mul

menu_div DB '4. Divide', 0x0D, 0x0A
menu_div_len EQU $ - menu_div

menu_exit DB '0. Exit', 0x0D, 0x0A
menu_exit_len EQU $ - menu_exit

menu_prompt DB 'Choose option: '
menu_prompt_len EQU $ - menu_prompt

msg_add_selected DB 'Addition selected', 0x0D, 0x0A
msg_add_selected_len EQU $ - msg_add_selected

msg_sub_selected DB 'Subtract selected', 0x0D, 0x0A
msg_sub_selected_len EQU $ - msg_sub_selected

msg_mul_selected DB 'Multiply selected', 0x0D, 0x0A
msg_mul_selected_len EQU $ - msg_mul_selected

msg_div_selected DB 'Divide selected', 0x0D, 0x0A
msg_div_selected_len EQU $ - msg_div_selected

msg_invalid DB 'Invalid option', 0x0D, 0x0A
msg_invalid_len EQU $ - msg_invalid

msg_enter_first_operand DB 'Enter the first operand: '
msg_enter_first_operand_len EQU $ - msg_enter_first_operand

msg_enter_second_operand DB 'Enter the second operand: '
msg_enter_second_operand_len EQU $ - msg_enter_second_operand

msg_incorrect_input DB 'Incorrect input. Enter only non-negative integers.', 0x0D, 0x0A
msg_incorrect_input_len EQU $ - msg_incorrect_input

msg_result DB 'Result: '
msg_result_len EQU $ - msg_result

msg_div_zero DB 'Error: division by zero.', 0x0D, 0x0A
msg_div_zero_len EQU $ - msg_div_zero

dot DB '.'
dot_len EQU $ - dot

newline DB 0x0D, 0x0A
newline_len EQU $ - newline