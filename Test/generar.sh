#!/bin/bash

FILE=$1.s
SO_SYSTEM=system
SO_DATA=data_system
if [ -f $FILE ];
then
    FUENTE=$1

    echo "Ensamblando ..."
    #compila el ensamblador
    ./eines-sisa/bin/sisa-as --gstabs+  $FUENTE.s -o $FUENTE.o
    ./eines-sisa/bin/sisa-ld --section-start $SO_SYSTEM=0xC000 -Ttext=0x0000 -Tdata=0x2000 --section-start $SO_DATA=0xE000 $FUENTE.o -o $FUENTE.exe

    #desensamblamos el codigo
    ./eines-sisa/bin/sisa-objdump -d $FUENTE.exe > $FUENTE.code
    ./eines-sisa/bin/sisa-objdump -s --section=.data $FUENTE.exe > $FUENTE.data
    ./eines-sisa/bin/sisa-objdump -s --section=$SO_SYSTEM $FUENTE.exe > $FUENTE.system
    ./eines-sisa/bin/sisa-objdump -s --section=$SO_DATA $FUENTE.exe > $FUENTE.$SO_DATA


    #a partir del codigo generamos los ficheros fuente con el formato adecuado para poder 
    #ser ejecutado con el emulador (.rom) o en las placas DE1 o DE2-115
    ./limpiar.pl codigo $FUENTE.code
    ./limpiar.pl datos  $FUENTE.data
    ./limpiar.pl system $FUENTE.system
    ./limpiar.pl system_data  $FUENTE.$SO_DATA

    #desensamblamos
    ./eines-sisa/bin/sisa-objdump -d -w --section=.text $FUENTE.exe >$FUENTE.dis
    ./eines-sisa/bin/sisa-objdump -s -w --section=.data $FUENTE.exe >>$FUENTE.dis
    ./eines-sisa/bin/sisa-objdump -d -w --section=$SO_SYSTEM $FUENTE.exe >>$FUENTE.dis
    ./eines-sisa/bin/sisa-objdump -s -w --section=$SO_DATA $FUENTE.exe >>$FUENTE.dis
    rm $FUENTE.o $FUENTE.exe $FUENTE.code $FUENTE.data
else
    echo "El fichero $FILE no existe"
    echo "No hay que poner la extension .s si es que la has puesto"
fi
 

