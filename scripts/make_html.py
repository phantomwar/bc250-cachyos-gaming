#!/usr/bin/env python3
"""Gera a versao HTML autocontida (tema escuro, zero recursos externos) do guia.

Uso:
    python scripts/make_html.py                        # usa docs/GUIA_BC250_CACHYOS_GAMING.md
    python scripts/make_html.py caminho/para/guia.md   # caminho arbitrario

Requer: pip install markdown
"""
import re
import sys
from pathlib import Path

import markdown

DEFAULT = Path(__file__).resolve().parent.parent / "docs" / "GUIA_BC250_CACHYOS_GAMING.md"
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT
DST = SRC.with_suffix(".html")

text = SRC.read_text(encoding="utf-8")

# Remove a secao de indice manual (o TOC e gerado automaticamente)
text = re.sub(r"## Índice\n.*?\n---\n", "", text, count=1, flags=re.S)

m = re.match(r"#\s+(.+)", text.strip())
title = m.group(1).strip() if m else "Guia BC-250"

md = markdown.Markdown(
    extensions=["tables", "fenced_code", "sane_lists", "toc"],
    extension_configs={"toc": {"permalink": False}},
)
body = md.convert(text)
toc = md.toc

css = (
":root{--bg:#0f1115;--panel:#161a21;--line:#2a2f3a;--tx:#d7dce3;--dim:#9aa4b2;--acc:#4fc3f7;--warn:#ffb454;--code:#ffd479}\n"
"*{box-sizing:border-box}\n"
"html{scroll-behavior:smooth}\n"
"body{margin:0;background:var(--bg);color:var(--tx);font:16px/1.65 'Segoe UI',system-ui,-apple-system,sans-serif}\n"
"main{max-width:960px;margin:0 auto;padding:34px 20px 90px}\n"
"h1{font-size:1.85rem;line-height:1.3;color:var(--acc);margin:.2em 0 .5em}\n"
"h2{font-size:1.32rem;margin:2.1em 0 .6em;padding-bottom:.3em;border-bottom:1px solid var(--line)}\n"
"h3{font-size:1.1rem;color:#8fd3f4;margin:1.7em 0 .5em}\n"
"a{color:var(--acc);text-decoration:none}\n"
"a:hover{text-decoration:underline}\n"
"code{background:var(--panel);color:var(--code);padding:2px 6px;border-radius:4px;font:.88em/1.55 Consolas,Menlo,monospace}\n"
"pre{background:#12151b;border:1px solid var(--line);border-radius:8px;padding:14px 16px;overflow-x:auto}\n"
"pre code{background:none;padding:0;color:#9cdcfe}\n"
"table{border-collapse:collapse;width:100%;margin:1em 0;font-size:.95em;display:block;overflow-x:auto}\n"
"th,td{border:1px solid var(--line);padding:8px 12px;text-align:left;vertical-align:top}\n"
"th{background:#1b2028;color:#fff}\n"
"tr:nth-child(even) td{background:#141821}\n"
"blockquote{margin:1.1em 0;padding:10px 16px;border-left:4px solid var(--warn);background:rgba(255,180,84,.08);border-radius:0 8px 8px 0}\n"
"blockquote p{margin:.35em 0}\n"
"hr{border:0;border-top:1px solid var(--line);margin:2.4em 0}\n"
"ul,ol{padding-left:1.4em}\n"
"li{margin:.3em 0}\n"
".toc{background:var(--panel);border:1px solid var(--line);border-radius:10px;padding:14px 22px;margin:1.6em 0}\n"
".toc ul{padding-left:1.2em;margin:.2em 0;list-style:none}\n"
".toc li{margin:.28em 0}\n"
".toc>div>ul>li,.toc>ul>li{font-weight:600}\n"
".toc ul ul li{font-weight:400;font-size:.95em}\n"
".meta{color:var(--dim);font-size:.9em;margin:0 0 1.2em}\n"
"@media print{body{background:#fff;color:#111}pre{border-color:#ccc}}\n"
)

page = (
"<!doctype html>\n"
'<html lang="pt-BR">\n'
"<head>\n"
'<meta charset="utf-8">\n'
'<meta name="viewport" content="width=device-width, initial-scale=1">\n'
"<title>%%TITLE%%</title>\n"
"<style>%%CSS%%</style>\n"
"</head>\n"
"<body>\n"
"<main>\n"
'<p class="meta">AMD BC-250 &middot; CachyOS &middot; vers&atilde;o HTML autocontida (sem recursos externos) do guia em Markdown</p>\n'
'<nav class="toc"><strong>Neste guia</strong>%%TOC%%</nav>\n'
"%%BODY%%\n"
"</main>\n"
"</body>\n"
"</html>\n"
)

page = page.replace("%%TITLE%%", title).replace("%%CSS%%", css).replace("%%TOC%%", toc).replace("%%BODY%%", body)
DST.write_text(page, encoding="utf-8")
print(f"HTML gerado: {DST} ({DST.stat().st_size} bytes)")
