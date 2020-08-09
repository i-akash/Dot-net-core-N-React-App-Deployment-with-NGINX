                        # Initialization part

# work drive
WORK_DRIVE="D:"

# Solution directory
API_WDIR="cefalo-attendance-server-core/Cefalo.AttendanceManagement.Api/"
SYNC_WDIR="cefalo-attendance-server-core/Cefalo.AttendanceSyncService/"
UI_WDIR="attendance-app-frontend/"

# Build Directory
BASE_DIR="$WORK_DRIVE/cefalo-all-apps"
API_DEST_DIR="$BASE_DIR/cefalo-hrportal-api"
SYNC_DEST_DIR="$BASE_DIR/cefalo-hrportal-sync-service"
UI_DEST_DIR="$BASE_DIR/cefalo-hrportal-ui"
                        
                        # Solution Build Part

# remove base dir
rm -r $BASE_DIR
# make base dir
mkdir $BASE_DIR

build_dotnet_project (){
    # going to working drive
    cd $1
    # going to working dir
    cd $2
    
    WORK=$3
    echo "[############## $WORK BUILD STARTING  ############## ]"
    echo ""
    
    dotnet publish -c Release -o $4
    echo "[############## $WORK BUILD ENDED   ############## ]"
    echo ""
}


build_react_project (){
    # going to working drive
    cd $1
    # going to working dir
    cd $2
    
    WORK=$3
    echo "[############## $WORK BUILD START  ############## ]"
    echo ""

    npm run build
    mv build $4
    
    echo "[############## $WORK BUILD END   ############## ]"
    echo ""
}


# build Api 
build_dotnet_project $WORK_DRIVE $API_WDIR "API"  $API_DEST_DIR
# build sync service
build_dotnet_project $WORK_DRIVE $SYNC_WDIR "SERVICE"  $SYNC_DEST_DIR
# build ui
build_react_project $WORK_DRIVE $UI_WDIR "UI"  $UI_DEST_DIR


                        # Copy part

echo "[############## COPYING   ############## ]"
echo ""

cd $WORK_DRIVE
LOCAL_DIR="cefalo-all-apps"
REMOTE_DIR="~/"
REMOTE_ADDR="sysadmin@192.168.1.58"
REMOTE_DEST="$REMOTE_ADDR:$REMOTE_DIR"

scp -r  $LOCAL_DIR $REMOTE_DEST
echo "[############## END   ############## ]"
echo ""




