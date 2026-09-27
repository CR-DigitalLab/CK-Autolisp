# ZW-auto_lisp

面向中望 CAD 2026 的 AutoLISP 常用命令集合，主程序为 `AA整合版本.lsp`。

## 使用

1. 在 CAD 中运行 `APPLOAD`。
2. 加载 `E:\366256\ZW-auto_lisp\AA整合版本.lsp`（或将其加入 APPLOAD 启动组，实现每次启动自动加载）。
3. 输入所需命令。完整清单见 [`命令索引.md`](命令索引.md)。

## ZTF 字体搜索器

输入 `ZTF` 可搜索并修改文字样式字体。左侧可搜索文字样式，右侧可搜索 TrueType/TTC/OTF 和 SHX 字体；选中后点击 `Apply to Style`，会更新该样式下的文字。`txt.shx` 等 SHX 字体由 ZWCAD 支持文件搜索路径查找。

常用文字命令：

- `T`：将所选 `TEXT/MTEXT` 刷为 `HZ` 样式，高度 `3`、宽度比例 `0.7`；`MTEXT` 会先拆成 `TEXT`。
- `QSTXT`：从选择内容中保留文字对象。
- `QW`：修改文字高度。
- `WI`：修改文字宽度比例。
- `ZUO` / `ZHONG` / `YOU`：先将所选 `TEXT/MTEXT` 的完整对正方式统一为左中、中中或右中，再执行对应的水平对齐。
- `SHANG` / `XIA`：先将所选 `TEXT/MTEXT` 的完整对正方式统一为中上或中下，再执行对应的垂直对齐。
- `MJ`：框选单列表格的全部边线和文字，自动按最长文字收窄表格宽度并将各行文字居中；保持表格总高度和各行高度不变。
- `ZJ`：选择两条水平直线，在各自左端生成长度 10 的短线，并在左侧生成宽 12、高度至少 20 的矩形。

## 主要文件

- `AA整合版本.lsp`：主整合程序（自包含全部命令，直接加载即可）。
- `V6/`：AICAD 扩展、桥接脚本和功能区 DLL，固定安装位置为 `E:\366256\ZW-auto_lisp\V6`。
- `命令索引.md`：自动生成的命令、文件和行号索引。
- `gen_命令索引.py`：命令索引生成脚本。

## 运行时加载

CADTools/YS-Tools 已从 ZWCAD 支持目录、启动文件和 APPLOAD 注册表中卸载，不再参与命令加载。不要重新部署该工具箱，否则可能覆盖整合版本中的同名命令。

ZWCAD 启动套件只保留 `AA整合版本.lsp` 和 `V6/aicad_aa_loader.lsp`。AICAD 的默认目录及 `AICADAA_BASEDIR` 均应指向 `E:\366256\ZW-auto_lisp\V6`。

## 开发约束

所有项目文本统一使用 UTF-8 无 BOM；`.lsp` 及 CAD 相关文本文件使用 CRLF 换行。ZWCAD 2026 中需将 `LISPSYS` 设为 `1` 并重启后加载。修改主文件前必须做字节级备份，写入后检查 UTF-8、无 BOM、CRLF 和括号结构。详细规则见 [`AGENTS.md`](AGENTS.md) 或 [`CLAUDE.md`](CLAUDE.md)。

命令入口有增删或代码行号明显变化后，在项目根目录运行：

```powershell
python gen_命令索引.py
```
