echo "time_s exit_code model n" > times.dat
cat joblog | sort -n | tail -n+2| cut -f 4,7,9- | sed 's/minizinc -c --solver chuffed models\/\(.*\)\.mzn models\/\(.*\)\.dzn/\1 \2/' >> times.dat


