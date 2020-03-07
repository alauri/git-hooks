#!/usr/bin/ruby

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


# A pre push tag
$ppt = "***** PRE PUSH GIT HOOK ***** -"

def get_version_content(ref_sha)
  response = nil

  # Read commit info the last tag which points to
  tree_obj = /^tree\s([a-fA-F0-9]{40})$/.match(`git cat-file -p #{ref_sha}`).captures.last.split(' ').last
  
  # Read root dir information and, if the file VERSION is found, read its content
  dir_obj = /blob\s([a-fA-F0-9]{40})\sVERSION$/.match(`git cat-file -p #{tree_obj}`)
  if dir_obj.nil?
    exit 0
  else
    response = `git cat-file -p #{dir_obj.captures.last.split(' ').last}`
  end

  return response
end

# Split all tags into an array.
# If no tags are found, exit with a non-zero code
tags = `git tag`.split(' ')
if tags.length.eql? 0
  exit 0
end

# Retrieve version content for both the lastest tag and the current reference
ver_tag = get_version_content(`git rev-list -n 1 #{tags.last}`)	# Get tag sha
ver_ref = get_version_content(STDIN.gets.split(' ')[1])	# Get local sha

# Notify to the user the project's version hasn't been updated since the last
# tag
if ver_ref.strip.eql? ver_tag.strip
  puts "#{$ppt} Project's version has not been updated since the last tag."
end

exit 0

