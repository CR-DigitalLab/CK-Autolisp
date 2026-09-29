# note 記事の「LT で使えるか」の表記と LISP の中身の照合（2026-09-29）

ChikoLispCheck は記事を読めないため、チコさんの note の無料記事（LISP 22本分）を Claude が読んで、LT についての書き方と、LISP の中身（ChikoLispCheck の A1 と目視）を照らし合わせた結果。

| 区分 | LISP | 判定 |
|---|---|---|
| 記事に LT 2024 以降対応と書いてあり、中身も LT で使えそう | Web、CADSOZAI、Load_All_Lsp、FlattenFast、ExportSysVars、ZeroByLayer、LPON・LPOFF、RANDOMBNAME、CHAMFER+、HPDRAWORDER1、LockAllVP、AutoIME ver2.1（LT対応版） | 問題なし |
| 記事に LT のことが書いていない | REVCLAUTO、BakClean、SolidToHatch、CopyBlock、ClipCopy、XForce、RegionToPL、SetAllPSLT、Quake（動作環境は「レギュラー版・IJCAD」。中身は LT で使えない WScript/XMLHTTP を使用） | 問題なし |
| 要注意 | AutoIME ver2 | 記事冒頭に「レギュラー版および LT 2024 以降で動作」、手順1は「AutoIME_ver2.lsp をダウンロード」。ver2 は LT で使えない vlax-create-object（WScript.Shell）を使うため、手順どおり ver2 を入れた LT ユーザーは動かない。「LT の方は ver2.1 を」と添えるか、ver2.1 に一本化するのがおすすめ |

補足：ExportSysVars のログ書き出し（LOGFILEMODE など）と `menucmd` が LT 2024 で使えるかは、資料で確かめきれていない。LT での実機確認がおすすめ。
