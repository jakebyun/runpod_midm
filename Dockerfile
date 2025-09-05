FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

# 기본 환경 준비
RUN apt-get update && apt-get install -y git python3 python3-pip && rm -rf /var/lib/apt/lists/*
WORKDIR /app

# 핸들러 복사
COPY handler.py .

# 필요한 파이썬 패키지 설치
RUN pip install --no-cache-dir runpod llama-cpp-python==0.2.76 huggingface_hub

# Hugging Face에서 GGUF 모델 다운로드 (빌드 시 포함)
RUN huggingface-cli download mykor/Midm-2.0-Base-Instruct-gguf \
    --include "Midm-2.0-Base-Instruct-Q5_K_M.gguf" \
    --local-dir /models

ENV MODEL_PATH=/models/Midm-2.0-Base-Instruct-Q5_K_M.gguf

CMD ["python3", "handler.py"]
