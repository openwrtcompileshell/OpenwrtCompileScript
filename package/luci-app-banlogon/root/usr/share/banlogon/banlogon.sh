#!/bin/sh
ipset list uhttpd4 2>/dev/null|grep timeout|sed '/Header:/d'|awk '{print "uhttpd",$1,$3}'
ipset list uhttpd6 2>/dev/null|grep timeout|sed '/Header:/d'|awk '{print "uhttpd",$1,$3}'
ipset list dropbear4 2>/dev/null|grep timeout|sed '/Header:/d'|awk '{print "dropbear",$1,$3}'
ipset list dropbear6 2>/dev/null|grep timeout|sed '/Header:/d'|awk '{print "dropbear",$1,$3}'
