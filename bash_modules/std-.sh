###############################################################
#TOP LEVEL FUNCTIONS - move elsewhere when we can compile bash from different files

## allow a list of options, then selection via number, the menu value being stored in MENUCHOICE
# call:
# menu a,b,c,d
# echo MENUCHOICE
# would give 'c' if option 3 selected
function std-menu(){
  options=""$1"";
  title=""$2"";
  	if [ "$title" != "" ]; then
  	  echo ""
  		echo-b "$title";
  		echo "";
  	fi
  IFS=',' read -r -a values <<<"$options";
  optioncount=${#values[@]};#note no space in assignation
  optioncount=$optioncount-1;
  #for i in {0..$optioncount}; do
  start=0;
  for (( i=$start; i<=$optioncount; i++ ));do
    	echo "$((i + 1)): ${values[$i]}"
  done
  echo "";
  echo-b "Enter Choice:";
  read choice
  choice=$choice-1;
  MENUCHOICE=${values[$choice]};
  echo "";
}