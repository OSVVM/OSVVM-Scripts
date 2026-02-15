# shellcheck shell=bash

# Ruff! settings
RUFF_TITLE="OSVVM Scripts"
RUFF_NAMESPACES="::osvvm"
RUFF_DIR="osvvm-scripts"

RUFF_SPHINX_PREFIX="RUFF"

# Sphinx settings
SPHINX_BUILD_DIR="_build"

# Color definitions
ANSI_RED=$'\x1b[31m'
ANSI_GREEN=$'\x1b[32m'
ANSI_YELLOW=$'\x1b[33m'
ANSI_BLUE=$'\x1b[34m'
ANSI_MAGENTA=$'\x1b[35m'
ANSI_CYAN=$'\x1b[36m'
ANSI_DARK_GRAY=$'\x1b[90m'
ANSI_LIGHT_GRAY=$'\x1b[37m'
ANSI_LIGHT_RED=$'\x1b[91m'
ANSI_LIGHT_GREEN=$'\x1b[92m'
ANSI_LIGHT_YELLOW=$'\x1b[93m'
ANSI_LIGHT_BLUE=$'\x1b[94m'
ANSI_LIGHT_MAGENTA=$'\x1b[95m'
ANSI_LIGHT_CYAN=$'\x1b[96m'
ANSI_WHITE=$'\x1b[97m'
ANSI_NOCOLOR=$'\x1b[0m'

# red texts
COLORED_ERROR="${ANSI_RED}[ERROR]"
COLORED_WARNING="${ANSI_YELLOW}[WARNING]"
COLORED_FAILED="${ANSI_RED}[FAILED]${ANSI_NOCOLOR}"

# green texts
COLORED_DONE="${ANSI_GREEN}[DONE]${ANSI_NOCOLOR}"
COLORED_SUCCESSFUL="${ANSI_GREEN}[SUCCESSFUL]${ANSI_NOCOLOR}"

# Helper functions
PrintError() {
	case $# in
		1) local indent="";   local message="$1" ;;
		2) local indent="$1"; local message="$2" ;;
	esac
	printf "${indent}${COLORED_ERROR} %s${ANSI_NOCOLOR}\n" "${message}" 1>&2
}

# Command line argument processing
VERBOSE=0
DEBUG=0
COMMAND=1
CLEAN=0
RUFF=0
POST=1
SPHINX=0
BUILDERS=()
HTML=0
LATEX=0
INSTALL=0
while [[ $# -gt 0 ]]; do
	case "$1" in
		-c|--clean)
			COMMAND=3
			CLEAN=1
			;;
		-a|--all)
			COMMAND=2
			;;
		-r|--ruff)
			COMMAND=3
			RUFF=1
			;;
		-n|--no-post-process)
			POST=0
			;;
		-s|--sphinx)
			COMMAND=3
			SPHINX=1
			;;
		-H|--html)
			HTML=1
			BUILDERS+=("html")
			;;
		-l|--latex)
			LATEX=1
			BUILDERS+=("latex")
			;;
		-i|--install)
			COMMAND=3
			INSTALL=1
			;;
		-v|--verbose)
			VERBOSE=1
			;;
		-d|--debug)
			VERBOSE=1
			DEBUG=1
			;;
		-h|--help)
			COMMAND=0
			break
			;;
		*)		# unknown option
			PrintError "Unknown command line option '$1'."
			COMMAND=0
			break
			;;
	esac
	shift # parsed argument or value
done

if [[ ${COMMAND} -le 1 ]]; then
	test ${COMMAND} -eq 1 && PrintError "No command selected."
	printf "\n"
	printf "%s\n" "${ANSI_CYAN}Synopsis:${ANSI_NOCOLOR}"
	printf "%s\n" "  Build the OSVVM-Scripts documentation."
	printf "\n"
	printf "%s\n" "${ANSI_CYAN}Usage:${ANSI_NOCOLOR}"
	printf "%s\n" "  ${ANSI_LIGHT_CYAN}$(basename "$0")${ANSI_NOCOLOR} [<verbosity>] [--clean] [--all] [--ruff] [--sphinx]"
	printf "\n"
	printf "%s\n" "${ANSI_CYAN}Common commands:${ANSI_NOCOLOR}"
	printf "%s\n" "  -h --help              Print this help page"
	printf "%s\n" "  -c --clean             Remove all generated files"
	printf "\n"
	printf "%s\n" "${ANSI_CYAN}Steps:${ANSI_NOCOLOR}"
	printf "%s\n" "  -a --all               Run all steps (--ruff --sphinx)."
	printf "%s\n" "  -r --ruff              Extract code documentation from TCL code using Ruff!."
	printf "%s\n" "  -n --no-post-process   No post-processing of Ruff! generated files."
	printf "%s\n" "  -s --sphinx            Build documentation using Sphinx."
	printf "%s\n" "                         If not specified, build only HTML variant."
	printf "%s\n" "  -H --html              Build HTML documentation using Sphinx."
	printf "%s\n" "  -l --latex             Build LaTeX documentation using Sphinx."
	printf "\n"
	printf "%s\n" "${ANSI_CYAN}Verbosity:${ANSI_NOCOLOR}"
	printf "%s\n" "  -v --verbose           Print verbose messages."
	printf "%s\n" "  -d --debug             Print debug messages."
	printf "\n"
	printf "%s\n" "${ANSI_CYAN}Requirements:${ANSI_NOCOLOR}"
	printf "%s\n" "  -i --install           Install / update required Python packages."
	exit ${COMMAND}
fi

if [[ ${COMMAND} -eq 2 ]]; then
	RUFF=1
	SPHINX=1
fi

if [[ ${SPHINX} -eq 1 ]] && (( HTML + LATEX == 0)); then
	HTML=1
	BUILDERS+=("html")
fi

# Install (or update) dependencies
if [[ ${INSTALL} -eq 1 ]]; then
	printf -- "${ANSI_MAGENTA}[BUILD] Install (or update) dependencies ...${ANSI_NOCOLOR}\n"
	pip install --break-system-packages -U -r requirements.txt | sed 's/^/  /'
fi

# Remove all generated files
if [[ ${CLEAN} -eq 1 ]]; then
	printf -- "${ANSI_MAGENTA}[BUILD] Delete old files in '${RUFF_DIR}' ...${ANSI_NOCOLOR}\n"

	test $VERBOSE -eq 1 && ARGS="-v"
	rm -Rf $ARGS ${RUFF_DIR:-.}/* | sed 's/^/  /'
	unset ARGS

	test $DEBUG -eq 1 && ARGS="-v"
	printf -- "${ANSI_MAGENTA}[BUILD] Delete old documentation files in '_build' ...${ANSI_NOCOLOR}\n"
	rm -Rf $ARGS ${SPHINX_BUILD_DIR:-.}/* | sed 's/^/  /'
	unset ARGS
fi

# Extract code documentation from TCL code
if [[ ${RUFF} -eq 1 ]]; then
	# Replace '[' with '\['
	TCL_GREEN="${ANSI_GREEN//\[/\\[}"
	TCL_CYAN="${ANSI_CYAN//\[/\\[}"
	TCL_NOCOLOR="${ANSI_NOCOLOR//\[/\\[}"

	printf -- "${ANSI_MAGENTA}[BUILD] Run Ruff! command in tclsh ...${ANSI_NOCOLOR}\n"
	mkdir -p ${SPHINX_BUILD_DIR}
	tclsh - << EOF | tee ${SPHINX_BUILD_DIR}/ruff.log | sed 's/^/  /'
puts "${TCL_CYAN}\[EXPORT SCRIPT\] Load Ruff! ...${TCL_NOCOLOR}"
puts "Ruff version: [package require ruff]"

puts "${TCL_CYAN}\[EXPORT SCRIPT\] Source ${RUFF_DIR} ...${TCL_NOCOLOR}"
source ../StartUp.tcl

puts "${TCL_CYAN}\[EXPORT SCRIPT\] Write ReST files ...${TCL_NOCOLOR}"
ruff::document ${RUFF_NAMESPACES} \
  -format sphinx \
  -title {${RUFF_TITLE}} \
  -onlyexports true \
  -recurse true \
  -outdir ${RUFF_DIR}

#  -pagesplit namespace \

puts "${TCL_CYAN}\[EXPORT SCRIPT\] ${TCL_GREEN}DONE${TCL_NOCOLOR}"
EOF

	printf -- "${ANSI_MAGENTA}[BUILD] Delete some generated files ...${ANSI_NOCOLOR}\n"
	test $VERBOSE -eq 1 && ARGS="-v"
	rm -f $ARGS ${RUFF_DIR}/conf.py    | sed 's/^/  /'
	rm -Rf $ARGS ${RUFF_DIR}/_static   | sed 's/^/  /'
	# rm -Rf $ARGS ${RUFF_DIR}/osvvm.rst | sed 's/^/  /'   # for page split
	rm -Rf $ARGS ${RUFF_DIR}/index.rst | sed 's/^/  /'     # for single page
	unset ARGS

	if [[ $DEBUG -eq 1 ]]; then
		printf -- "${ANSI_MAGENTA}[BUILD] List generated files ...${ANSI_NOCOLOR}\n"
		ls ${RUFF_DIR} | sed 's/^/  /'
	fi

	if [[ ${POST} -eq 1 ]]; then
			printf -- "${ANSI_MAGENTA}[BUILD] Patch ReST files ...${ANSI_NOCOLOR}\n"
		#printf -- "  ${ANSI_CYAN}Patching ${RUFF_DIR}/index.rst ...${ANSI_NOCOLOR}\n"
		#sed -i -E 's/.rst$//g' ${RUFF_DIR}/index.rst                     # for page split
		#sed -i -E 's/:maxdepth: .*$/:hidden:/g' ${RUFF_DIR}/index.rst    # for page split
		#sed -i -E 's/:caption: .*$//g' ${RUFF_DIR}/index.rst             # for page split
		#sed -i -E 's/   osvvm$//g' ${RUFF_DIR}/index.rst                 # for page split

		for rstFile in ${RUFF_DIR}/*.rst; do
			printf -- "  ${ANSI_CYAN}Patching ${rstFile} ...${ANSI_NOCOLOR}\n"

			filename="${rstFile##*/}"
			namespace="${filename%.*}"

			test $VERBOSE -eq 1 && printf -- "    ${ANSI_LIGHT_CYAN}Insert index entry for '${namespace}' namespace${ANSI_NOCOLOR}\n"
				sed -i -E "/^\.\. _r-${namespace}:$/a \\\n.. index::\n   single: ${namespace}" "${rstFile}"

			test $VERBOSE -eq 1 && printf -- "    ${ANSI_LIGHT_CYAN}Remove intermediate 'Commands' heading${ANSI_NOCOLOR}\n"
				sed -i -E "/^\.\. _r-3a3a${namespace}.*Commands:/,/^========$/d" "${rstFile}"

			test $VERBOSE -eq 1 && printf -- "    ${ANSI_LIGHT_CYAN}Correct index entry${ANSI_NOCOLOR}\n"
				sed -i -E "/^\.\. index::/{N; N; s|\n\.\. index::||}" "${rstFile}"
				sed -i -E "s|   single: ${namespace} namespace;|   single: ${namespace}; |g" "${rstFile}"

			test $VERBOSE -eq 1 && printf -- "    ${ANSI_LIGHT_CYAN}Add readable label${ANSI_NOCOLOR}\n"
				sed -i -E "s|^\.\. _r-3a3a(\w+)3a3a(\w+):|&\n.. _${RUFF_SPHINX_PREFIX}/\1/\2:| " "${rstFile}"

			test $VERBOSE -eq 1 && printf -- "    ${ANSI_LIGHT_CYAN}Remove backticks from heading${ANSI_NOCOLOR}\n"
				sed -i -E 's|^``(\w+)``$|\1|g' "${rstFile}"
				sed -i -E 's|----$||g' "${rstFile}"

			test $VERBOSE -eq 1 && printf -- "    ${ANSI_LIGHT_CYAN}Remove inline code markers from parameter names${ANSI_NOCOLOR}\n"
				sed -i -E 's|^:``(\w+)``:|:\1:|g' "${rstFile}"

			test $VERBOSE -eq 1 && printf -- "    ${ANSI_LIGHT_CYAN}Cleanup ReST roles${ANSI_NOCOLOR}\n"
				sed -i -E 's|:ref:``([^`]*)``|:ref:`\1`|g'   "${rstFile}"
				sed -i -E 's|:file:``([^`]*)``|:file:`\1`|g' "${rstFile}"

			test $VERBOSE -eq 1 && printf -- "    ${ANSI_LIGHT_CYAN}Fix todo directive${ANSI_NOCOLOR}\n"
				sed -i '/^\.\. todo::/,/^\.\. seealso::/ s/^- /   - /' "${rstFile}"

			test $VERBOSE -eq 1 && printf -- "    ${ANSI_LIGHT_CYAN}Fix seealso directive${ANSI_NOCOLOR}\n"
				sed -i '/^\.\. seealso::/,/^\.\. index::/ s/^- /   - /' "${rstFile}"
		done
	else
		printf -- "${ANSI_MAGENTA}[BUILD] Patch ReST files ... ${ANSI_YELLOW}[SKIPPED]\n${ANSI_NOCOLOR}"
	fi
fi

# Build documentation using Sphinx
if [[ ${SPHINX} -eq 1 ]]; then
	for builder in "${BUILDERS[@]}"; do
		printf -- "${ANSI_MAGENTA}[BUILD] Build '%s' documentation ...${ANSI_NOCOLOR}\n" "${builder}"
		sphinxArgs=(
			--verbose                                 # increase verbosity (can be repeated)
	#		--fresh-env                               # don't use a saved environment, always read all files
			--write-all                               # write all files (default: only write new and changed files)
			--builder ${builder}                      # Builder is html or latex
			-d "${SPHINX_BUILD_DIR}/doctrees"         # Sphinx document tree cache
			--jobs "$(nproc)"                         # Parallelism
			-w "${SPHINX_BUILD_DIR}/${builder}.log"   # Sphinx warning file
			.                                         # Input directory
			"${SPHINX_BUILD_DIR}/${builder}"          # Output directory
		)
		python -m sphinx build "${sphinxArgs[@]}"  | sed 's/^/  /'
	done
fi

printf -- "${ANSI_MAGENTA}[BUILD] ${ANSI_LIGHT_GREEN}COMPLETED${ANSI_NOCOLOR}\n"
