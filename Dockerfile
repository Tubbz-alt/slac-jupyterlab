FROM rapidsai/rapidsai:0.8-cuda10.0-devel-centos7-gcc7-py3.6

USER root
RUN   curl -sL https://rpm.nodesource.com/setup_10.x | bash - && \
        yum install -y epel-release \
        && yum repolist \
        && yum -y upgrade

RUN   yum -y install centos-release-scl && \
      yum -y install \
        git sudo \
        nodejs \
        wget jq \
        bzip2 zip unzip lrzip \
        tree \
        which \
        && yum clean all

RUN  pip  --no-cache-dir  install --upgrade \
        virtualenv \
        virtualenvwrapper \
        pipenv \
        jupyterhub \
        jupyterlabutils \
        ipykernel \
        nbval \
        ipyevents \
        ipywidgets \
        tqdm \
        paramnb \
        gputil \
        psutil \
        gsutil \
        pygments \
        humanize \
        pypandoc \
        jupyterlab-git \
        numpydoc 

# data libraries
RUN  pip  --no-cache-dir  install --upgrade \
        uproot \
        papermill \
        pyculib \
        pypandoc 

# machine learning libs
RUN  pip  --no-cache-dir  install --upgrade \
        kaggle \
        fastai \
        nltk \
        h5py \
        mat4py \
        scikit-image \
        Pillow \
        opencv-python \
        scikit-learn \
        Theano \
        tensorflow-gpu \
        tensorboard \
        jupyter-tensorboard \
        keras \
        torch \
        torchvision 

#RUN source scl_source enable rh-python36 && \
#      pip  --no-cache-dir  install --upgrade \
#        torch-scatter torch-sparse torch-cluster torch-spline-conv torch-geometric  
        
# visualisation libs
#RUN  source scl_source enable rh-python36 && \
RUN   pip  --no-cache-dir  install --upgrade \
        rise \
        graphviz \
        tables \
        bokeh \
        seaborn \
        bqplot \
        ipyvolume \
        gmaps

RUN  server_extensions="jupyterlab \
        jupyterlab_git" && \
      set -e && \
      for s in ${server_extensions}; do \
        echo "Installing ${s}..."; \
        jupyter serverextension enable ${s} --py --sys-prefix; \
      done
      
RUN  notebook_extensions="widgetsnbextension \
        ipyevents \
        rise \
        ipyvolume" && \
      set -e && \
      for n in ${notebook_extensions}; do \
        echo "Installing ${n}..."; \
        jupyter nbextension install --py --sys-prefix ${n}; \
        jupyter nbextension enable --py --sys-prefix ${n}; \
      done

#        @enlznep/runall-extension \
#        jupyterlab-server-proxy \
#        @lckr/jupyterlab_variableinspector \
#        nbdime-jupyterlab \
#        dask-labextension \
RUN  lab_extensions="@jupyterlab/celltags \
        @jupyterlab/toc \
        jupyterlab-spreadsheet \
        @krassowski/jupyterlab_go_to_definition \
        @jupyter-widgets/jupyterlab-manager \
        @lsst-sqre/jupyterlab-savequit \
        bqplot \
        ipyevents \
        ipyvolume \
        jupyter-threejs \
        jupyter-matplotlib \
        jupyterlab_bokeh \
        @jupyterlab/git \
        @jupyterlab/google-drive \
        jupyterlab_tensorboard \
        @jupyterlab/hub-extension" && \
      set -e && \
      for l in ${lab_extensions}; do \
        echo "Installing ${l}..."; \
        jupyter labextension install --no-build ${l} ; \
        jupyter labextension enable ${l} ; \
      done

ENV  NODE_OPTIONS=--max-old-space-size=4096
RUN jupyter lab clean && \
      jupyter lab build

# Custom local files
COPY profile.d/local03-showmotd.sh \
      profile.d/local04-pythonrc.sh \
      profile.d/local05-path.sh \
      profile.d/local06-scl.sh \
      profile.d/local07-term.sh \
      profile.d/local08-virtualenvwrapper.sh \
      /etc/profile.d/
RUN  cd /etc/profile.d && \
     for i in local*; do \
         ln ${i} $(basename ${i} .sh).csh ; \
     done
RUN  for i in notebooks idleculler ; do \
        mkdir -p /etc/skel/${i} ; \
     done	

COPY motd /etc/motd
COPY jupyter_notebook_config.json /usr/etc/jupyter
COPY 20_jupytervars /etc/sudoers.d/
COPY pythonrc /etc/skel/.pythonrc
COPY scripts/selfculler.py \
      scripts/launch.bash \
      scripts/entrypoint.bash \
      scripts/runlab.sh \
      scripts/prepuller.sh \
      scripts/post-hook.sh \
      /opt/slac/jupyterlab/

RUN  ln -sf /opt/lsf/curr/conf/lsf.conf.co /etc/lsf.conf \
  &&  ln -sf /afs/slac/package/lsf /opt/lsf

ENV  LANG=C.UTF-8

WORKDIR /tmp
CMD [ "/opt/slac/jupyterlab/entrypoint.bash" ]

