#!/bin/bash
unset ARRAY_PID
unset ARRAY_STAT
unset ARRAY_COMMAND
unset ARRAY_TTY
unset ARRAY_TIME
rm -rf /tmp/ps_script*.temp

ARRAY_PID=($(ls -l /proc | awk '{print $9}' | grep -v '[A-Za-z]' | sort -g))

for XZ in ${ARRAY_PID[@]}
    do
        if [ -d /proc/$XZ ]
            then
                ARRAY_STAT+=($(cat /proc/$XZ/status | grep State | tr -d ' ' | awk '{print $2}'))
            else
                ARRAY_STAT+=(NO)
        fi
    done

for XZ in ${ARRAY_PID[@]}
    do
        if [ -d /proc/$XZ ]
            then
                if [ -f /proc/$XZ/cmdline ]
                    then
                        TEMPVAR1=$(cat /proc/$XZ/cmdline | sed 's/\x0/'" "'/g')
                        if [ ! -z "${TEMPVAR1}" ]
                            then
                                cat /proc/$XZ/cmdline | sed 's/\x0/'" "'/g' > /tmp/ps_script$XZ.temp
                                echo >> /tmp/ps_script$XZ.temp
                                #ARRAY_COMMAND+=$TEMPVAR1
                            else
                                #ARRAY_COMMAND+=($(cat /proc/$XZ/status | grep Name | awk '{print $2}'))
                                cat /proc/$XZ/status | grep Name | awk '{print $2}' > /tmp/ps_script$XZ.temp
                                echo >> /tmp/ps_script$XZ.temp
                        fi
                    else
                        cat /proc/$XZ/status | grep Name | awk '{print $2}' > /tmp/ps_script$XZ.temp
                        echo >> /tmp/ps_script$XZ.temp
                fi
            else
                #ARRAY_COMMAND+=(NO)
                echo "NO" > /tmp/ps_script$XZ.temp
        fi
    done

for XZ in ${ARRAY_PID[@]}
    do
        if [ -d /proc/$XZ/fd ]
            then
                TEMPVAR1=$(ls -l /proc/$XZ/fd | grep /dev/tty | awk '{print $11}' | tr -d "/dev/" | head -1)
                if [ ! -z "${TEMPVAR1}" ]
                    then
                        ARRAY_TTY+=($TEMPVAR1)
                    else
                        ARRAY_TTY+=("?")
                fi
            else
                ARRAY_TTY+=(NO)
        fi
    done

for XZ in ${ARRAY_PID[@]}
    do
        if [ -d /proc/$XZ ]
            then
                TEMP_TIME=$(cat /proc/$XZ/stat | rev | awk '{print $36" "$37" "$38" "$39}' | rev | awk '{sum=$1+$2+$3+$4}END{print int(sum/100)}') 
                ARRAY_TIME+=($TEMP_TIME)
            else
                ARRAY_TIME+=(0)
        fi
    done

echo "PID STAT TTY TIME COMMAND"
for XZ in ${!ARRAY_PID[@]}
    do
        TEMPPP=${ARRAY_PID[$XZ]}

        TEMP_TIME=${ARRAY_TIME[$XZ]}
        TEMP_H=0
        TEMP_M=0
        TEMP_S=0
        if [ $TEMP_TIME  -ne  0 ]
            then
                TEMP_H=$(($TEMP_TIME / 3600))
                TEMP_TIME=$(($TEMP_TIME % 3600))
                TEMP_M=$(($TEMP_TIME / 60))
                TEMP_S=$(($TEMP_TIME % 60))
                if [ $TEMP_M  -lt  10 ]
                    then
                        TEMP_M=0$TEMP_M
                fi
                if [ $TEMP_S  -lt  10 ]
                    then
                        TEMP_S=0$TEMP_S
                fi
        fi
        TEMP_TIME=$(echo $TEMP_H ":" $TEMP_M ":" $TEMP_S)

        TEMP_ECHO=$(echo $TEMPPP " " ${ARRAY_STAT[$XZ]} " " ${ARRAY_TTY[$XZ]} " " $TEMP_TIME " " $(cat /tmp/ps_script$TEMPPP.temp | head -1) | grep -v NO)
        if [ ! -z "${TEMP_ECHO}" ]
            then
                echo $TEMP_ECHO
        fi
    done

rm -rf /tmp/ps_script*.temp






