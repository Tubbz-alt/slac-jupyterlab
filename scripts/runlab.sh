#!/bin/sh

# Set DEBUG to a non-empty value to turn on debugging
if [ -n "${DEBUG}" ]; then
  set -x
fi

###
# Set up environment
###
#source /etc/profile.d/local06-scl.sh
export PATH="${PATH}:/opt/lsf/curr/amd64_rhel70/bin/"
export SHELL="/usr/bin/bash"

###
# Create standard dirs
###
cd ${HOME}
for i in notebooks idleculler; do
  mkdir -p "${HOME}/${i}"
done

###
# allow custom post scripts
if [ -f /opt/slac/jupyterlab/post-hook.sh ]; then
  sh /opt/slac/jupyterlab/post-hook.sh
fi

###
# Run idle culler.
###
if [ -n "${JUPYTERLAB_IDLE_TIMEOUT}" ] && \
       [ "${JUPYTERLAB_IDLE_TIMEOUT}" -gt 0 ]; then
  touch ${HOME}/idleculler/culler.output && \
  nohup python3 /opt/slac/jupyterlab/selfculler.py >> \
  ${HOME}/idleculler/culler.output 2>&1 &
fi

###
# run the hub
###
cmd="/conda/envs/rapids/bin/jupyter-labhub \
     --ip='*' --port=8888 \
     --hub-api-url=${JUPYTERHUB_API_URL} \
     --notebook-dir=${HOME}/notebooks"
if [ -n "${DEBUG}" ]; then
    cmd="${cmd} --debug"
fi
echo "JupyterLab command: '${cmd}'"
if [ -n "${DEBUG}" ]; then
  # Spin while waiting for interactive container use.
  while : ; do
    ${cmd}
    d=$(date)
    echo "${d}: sleeping."
    sleep 60
  done
else
  # Start Lab
  exec ${cmd}
fi
