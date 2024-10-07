# rh-security-data-api
Shell script to extract jason data for a CVE

**Usage**
1. Login to a terminal
2. Copy or clone the script from github
3. Ensure files have execute permission. (chmod u+x <script>)
4. Execute the script (./<script> <CVE_ID>)

**Mapping RHEL CVE fix to RHCOS and RHOCP**
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

##################
# PRE-REQUISITES #
##################
# export REGISTRY_AUTH_FILE=<pull-secret-file>
# Example:
# chmod u+x set-var.sh
# ./set-var.sh

$ ./get-package-version.sh 4.15.30 openssl
openssl-3.0.7-18.el9_2.x86_64
$ ./get-package-version.sh 4.15.30 kernel
kernel-5.14.0-284.82.1.el9_2.x86_64
$ ./get-package-version.sh 4.15.30 systemd
systemd-252-14.el9_2.8.x86_64

OR FOLLOW BELOW STEPS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
1. Check the image name
$ oc adm release info 4.15.30 | grep machine-os-content
  machine-os-content                             sha256:07e296ea94784f4d54008627a77830086445458ddec2b70c043f6e87d81ca273

$ oc adm release info --image-for=machine-os-content 4.15.30
quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:07e296ea94784f4d54008627a77830086445458ddec2b70c043f6e87d81ca273

2. Find the package version
$ podman run --rm --authfile ./ocp-pull-secret.json -it --entrypoint /bin/cat quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:07e296ea94784f4d54008627a77830086445458ddec2b70c043f6e87d81ca273 /pkglist.txt | grep openssl
Trying to pull quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:07e296ea94784f4d54008627a77830086445458ddec2b70c043f6e87d81ca273...
Getting image source signatures
Copying blob sha256:aba58f50907bfaec75ad5469e19d9ec9296f4e326fb92be972c002570c46e94f
Copying blob sha256:ebbef44f94490275d5c317ffaaa288be346a3521ff962d11fedf0acac9c232b7
Copying config sha256:334602f57b80a1e9734447ac09081759ff40db1b79a2d4e39e11ffe58ed2aa18
Writing manifest to image destination
WARNING: image platform (linux/amd64) does not match the expected platform (linux/arm64)
openssl-1:3.0.7-18.el9_2.x86_64
openssl-libs-1:3.0.7-18.el9_2.x86_64
xmlsec1-openssl-1.2.29-9.el9.x86_64

$ podman run --rm --authfile ./ocp-pull-secret.json -it --entrypoint /bin/cat quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:07e296ea94784f4d54008627a77830086445458ddec2b70c043f6e87d81ca273 /pkglist.txt | grep systemd
WARNING: image platform (linux/amd64) does not match the expected platform (linux/arm64)
clevis-systemd-18-110.el9.x86_64
systemd-252-14.el9_2.8.x86_64
systemd-journal-remote-252-14.el9_2.8.x86_64
systemd-libs-252-14.el9_2.8.x86_64
systemd-pam-252-14.el9_2.8.x86_64
systemd-rpm-macros-252-14.el9_2.8.noarch
systemd-udev-252-14.el9_2.8.x86_64


**References**
https://access.redhat.com/solutions/6962273 - How do I map a RHEL CVE fix to RHCOS and RHOCP?
https://access.redhat.com/solutions/5787001 - Obtaining package list for RHEL CoreOS or specific image
https://access.redhat.com/articles/6907891 - RHEL Versions Utilized by RHEL CoreOS and OCP
