FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# 기본 환경 준비 (ninja 빌드 툴 추가)
RUN apt-get update && apt-get install -y \
    git python3 python3-pip cmake build-essential ninja-build \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 핸들러 복사
COPY handler.py .

# 환경변수 설정 (CUDA 지원)
ENV CMAKE_ARGS="-DLLAMA_CUBLAS=ON"
ENV FORCE_CMAKE=1

# 필요한 파이썬 패키지 설치 (순서 중요)
RUN pip install --no-cache-dir runpod huggingface_hub
RUN pip install --no-cache-dir llama-cpp-python==0.2.76 --verbose

# Hugging Face에서 GGUF 모델 다운로드 (빌드 시 포함)
# HF_TOKEN은 Dockerfile에 직접 넣지 않고 빌드/런타임에서 ENV로 전달
RUN mkdir -p /models && \
    huggingface-cli download mykor/Midm-2.0-Base-Instruct-gguf \
    Midm-2.0-Base-Instruct-Q5_K_M.gguf \
    --local-dir /models --token $HF_TOKEN

ENV MODEL_PATH=/models/Midm-2.0-Base-Instruct-Q5_K_M.gguf

CMD ["python3", "handler.py"]
