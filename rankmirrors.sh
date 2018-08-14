#!/usr/bin/env bash
#
#   rankmirrors - read a list of mirrors from a file and rank them by speed
#   Generated from rankmirrors.sh.in; do not edit by hand.
#
#   Copyright (c) 2009 Matthew Bruenig <matthewbruenig@gmail.com>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

# traps interrupt key to spit out pre-interrupt info
trap finaloutput INT

declare -r myname='rankmirrors'
declare -r myver='1.1.0'

usage() {
	echo "${myname} v${myver}"
	echo
	echo "Ranks pacman mirrors by their connection and opening speed. Pacman mirror"
	echo "files are located in /etc/pacman.d/. It can also rank one mirror if the URL is"
	echo "provided."
	echo
	echo "Usage: ${myname} [options] MIRRORFILE | URL"
	echo
	echo "Options:"
	echo "  --version           show program's version number and exit"
	echo "  -h, --help          show this help message and exit"
	echo "  -n NUM              number of servers to output, 0 for all"
	echo "  -m, --max-time NUM  specify a ranking operation timeout, can be decimal number"
	echo "  -t, --times         only output mirrors and their response times"
	echo "  -u, --url           test a specific URL"
	echo "  -v, --verbose       be verbose in output"
	echo "  -r, --repo          specify a repository name instead of guessing"
	exit 0
}

version() {
	echo "${myname} (pacman) ${myver}"
	echo "Copyright (c) 2009 Matthew Bruenig <matthewbruenig@gmail.com>."
	echo
	echo "This is free software; see the source for copying conditions."
	echo "There is NO WARRANTY, to the extent permitted by law."
	exit 0
}

err() {
	echo "$1" >&2
	exit 1
}

# gettime fetchurl (e.g gettime http://foo.com/core/os/i686/core.db.tar.gz)
# returns the fetching time, or timeout, or unreachable
gettime() {
	IFS=' ' output=( $(curl -s -m $MAX_TIME -w "%{time_total} %{http_code}" "$1" -o/dev/null) )
	(( $? == 28 )) && echo timeout && return
	(( ${output[1]} >= 400 || ! ${output[1]} )) && echo unreachable && return
	echo "${output[0]}"
}

# getfetchurl serverurl (e.g. getturl http://foo.com/core/os/i686)
# if $repo is in the line, then assumes core
# if $arch is in the line, then assumes $(uname -m)
# returns a fetchurl (e.g. http://foo.com/core/os/i686/core.db.tar.gz)
ARCH="$(uname -m)"
getfetchurl() {
	local strippedurl="${1%/}"

	local replacedurl="${strippedurl//'$arch'/$ARCH}"
	if [[ ! $TARGETREPO ]]; then
		replacedurl="${replacedurl//'$repo'/core}"
		local tmp="${replacedurl%/*}"
		tmp="${tmp%/*}"

		local reponame="${tmp##*/}"
	else
		replacedurl="${replacedurl//'$repo'/$TARGETREPO}"
		local reponame="$TARGETREPO"
	fi

	if [[ -z $reponame || $reponame = $replacedurl ]]; then
		echo "fail"
	else
		local fetchurl="${replacedurl}/$reponame.db"
		echo "$fetchurl"
	fi
}

# This exists to remove the need for a separate interrupt function
finaloutput() {
	IFS=$'\n' read -r -d '' -a sortedarray < \
		<(printf '%s\n' "${timesarray[@]}" | LC_COLLATE=C sort)

	# Final output for mirrorfile
	numiterator="0"
	if [[ $TIMESONLY ]]; then
		echo
		echo " Servers sorted by time (seconds):"
		for line in "${sortedarray[@]}"; do
			echo "${line#* } : ${line% *}"
			((numiterator++))
			(( NUM && numiterator >= NUM )) && break
		done
	else
		for line in "${sortedarray[@]}"; do
			echo "Server = ${line#* }"
			((numiterator++))
			(( NUM && numiterator >= NUM )) && break
		done
	fi
	exit 0
}


# Argument parsing
[[ $1 ]] || usage
while [[ $1 ]]; do
	if [[ ${1:0:2} = -- ]]; then
		case "${1:2}" in
			help) usage ;;
			version) version ;;
			max-time)
				[[ $2 ]] || err "Must specify number.";
				MAX_TIME="$2"
				shift 2;;
			times) TIMESONLY=1 ; shift ;;
			verbose) VERBOSE=1 ; shift ;;
			url)
				CHECKURL=1;
				[[ $2 ]] || err "Must specify URL.";
				URL="$2";
				shift 2;;
			repo)
				[[ $2 ]] || err "Must specify repository name.";
				TARGETREPO="$2";
				shift 2;;
			*) err "'$1' is an invalid argument."
		esac
	elif [[ ${1:0:1} = - ]]; then

		if [[ ! ${1:1:1} ]]; then
			[[ -t 0 ]] && err "Stdin is empty."
			IFS=$'\n' linearray=( $(</dev/stdin) )
			STDIN=1
			shift
		else
			snum=1
			for ((i=1 ; i<${#1}; i++)); do
				case ${1:$i:1} in
					h) usage ;;
					m)
						[[ $2 ]] || err "Must specify number.";
						MAX_TIME="$2"
						shift 2;;
					t) TIMESONLY=1 ;;
					v) VERBOSE=1 ;;
					u)
						CHECKURL=1;
						[[ $2 ]] || err "Must specify URL.";
						URL="$2";
						snum=2;;
					r)
						[[ $2 ]] || err "Must specify repository name.";
						TARGETREPO="$2";
						snum=2;;
					n)
						[[ $2 ]] || err "Must specify number.";
						NUM="$2";
						snum=2;;
					*) err "'$1' is an invalid argument." ;;
				esac
			done
			shift $snum
		fi
	elif [[ -f $1 ]]; then
		FILE="1"
		IFS=$'\n' linearray=( $(<$1) )
		[[ $linearray ]] || err "File is empty."
		shift
	else
		err "'$1' does not exist."
	fi
done

# Some sanity checks
[[ $NUM ]] || NUM=0
[[ $MAX_TIME ]] || MAX_TIME=10
[[ $FILE && $CHECKURL ]] && err "Cannot specify a URL and mirrorfile."
[[ $FILE || $CHECKURL || $STDIN ]] || err "Must specify URL, mirrorfile, or stdin."

# Single URL handling
if [[ $CHECKURL ]]; then
	url="$(getfetchurl "$URL")"
	[[ $url = fail ]] && err "URL '$URL' is malformed."
	[[ $VERBOSE ]] && echo "Testing $url..."
	time=$(gettime "$url")
	echo "$URL : $time"
	exit 0
fi

# Get URL results from mirrorfile, fill up the array, and so on
if [[ $TIMESONLY ]]; then
	echo "Querying servers. This may take some time..."
elif [[ $FILE ]]; then
	echo "# Server list generated by rankmirrors on $(date +%Y-%m-%d)"
fi

timesarray=()
for line in "${linearray[@]}"; do
	if [[ $line =~ ^[[:space:]]*# ]]; then
		[[ $TIMESONLY ]] || echo $line
	elif [[ $line =~ ^[[:space:]]*Server ]]; then

		# Getting values and times and such
		server="${line#*= }"
		server="${server%%#*}"
		url="$(getfetchurl "$server")"
		[[ $url = fail ]] && err "URL '$URL' is malformed."
		time=$(gettime "$url")
		timesarray+=("$time $server")

		# Output
		if [[ $VERBOSE && $TIMESONLY ]]; then
			echo "$server ... $time"
		elif [[ $VERBOSE ]]; then
			echo "# $server ... $time"
		elif [[ $TIMESONLY ]]; then
			echo -n "   *"
		fi
	fi
done
finaloutput
