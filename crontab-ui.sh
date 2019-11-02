#!/bin/sh

touch cronCopy
chmod 777 cronCopy

# ------------------
# [Format Output Field Function]
# --
# -- Context: Helper function to output user friendly format of a field parameter from a crontab job
# --
# -- Args: -> $1 ( Output Field ) 
# --
# -- Returns: -> "any" if $1 equals "*", otherwise "every $1"
# --
# ------------------
format_output_field() {
	if [ "$1" = "*" ];then
		echo "any"
	else
		echo "every $1"
	fi
}


# ------------------
# [ Ensure Numeric Argument Function]
# --
# -- Context: Checks if argument is numeric value
# --
# -- Args: -> $1 ( Argument To Be Checked )  
# --
# -- Returns: -> 1 ( True ) | 0 ( False ) 
# --
# ------------------
ensure_numeric() {
	if [ "$1" -eq "$1" ] 2>/dev/null; then	
		return 1
	else 
		return 0
	fi
}

# ------------------
# [Ensure Range Function]
# --
# -- Context: Ensures that numeric $1 argument is in range between arguments $2 and $3
# --
# -- Args: -> $1 ( User Argument ) 
#          -> $2 ( Range: Lower Bound ) 
#          -> $3 ( Range: Upper Bound ) 
# --
# -- Returns: -> 1 ( True ) | 0 ( False ) 
# --
# ------------------
ensure_range() {
	# Check -> Numeric value
	ensure_numeric $1
	if [ ! $? -eq 1 ]
	then
		echo "***** Error: Invalid input, please check regulations and try again *****"
		return 0
	fi

	# Range check
	if [ "$1" -ge "$2" ] && [ "$1" -le "$3" ]
	then
		# Success
		return 1
	else
		# Failure -> Input out of range
		echo "***** Error: Invalid range, please check regulations and try again *****"
		return 0
	fi
}


# ------------------
# [Validate Input Field Function]
# --
# -- Context: Validates whether user input is valid according to the corresponding field
# --
# -- Args: -> $1 ( User Input ) 
#	   -> $2 ( Field ) of { 'min', 'hour', 'day', 'month', 'weekDay' }
# --
# -- Returns -> 1 ( True )  | 0 ( False ) 
# --
# ------------------
validate_input_field() {
  	# ------------------------
	# [ Base Case - Asterix ] - Valid for all inputs
        # ------------------------
	if [ "$1" = "*" ];
	then
		return 1
	fi

	case "$2" in

	# ------------------------
	# [ Minute Case ]
        # ------------------------
	"min")
		
		ensure_range "$1" 0 59
		return	$?

	  ;;
	# ------------------------
	# [ Hour Case ]
        # ------------------------
	"hour")
		ensure_range "$1" 0 23
		return	$?
	 ;;
	# ------------------------
	# [ Day Case ]
        # ------------------------
	"day")
		ensure_range "$1" 1 31
		return	$?	  
	;;
	  
	# ------------------------
	# [ Month Case ]
        # ------------------------
	"month")
		ensure_range "$1" 1 12
		return	$?  
	  ;;
	# ------------------------
	# [ WeekDay Case ]
        # ------------------------
	"weekDay")
		ensure_range "$1" 0 6
		return	$?  
	  ;;
	# ------------------------
	# [ Default case: invalid parameters
        # ------------------------
	*)
		echo "***** Error: Invalid parameters, please check regulations and try again *****"
		return 0
	  ;;
	esac
}


while [ true ]
  do

  # ------------------
  # [Display the menu]
  # ------------------

	echo "----------------------"
	echo "Welcome to mycrontab!"
	echo "Choose one of the following commands by entering the appropriate number."
  echo "--"
	echo "1. Display all crontab jobs."
	echo "2. Insert a job."
  echo "3. Edit a job."
	echo "4. Remove a job."
	echo "5. Remove all jobs."
	echo "9. Exit."
	echo ""
	read -p "Select a command number: " num
	echo ""

  # ------------------
  # [Input validation]
  # ------------------
	ensure_range "$num" 1 9
	if [ ! $? -eq 1 ]
	then
		continue
	fi		

  # ------------------------
  # [Menu commands handling]
  # ------------------------

  # -----------------
	# Display all jobs
  # -----------------

	if [ $num -eq 1 ]
	then

    #update cronCopy with content of crontab
    crontab -l > cronCopy;

    #checks for content in cronCopy
		if [ -s cronCopy ]
		then
			cat cronCopy | while read min hour day month weekDay cm
			do
				min=$(format_output_field "$min")
				hour=$(format_output_field "$hour")
				day=$(format_output_field "$day")
				month=$(format_output_field "$month")
				weekDay=$(format_output_field "$weekDay")
	
				printf "Command: %s. Running: on %s minute/s, %s hour/s, on %s day of month,  on %s month, %s day of the week\n" "$cm" "$min" "$hour" "$day" "$month" "$weekDay"
			done
		else
      echo ""
			echo "No Jobs to Display";
      echo ""
		fi

  # ------------
	# Insert a job
  # ------------

	elif [ $num -eq 2 ]
  then

  	# Prompt for command settings input
  	echo 'Enter minutes ( 0 - 59 ) | * for any'; read minutes
	validate_input_field "$minutes" "min" 
	if [ ! $? -eq 1 ]
	then
		continue
	fi
  	echo 'Enter hour ( 0 - 23 ) | * for any:'; read hour
	validate_input_field "$hour" "hour"
	if [ ! $? -eq 1 ]
	then
		continue
	fi
  	echo 'Enter the day ( 1 - 31 ) | * for any:'; read day
	validate_input_field "$day" "day"
	if [ ! $? -eq 1 ]
	then
		continue
	fi
  	echo 'Enter day of month ( 1 - 12 ) | * for any:'; read month
	validate_input_field "$month" "month"
	if [ ! $? -eq 1 ]
	then
		continue
	fi
  	echo 'Enter weekday ( 0 - Sun, 6 - Sat ) | * for any:'; read weekDay
	validate_input_field "$weekDay" "weekDay"
	if [ ! $? -eq 1 ]
	then
		continue
	fi
  	echo 'Enter command to install'; read user_command

  	# Using quotes to catch the asterixes '*'
  	echo "$minutes $hour $day $month $weekDay $user_command" >> cronCopy;

  	# Update crontab file
  	crontab cronCopy
  	echo "Job inserted"
    echo ""

  # ----------
	# Edit a job
  # ----------

	elif [ $num -eq 3 ]
	then

  #instanciate counter
  count=0

  #show the user the available commands
  while read line;
  do
    count=$((count + 1))
    echo "$count"." $line"
    echo ""

  #read-in filename cronCopy
  done < cronCopy

  #prompt for command to edit
  read -p "Select command to be edited: " commandEdit

  #remove the command and update crontab file
  sed -i "$commandEdit"d cronCopy
  crontab cronCopy

  # Prompt for new command input
	echo 'Enter minutes ( 0 - 59 ) | * for any'; read minutes
	echo 'Enter hour ( 0 - 23 ) | * for any:'; read hour
	echo 'Enter the day ( 1 - 31 ) | * for any:'; read day
	echo 'Enter day of month ( 1 - 12 ) | * for any:'; read month
	echo 'Enter weekday ( 0 - Sun, 1 - Mon ) | * for any:'; read weekDay
	echo 'Enter command to install'; read user_command

  # Using quotes to catch the asterixes '*'
  echo "$minutes $hour $day $month $weekDay $user_command" >> cronCopy;

  # Update crontab file
  crontab cronCopy;
	echo "Job successfully edited";
  echo ""

  # ------------
	# Remove a job
  # ------------

  elif [ $num -eq 4 ]
	then

  #instanciate counter
  count=0

  #show the user the available commands
  while read line;
  do
    count=$((count + 1))
    echo "$count"." $line"
    echo ""

  #read-in filename cronCopy
  done < cronCopy

  #prompt for command to delete
  read -p "Select command to be deleted: " commandDel

  #remove the command and update crontab file
  sed -i "$commandDel"d cronCopy;
  crontab cronCopy;
  echo "Job deleted successfully."
  echo ""

  # ---------------
	# Remove all jobs
  # ---------------

	elif [ $num -eq 5 ]
	then
    crontab -r >/dev/null 2>&1;
    echo "All jobs removed"
    echo ""

  # -------------------
	# Exit the while loop
  # -------------------

	elif [ $num -eq 9 ]
	then
		break

  # ------------------------------
	# Error if command is not listed
  # ------------------------------

	else
		echo "Error: command number $num is not listed."
    echo ""

	fi

done

# -- END

# delete cronCopy file
rm cronCopy;

# Exit crontab
echo "Exit successfull!"

