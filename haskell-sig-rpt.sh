#!/usr/bin/bash

WDIR=$(pwd)
HDIR=${1:-${WDIR}}
SDIR=${2:-${HDIR}}
HS_SIG="${SDIR}/haskell-sig.sed"

[ -f ${HS_SIG} ] || { 
  echo "missing script file ${HS_SIG}" >/dev/stderr
  exit 2
}

find ${HDIR} -type d -print                                  \
  | sort                                                     \
  | while read WDIR
    do
      find ${WDIR} -maxdepth 1 -type f -name '*.hs' | grep -q '.hs' || continue
      test $(find ${WDIR} -maxdepth 1 -type f -name '*.hs' | xargs -ri sed -n -f ${HS_SIG} {} -- | wc -l) -gt 0 || continue
      echo -e "\n# ${WDIR}"
      pushd ${WDIR} >/dev/null
      find -maxdepth 1 -type f -name '*.hs'                 \
        | sort                                              \
        | while read HS
          do
            test $(sed -n -f ${HS_SIG} ${HS} | wc -l) -gt 0 || continue
            echo -e "\n## $(basename ${HS} .hs)\n"
            sed -n -f ${HS_SIG} ${HS} | sort -u
          done
      popd >/dev/null
    done


