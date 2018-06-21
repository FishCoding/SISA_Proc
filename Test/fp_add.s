; Incluir las macros necesarias
.include "macros.s"



; txt user = 0x0000
; data user = 0x2000;

;system = 0xC000;

.set PILA, 0x3000               ;una posicion de memoria de una zona no ocupada para usarse como PILA
.set CHAR_CLEAR_SCREEN, 0x152E  ;borramos la pantalla con un punto gris oscuro
;.set CHAR_CLEAR_SCREEN, 0x0020  ;borramos la pantalla con un espacio negro
        

; seccion de datos
.data
        ; dades globals
        

.text
        


 halt

.section data_system


.section system
__entry:
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Inicializacion
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        $MOVEI r1, RSG 
        wrs    s5, r1      ;inicializamos en S5 la direccion de la rutina de antencion a la interrupcion
        $MOVEI r7, PILA    ;inicializamos R7 como puntero a la pila
		movi r1,0x2E
		wrpd r1,r1 ; la entrada 6 de la tabla contiene el vtag E y el ptag E con bit de valido a 1 y read a 0
		wrvd r1,r1 ; o sea, es lectura y escritura
		
		movi r1, 0x22
		wrpd r1, r1 ; la entrada 2 contiene el vtag 2 y el ptag 2 con el bit de valido a 1 y solo lectura a 0
		wrvd r1, r1 ; o sea, es lectura y escritura
	
		$MOVEI r6, inici   ;direccion de la rutina principal
jmp:    jmp    r6


		__interrup_key:
				in     r3, 7               ;leemos el valor de los pulsadores
				not    r3,r3               ;los pulsadores son activos a '0'
				movi   r4,0x0F
				and    r3, r3, r4          ;mascara para apagar los leds que no corresponden a ningun pulsador
				out     5, r3              ;activa los leds verdes con el valor de los pulsadores
				$MOVEI r4, d_pulsadores    ;carga la direccion de memoria donde esta el dato sobre el estado de los pulsadores
				st     0(r4), r3           ;actualiza la variable sobre el estado de los pulsadores
				$MOVEI r6, end_excepcion         ;direccion del fin del servicio de interrupcion
				jmp    r6


        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina interrupcion interruptores
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__interrup_switch:
        in     r3, 8               ;leemos el valor de los interruptores
        out     6, r3              ;activa los leds rojos con el valor de los interruptores
        $MOVEI r4, d_interruptores ;carga la direccion de memoria donde esta el dato sobre el estado de los interruptores
        st     0(r4), r3           ;actualiza la variable sobre el estado de los interruptores
        $MOVEI r6, end_excepcion         ;direccion del fin del servicio de interrupcion
        jmp    r6


        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina interrupcion teclado PS/2
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__interrup_keyboard:
        in     r3, 15              ;leemos el valor correspondiente al caracter ASCII de la tecla pulsada
        $MOVEI r4, d_tecla         ;carga la direccion de memoria donde esta el dato sobre la ultima tecla pulsada
        ld     r5, 0(r4)           ;carga la ultima tecla pulsada
        st     0(r4), r3           ;actualiza la variable con la nueva tecla pulsada
        cmpeq  r3, r3, r5
        $MOVEI r4, d_clicks_tecla  ;carga la direccion de memoria donde esta el dato sobre el numero de veces que se ha pulsado la ultima tecla
        bz     r3, __distintas
        ; teclas iguales
        ld     r5, 0(r4)           ;carga el numero de veces consecutivas que se ha pulsado la tecla
        addi   r5, r5, 1           ;se incrementa en 1 el numero de repeticiones consecutivas
        bnz r3, __fin_keyboard
__distintas:
        ; teclas distintas 
        movi   r5, 1               ;es la primera vez que se pulsa
__fin_keyboard:
        st     0(r4), r5           ;actualiza la variable con el numero de repeticiones
        $MOVEI r6, end_excepcion         ;direccion del fin del servicio de interrupcion
        jmp    r6



        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina de servicio de interrupcion
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
RSG:    $PUSH r0, r1, r2, r3, r4, r5, r6 ;salvamos el estado en la pila; El r0 lo utilizaremos para argumentos de las llamadas 
	rds r1, s2
	movi r2, 2
	cmpeq r3, r1, r2
	bnz r3, __overflow_fp  
	movi r2, 3
	cmpeq r3, r1, r2
	bnz r3, __invalid_division_fp
	
	movi r2, 0xF
	cmpeq r3, r1, r2
	bnz r3, __excep_interrupt 
  

__excep_interrupt:
	getiid r1          
        movi   r3, 0                     ;comprueba si es una interrupcion del interval timer
        cmpeq  r2, r1, r3
        bnz    r2, __interrup_timer
        movi   r3, 1                     ;comprueba si es una interrupcion del controlador de los pulsadores
        cmpeq  r2, r1, r3 
        bnz    r2, __interrup_key
        movi   r3, 2                     ;comprueba si es una interrupcion del controlador de los interruptores
        cmpeq  r2, r1, r3
        bnz    r2, __interrup_switch
        movi   r3, 3                     ;comprueba si es una interrupcion del controlador del teclado
        cmpeq  r2, r1, r3
        bnz    r2, __interrup_keyboard

end_excepcion:
        $POP r6, r5, r4, r3, r2, r1, r0  ;restauramos el estado desde la pila (ojo orden inverso)
        reti

	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    ; Rutina Overflow FP
    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__overflow_fp:
	in r3, 5
    movi r1,1
    or r3,r1,r3
	out 5, r3              	     ;activa el led verde 0
	$MOVEI r6, end_excepcion     ;direccion del fin del servicio de excepcion
    jmp    r6
	
	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
    ; Rutina division 0 en FP
    ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__invalid_division_fp:
	in r3, 6
    movi r1,1
    or r3,r1,r3
	out 6, r3              	         ;activa los leds verdes 2
	$MOVEI r6, end_excepcion         ;direccion del fin del servicio de excepcion
    jmp    r6




        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina interrupcion reloj
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__interrup_timer:
        $MOVEI r4, d_ticks         ;carga la direccion de memoria donde esta el dato sobre el # de ticks de reloj que han llegado
        ld     r3, 0(r4)           ;carga el numero de ticks
        addi   r3, r3, 1           ;lo incrementa en una unidad
        st     0(r4), r3           ;actualiza la variable sobre el numero de ticks
        out    10, r3              ;muesta el numero de ticks por los visores
    

 __finreloj:
        $MOVEI r6, end_excepcion         ;direccion del fin del servicio de interrupcion
        jmp    r6


        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina interrupcion pulsadores
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*

__disable_system: 
        rds r1, s7
        $MOVEI r0, 0xFFFE
        and r1, r1, r0
        wrs s0, r1
        movi r1, 0
        wrs  s1,r1
        reti


        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina principal
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
inici: 
        movi   r1, 0x0F
        out     9, r1              ;activa todos los visores hexadecimales
        movi   r1, 0x00
        out    10, r1              ;muestra el valor 0x0000 en los visores
        out     5, r1              ;apaga los leds verdes
        in     r1, 8               ;leemos el valor de los interruptores
        out     6, r1              ;activa los leds rojos con el valor de los interruptores
        ; $CALL  r6, __clear_screen  ;borra la pantalla (en R6 se almacena la direccion de retorno de la subrutina)
        ei                         ;activa las interrupciones
        $CALL r6, __disable_system


