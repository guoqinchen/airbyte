#!/usr/bin/env python3
"""
glossary-to-csv.py — 将 i18n 术语库 Markdown 表格转换为 Weblate 接受的 CSV 格式。

输入:docs/contributing-to-airbyte/i18n-glossary.md
输出:Weblate glossary CSV 到 stdout

Weblate glossary CSV 格式:
    en,zh-Hans,ja,pt-BR
    Source,数据源,ソース,Fonte
    ...
"""
import re
import sys
from pathlib import Path


def parse_markdown_table(text: str) -> list[dict[str, str]]:
    """解析 Markdown 表格为字典列表。"""
    rows: list[dict[str, str]] = []
    lines = text.splitlines()
    in_table = False
    headers: list[str] = []
    for line in lines:
        line = line.strip()
        if line.startswith("|") and not in_table:
            # 表头
            headers = [c.strip() for c in line.strip("|").split("|")]
            in_table = True
        elif line.startswith("|") and in_table:
            # 跳过分隔行(---|---|---)
            if re.match(r"^\|[\s\-:|]+\|$", line):
                continue
            cells = [c.strip() for c in line.strip("|").split("|")]
            if len(cells) != len(headers):
                continue
            row = dict(zip(headers, cells))
            # 跳过 "备注" 列
            row.pop("备注", None)
            row.pop("Note", None)
            rows.append(row)
        else:
            in_table = False
    return rows


def to_weblate_csv(rows: list[dict[str, str]]) -> str:
    """转换为 Weblate CSV 格式(第一列为 source,其余为 translations)。"""
    if not rows:
        return "en,zh-Hans,ja,pt-BR\n"

    # 找到 English 列
    en_key = next(
        (k for k in rows[0] if k.lower() in ("english", "en")), None
    )
    if not en_key:
        sys.exit("ERROR: 表格未找到 'English' 列")

    # 其他 locale 列
    target_keys = [
        k for k in rows[0] if k not in (en_key, "备注", "Note", "")
    ]

    out_lines = [",".join([en_key, *target_keys])]
    for row in rows:
        en_val = row.get(en_key, "").strip()
        if not en_val or en_val.startswith("#"):
            continue
        cells = [en_val]
        for tk in target_keys:
            cells.append(row.get(tk, "").strip())
        # 转义包含逗号或引号的字段
        escaped = []
        for c in cells:
            if "," in c or '"' in c or "\n" in c:
                c = '"' + c.replace('"', '""') + '"'
            escaped.append(c)
        out_lines.append(",".join(escaped))
    return "\n".join(out_lines) + "\n"


def main() -> None:
    if len(sys.argv) != 2:
        sys.exit(f"用法:{sys.argv[0]} <i18n-glossary.md>")

    md_path = Path(sys.argv[1])
    if not md_path.exists():
        sys.exit(f"ERROR: 文件不存在:{md_path}")

    text = md_path.read_text(encoding="utf-8")
    rows = parse_markdown_table(text)
    csv = to_weblate_csv(rows)
    sys.stdout.write(csv)


if __name__ == "__main__":
    main()
