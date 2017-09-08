The script will ban all IPs which are in countries added to the blacklist.
You can add both full name and/or countries shortcut.

ATTENTION: You must have 'package GeoIP' for the script to work.

------------------------------------------------------------------

Scriptul va bana toate IP-urile din țările care se găsesc adăugate in blacklist.
Puteți adăuga atât numele complet, cât și scurtătura țării dorite.

ATENȚIE: Trebuie să aveți "pachetul GeoIP" instalat pentru ca acest script să funcționeze.

------------------------------------------------------------------

cd /usr/share/GeoIP
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
gunzip GeoIP.dat.gz
mv -v GeoIP.dat /usr/share/GeoIP/GeoIP.dat
