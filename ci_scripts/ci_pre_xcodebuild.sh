#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Story
#
#  Created by Alexandre Madeira on 12/07/23.
#  
echo "Stage: PRE-Xcode Build is activated .... "
cd ../Shared/Configuration
API_KEY_TMDB=$CRONICA_API_KEY_TMDB
API_KEY_TELEMETRYDECK=$CRONICA_API_KEY_TELEMETRYDECK
TMDB_AuthorizationHeader=$CRONICA_API_KEY_TMDB_AuthorizationHeader
plutil -replace CRONICA_API_KEY_TMDB -string "$API_KEY_TMDB" Cronica--info.plist
plutil -replace CRONICA_API_KEY_TELEMETRYDECK -string "$API_KEY_TELEMETRYDECK" Cronica--info.plist
plutil -replace CRONICA_API_KEY_TMDB_AuthorizationHeader -string "$TMDB_AuthorizationHeader" Cronica--info.plist

plutil -p Cronica--info.plist

echo "Stage: PRE-Xcode Build is DONE .... "

exit 0
