# CUDA 개발 이미지 사용 (runtime 대신)
FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# 기본 환경 준비
RUN apt-get update && apt-get install -y \
    git python3 python3-pip python3-dev \
    cmake build-essential ninja-build \
    libopenblas-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 핸들러 복사
COPY handler.py .

# 환경변수 설정 (CUDA 지원 - GGML_CUDA 사용)
ENV CMAKE_ARGS="-DGGML_CUDA=on -DCMAKE_CUDA_ARCHITECTURES=all"
ENV FORCE_CMAKE=1
ENV CUDA_DOCKER_ARCH=all
ENV GGML_CUDA=1

# HF 토큰 (빌드 타임에 전달)
ARG HF_TOKEN
ENV HF_TOKEN=$HF_TOKEN

# Python 패키지 설치
RUN pip install --upgrade pip
RUN pip install --no-cache-dir runpod huggingface_hub

# llama-cpp-python을 소스에서 빌드 (GGML_CUDA 사용)
RUN CMAKE_ARGS="-DGGML_CUDA=on -DCMAKE_CUDA_ARCHITECTURES=all" \
    FORCE_CMAKE=1 \
    pip install --no-cache-dir llama-cpp-python --no-binary llama-cpp-python --verbose

# Hugging Face에서 GGUF 모델 다운로드 (빌드 시 포함)
RUN mkdir -p /models && \
    huggingface-cli download mykor/Midm-2.0-Base-Instruct-gguf \
    Midm-2.0-Base-Instruct-Q5_K_M.gguf \
    --local-dir /models

ENV MODEL_PATH=/models/Midm-2.0-Base-Instruct-Q5_K_M.gguf

CMD ["python3", "handler.py"]
