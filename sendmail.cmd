#!/bin/bash
#   send email out with place holder such as NAME (Dear John Doe,)
#       All you need is to update some environment variables
#       You also need to have gomplate install on your machine
#       https://github.com/hairyhenderson/gomplate/releases/download/v3.8.0/gomplate_linux-amd64

if [ $# -ne 1 ] ; then
   echo "Usage:  $0 inputfile"
   exit 1
fi
  
INFILE=$1

export EMAILTEMPLATE=mail.templ
export EMAILTEXT=tosend.html
export REPLYTO="do-not-replay@stanford.eu"
export FROM="System Generated Email <do-not-reply@stanford.edu"
export SUBJECT="Comming Meeting due to COVID"

function sm {
 TO=$1
(
  echo "To: ${TO}"
  echo "Subject: $SUBJECT"
  echo "Reply-To: $REPLYTO"
  echo "From: $FROM"
  echo "Content-Type: text/html"
  echo 
  cat $EMAILTEXT
) | sendmail -t
 }  

if [ ! -f $INFILE ] ; then
   echo "File $INFILE doesn't exist.  Abort."
   echo "Usage:  $0 inputfile"
   exit 1
fi

cat $INFILE | grep -v '^#' | while read inrec
do
   export EMAIL=`echo $inrec | awk -F',' '{print $1}'`
   export NAME=`echo $inrec | awk -F',' '{print $2}'`
   cat $EMAILTEMPLATE | gomplate > $EMAILTEXT
   sm $EMAIL
done

