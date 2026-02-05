#!/usr/bin/env python3

import subprocess

def run(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL).decode().strip()
    except Exception:
        return ""

# Check if NVIDIA tools exist
if not run("command -v nvidia-smi"):
    print("0|0|0|0")
    exit(0)

# Query GPU stats
query = run(
    "nvidia-smi --query-gpu=utilization.gpu,"
    "memory.used,memory.total,temperature.gpu "
    "--format=csv,noheader,nounits"
)

if not query:
    print("0|0|0|0")
    exit(0)

try:
    gpu_util, mem_used, mem_total, gpu_temp = map(int, query.split(","))
    vram_pct = int((mem_used / mem_total) * 100) if mem_total > 0 else 0
    print(f"{gpu_util}|{mem_used}|{vram_pct}|{gpu_temp}")
except Exception:
    print("0|0|0|0")
