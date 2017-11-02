###################################################################################
#
# BlackCountry 1.0
##
# Scriptul va bana pe cei a caror ipuri se afla in tarile adaugate in blacklist.
# Puteti adauga atat numele complet cat si scurtatura tarii dorite.
#
# Pentru a porni sau opri scriptul folositi !country <on>/<off>"
# Puteti adauga locatii folosind !country add <locatie> (Ex: US sau United States)"
# Pentru listare folositi !country list
# Pentru a sterge o locatie folositi !country del <numar> (se ia din lista)
# Pentru ajutor folositi !country help
#
#+++ Atentie ++++ Trebuie sa fie instalat 'geoiplookup' pe server pentru a functiona.
#
#                       BLaCkShaDoW ProductionS
#      _   _   _   _   _   _   _   _   _   _   _   _   _   _  
#     / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ 
#    ( t | c | l | s | c | r | i | p | t | s | . | n | e | t )
#     \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/
#
###################################################################################

#Aici setezi mesajul predefinit de ban

set blackcountry(breason) "Locatia ta este una interzisa pe acest canal. Locatia este :%location%"

#Aici setezi timpul de ban predefinit (minute)

set blackcountry(btime) "120"

###################################################################################

bind pub mn|- !country blackcountry:cmd
bind join - * blackcountry:join
setudef flag bcountry
set blackcountry(file) "country_list.txt"


if {![file exists $blackcountry(file)]} {
	set file [open $blackcountry(file) w]
	close $file
}

proc blackcountry:cmd {nick host hand chan arg} {
	global blackcountry
	
	set arg0 [lindex [split $arg] 0]
	set arg1 [lindex [split $arg] 1]
if {$arg0 == ""} {
	putserv "NOTICE $nick :\[BlackCountry\] Foloseste !country help pentru ajutor."
	return
}
switch $arg0 {

	on {
	channel set $chan +bcountry
	putserv "NOTICE $nick :\[BlackCountry\] activat pe $chan."
	}
	off {
	channel set $chan -bcountry
	putserv "NOTICE $nick :\[BlackCountry\] dezactivat pe $chan."
	}
	add {
if {$arg1 == ""} {
	putserv "NOTICE $nick :\[BlackCountry\] Foloseste !country help pentru ajutor."
	return
}
	set file [open $blackcountry(file) a]
	puts $file "$chan $arg1"
	close $file
	putserv "NOTICE $nick :\[BlackCountry\] Am adaugat locatia $arg1 in blacklist."
	}

	list {
	set file [open $blackcountry(file) "r"]
	set read [read -nonewline $file]
	close $file
	set data [split $read "\n"]
	set i 0
if {$data == ""} { 
	putserv "NOTICE $nick :\[BlackCountry\] Nu sunt locatii adaugate la blacklist."
	return
}
	putserv "NOTICE $nick :\[BlackCountry\] Lista locatii adaugate in blacklist."
foreach line $data {
	set read_chan [lindex [split $line] 0]
if {[string match -nocase $read_chan $chan]} {
	set i [expr $i +1]
	set read_blackchan [lindex [split $line] 1]
	putserv "NOTICE $nick :$i.) $read_blackchan"
			}
		}
	}

	
	del {
	array set countrydel [list]
if {![regexp {^[0-9]} $arg1]} {
	putserv "NOTICE $nick :\[BlackCountry\] Foloseste !country help pentru ajutor."
	return
}


set file [open $blackcountry(file) "r"]
	set data [read -nonewline $file]
	close $file
	set lines [split $data "\n"]
	set counter -1
	set line_counter -1
	set current_place -1
foreach line $lines {
	set line_counter [expr $line_counter + 1]
	set read_chan [lindex [split $line] 0]
if {[string match -nocase $read_chan $chan]} {
	set counter [expr $counter + 1]
	set countrydel($counter) $line_counter
	}
}

foreach place [array names countrydel] {
	if {$place == [expr $arg1 - 1]} {
	set current_place $countrydel($place)
	}
}

if {$current_place == "-1"} {
	putserv "NOTICE $nick :\[BlackCountry\] Nu exista locatia cu numarul $arg1."	
	return	
}

	set delete [lreplace $lines $current_place $current_place]
	set files [open $blackcountry(file) "w"]
	puts $files [join $delete "\n"]
	close $files
	set file [open $blackcountry(file) "r"]
	set data [read -nonewline $file]
	close $file
if {$data == ""} {
	set files [open $blackcountry(file) "w"]
	close $files
}
	putserv "NOTICE $nick :\[BlackCountry\] Am sters locatia cu numarul $arg1 din lista de blacklist."

	}

	help {
	putserv "NOTICE $nick :\[BlackCountry\] Pentru a pornii sau oprii scriptul folositi !country <on>/<off>"
	putserv "NOTICE $nick :\[BlackCountry\] Puteti adauga locatii folosind !country add <locatie> (Ex: US sau United States)"
	putserv "NOTICE $nick :\[BlackCountry\] Pentru listare folositi !country list"
	putserv "NOTICE $nick :\[BlackCountry\] Pentru a sterge o locatie folositi !country del <numar> (se ia din lista)"
		}
	}
}


proc blackcountry:join {nick host hand chan } {
	global blackcountry

	set handle [nick2hand $nick]
	set hostname [lindex [split $host @] 1]

if {![validchan $chan]} { return }
if {![channel get $chan bcountry]} { return }
if {[isbotnick $nick]} { return }
if {![botisop $chan]} { return }
if {[string match -nocase "*undernet.org" $host]} { return}
if {[matchattr $handle "nm|oHPASMVO" $chan]} { return }


	set execution [exec geoiplookup $hostname]
	set execution [split $execution "\n"]
	set split_execution [split [lindex $execution 0] ","]
	set short_location [concat [string map {"GeoIP Country Edition:" "" "  " ""} [lindex $split_execution 0]]]
	set location [concat [lindex $split_execution 1]]

	set file [open $blackcountry(file) "r"]
	set read [read -nonewline $file]
	close $file
	set data [split $read "\n"]

foreach line $data {
	set read_chan [lindex $line 0]
	set read_location [lindex $line 1]

if {[string match -nocase $read_chan $chan]} {
if {[string equal -nocase $read_location $short_location] || [string match -nocase $read_location $location]} {

	set replace(%location%) $read_location
	set reason [string map [array get replace] $blackcountry(breason)]
	set banmask "*!*@[lindex [split $host @] 1]"
	newchanban $chan $banmask "BlackCountry" $reason $blackcountry(btime)
			}
		}
	}
}


putlog "BlackCountry 1.0 by BLaCkShaDoW Loaded."
