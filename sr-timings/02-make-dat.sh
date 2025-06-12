echo "time_s exit_code model n" > times.dat
cat log | sort -n | tail -n+2| cut -f 4,7,9- | sed 's/savilerow -O0 \(.*\)\.eprime \(.*\)\.param/\1 \2/' >> times.dat
