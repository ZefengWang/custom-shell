#!/bin/bash



SCRIPTHEAD="<background>\n\t<starttime>\n\t\t<year>2021</year>\n\t\t<month>04</month>\n\t\t<day>01</day>\n\t\t<hour>00</hour>\n\t\t<minute>00</minute>\n\t\t<second>00</second>\n\t</starttime>"
SCRIPTTAIL="</background>"
SCRIPTBODY=""

SHOWTIME="1795.0"
ANMITIME="5.0"
PICARR=()

function genxml() {
	if [[ $# == 0 ]];then echo "No args specific!"; echo -e "usage: $0 /PATH/to/your/pics\n"; return 1; fi
	NUM=0
	PICARR=()
	RESULT=""
	TOTAL=0
	for i in $@; do for f in `ls $@`;do if [ "${i:0:1}" == "/" ];then PICARR[$NUM]=$i/$f;else PICARR[$NUM]=`pwd`/$i/$f;fi;let NUM+=1;done;done

	echo ${PICARR[@]}
	TOTAL=${#PICARR[@]}
	echo $TOTAL ${PICARR[0]}
	echo "------------"
	if [[ 1 == ${#PICARR[@]} ]];then
		echo "Only One pic"
		RESULT="${RESULT}\t<static>\n\t\t<duration>$SHOWTIME</duration>\n\t\t<file>${#PICARR[0]}</file>\n\t</static>\n"
		RESULT="${RESULT}\t<transition>\n\t\t<duration>$ANMITIME</duration>\n\t\t<from>${PICARR[0]}</from>\n\t\t<to>${PICARR[0]}</to>\n\t</transition>\n"
	else
		RESULT="${RESULT}\t<static>\n\t\t<duration>$SHOWTIME</duration>\n\t\t<file>${PICARR[0]}</file>\n\t</static>\n"
		RESULT="${RESULT}\t<transition>\n\t\t<duration>$ANMITIME</duration>\n\t\t<from>${PICARR[0]}</from>\n\t\t<to>${PICARR[1]}</to>\n\t</transition>\n"
		for i in $(seq 1 $TOTAL );
		do
			let NEXT=i+1
			echo ${PICARR[$i]}
			if [[ $NEXT == $TOTAL ]];then let NEXT=0;fi
			RESULT="${RESULT}\t<static>\n\t\t<duration>$SHOWTIME</duration>\n\t\t<file>${PICARR[$i]}</file>\n\t</static>\n"
			RESULT="${RESULT}\t<transition>\n\t\t<duration>$ANMITIME</duration>\n\t\t<from>${PICARR[$i]}</from>\n\t\t<to>${PICARR[$NEXT]}</to>\n\t</transition>\n"
		done
	fi
	SCRIPTBODY=$RESULT
	echo -e $SCRIPTHEAD > custom.xml
	echo -e $SCRIPTBODY >> custom.xml
	echo -e $SCRIPTTAIL >> custom.xml

	sudo cp custom.xml /usr/share/backgrounds/contest/custom.xml

}

function genxml2()
{
	
	local TOTAL=${#PICARR[@]}
	let TOTAL-=1
	CONFIGBODY=""
	for i in $(seq 0 $TOTAL );
	do
		str=${PICARR[$i]##*/}
		CONFIGBODY="$CONFIGBODY\t<wallpaper>\n\t\t<name>${str%.*}</name>\n\t\t<filename>${PICARR[$i]}</filename>\n\t\t<options>zoom</options>\n\t\t<pcolor>#000000</pcolor>\n\t\t<scolor>#000000</scolor>\n\t\t<shade_type>solid</shade_type>\n\t</wallpaper>\n"
		let NUM+=1
	done
	#CONFIGHEAD="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE wallpapers SYSTEM \"gnome-wp-list.dtd\">\n<wallpapers>\n"
	CONFIGANMI="\t<wallpaper deleted=\"false\">\n\t\t<name>Custom Wallpapers</name>\n\t\t<filename>/usr/share/backgrounds/contest/custom.xml</filename>\n\t\t<options>zoom</options>\n\t</wallpaper>"
	#CONFIGTAIL="</wallpapers>\n"
	#sudo touch /usr/share/gnome-background-properties/custom-wallpapers.xml 
	#sudo chown $USER /usr/share/gnome-background-properties/custom-wallpapers.xml
	#echo -e $CONFIGHEAD >  /usr/share/gnome-background-properties/custom-wallpapers.xml
	#echo -e $CONFIGANMI >> /usr/share/gnome-background-properties/custom-wallpapers.xml
	#echo -e $CONFIGBODY >> /usr/share/gnome-background-properties/custom-wallpapers.xml
	#echo -e $CONFIGTAIL >> /usr/share/gnome-background-properties/custom-wallpapers.xml

	echo -e $CONFIGANMI > tmp.txt
	echo -e $CONFIGBODY >> tmp.txt
	sudo sed -i '/<wallpapers>/r tmp.txt' /usr/share/gnome-background-properties/focal-wallpapers.xml > /dev/null
	rm tmp.txt
}

genxml $@
if [ $? == 0 ];then genxml2;fi
