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
        frase0a:          .asciz "Ticks Timer: "
        frase0b:          .asciz "Hora: "
        frase1:           .asciz "Pulsadores: "
        frase2:           .asciz "Interruptores: "
        frase3a:          .asciz "Codigo ASCII tecla: "
        frase3b:          .asciz "Numero repeticiones: "
        frase4a:          .asciz "Numero fallos TLB: "
        frase4b:          .asciz "Numero calls: "
        

        cadena_aux:       .fill  10, 1, 0      ;10 elementos de tamaño byte inicializados a 0

        .balign 2       ;garantiza que los siguientes datos de tipo word esten alineados en posiciones pares

        d_ticks:          .word 0
        d_pulsadores:     .word 0
        d_interruptores:  .word 0
        d_tecla:          .word 0
        d_clicks_tecla:   .word 0
        ;datos para mostrar un reloj por pantalla
        d_ticks_seg:      .word 0
        d_segundos:       .word 0
        d_minutos:        .word 0
        d_horas:          .word 0

        d_timer0:          .word 0
        d_timer0_ticks:    .word 0
        d_timer_enable:    .word 0
        d_miss_tlb:        .word 0
        d_calls:           .word 0
        

.text
        
        $MOVEI r0, 0x4; Imprimir por pantalla
        calls r0
        ;$MOVEI r0, 0x5 ; 
        ;calls r0
        
        $MOVEI r1,0x7000
        ld r1,0(r1)
        $MOVEI r1,0x5
        $MOVEI r0, 0x5
        ;$PUSH r0,r1
        ;$MOVEI r1,0x6
        ;calls r1
		
        ;$POP r0,r1
	;$MOVEI r1, 0x5002
	;st 0(r1),r1

        $MOVEI r0, 0x4
        calls r0
        
	$MOVEI r1, 0x0000
	$MOVEI r3, 0x8002 
for_main: 	
	ld r2,0(r1)
	addi r1,r1,0x2


        $MOVEI r0, 0x4; Imprimir por pantalla
        calls r0

 	cmpleu r2,r1,r3 
	bnz r2, for_main	


        ;movi r6, 0            ;bucle infinito a la espera de que lleguen interrupciones
        ;jmp    r6
        movi r0,0x7
        calls r0
        $MOVEI r1,_jmp
        movi r0,0x4
_jmp:  
        calls r0

        jmp r1

        halt

.section data_system

		sd_tlb_datos: .word 0
		sd_tlb_instr: .word 0
; seccion de codigo
.section system
__entry:       ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Inicializacion
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        $MOVEI r1, RSG 
        wrs    s5, r1      ;inicializamos en S5 la direccion de la rutina de antencion a la interrupcion
        $MOVEI r7, PILA    ;inicializamos R7 como puntero a la pila
		;movi r0, 0x2E
		movi r1,0x2E
		wrpd r1,r1 ; la entrada 6 de la tabla contiene el vtag E y el ptag E con bit de valido a 1 y read a 0
		wrvd r1,r1 ; o sea, es lectura y escriptura
		
		movi r1, 0x32
		wrpd r1, r1 ; la entrada 2 contiene el vtag 2 y el ptag 2 con el bit de valido y solo lectura a 1
		wrvd r1, r1
		;$MOVEI r0, 0x1000
		;$MOVEI r1, sd_tlb_datos
		;st 0(r1),r0 
		;$MOVEI r0, 0xFFFF
		;$MOVEI r1, sd_tlb_instr	
		$MOVEI r6, inici   ;direccion de la rutina principal
jmp:		jmp    r6


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
	movi r2, 0
	cmpeq r3, r1, r2
	bnz r3, __excep_instr_ilegal  
	movi r2, 1
	cmpeq r3, r1, r2
	bnz r3, __excep_mem_align
	movi r2, 4
	cmpeq r3, r1, r2
	bnz r3, __excep_div0
        
        movi r2, 6 ; TLB_MISS INSTR
	$MOVEI r4, __miss_routine_instr
	cmpeq r3, r1, r2
	jnz r3, r4 
        
        movi r2, 7 ; TLB_MIS DATOS
	$MOVEI r4, __miss_routine_datos
	cmpeq r3, r1, r2
	jnz r3, r4
        
        movi r2, 8 ; TLB_INVALID INST
	$MOVEI r4, __invalid_routine
	cmpeq r3, r1, r2
	jnz r3, r4
        
        movi r2, 9 ; TLB_INVALID DATOS
        $MOVEI r4,__invalid_routine
	cmpeq r3, r1, r2
        
	jnz r3, r4
        
        movi r2, 0xA; TLB_PROT INST
	cmpeq r3, r1, r2
	bnz r3, end_excepcion  

        movi r2, 0xB; TLB PROT DATOS
        cmpeq r3, r1, r2
        bnz r3, __memory_protec
        
        movi r2, 0xC ; TLB_LECTURA DATOS
	cmpeq r3, r1, r2
	bnz r3, end_excepcion 

        movi r2, 0xD ; INSTR PROTECTED
        cmpeq r3, r1, r2
        bnz r3, __excep_protec

        movi r2, 0xE
	cmpeq r3, r1, r2
	bnz r3, __calls_routine 

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
        ; Rutina instruccion ilegal
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__excep_instr_ilegal:
	in r3, 5
        movi r1,1
        or r3,r1,r3
	out     5, r3              	 ;activa los leds verdes 0
	$MOVEI r6, end_excepcion         ;direccion del fin del servicio de excepcion
        jmp    r6
	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina memoria no alineada
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__excep_mem_align:
	in r3, 5
        movi r1,2
        or r3,r1,r3
	out     5, r3              	 ;activa los leds verdes 1
	$MOVEI r6, end_excepcion         ;direccion del fin del servicio de excepcion
        jmp    r6
	; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina division 0
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__excep_div0:
	in r3, 5
        movi r1,4
        or r3,r1,r3
	out     5, r3              	 ;activa los leds verdes 2
	$MOVEI r6, end_excepcion         ;direccion del fin del servicio de excepcion
        jmp    r6

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

__memory_protec:
	in r3,6
        movi r1,1
        or r3,r1,r3
	out     6, r3              	 ;activa los leds rojos 0
	$MOVEI r6, end_excepcion         ;direccion del fin del servicio de excepcion
        jmp    r6

__excep_protec:
	in r3,6
        movi r1,2
        or r3,r1,r3
	out     6, r3              	 ;activa los leds rojos 1
	$MOVEI r6, end_excepcion         ;direccion del fin del servicio de excepcion
        jmp    r6


__flush_routine: 
        $MOVEI r1,0x2
        flush r1
        $MOVEI r6,end_excepcion
        jmp r6

__calls_routine:

        $MOVEI r4, d_calls
        ld     r3, 0(r4)
        addi   r3, r3, 1           ;d_ticks_seg++
        st     0(r4), r3

	rds r2,s3

        $MOVEI r1, 0x4
        $MOVEI r3, binf
	cmpeq r2,r1,r2
        jnz r2, r3
        
        $MOVEI r1, 0x5
        cmpeq r2,r1,r2
        bnz r2,__timer_rutine
    
        $MOVEI r1, 0x6
        $MOVEI r3, __map_allocate
		cmpeq r2,r1,r2
        jnz r2, r3

        $MOVEI r1, 0x7
        cmpeq r2,r1,r2
        bnz r2,__flush_routine 

        $MOVEI r1, 0xA
        cmpeq r2,r1,r2
        bnz r2,__flush_routine 

	$MOVEI r6, end_excepcion         ;direccion del fin del servicio de excepcion
        jmp    r6


__timer_rutine:

    $MOVEI r0,0x0
    $MOVEI r1, d_timer0 ; Inicializa 0x0 en el timer0
    st 0(r1),r0
    $MOVEI r1,d_timer0_ticks ; Inicializa 0x0 en el timer_ticks
    st 0(r1),r0
    $MOVEI r0,0x1
    $MOVEI r1, d_timer_enable ; Activamos el timer0
    st 0(r1),r0
    $MOVEI r1,d_timer0
    movi r6,0x5
for:
    ld r0,0(r1)
    cmpeq r0,r1,r6
    bnz r0,for

    $MOVEI r6, end_excepcion
    jmp r6

    


        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Rutina interrupcion reloj
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__interrup_timer:
        $MOVEI r4, d_ticks         ;carga la direccion de memoria donde esta el dato sobre el # de ticks de reloj que han llegado
        ld     r3, 0(r4)           ;carga el numero de ticks
        addi   r3, r3, 1           ;lo incrementa en una unidad
        st     0(r4), r3           ;actualiza la variable sobre el numero de ticks
        out    10, r3              ;muesta el numero de ticks por los visores

        ;reloj
        $MOVEI r4, d_ticks_seg
        ld     r3, 0(r4)
        addi   r3, r3, 1           ;d_ticks_seg++
        st     0(r4), r3
        movi   r1, 20
        cmpeq  r1, r3, r1
        bz     r1, __finreloj
        movi   r3, 0               ;d_ticks_seg=0
        st     0(r4), r3
        $MOVEI r4, d_segundos
        ld     r3, 0(r4)
        addi   r3, r3, 1           ;d_segundos++
        st     0(r4), r3
        movi   r1, 60
        cmpeq  r1, r3, r1
        bz     r1, __finreloj
        movi   r3, 0               ;d_segundos=0
        st     0(r4), r3
        $MOVEI r4, d_minutos
        ld     r3, 0(r4)
        addi   r3, r3, 1           ;d_minutos++
        st     0(r4), r3
        movi   r1, 60
        cmpeq  r1, r3, r1
        bz     r1, __finreloj
        movi   r3, 0               ;d_minutos=0
        st     0(r4), r3
        $MOVEI r4, d_horas
        ld     r3, 0(r4)
        addi   r3, r3, 1           ;d_horas++
        st     0(r4), r3
        
        $MOVEI r0, d_timer_enable       ;miramos si tenemos nuestro timer funcionado
        ld r1,0(r0)             ;cargamos el valor de memoria
        $MOVEI r0,0x0           ; 0-> apagado
        cmpeq r0,r0,r1 
        bz r0, __finreloj       ; terminamos, no esta activo
        $MOVEI r0,d_timer0_ticks        ; esta activo, vamos a ver cuantos ticks lleva
        ld r1,0(r0)
        addi r1,r1,0x1          ; incrementamos los ticks en 1
        st 0(r0), r1
        movi r3, 20             ; cada 50ms se activa esta interrupcion, asi que 1s seran 20 ticks
        cmpeq r3, r3, r1
        bz r3, __finreloj           ; si no han ocurrido 20 no hemos de incrementar los segundos
        movi r2, 0              ; aqui ya han ocurrido 20 ticks, asi que reiniciamos el contador a 0
        st 0(r0), r2
        $MOVEI r3, d_timer0     ; toca incrementar el contador de segundos
        ld r4, 0(r3)
        addi r4, r4, 1
        st 0(r3), r4
    

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
        $CALL  r6, __clear_screen  ;borra la pantalla (en R6 se almacena la direccion de retorno de la subrutina)
        ei                         ;activa las interrupciones
        $CALL r6, __disable_system


__invalid_routine:
        rds r1,s1
        addi r1,r1,-2
        wrs s1,r1

        $MOVEI r4, d_miss_tlb
        ld     r3, 0(r4)
        addi   r3, r3, 1           ;d_ticks_seg++
        st     0(r4), r3

	$MOVEI r6, end_excepcion         ;direccion del fin del servicio de excepcion
        jmp    r6


binf:   
        $MOVEI r1, 0xA000          ;fila 0; columna 0
        $MOVEI r2, frase0a         ;frase 0a
        $CALL  r6, __write_line
        $MOVEI r1, 0xA01A          ;fila 0; columna 13
        $MOVEI r2, d_ticks         ;carga la direccion de memoria donde esta el dato sobre el # de ticks de reloj que han llegado
        ld     r2, 0(r2)           ;carga el numero de ticks
        $CALL  r6, __write_valor

        $MOVEI r1, 0xA032          ;fila 0; columna 25
        $MOVEI r2, frase0b         ;frase 0b
        $CALL  r6, __write_line
        $MOVEI r1, 0xA03E          ;fila 0; columna 31
        $CALL  r6, __mostrar_reloj

        $MOVEI r1, 0xA0A0          ;fila 1; columna 0
        $MOVEI r2, frase1          ;frase 1
        $CALL  r6, __write_line
        $MOVEI r1, 0xA0B8          ;fila 1; columna 12
        $MOVEI r2, d_pulsadores    ;carga la direccion de memoria donde esta el dato sobre el estado de los pulsadores
        ld     r2, 0(r2)          
        $CALL  r6, __write_valor


        $MOVEI r1, 0xA140          ;fila 2; columna 0
        $MOVEI r2, frase2          ;frase 2
        $CALL  r6, __write_line
        $MOVEI r1, 0xA15E          ;fila 2; columna 15
        $MOVEI r2, d_interruptores ;carga la direccion de memoria donde esta el dato sobre el estado de los interruptores
        ld     r2, 0(r2)
        $CALL  r6, __write_valor

        $MOVEI r1, 0xA1E0          ;fila 3; columna 0
        $MOVEI r2, frase3a         ;frase 3a
        $CALL  r6, __write_line
        $MOVEI r1, 0xA208          ;fila 3; columna 20
        $MOVEI r2, d_tecla         ;carga la direccion de memoria donde esta el dato sobre la ultima tecla pulsada
        ld     r2, 0(r2)           ;carga la ultima tecla pulsada
        $CALL  r6, __write_valor

        $MOVEI r1, 0xA212          ;fila 3; columna 25
        $MOVEI r2, frase3b         ;frase 3b
        $CALL  r6, __write_line
        $MOVEI r1, 0xA23C          ;fila 3; columna 21
        $MOVEI r2, d_clicks_tecla  ;carga la direccion de memoria donde esta el dato sobre el numero de veces que se ha pulsado la ultima tecla
        ld     r2, 0(r2)           ;carga el numero de veces consecutivas que se ha pulsado la tecla
        $CALL  r6, __write_valor

        $MOVEI r1, 0xA280          ;fila 4; columna 0
        $MOVEI r2, frase4a         ;frase 3b
        $CALL  r6, __write_line
        $MOVEI r1, 0xA308          ;fila 4; columna 21
        $MOVEI r2, d_miss_tlb  ;carga la direccion de memoria donde esta el dato sobre el numero de veces que se ha pulsado la ultima tecla
        ld     r2, 0(r2)           ;carga el numero de veces consecutivas que se ha pulsado la tecla
        $CALL  r6, __write_valor

        $MOVEI r1, 0xA340          ;fila 5; columna 0
        $MOVEI r2, frase4b         ;frase 3b
        $CALL  r6, __write_line
        $MOVEI r1, 0xA368          ;fila 5; columna 21
        $MOVEI r2, d_calls         ;carga la direccion de memoria donde esta el dato sobre el numero de veces que se ha pulsado la ultima tecla
        ld     r2, 0(r2)           ;carga el numero de veces consecutivas que se ha pulsado la tecla
        $CALL  r6, __write_valor

        $MOVEI r0, end_excepcion
        jmp r0



        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Subrutina para limpiar la pantalla
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
__clear_screen:
        $MOVEI r0, 0xA000          ;0xA000 direccion de inicio de la memoria de video
        $MOVEI r1, 2400            ;(80*30=2400=0x0960) numero caracteres de la pantalla
        $MOVEI r2, CHAR_CLEAR_SCREEN ;caracter ASCII y color con el que se borra la pantalla
__repe: st 0(r0), r2
        addi  r0, r0, 2
        addi  r1, r1, -1
        bnz   r1, __repe
        jmp r6                     ;R6 contiene la direccion de retorno de la subrutina



        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Subrutina para escribir una linea de texto en 
        ; pantalla seguida de un valor 
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; r1 <= contiene la direccion de memoria de pantalla donde se quiere escribir
        ; r2 <= contiene la direccion de memoria de la cadena de texto que queremos escribir
__write_line:
bucle_cad: ldb   r4, 0(r2)        
           bz    r4, fin_bucle_cad
           movhi r4, 0x0F          ;color amarillo   
           st    0(r1), r4
           addi  r1, r1, 2
           addi  r2, r2, 1
           bnz   r4, bucle_cad
fin_bucle_cad:
           jmp r6    ; retornar de la subrutina



        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Subrutina para escribir un valor por la pantalla
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; r1 <= contiene la direccion de memoria de pantalla donde se quiere escribir
        ; r2 <= contiene la direccion de memoria del valor que queremos escribir
__write_valor:
           $PUSH r1              ;guardamos r1 porque la rutina nos va a machacar el valor que es por donde devuelve el resultado

           $MOVEI r4, cadena_aux ;pone la direccion (puntero) de la cadena auxiliar para el resultado de la conversion
           $PUSH  r4
           $PUSH  r2             ;pone el valor entero a convertir a ASCII
           $CALL  r5, __itoa     ;convierte a ASCII el valor (R5=@ retorno, R7=@pila, retorno resultado por R1)
           addi   r7, r7, 4      ;recuperamos el espacio de la pila

           $POP r1               ;recuperamos r1 que contiene la posicion de pantalla a escribir

bucle_val: ldb   r5, 0(r4)        
           bz    r5, fin_bucle_val
           movhi r5, 0x3C        ;color cyan
           st    0(r1), r5
           addi  r1, r1, 2
           addi  r4, r4, 1
           bnz   r5, bucle_val
fin_bucle_val:
           ;imprime los dos siguentes caracteres para borrar los digitos 
           ;sobrantes si el numero anterior ocupaba más digitos que el actual
           $MOVEI r5, CHAR_CLEAR_SCREEN
           st    0(r1), r5
           st    2(r1), r5
           jmp   r6              ;retornar de la subrutina




        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Subrutina para escribir el reloj por pantalla
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; r1 <= contiene la direccion de memoria de pantalla donde se quiere escribir

__mostrar_reloj:
           addi   r0, r1, 0      ;copiamos la direccion de la posicion de pantalla del reloj

           $MOVEI r4, cadena_aux ;pone la direccion (puntero) de la cadena auxiliar para el resultado de la conversion
           $PUSH  r4
           $MOVEI r3, d_horas    ;carga la direccion de memoria donde esta el dato
           ld     r3, 0(r3)          
           $PUSH  r3             ;pone el valor entero a convertir a ASCII
           $CALL  r5, __itoa     ;convierte a ASCII el valor (R5=@ retorno, R7=@pila, retorno resultado por R1)
           addi   r7, r7, 4      ;recuperamos el espacio de la pila

bcad_hora: ldb   r5, 0(r4)        
           bz    r5, fin_bcad_hora
           movhi r5, 0x03        ;color rojo
           st    0(r0), r5
           addi  r0, r0, 2
           addi  r4, r4, 1
           bnz   r5, bcad_hora
fin_bcad_hora:
           $MOVEI r5,0x0C3A      ;dos puntos ':' verdes
           st     0(r0), r5
           addi   r0, r0, 2

           $MOVEI r4, cadena_aux ;pone la direccion (puntero) de/ la cadena auxiliar para el resultado de la conversion
           $PUSH  r4
           $MOVEI r3, d_minutos  ;carga la direccion de memoria donde esta el dato
           ld     r3, 0(r3)          
           $PUSH  r3             ;pone el valor entero a convertir a ASCII
           $CALL  r5, __itoa     ;convierte a ASCII el valor (R5=@ retorno, R7=@pila, retorno resultado por R1)
           addi   r7, r7, 4      ;recuperamos el espacio de la pila

           ;comprobamos si el numero tiene un solo digito y le añadimos el 0 delante
           movi  r1, 9
           cmple r1, r3, r1
           bz    r1, bcad_min
           ;un solo digito
           ldb   r3, 0(r4)
           stb   1(r4),r3
           movi  r3, 48   ; caracter 0
           stb   0(r4),r3
           movi  r3, 0    ; fin de cadena '\0'
           stb   2(r4),r3
bcad_min:  ldb   r5, 0(r4)        
           bz    r5, fin_bcad_min
           movhi r5, 0x03        ;color rojo
           st    0(r0), r5
           addi  r0, r0, 2
           addi  r4, r4, 1
           bnz   r5, bcad_min
fin_bcad_min:
           $MOVEI r5,0x0C3A      ;dos puntos ':' verdes
           st    0(r0), r5
           addi  r0, r0, 2

           $MOVEI r4, cadena_aux ;pone la direccion (puntero) de la cadena auxiliar para el resultado de la conversion
           $PUSH  r4
           $MOVEI r3, d_segundos  ;carga la direccion de memoria donde esta el dato
           ld     r3, 0(r3)          
           $PUSH  r3             ;pone el valor entero a convertir a ASCII
           $CALL  r5, __itoa     ;convierte a ASCII el valor (R5=@ retorno, R7=@pila, retorno resultado por R1)
           addi   r7, r7, 4      ;recuperamos el espacio de la pila

           ;comprobamos si el numero tiene un solo digito y le añadimos el 0 delante
           movi  r1, 9
           cmple r1, r3, r1
           bz    r1, bcad_seg
           ;un solo digito
           ldb   r3, 0(r4)
           stb   1(r4),r3
           movi  r3, 48   ; caracter 0
           stb   0(r4),r3
           movi  r3, 0    ; fin de cadena '\0'
           stb   2(r4),r3
bcad_seg:  ldb   r5, 0(r4)        
           bz    r5, fin_bcad_seg
           movhi r5, 0x03        ;color rojo
           st    0(r0), r5
           addi  r0, r0, 2
           addi  r4, r4, 1
           bnz   r5, bcad_seg
fin_bcad_seg:
           jmp r6    ; retornar de la subrutina



__map_allocate: 
;r0 la direccion de la pila

        ;ld r1, 0(r7) ;timer_ticks
        ;ld r2, 1(r7);
        ;wrpd r1
        ;wrvd r2

        $MOVEI r1, end_excepcion 
        jmp r1;

__miss_routine_datos:
        $MOVEI r4, d_miss_tlb
        ld     r3, 0(r4)
        addi   r3, r3, 1         
        st     0(r4), r3
        
	rds r3,s3 
	$MOVEI r4,0xF4
	shl r3,r3,r4
	out 6,r3
        movi r4, 1
	wrvd r4, r3
	movi r3, 0x33
	wrpd r4, r3
		
		$MOVEI r4,end_excepcion 
        jmp r4

__miss_routine_instr:
        ;$MOVEI r4, d_miss_tlb
        ;ld     r3, 0(r4)
        ;addi   r3, r3, 1         
        ;st     0(r4), r3
        
		;rds s3,r3 
		;$MOVEI r4,12
		;srl r3,r3,r4
		
		;wrpi r3 
		;wrvi r3 
		
		in r3, 6
        movi r1, 64
        or r3,r1,r3
        out   6, r3                ;activa los leds rojos 1

		$MOVEI r4,end_excepcion 
        jmp r4


        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; Subrutina itoa() - fa la conversió d'un enter a
        ; ASCII, retorna la longitud de la cadena
        ; *=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
        ; al top de la pila conte el punter a la cadena auxiliar on deixara la conversio
        ; seguidament a la pila conte el valor enter a convertir
        ; r5 conte l'adreça de retorn i r7 el punter a la pila
        ; retorna per r1 la longitud de la cadena convertida (si es igual a 0 ==> error)
__itoa: 
        addi      r7, r7, -32  ;reserva 24 bytes a la pila per variables temporals mes 4 bytes per backup de l'adreça de retorn y el registe R6 Base Pointer (BP) mes 4 bytes per salvar R0 i R2
        st        30(r7), r5
        st        28(r7), r6
        addi      r6, r7, 28   ;actualiza el registre BP
        addi      r7, r7, -4   ;reserva 4 bytes mes per salvar l'estat d'R4 i R3
        st        6(r7), r0
        st        4(r7), r2
        st        2(r7), r3
        st        0(r7), r4

        ;  int neg=0, i, j;
        ;  char tmpstr[10];
        ;  if (in<0) { str[0]='-'; neg=1; in=-in; }
        movi      r1, 0
        st        -6(r6), r1   ;neg=0
        ld        r2, 4(r6)    ;r2=valor enter
        movi      r1, 0
        cmplt     r1, r2, r1  
        bz        r1, __for1
        ld        r1, 6(r6)    ;r1=@cadena_aux
        movi      r2, 45
        stb       0(r1), r2    ;cadena_aux[0]='-' el signe negatiu
        movi      r1, 1
        st        -6(r6), r1   ;neg=1
        ld        r1, 4(r6)    ;r1=valor enter
        not       r1, r1       ;canvi de signe
        addi      r1, r1, 1
        st        4(r6), r1    ;valor=-valor
        ;  for (i=0; in>=10; i++)
        ;    {
        ;      tmpstr[9-i]=(in%10) + '0';
        ;      in/=10;
        ;    }
        ;  tmpstr[9-i] = in + '0';
__for1:
        movi      r1, 0
        st        -4(r6), r1   ;i=0
        $MOVEI r5, __condfor1
        jmp       r5
__cosfor1:
        movi      r2, 9
        ld        r1, -4(r6)   ;r1=i
        sub       r2, r2, r1   ;r2=9-i
        st        -20(r6), r2  ;@aux1=r2
        ld        r3, 4(r6)    ;r3=valor enter
        movi      r1, 10
        div       r5, r3, r1   ;r5=r3/10 (quocient)
        add       r1, r5, r5   ;r1=r5*2
        movi      r2, 2
        sha       r2, r1, r2   ;r2=(r5*4)*2
        add       r1, r1, r2   ;r1=quocient*10  (r1=r5*8+r5*2)
        sub       r1, r3, r1   ;r1=residu modul 10
        movi      r2, 48
        add       r1, r1, r2   ;convertir a carcater ASCII el digit
        addi      r4, r1, 0    ;r4=r1=digit ASCII
        st        4(r6), r5    ;@val=r5 actualitzem el valor enter amb el quocient
        addi      r0, r6, -16  ;inici cadena auxiliar tmpstr
        ld        r3, -20(r6)  ;r3=@aux1=9-i
        add       r1, r0, r3
        stb       0(r1), r4    ;tmpstr[9-i]=digit ASCII
        ld        r1, -4(r6)   ;r1=i
        addi      r1, r1, 1    ;i++
        st        -4(r6), r1
__condfor1:
        ld        r1, 4(r6)    ;r1=i
        movi      r2, 9
        cmple     r1, r1, r2   ;r1<=9?
        $MOVEI    r5, __cosfor1
        jz        r1, r5
        movi      r2, 9
        ld        r1, -4(r6)
        sub       r4, r2, r1
        ld        r1, 4(r6)
        movi      r2, 48
        add       r1, r1, r2
        addi      r0, r1, 0
        addi      r3, r6, -16
        st        -22(r6), r3
        movi      r1, 15
        not       r1, r1
        addi      r1, r1, 1
        sha       r3, r4, r1
        addi      r1, r4, 0
        addi      r2, r3, 0
        ld        r3, -22(r6)
        add       r1, r3, r1
        stb       0(r1), r0
        ;  for(j=neg; j<=i+neg; j++)
        ;    str[j] = tmpstr[9-i+j-neg];
        ;  str[j] = '\0';
        ld        r1, -6(r6)
        st        -2(r6), r1
        movi      r5, 0
        bz        r5, __condfor2
__cosfor2:
        ld        r2, -2(r6)
        ld        r1, 6(r6)
        add       r2, r2, r1
        st        -18(r6), r2
        movi      r2, 9
        ld        r1, -4(r6)
        sub       r2, r2, r1
        ld        r1, -2(r6)
        add       r1, r2, r1
        addi      r2, r1, 0
        ld        r1, -6(r6)
        sub       r4, r2, r1
        addi      r0, r6, -16
        addi      r1, r4, 0
        add       r1, r0, r1
        ldb       r1, 0(r1)
        ld        r2, -18(r6)
        stb       0(r2), r1
        ld        r1, -2(r6)
        addi      r1, r1, 1
        st        -2(r6), r1
__condfor2:
        ld        r2, -4(r6)
        ld        r1, -6(r6)
        add       r2, r2, r1
        ld        r1, -2(r6)
        cmplt     r1, r2, r1
        bz        r1, __cosfor2
        ld        r2, -2(r6)   ;str[j] = '\0';
        ld        r1, 6(r6)
        add       r2, r2, r1
        movi      r1, 0
        stb       0(r2), r1

        ;  return j;
        ld        r1, -2(r6)   ;devolvemos la longitud de la cadena por R1

        ld        r0, 6(r7)    ;recuperamos el estado 
        ld        r2, 4(r7)
        ld        r3, 2(r7)
        ld        r4, 0(r7)
        addi      r7, r6, 0
        ld        r6, 0(r7)
        ld        r5, 2(r7)
        addi      r7, r7, 4
        jmp       r5



