if [ $# -eq 0 ]
then
  echo "Usage: $0 <image-path>"
  echo "Example: $0 registry.redhat.io/multicluster-engine/registration-operator-rhel9@sha256:ebcffa33976b385266488b356ae3add03ff11c4ec9928674edbb90c481c6c771"
  exit 0
fi

if ! [ -f ./ocp-pull-secret.json ]
then
  echo "Ensure to store the pull secret in `pwd`/ocp-pull-secret.json"
  exit 0
fi

podman run --rm --authfile ./ocp-pull-secret.json -it --entrypoint /bin/bash $1
