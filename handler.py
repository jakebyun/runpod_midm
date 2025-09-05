import os
import runpod
from llama_cpp import Llama

# 모델 경로 (도커 이미지 빌드시 /models 안에 넣을 예정)
MODEL_PATH = os.getenv("MODEL_PATH", "/models/Midm-2.0-Base-Instruct-Q5_K_M.gguf")

# Pod 시작 시 모델 로드 (1회)
llm = Llama(
    model_path=MODEL_PATH,
    n_ctx=4096,        # 24GB GPU → 4k context 안정적
    n_gpu_layers=-1    # GPU에 가능한 만큼 올림
)

def handler(job):
    """Runpod Serverless 핸들러"""
    prompt = job.get("input", {}).get("prompt", "")
    if not prompt:
        return {"error": "no prompt provided"}

    output = llm(
        prompt,
        max_tokens=512,
        temperature=0.7,
        top_p=0.9
    )

    return {
        "status": "success",
        "output": output["choices"][0]["text"]
    }

# Runpod 서버리스 시작
runpod.serverless.start({"handler": handler})
