#!/usr/bin/env bash
# libspeex 统一门禁用例：内核级差分（标量参考实现 vs 链接库里的实现）。
# 六个差分程序各自把"参考实现"和"库里实际跑的代码"逐次对比，正常应打印 0 处不一致。
# 输出是确定性的（无计时、无地址），A/B 两侧可直接 diff。
set -euo pipefail

: "${STAGE:=run}" "${SIDE:=A}" "${BIN:=build/ab-a}" "${DATA:=build/ab-data}" "${OUT:=build/ab-data/out}"
mkdir -p "$DATA" "$OUT"

KERNEL_DIFFS="gshelp_diff open_loop_diff vqtail_diff inner_prod_diff qmf_diff filter_diff"

case "$STAGE" in
  gen)
    # 输入全部由差分程序内部合成，无需外部语料
    ;;
  run)
    : > "$OUT/kernels.txt"
    for t in ${KERNEL_DIFFS}; do
      if [ ! -x "$BIN/test/$t" ]; then
        echo "缺少 $BIN/test/$t" >&2
        exit 1
      fi
      echo "== $t" >> "$OUT/kernels.txt"
      ${RUNNER:-} "$BIN/test/$t" >> "$OUT/kernels.txt"
    done
    ;;
  *)
    echo "未知 STAGE=$STAGE" >&2; exit 2 ;;
esac
