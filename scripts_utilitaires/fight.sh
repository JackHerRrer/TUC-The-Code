#! /bin/bash
set +x

COMMAND_PATH=$(dirname $0)
VAR_PATH=$COMMAND_PATH/var
LOG_PATH=$COMMAND_PATH/log
BIN_PATH=$COMMAND_PATH/bin

source $BIN_PATH/connect.sh
source $BIN_PATH/disconnect.sh
source $BIN_PATH/garden_fight.sh
source $BIN_PATH/fight_analysis.sh

#--------------------------------------------------------------------------------------------------------------------------
# Parameters of the script  

LEEK_NAME=JeanFile
NBR_FIGHT=$1


connect

for ((i = 0; i < $NBR_FIGHT; i++ )); do
	clear
#     	tput sc
	printf "\n["
        for ((j = 0; j < $i; j++)); do
                printf "="
        done
        printf ">"

        for ((j = $i; j < $NBR_FIGHT; j++)); do
                printf " "
        done
        
	printf "] %d / %d\n" "$i" "$NBR_FIGHT"

	if [ "$RESULT_FIGHT" == "tie" ]; then
		toilet "Tie                                        " -f big
	elif [ "$RESULT_FIGHT" == "victory" ]; then
		toilet "Victory                                    " -f big --gay
        elif [ "$RESULT_FIGHT" == "defeat" ]; then
		toilet "Defeat                                     " -f big
	else 
		echo Begining 
	fi 
	
	echo
	echo
    garden_fight
    fight_analysis	
done

clear
printf "\n["
for ((i = 0; i < $NBR_FIGHT; i++)); do
        printf "="
done

printf "] %d / %d\n" "$i" "$NBR_FIGHT"

if [ "$RESULT_FIGHT" == "tie" ]; then
        toilet "Tie                                               " -f big
elif [ "$RESULT_FIGHT" == "victory" ]; then
        toilet "Victory                                           " -f big --gay
elif [ "$RESULT_FIGHT" == "defeat" ]; then
        toilet "Defeat                                            " -f big
else
        echo Begining
fi

echo victory :
tail -n ${NBR_FIGHT} $LOG_PATH/fight_history.log | grep victory | wc -l
echo tie :
tail -n ${NBR_FIGHT} $LOG_PATH/fight_history.log | grep tie | wc -l
echo defeat :
tail -n ${NBR_FIGHT} $LOG_PATH/fight_history.log | grep defeat | wc -l

disconnect
