which_cmd() {
	local block=1
	if [ "a${1}" = "a-n" ]
	then
		local block=0
		shift
	fi

	unalias "$2" >/dev/null 2>&1
	local cmd
  cmd=$(which "$2" 2>/dev/null | head -n 1)
	local exit_code=$?
	if [ $exit_code -gt 0 ] || [ ! -x "${cmd}" ]
	then
		if [ ${block} -eq 1 ]
		then
			echo >&2
			echo >&2 "ERROR:	Command '$2' not found in the system path."
			echo >&2
			echo >&2 "	which $2"
			exit 1
		fi
		return 1
	fi

	eval "$1"="${cmd}"
	return 0
}

which_cmd GIT git

echo "$GIT"