# Un juego de memoria escrito en assembler MIPS por Alejandro Ismael Silva


        #################################################
        #                     SIMON                     #
        #################################################

                # El juego es de 32x32 pixeles
                        # Con sonido!
        # Configura el Bitmap Display con 256x256 con pixeles de 8
        # No olvides de conectar el Keyboard Simulator
                        # Juegas con q w a s
                # Enter para terminar el juego
                        # Nada, diviertete!


################# Un croqui de la pantalla #################
# Símbolo = color (distancia entre la dir del framebuffer y el primer pixel)
#    #=bordes 1=verde(+33) 2=rojo(+49) 3=amarillo(+545) 4=azul(+561)

                # # # # # # # # # # # #
                # 1 1 1 1 # # 2 2 2 2 #
                # 1 1 1 1 # # 2 2 2 2 #
                # 1 1 1 1 # # 2 2 2 2 #
                # 1 1 1 1 # # 2 2 2 2 #
                # # # # # # # # # # # #
                # # # # # # # # # # # #
                # 3 3 3 3 # # 4 4 4 4 #
                # 3 3 3 3 # # 4 4 4 4 #
                # 3 3 3 3 # # 4 4 4 4 #
                # 3 3 3 3 # # 4 4 4 4 #
                # 3 3 3 3 # # 4 4 4 4 #
                # # # # # # # # # # # #



.data
# espacio destinado al framebuffer 32*32*4
pantalla:       .space 4096

# mensajes a imprimir por consola
mensaje1:       .asciiz "# La melodia tiene "
mensaje_1:      .asciiz " notas\n\n"
mensaje2:       .asciiz "##############################################\n Lograste memorizar "
mensaje_2:      .asciiz " notas!Felicitaciones!\n##############################################\n"

#               cuadrado  1 ,  2 ,  3 ,  4
teclas:         .ascii   "q", "w", "a", "s"

# la melodía se genera a medida que el juego avanza
melodia:        .byte

.text
                li $s0,0xffff0000       # dir para leer teclado
                li $t8,0                # progreso a través de la melodía
                li $t9,1                # final del progreso

                la $t0,teclas
                lbu $s4,($t0)           # tecla verde
                lbu $s5,1($t0)          # tecla roja
                lbu $s6,2($t0)          # tecla amarilla
                lbu $s7,3($t0)          # tecla azul

                la $s3,melodia          # dir base de la melodía
                la $s1,pantalla         # dir base de la pantalla
                addiu $s2,$s1,4096      # dir final de la pantalla

################# primera nota aleatorea
                # $t0 tiene dir de teclas
                li $v0,42
                li $a1,4
                syscall                 # genera nota aleatoria en $a0

                addu $t0,$t0,$a0        # en $t0 dir de la nota
                lbu $t0,($t0)           # nueva nota aleatoria
                sb $t0,($s3)            # guardar primera nota

################# bordes iniciales
                li $a0,0xffffffff       # bordes blancos
                jal bordes

################# cuadrados apagados
                li $a0,0x009a51         # verde apagado
                addi $a1,$s1,132        # 33*4 cuadrado 1
                jal cuadrado

                li $a0,0x9200b4         # rojo apagado
                addi $a1,$s1,196        # 49*4 cuadrado 2
                jal cuadrado

                li $a0,0xe76200         # amarillo apagado
                addi $a1,$s1,2180       # 545*4 cuadrado 3
                jal cuadrado

                li $a0,0x0062af         # azul apagado
                addi $a1,$s1,2244       # 561*4 cuadrado 4
                jal cuadrado

                jal pausa
                j sonar                 # saltar el código de cuando se equivoca

#########################################################################################
                        ##### bucle infinito #####

################# cuando se equivoca poner bordes rojos
reiniciar:
                li $t8,0                # progreso = 0
                li $a0,0xff9696         # bordes rojos
                jal bordes

                # $v0 debería seguir en 33
                li $a0,50               # nota
                li $a1,300              # tiempo
                li $a2,27               # instrumento
                li $a3,95               # volumen
                syscall                 # sonar incorrecto!

                li $a0,0xffffff         # bordes blancos
                jal bordes
                jal pausa

################# sonar nota
sonar:
                addu $t0,$s3,$t8        # dir base melodía + progreso
                lbu $t0,($t0)           # cargar nota
                li $v0,33               # para la llamada a syscall
                li $a2,27               # instrumento 85
                li $a3,127              # volúmen de melodía
                beq $t0,$s4,verde
                beq $t0,$s5,rojo
                beq $t0,$s6,amar
                beq $t0,$s7,azul

verde:
                li $a0,0x77ff00         # verde encendido
                addi $a1,$s1,132        # cuadrado 1
                jal cuadrado

                li $a0,60               # nota
                li $a1,500              # duración
                syscall                 # sonar melodía

                li $a0,0x009a51         # verde apagado
                addi $a1,$s1,132        # cuadrado 1
                jal cuadrado
                j listo

rojo:
                li $a0,0xff25e7         # rojo encendido
                addi $a1,$s1,196        # cuadrado 2
                jal cuadrado

                li $a0,62               # nota
                li $a1,500              # duración
                syscall                 # sonar melodía

                li $a0,0x9200b4         # rojo apagado
                addi $a1,$s1,196        # cuadrado 2
                jal cuadrado
                j listo

amar:
                li $a0,0xffd712         # amarillo encendido
                addi $a1,$s1,2180       # cuadrado 3
                jal cuadrado

                li $a0,64               # nota
                li $a1,500              # duración
                syscall                 # sonar melodía

                li $a0,0xe76200         # amarillo apagado
                addi $a1,$s1,2180       # cuadrado 3
                jal cuadrado
                j listo

azul:
                li $a0,0x27fff7         # azul encendido
                addi $a1,$s1,2244       # cuadrado 4
                jal cuadrado

                li $a0,66               # nota
                li $a1,500              # duración
                syscall                 # sonar melodía

                li $a0,0x0062af         # azul apagado
                addi $a1,$s1,2244       # cuadrado 4
                jal cuadrado

listo:
                addi $t8,$t8,1          # progreso++
                bne $t8,$t9,sonar       # si no termina la melodía, volver

                li $t8,0                # progreso = 0
                sw $zero,($s0)          # por si se tocó una tecla mientras sonaba

################# leer teclado
loop:
                lw $t0,($s0)            # leer estado
                beq $t0,$zero,loop      # si no se tocó nada volver a leer

################# procesar tecla / nota
                lw $t0,4($s0)           # leer letra / nota
                beq $t0,10,salir        # salir con enter
                addu $t1,$s3,$t8        # dir base melodía + progreso
                lbu $t2,($t1)           # cargar tono verdadero
                bne $t0,$t2,reiniciar   # si no es correcto, volver a sonar

################# si es correcto
                li $a0,0x98ff47         # bordes verdes
                jal bordes

                # $v0 deberia seguir en 33
                li $a0,82               # nota
                li $a1,300              # tiempo
                li $a2,27               # instrumento
                li $a3,127              # volúmen
                syscall                 # sonar correcto!

                li $a0,0xffffff         # bordes blancos
                jal bordes

                addi $t8,$t8,1          # progreso++
                bne $t8,$t9,loop        # si quedan tonos, leer teclado

################# si se termina la melodía
                li $a0,0x90b6ff         # bordes azules
                jal bordes

                # $v0 deberia seguir en 33
                li $a0,85               # nota
                li $a1,300              # tiempo
                li $a2,34               # instrumento
                li $a3,95               # volúmen
                syscall                 # sonar melodía completada!

                li $a0,0xffffff         # bordes blancos
                jal bordes
                jal pausa

################# nueva nota aleatoria
                li $v0,42
                li $a1,4
                syscall                 # genera nota aleatoria en $a0

                la $t1,teclas
                addu $t0,$t1,$a0        # en t0 dir de nueva nota
                lbu $t0,($t0)           # nueva nota aleatorea
                addu $t1,$s3,$t9        # dir base melodía + fin melodía
                sb $t0,($t1)            # guardar nueva nota

                addi $t9,$t9,1          # +1 nota
                li $t8,0                # progreso en cero

################# imprimir por consola cuantas notas tiene la melodía ($t9)
                li $v0,4
                la $a0,mensaje1         # "la melodia tiene"
                syscall
                li $v0,1
                move $a0,$t9
                syscall                 # "tantas"
                li $v0,4
                la $a0,mensaje_1
                syscall                 # "notas"

                j sonar                 # volver a empezar

salir:
################# imprimir por consola cuantas notas memorizó ($t9)
                li $v0,4
                la $a0,mensaje2
                syscall                 # "lograste memorizar"
                li $v0,1
                move $a0,$t9
                syscall                 # "tantas"
                li $v0,4
                la $a0,mensaje_2
                syscall                 # "notas, felicitaciones!"

                li $v0,10
                syscall                 # llamar al sistema para terminar


#########################################################################################
                        ##### funciones auxiliares #####
################# pausa
pausa:
                li $v0,32               # para hacer el syscall
                li $a0,200              # los milisegundos
                syscall
                jr $ra                  # volver

################# bordes de color
                # $a0 color a imprimir
bordes:
                # columnas
                move $t1,$s1            # $t1 dir base de la pantalla
                li $t0,0
                addi $t1,$t1,124        # saltar primera fila

columas:
                sw $a0,($t1)
                sw $a0,4($t1)
                addi $t1,$t1,64         # 15*4
                addi $t0,$t0,1
                bne $t0,62,columas      # hacer 62 veces

                # filas
                move $t1,$s1            # dir pantalla
                li $t0,0                # fila
                li $t2,0                # columnas

filas:
                sw $a0,($t1)
                addi $t1,$t1,4          # siguiente pixel
                addi $t0,$t0,1          # i de línea
                bne $t0,32,filas        # hacer 32 veces, una fila

                addi $t2,$t2,1          # línea terminada
                li $t0,0                # reset i de línea
                beq $t2,2,filas         # dos líneas juntas en el medio
                addi $t1,$t1,1792       # 14*32*4 saltar 14 filas
                bne $t2,4,filas         # hacer 4 veces

                jr $ra                  # volver

################# colorear un cuadrado
                # en $a0 el color y en $a1 dir del cuadrado
cuadrado:
                move $t1,$a1            # dir rectangulo
                li $t0,0                # columna
                li $t2,0                # fila

fila:
                sw $a0,($t1)            # pintar pixel
                addi $t1,$t1,4          # siguiente pixel
                addi $t0,$t0,1          # columna++
                bne $t0,14,fila         # repetir 14 veces

                addi $t1,$t1,72         # 19*4, saltar 19 pixeles
                li $t0,0                # columna = 0
                addi $t2,$t2,1          # fila++
                bne $t2,14,fila         # repetir 14 veces

                jr $ra                  # volver
