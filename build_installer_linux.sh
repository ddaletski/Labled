CURRDIR=`readlink -f $(pwd)`
SCRIPTDIR=`dirname "$(readlink -f "$0")"`

cd $SCRIPTDIR/installer/linux/
./build.sh
cd $CURRDIR
