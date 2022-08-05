#!/bin/sh
#
# web2rgbmatrix service
#

. /media/fat/web2rgbmatrix/web2rgbmatrix.conf

# Debug function
dbug() {
  if [ "${DEBUG}" = "true" ]; then
    if [ ! -e ${DEBUGFILE} ]; then                                              # log file not (!) exists (-e) create it
      echo "---------- web2rgbmatrix Debuglog ----------" > ${DEBUGFILE}
    fi 
    echo "${1}" >> ${DEBUGFILE}                                                 # output debug text
  fi
}

# Send Core GIF image over the web
senddata() {
	curl -F file=@${WEB2RGBMATRIX_PATH}/gifs/${1}.gif http://${HOSTNAME}/play
}

while true; do                                                                # main loop
  if [ -r ${CORENAMEFILE} ]; then                                             # proceed if file exists and is readable (-r)
    NEWCORE=$(cat ${CORENAMEFILE})                                            # get CORENAME
    echo "Read CORENAME: -${NEWCORE}-"
    dbug "Read CORENAME: -${NEWCORE}-"
    if [ "${NEWCORE}" != "${OLDCORE}" ]; then                                 # proceed only if Core has changed
      echo "Send -${NEWCORE} GIF - to http://${HOSTNAME}/play ."
      dbug "Send -${NEWCORE} GIF - to http://${HOSTNAME}/play ."
      senddata "${NEWCORE}"                                                   # The "Magic"
      OLDCORE="${NEWCORE}"                                                    # update oldcore variable
    fi                                                                        # end if core check
    inotifywait -e modify "${CORENAMEFILE}"                                   # wait here for next change of corename
  else                                                                        # CORENAME file not found
   echo "File ${CORENAMEFILE} not found!"
   dbug "File ${CORENAMEFILE} not found!"
  fi                                                                          # end if /tmp/CORENAME check
done
# ** End Main **