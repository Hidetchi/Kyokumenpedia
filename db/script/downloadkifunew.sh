#!/bin/bash
for i in {77458..82407}
do
  wget --referer="" --user-agent="Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.16) Gecko/20110323 Ubuntu/10.04 (lucid) Firefox/3.6.16" -O kif$i.kif "http://wiki.optus.nu/shogi/java/kif.php?kid=$i"
  sleep 30s
done
