iOSAddressBook (now stopped project)
===

A Offline synchronized address book with battery-friendly nearby
notification.

Mostly 2 things here:
- offline, battery-friendly notification system
- geolocation aware synchronization system: the goal of this is to allow
  synchronizing huge list of geolocated points

Worked with [Parsemap](https://github.com/OpenZilia/parsemap), would
require some modifications to make it work now (for ex: parsemap doesn't
do user management anymore). I suggest using something like parse
for this task.

Just like [Parsemap](https://github.com/OpenZilia/parsemap), it heavily
relies on [geohash](https://github.com/vitaminwater/geohash) to handle
geolocation-aware algorithms.
