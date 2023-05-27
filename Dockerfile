FROM nvidia/cuda:11.1.1-devel-ubuntu18.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3.7 \
    python3.7-dev \
    python3-pip \
    vim

# setup workdir
WORKDIR /app

# Set the default Python version to 3.7
RUN ln -s /usr/bin/python3.7 /usr/bin/python
RUN python -m pip install --upgrade pip

# set up open-cv and graphics
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

# Install pytorch
RUN pip install torch==1.10.0+cu111 torchvision==0.11.0+cu111 torchaudio==0.10.0 -f https://download.pytorch.org/whl/torch_stable.html

# install mmcv 1.4.4
RUN MMCV_WITH_OPS=1 FORCE_CUDA=1 pip install mmcv-full==1.4.4 -f https://download.openmmlab.com/mmcv/dist/cu111/torch1.10.0/index.html

RUN pip install future tensorboard
RUN pip install wandb

# add ENV variables
ENV FORCE_CUDA="1"
ENV MMCV_WITH_OPS=1

# Set up development environment
ENV PYTHONPATH=/app/mmdetection:$PYTHONPATH
ENV CUDA_HOME=/usr/local/cuda


COPY mmdet-requirements.txt /app/mmdet-requirements.txt

# download release of github repo from https://github.com/open-mmlab/mmdetection/archive/refs/tags/v2.21.0.zip
RUN wget https://github.com/open-mmlab/mmdetection/archive/refs/tags/v2.21.0.zip
RUN unzip mmdetection-2.21.0.zip
RUN mv mmdetection-2.21.0 mmdetection

# Install mmdetection
RUN cd /app/mmdetection && pip install -r requirements/build.txt
RUN pip install "git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI"
RUN cd /app/mmdetection && pip install -v -e .

# Start the development server or any other development command
CMD ["/bin/bash"]
