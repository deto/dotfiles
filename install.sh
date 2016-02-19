for i in $(find `pwd` -name '*.linux-symlink' );
do
    filename=$(basename "$i")
    rootname="${filename%.*}"
    newfile="~/$rootname"
    echo "Linking $i to $newfile"
    eval ln -s $i $newfile
done

for i in $(find `pwd` -name '*.symlink' );
do
    filename=$(basename "$i")
    rootname="${filename%.*}"
    newfile="~/$rootname"
    echo "Linking $i to $newfile"
    eval ln -s $i $newfile
done
