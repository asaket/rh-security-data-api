#!/bin/bash

set -euo pipefail

readonly RHCOS_ART_BASE_DOMAIN="releases-rhcos-art.apps.ocp-virt.prod.psi.redhat.com"
#ARCH="$(arch)"
ARCH="x86_64"
readonly ARCH

function get-rhelver {

		local RHCOS_VERSION
		RHCOS_VERSION="${1}"

		local RHELVER_FOUND
		RHELVER_FOUND="$(echo "${RHCOS_VERSION}" | gawk -F. '{version=gensub("^([89])([0-9]*)$","\\1.\\2","g",$2);print version}')"
		echo -n "${RHELVER_FOUND}"
}


function get-commitmeta-url {
	local OCP_MAJOR="${1}"
	local RHCOS_VERSION="${2}"
	local RHELVER
	RHELVER="$(get-rhelver "${RHCOS_VERSION}")"
	
	if (curl -s -k "https://${RHCOS_ART_BASE_DOMAIN}/storage/releases/rhcos-${OCP_MAJOR}/builds.json" | jq '.builds[]|.id' -r 2>/dev/null | grep "${RHCOS_VERSION}" > /dev/null 2>/dev/null)
	then
		echo -n "https://${RHCOS_ART_BASE_DOMAIN}/storage/releases/rhcos-${OCP_MAJOR}/${RHCOS_VERSION}/${ARCH}/commitmeta.json"
	elif (curl -s -k "https://${RHCOS_ART_BASE_DOMAIN}/storage/releases/rhcos-${OCP_MAJOR}-custom/builds.json" | jq '.builds[]|.id' -r 2>/dev/null | grep "${RHCOS_VERSION}" > /dev/null 2>/dev/null)
	then
		echo -n "https://${RHCOS_ART_BASE_DOMAIN}/storage/releases/rhcos-${OCP_MAJOR}-custom/${RHCOS_VERSION}/${ARCH}/commitmeta.json"
	elif [[ "$(echo "${RHELVER}" | awk -F. '{print $1}')" == "8" ]]
	then
		echo -n "https://${RHCOS_ART_BASE_DOMAIN}/storage/prod/streams/${OCP_MAJOR}/builds/${RHCOS_VERSION}/${ARCH}/commitmeta.json" 
	else
		echo -n "https://${RHCOS_ART_BASE_DOMAIN}/storage/prod/streams/${OCP_MAJOR}-${RHELVER}/builds/${RHCOS_VERSION}/${ARCH}/commitmeta.json"
	fi
}


function get-package-version {
	OCP_RELEASE="${1}"
	PACKAGE="${2}"

	OCP_MAJOR="$(echo "${OCP_RELEASE}" | awk -F. '{print $1"."$2}')"

	RHCOS_VERSION="$(oc adm release info "${OCP_RELEASE}" -o jsonpath='{.displayVersions.machine-os.Version}')"

	RHCOS_COMMITMETA_URL="$(get-commitmeta-url "${OCP_MAJOR}" "${RHCOS_VERSION}")"

	curl -sk "${RHCOS_COMMITMETA_URL}" | jq -r '.["rpmostree.rpmdb.pkglist"]|map(select(.[0]=="'"${PACKAGE}"'"))[0]|.[0]+"-"+.[2]+"-"+.[3]+"."+.[4]'
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]]  || get-package-version "${@}"

