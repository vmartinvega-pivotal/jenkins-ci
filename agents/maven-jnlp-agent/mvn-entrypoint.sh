#!/bin/bash -eu

function tmpFile() {
	local -r suffix="${1}"
	local -r file="$(mktemp --tmpdir ".mvn-entrypoint.${suffix}.XXXXX")"
	echo "${file}"
}

function traceFile() {
  local -r file="${1}"
  echo "${file}.trace"
}

function headersFile() {
  local -r file="${1}"
  echo "${file}.headers"
}

function downloadExtension() {
    local -r url="${1}"
    local -r file="${2}"
    echo -e "Downloading Maven extension '$(basename "${file}")':"
    echo -e "  - Source url......: ${url} "
    echo -e "  - Target directory: $(dirname "${file}")"
    no_proxy=.corp curl \
        -fk# \
        --connect-timeout "${CURL_CONNECTION_TIMEOUT:-20}" \
        --retry "${CURL_RETRY:-5}" \
        --retry-delay "${CURL_RETRY_DELAY:-0}" \
        --retry-max-time "${CURL_RETRY_MAX_TIME:-60}" \
        --trace-ascii "$(traceFile "${file}")" \
        --dump-header "$(headersFile "${file}")" \
        -o "${file}" \
        "${url}"
}

function installExtension() {
  local -r extensionUrl="${1}"
  local -r extensionLocalFile="${2}"
  local -r extensionName="$(basename "${extensionLocalFile}")"
  if ! downloadExtension "${extensionUrl}" "${extensionLocalFile}"; then
    local -r code=${PIPESTATUS[0]}
    local -r trace="$(traceFile "${extensionLocalFile}")"
    echo -e "Maven extension '${extensionName}' download failure. Exit code ${code}."
    echo -e "  | Download trace summary:"
    while read -r fline; do
      echo -e "  |  >  ${fline}"
    done <<< "$(sed -ne '/Send header/,/Info: Ignoring the response-body/p' "${trace}" )"
    echo -e "  |  > Check full log at ${trace}"
  else
    echo -e "Maven extension '${extensionName}' installed successfully."
  fi
}

if [[ -n "${MVN_EXTENSION_URL:-}" ]]; then
  filename=${MVN_EXTENSION_URL##*/}
  targetFile="${MAVEN_HOME}/lib/ext/${filename}"
  if [[ -f "${targetFile}" ]]; then
    echo "Maven extension '${filename}' is already installed."
  else
    echo "Maven extension '${filename}' is not installed yet."
    installExtension "${MVN_EXTENSION_URL}" "${targetFile}"
	fi
else
  echo "Maven extension not configured."
fi
export PATH=$JAVA_HOME/bin:$PATH
exec "$@"
