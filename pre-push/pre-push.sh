#!/bin/bash

# An example hook script to verify what is about to be pushed.  Called by "git
# push" after it has checked the remote status, but before anything has been
# pushed.  If this script exits with a non-zero status nothing will be pushed.
#
# This hook is called with the following parameters:
#
# $1 -- Name of the remote to which the push is being done
# $2 -- URL to which the push is being done
#
# If pushing without using a named remote those arguments will be equal.
#
# Information about the commits which are being pushed is supplied as lines to
# the standard input in the form:
#
#   <local ref> <local sha1> <remote ref> <remote sha1>
#
# The aim of this Git pre-push hook is to verify and notify to the user if the
# project's version has been updated since the last tag. It checks automatically
# the file VERSION of the last local reference against the same file of the
# checksum the lastest tag is related to.
#
# In case this file does not exist in one of the two references, this hook exits
# with no errors, otherwise it will notify to the user if the version has not
# been updated.


read local_ref local_sha remote_ref remote_sha

# A pre push tag
ppt="***** PRE PUSH GIT HOOK ***** -"


function get_version_content() {
  # Read commit info the last tag which points to
  [[ `git cat-file -p $1` =~ ^tree[[:space:]]*([a-zA-Z0-9]{40}) ]]

  # Read root dir information and, if the file VERSION is found, read its content
  [[ `git cat-file -p ${BASH_REMATCH[1]}` =~ blob[[:space:]]*([a-zA-Z0-9]{40})[[:space:]]*VERSION ]]
  if [[ -z "${BASH_REMATCH[1]}" ]]; then
    exit 0
  else
    response=`git cat-file -p ${BASH_REMATCH[1]}`
  fi
}

# Split all tags into an array.
# If no tags are found, exit with a non-zero code
IFS=' ' read -ra tags <<< `git tag`
if [ ${#tags[@]} -eq 0 ]; then
  exit 0
fi

# Retrieve version content for both the lastest tag and the current reference
get_version_content `git rev-list -n 1 ${tags[${#tags[@]}-1]}` # Get tag sha
ver_tag=$response
get_version_content $local_sha # Get local sha
ver_ref=$response

# Notify to the user the project's version hasn't been updated since the last
# tag
if [[ ${ver_tag} = ${ver_ref} ]]; then
  echo "$ppt Project's version has not been updated since the last tag."
fi

exit 0

