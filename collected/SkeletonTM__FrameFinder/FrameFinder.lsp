;;; =====================================================================
;;;  FrameFinder.lsp  —  Автопоиск рамок ГОСТ (A4,A3,A2,A1,A0 и кратные:
;;;                      A4x3, A3x4, A2x5 ... A0x2) в пространстве модели
;;;                      и (1) пакетная печать, либо (2) создание листов.
;;;
;;;  Команды:
;;;     FF        — главное меню (выбор действия в диалоге командной строки)
;;;     FFPLOT    — сразу: найти рамки и напечатать (PDF/принтер)
;;;     FFLAYOUT  — сразу: найти рамки и создать листы (Layout) под пакетную печать
;;;
;;;  Особенности:
;;;     * Рамки могут быть БЛОКАМИ (обычными и динамическими) и/или
;;;       ЛИНИЯМИ / ПОЛИЛИНИЯМИ — режим выбирается в начале.
;;;     * Формат (A4..A0 и кратность Ax N) определяется по габаритам
;;;       рамки автоматически, с автоопределением масштаба чертежа
;;;       (1:1, x10, x100, x1000 ... и нестандартных через подбор).
;;;     * Сортировка результата: слева-направо, сверху-вниз.
;;;
;;;  Совместимость: AutoCAD 2010+ (нужен ActiveX / vl-load-com).
;;;  Базируется на проверенных приёмах из открытых решений
;;;  (BPDF beastt1992; AddLay; Plot-titles-in-model и форумы dwg.ru),
;;;  переработанных и объединённых под распознавание формата ГОСТ.
;;; =====================================================================

(vl-load-com)

;;; ------------------- ТАБЛИЦА ФОРМАТОВ ГОСТ 2.301 (мм) -----------------
;;; База: A4=210x297, A3=297x420, A2=420x594, A1=594x841, A0=841x1189
;;; Кратные форматы (удлинения) — короткая сторона базового формата
;;; умножается на N (для A4 это 210, для A3 — 297 и т.д.).
;;; Список: (имя короткая_сторона длинная_сторона)
(setq *FF-FORMATS*
  (list
    ;; основные (короткая длинная), мм
    '("A4"    210  297)
    '("A3"    297  420)
    '("A2"    420  594)
    '("A1"    594  841)
    '("A0"    841 1189)
    ;; --- дополнительные (удлинённые) форматы по ГОСТ 2.301-68, табл.2 ---
    ;; короткая сторона = ДЛИННАЯ сторона базового формата;
    ;; длинная сторона = короткая базового * кратность.
    ;; кратные A4 (короткая 297)
    '("A4x3"  297  630)
    '("A4x4"  297  841)
    '("A4x5"  297 1051)
    '("A4x6"  297 1261)
    '("A4x7"  297 1471)
    '("A4x8"  297 1682)
    '("A4x9"  297 1892)
    ;; кратные A3 (короткая 420)
    '("A3x3"  420  891)
    '("A3x4"  420 1189)
    '("A3x5"  420 1486)
    '("A3x6"  420 1783)
    '("A3x7"  420 2080)
    ;; кратные A2 (короткая 594)
    '("A2x3"  594 1261)
    '("A2x4"  594 1682)
    '("A2x5"  594 2102)
    ;; кратные A1 (короткая 841)
    '("A1x3"  841 1783)
    '("A1x4"  841 2378)
    ;; кратные A0 (короткая 1189)
    '("A0x2" 1189 1682)
    '("A0x3" 1189 2523)
  )
)

;;; ----------------------- НАСТРОЙКИ ПО УМОЛЧАНИЮ -----------------------
(setq *FF-TOL*        0.04)   ; допустимое относительное отклонение габарита (4%)
(setq *FF-PLOTTER*   "DWG To PDF.pc3")  ; устройство печати по умолчанию
(setq *FF-STYLE*     "monochrome.ctb")  ; стиль печати ("" = без стиля)
;; ПРИМЕЧАНИЕ: каждый найденный лист сохраняется в ОТДЕЛЬНЫЙ PDF-файл
;; (имя: <чертёж>-<лист>.pdf). Объединение в один многостраничный PDF не
;; реализовано — используйте штатную ПАКЕТНУЮ ПЕЧАТЬ (PUBLISH) для сборки.
(setq *FF-CURSCALE*  1.0)     ; масштаб оформления рамок (множитель относительно мм)
;;; Знаменатель пользовательского масштаба печати ЛИСТА (1:N).
;;; 25.4 — потому что 1 дюйм = 25.4 мм. Дюймовый драйвер DWG To PDF
;;; воспринимает размер листа в дюймах, поэтому масштаб
;;; "1 единица чертежа : 25.4 единицы бумаги" фактически означает 1:1 в мм.
;;; Если другой плоттер выдаёт повёрнутое/масштабированное изображение —
;;; поставьте 1.0 (метрический драйвер), удобнее через команду FFSET.
(setq *FF-PLOTDENOM* 25.4)

;;; Режим АВТООПРЕДЕЛЕНИЯ масштаба печати листа.
;;; T   = определять единицы листа автоматически (по DXF code 72 листа —
;;;       реальные единицы, которые использует драйвер: 0=дюймы→25.4, 1=мм→1.0);
;;; nil = использовать фиксированный *FF-PLOTDENOM* (ручной режим 1:1 / 1:25.4).
;;; По умолчанию включено (авто) - переключается в FFSET. Fallback при
;;; неудаче чтения = текущий *FF-PLOTDENOM*.
(setq *FF-PLOTAUTO* T)

;;; --- Настройки прогрева плоттера (ff-warmup) ---
;;; Кол-во вызовов RefreshPlotDeviceInfo при инициализации устройства.
;;; Меньше 3 иногда не успевает заполнить список носителей при холодном старте.
(setq *FF-WARMUP-REFRESH-COUNT* 3)
;;; Максимальное число попыток получить непустой список носителей.
(setq *FF-WARMUP-MAX-RETRY* 5)

;;; Допуск сравнения размеров носителя при поиске пользовательских форматов (мм).
;;; 2 мм — компенсирует округление в именах вида "210.00_x_297.00_MM".
(setq *FF-PAPER-TOL-MM* 2.0)

;;; --- Сохранение пользовательских настроек между сессиями (реестр Windows) ---
;;; Хранит значения, изменённые через FFSET, чтобы они не сбрасывались
;;; при перезапуске AutoCAD / перезагрузке скрипта.
(setq *FF-REGKEY* "HKEY_CURRENT_USER\\Software\\FrameFinder")

;; сохранить текущие настройки (вызывается при OK в FFSET)
(defun ff-settings-save ()
  ;; каждая запись независима — ошибка одной не обрывает остальные
  (vl-catch-all-apply
    '(lambda () (vl-registry-write *FF-REGKEY* "PlotDenom" (rtos *FF-PLOTDENOM* 2 6))))
  (vl-catch-all-apply
    '(lambda () (vl-registry-write *FF-REGKEY* "Plotter" *FF-PLOTTER*)))
  (vl-catch-all-apply
    '(lambda () (vl-registry-write *FF-REGKEY* "Style" (if *FF-STYLE* *FF-STYLE* ""))))
  (vl-catch-all-apply
    '(lambda () (vl-registry-write *FF-REGKEY* "Tolerance" (rtos *FF-TOL* 2 6))))
  (vl-catch-all-apply
    '(lambda () (vl-registry-write *FF-REGKEY* "PlotAuto" (if *FF-PLOTAUTO* "1" "0"))))
  (princ))

;; загрузить настройки (если есть в реестре). Безопасно: при отсутствии
;; ключей значения остаются дефолтными.
;; Прочитать один ключ из реестра безопасно. Возвращает строку или nil.
(defun ff-reg-get (name / r)
  (setq r (vl-catch-all-apply
            '(lambda () (vl-registry-read *FF-REGKEY* name))))
  (if (vl-catch-all-error-p r) nil r))

(defun ff-settings-load ( / v)
  ;; каждое чтение независимо — ошибка одного не обрывает остальные
  (if (setq v (ff-reg-get "PlotDenom"))
    (if (> (atof v) 0.0) (setq *FF-PLOTDENOM* (atof v))))
  (if (setq v (ff-reg-get "Plotter"))
    (if (/= v "") (setq *FF-PLOTTER* v)))
  (if (setq v (ff-reg-get "Style"))
    (setq *FF-STYLE* v))            ; "" допустимо = без стиля
  (if (setq v (ff-reg-get "Tolerance"))
    (if (> (atof v) 0.0) (setq *FF-TOL* (atof v))))
  (if (setq v (ff-reg-get "PlotAuto"))
    (setq *FF-PLOTAUTO* (= v "1")))
  (princ))


;;; --- Накопитель важных сообщений (для дублирования сводкой в конце) ---
(setq *FF-MSGS* nil)

;;; --- Счётчики статистики операции (для краткой summary-диагностики) ---
;;; FOUND  — распознано рамок (после удаления дублей)
;;; DUP    — отброшено дублей (внешняя/внутренняя линия одного формата)
;;; SKIP   — пропущено (кратный формат без точной бумаги)
;;; DONE   — реально создано листов / напечатано
(setq *FF-STAT-FOUND* 0 *FF-STAT-DUP* 0 *FF-STAT-SKIP* 0 *FF-STAT-DONE* 0)
(defun ff-stat-reset ()
  (setq *FF-STAT-FOUND* 0 *FF-STAT-DUP* 0 *FF-STAT-SKIP* 0 *FF-STAT-DONE* 0)
  (princ))

;; очистить накопленные сообщения (вызывается в начале операции)
(defun ff-msg-reset () (setq *FF-MSGS* nil) (ff-stat-reset) (princ))
;; вывести сообщение СРАЗУ и сохранить его для итоговой сводки
(defun ff-msg (s)
  (princ s)
  (setq *FF-MSGS* (cons s *FF-MSGS*))
  (princ))
;; вывести итоговую сводку всех накопленных сообщений (в конце операции)
(defun ff-msg-flush ( / lst)
  (setq lst (reverse *FF-MSGS*))
  (if lst
    (progn
      (princ "\n\n========== СВОДКА ПРЕДУПРЕЖДЕНИЙ / ОШИБОК ==========")
      (foreach m lst (princ m))
      (princ "\n===================================================\n"))
    (princ "\n(предупреждений нет)\n"))
  (princ))

;; Краткая summary-диагностика после команды (счётчики операции).
;; action: "L" (листы) или "P" (печать) — для подписи DONE.
(defun ff-summary (action)
  (princ "\n----- DEBUG SUMMARY -----")
  (princ (strcat "\n  Распознано рамок : " (itoa *FF-STAT-FOUND*)))
  (princ (strcat "\n  Отброшено дублей : " (itoa *FF-STAT-DUP*)
                 " (внешняя/внутренняя линия одной рамки)"))
  (princ (strcat "\n  Пропущено        : " (itoa *FF-STAT-SKIP*)
                 " (кратный формат без точной бумаги)"))
  (princ (strcat "\n  "
                 (if (= action "P") "Напечатано       : " "Создано листов   : ")
                 (itoa *FF-STAT-DONE*)))
  (princ (strcat "\n  Масштаб печати   : "
                 (if *FF-PLOTAUTO*
                   "АВТО (по единицам листа, DXF 72)"
                   (strcat "1:" (rtos *FF-PLOTDENOM* 2 3) " (ручной)"))))
  (princ "\n-------------------------\n")
  (princ))


;;; кандидаты масштабов чертежа (множитель размеров рамки относительно мм)
(setq *FF-SCALES* (list 1.0 2.0 2.5 5.0 10.0 20.0 25.0 40.0 50.0
                        75.0 100.0 200.0 250.0 500.0 1000.0))

;;; ====================================================================
;;;  УТИЛИТЫ
;;; ====================================================================

;; Округление до целого
(defun ff-round (x) (fix (+ x (if (< x 0) -0.5 0.5))))

;; габариты объекта -> (xmin ymin xmax ymax) или nil
(defun ff-bbox (ent / o mn mx)
  (setq o (vlax-ename->vla-object ent))
  (if (not (vl-catch-all-error-p
             (vl-catch-all-apply 'vla-getboundingbox (list o 'mn 'mx))))
    (list
      (vlax-safearray-get-element mn 0)
      (vlax-safearray-get-element mn 1)
      (vlax-safearray-get-element mx 0)
      (vlax-safearray-get-element mx 1))
    nil))

;; Подбор формата по габаритам W,H для ОДНОГО известного масштаба.
;; Среди всех подходящих форматов выбирается с минимальной ошибкой.
;; Возвращает (имя scale orient W H) либо nil.
(defun ff-detect-scl (w h scl / sh lg orient ts tl fmt fs fl
                                 err1 err2 e best berr)
  (if (>= w h)
    (setq sh h lg w orient "L")
    (setq sh w lg h orient "P"))
  (setq ts (/ sh scl) tl (/ lg scl))
  (setq best nil berr 1.0e9)
  (foreach fmt *FF-FORMATS*
    (setq fs (cadr fmt) fl (caddr fmt))
    (setq err1 (/ (abs (- ts fs)) (float fs))
          err2 (/ (abs (- tl fl)) (float fl)))
    (if (and (<= err1 *FF-TOL*) (<= err2 *FF-TOL*))
      (progn
        (setq e (+ err1 err2))
        (if (< e berr) (setq berr e best (list (car fmt) scl orient w h)))
      )
    )
  )
  best
)

;; ВНИМАНИЕ о неоднозначности: габариты форматов ГОСТ геометрически
;; почти подобны между соседними (стороны в отношении ~1:1.41), поэтому
;; "A4 в масштабе 100" и "A0 в масштабе 25" по габаритам неразличимы.
;; Поэтому масштаб лучше задавать (переменная *FF-CURSCALE*); режим "Авто"
;; пробует ряд масштабов и берёт ПЕРВЫЙ подходящий (наименьший масштаб).

;; Главная функция: использует *FF-CURSCALE* (задаётся в FF/командах, всегда
;; число). Режим "Авто" (перебор масштабов) убран из интерфейса как ненадёжный,
;; но как СТРАХОВКА: если *FF-CURSCALE* окажется nil — выполняется перебор
;; *FF-SCALES* (первый подходящий). В обычной работе этот путь не используется.
(defun ff-detect (w h / scl res)
  (if *FF-CURSCALE*
    (ff-detect-scl w h *FF-CURSCALE*)
    (progn
      (setq res nil)
      (foreach scl *FF-SCALES*
        (if (null res) (setq res (ff-detect-scl w h scl))))
      res
    )
  )
)

;; Имя стандартного формата AutoCAD (canonical) под формат ГОСТ.
;; Возвращает базовый "ISO_AxLandscape/Portrait"-подобный размер для печати.
;; Подбираем по короткому имени из доступных носителей плоттера.
;; Определить, альбомный ли установленный на листе носитель.
;; Берём физический размер бумаги (vla-GetPaperSize -> width height в мм).
;; ВАЖНО: GetPaperSize возвращает значения по ссылке как обычные числа
;; (real), а НЕ как variant — поэтому variant-value к ним применять нельзя.
;; Возвращает T (альбомная, width>height) или nil (книжная / не удалось).
(defun ff-media-is-landscape (lay / wv hv)
  (if (not (vl-catch-all-error-p
             (vl-catch-all-apply 'vla-GetPaperSize (list lay 'wv 'hv))))
    (if (and (numberp wv) (numberp hv))
      (> wv hv)
      nil)
    nil))



;; "Прогрев" устройства печати: назначаем плоттер на лист и несколько раз
;; обновляем инфо об устройстве. Это устраняет плавающий баг, когда при
;; ПЕРВОМ запуске в сессии список носителей ещё не готов и подхватывается
;; ANSI / съезжают границы. Возвращает список canonical-носителей.
(defun ff-warmup (lay plotter / i lst)
  (vl-catch-all-apply '(lambda () (vla-put-configname lay plotter)))
  ;; несколько обновлений подряд — даём устройству инициализироваться
  (repeat *FF-WARMUP-REFRESH-COUNT*
    (vl-catch-all-apply '(lambda () (vla-RefreshPlotDeviceInfo lay))))
  ;; считать список носителей (с повтором, если первый раз пусто)
  (setq lst nil i 0)
  (while (and (null lst) (< i *FF-WARMUP-MAX-RETRY*))
    (setq lst
      (vl-catch-all-apply
        '(lambda ()
           (vlax-safearray->list
             (vlax-variant-value (vla-GetCanonicalMediaNames lay))))))
    (if (or (vl-catch-all-error-p lst) (null lst) (not (listp lst)))
      (progn
        (setq lst nil)
        (vl-catch-all-apply '(lambda () (vla-RefreshPlotDeviceInfo lay)))))
    (setq i (1+ i)))
  (if (and lst (listp lst)) lst nil)
)

;; Вспомогательное: содержит ли строка одну из подстрок (списком)
(defun ff-has-any (s lst)
  (if (vl-some '(lambda (x) (vl-string-search x s)) lst) t nil))

;; Точное совпадение токена формата (A4/A3/...) в имени носителя.
;; Считаем совпадением, если в имени есть "A4" и сразу за ним НЕ цифра
;; (чтобы "A4" не цеплялся к "A40" и т.п.).
(defun ff-token-match (token s / p nextc)
  (setq p (vl-string-search token s))
  (if p
    (progn
      (setq nextc (substr s (+ p (strlen token) 1) 1))
      ;; следующий символ не должен быть цифрой
      (not (and (/= nextc "")
                (>= (ascii nextc) 48) (<= (ascii nextc) 57))))
    nil))


;; Размер носителя в мм из его имени. Поддерживает имена вида:
;;   "ISO_A3_(420.00_x_297.00_MM)"  "ANSI_A_(8.50_x_11.00_Inches)"
;;   "297x630"  "User_297_x_630"  и любые с двумя числами.
;; Если есть скобки "(...)" — числа берём ИЗ них (там реальный размер).
;; Дюймы (если в имени есть Inch) переводим в мм. Возвращает (w h) мм или nil.
(defun ff-media-size (m / s p1 p2 inch nums num1 num2)
  (setq s m)
  (setq inch (vl-string-search "INCH" (strcase s)))
  ;; если есть скобки — берём содержимое скобок (там точный размер)
  (setq p1 (vl-string-search "(" s))
  (if p1
    (progn
      (setq s (substr s (+ p1 2)))
      (setq p2 (vl-string-search ")" s))
      (if p2 (setq s (substr s 1 p2)))))
  ;; оставить только цифры/точки, остальное -> пробелы, взять 2 числа
  (setq nums (ff-parse-two-nums (ff-only-numbers s)))
  (if nums
    (progn
      (setq num1 (car nums) num2 (cadr nums))
      (if inch (setq num1 (* num1 25.4) num2 (* num2 25.4)))
      (list num1 num2))
    nil))

;; Заменить все символы, кроме цифр и точки, на пробелы.
;; Сборка через список + apply strcat (без O(n^2) конкатенации).
(defun ff-only-numbers (s / i n c chars)
  (setq chars nil i 1 n (strlen s))
  (while (<= i n)
    (setq c (substr s i 1))
    (setq chars
      (cons (if (or (and (>= (ascii c) 48) (<= (ascii c) 57)) (= c "."))
                c " ")
            chars))
    (setq i (1+ i)))
  (apply 'strcat (reverse chars)))

;; Достать первые два вещественных числа из строки (через пробелы).
(defun ff-parse-two-nums (s / i n c tok toks)
  (setq toks nil tok "" i 1 n (strlen s))
  (while (<= i n)
    (setq c (substr s i 1))
    (if (or (and (>= (ascii c) 48) (<= (ascii c) 57)) (= c "."))
      (setq tok (strcat tok c))
      (progn
        (if (> (strlen tok) 0) (setq toks (cons tok toks)))
        (setq tok "")))
    (setq i (1+ i)))
  (if (> (strlen tok) 0) (setq toks (cons tok toks)))
  (setq toks (reverse toks))
  (if (>= (length toks) 2)
    (list (atof (nth 0 toks)) (atof (nth 1 toks)))
    nil))

;; Нужный физический размер формата (короткая длинная), мм, из таблицы.
(defun ff-format-size (fmtName / r)
  (setq r (assoc fmtName *FF-FORMATS*))
  (if r (list (cadr r) (caddr r)) nil))

;; Подсказка для кратного формата, когда ТОЧНОГО носителя бумаги нет.
;; Выводит размеры, которые нужно один раз создать вручную в .pc3.
(defun ff-warn-need-custom (fmtName / need needS needL)
  (setq need (ff-format-size fmtName))
  (if need
    (progn
      (setq needS (car need) needL (cadr need))
      (ff-msg (strcat
        "\n   ! Нет бумаги ТОЧНО под формат " fmtName " ("
        (rtos needS 2 0) "x" (rtos needL 2 0) " мм)."))
      (ff-msg (strcat
        "\n     Создайте пользовательский размер " (rtos needS 2 0)
        "x" (rtos needL 2 0) " мм в плоттере и повторите:"))
      (ff-msg
        "\n     PLOTTERMANAGER > DWG To PDF.pc3 > Custom Paper Sizes > Add."))
  )
  (princ)
)


;; ПРАВИЛА:
;;  - берём только ISO/DIN метрические форматы (мм), НЕ ANSI/ARCH/дюймы;
;;  - для кратных форматов (A4x3 и т.п.) используем базовый A.. ;
;;  - предпочитаем точное совпадение токена (A4/A3...) и нужную ориентацию.
;; Возвращает имя носителя или nil (тогда формат бумаги не меняем).
(defun ff-paper-for (fmtName mediaList orient / base cand metric pick fb
                              ismult need needS needL sz mw mh ms ml
                              bestFit bestArea area)
  (setq base (substr fmtName 1 2))   ; "A4","A3","A2","A1","A0"
  ;; кратный? имена в таблице используют строчную "x" (A4x3) — ищем в оригинале
  (setq ismult (vl-string-search "x" fmtName))

  ;; 1) только метрические ISO/DIN-носители, без дюймовых/ANSI/ARCH
  (setq metric nil)
  (foreach m mediaList
    (if (and (not (ff-has-any (strcase m)
                              '("ANSI" "ARCH" "LETTER"
                                "LEGAL" "TABLOID" "JIS" "B0" "B1" "B2"
                                "B3" "B4" "B5")))
             (or (vl-string-search "ISO" (strcase m))
                 (vl-string-search "DIN" (strcase m))
                 (vl-string-search "MM"  (strcase m))))
      (setq metric (cons m metric))))
  (setq metric (reverse metric))
  (if (null metric) (setq metric mediaList))   ; фолбэк, если ничего не нашли

  ;; --- КРАТНЫЙ ФОРМАТ (A4x3, A3x4 ...) ---
  ;; ищем носитель с ТОЧНЫМ соответствием размеру формата (1:1).
  ;; ВАЖНО: перебираем ВЕСЬ список носителей (не только ISO/DIN/MM), потому
  ;; что пользовательские форматы часто называются без этих слов
  ;; (напр. "User_297x630"). Сравниваем по РАЗМЕРУ, а не по имени.
  ;; Если точного носителя нет — возвращаем nil (выводится подсказка создать).
  (if ismult
    (progn
      (setq need (ff-format-size fmtName))      ; (короткая длинная) мм
      (if need
        (progn
          (setq needS (car need) needL (cadr need))
          (setq pick nil)
          (foreach m mediaList            ; <-- ВЕСЬ список, без фильтра по имени
            (setq sz (ff-media-size m))
            (if (and sz (null pick))
              (progn
                (setq mw (car sz) mh (cadr sz))
                (if (<= mw mh) (setq ms mw ml mh) (setq ms mh ml mw))
                ;; ТОЧНОЕ совпадение по обеим сторонам (допуск 2 мм на округление)
                (if (and (<= (abs (- ms needS)) *FF-PAPER-TOL-MM*)
                         (<= (abs (- ml needL)) *FF-PAPER-TOL-MM*))
                  (setq pick m)))))
        )
      )
      ;; для кратного: что нашли (точный носитель) или nil — и ВЫХОД,
      ;; чтобы не подбирать базовый A4/A3.
      pick
    )

    ;; --- ОБЫЧНЫЙ ФОРМАТ (A4, A3, A2, A1, A0) ---
    (progn
      ;; 2) кандидаты с точным токеном базового формата (A4/A3/...)
      (setq cand nil)
      (foreach m metric
        (if (ff-token-match base (strcase m)) (setq cand (cons m cand))))
      (setq cand (reverse cand))
      (if (null cand) (setq cand metric))
      ;; 2.1) ПРИОРИТЕТ носителям БЕЗ ПОЛЕЙ (full bleed) — для рамок ГОСТ
      ;;      нужна область печати = весь лист. ВАЖНО: "expand" — это НЕ
      ;;      "без полей", а РАСШИРЕННЫЙ (печать выходит за край → съезд),
      ;;      поэтому expand из приоритета ИСКЛЮЧАЕМ.
      (setq fb nil)
      (foreach m cand
        (if (and (ff-has-any (strcase m) '("FULL" "BLEED" "БЕЗ ПОЛЕЙ"))
                 (not (vl-string-search "EXPAND" (strcase m))))
          (setq fb (cons m fb))))
      (if fb (setq cand (reverse fb)))
      ;; 3) среди кандидатов — предпочесть нужную ориентацию
      (foreach m cand
        (if (and (null pick)
                 (cond
                   ((and (= orient "L") (vl-string-search "andscape" m)) t)
                   ((and (= orient "P") (vl-string-search "ortrait"  m)) t)))
          (setq pick m)))
      (if (null pick) (setq pick (car cand)))
      pick
    )
  )
)

;;; ====================================================================
;;;  ПОИСК РАМОК
;;;  searchMode: "B"=блоки, "L"=линии/полилинии, "M"=и то и другое
;;;  Возвращает список элементов вида:
;;;    (ename xmin ymin xmax ymax fmtName scale orient)
;;;  только для тех объектов, чьи габариты опознаны как формат.
;;; ====================================================================
;; Обработать один объект: посчитать bbox, распознать формат и при успехе
;; добавить запись (ename xmin ymin xmax ymax fmt scale orient) в список res.
;; Возвращает обновлённый res (если не рамка — res без изменений).
;; Удалить дубли вложенных рамок. По ГОСТ у формата ДВЕ линии контура:
;; внешняя (граница листа) и внутренняя (рамка поля). Обе распознаются как
;; один формат и дают дубль. Если центры двух рамок близки И одна вложена
;; в другую — оставляем БОЛЬШУЮ (внешнюю), меньшую отбрасываем.
;; Элемент: (ename xmin ymin xmax ymax fmt scale orient).
(defun ff-dedup (lst / out a b acx acy bcx bcy aw ah bw bh keep tolc)
  (setq out nil)
  (foreach a lst
    (setq aw (- (nth 3 a) (nth 1 a))   ; ширина a
          ah (- (nth 4 a) (nth 2 a))   ; высота a
          acx (/ (+ (nth 1 a) (nth 3 a)) 2.0)
          acy (/ (+ (nth 2 a) (nth 4 a)) 2.0)
          keep t)
    ;; сравнить a со всеми уже принятыми (out): если a — меньшая копия
    ;; большей, не берём a; если a — большая, выкинуть меньшую из out.
    (foreach b out
      (setq bw (- (nth 3 b) (nth 1 b))
            bh (- (nth 4 b) (nth 2 b))
            bcx (/ (+ (nth 1 b) (nth 3 b)) 2.0)
            bcy (/ (+ (nth 2 b) (nth 4 b)) 2.0))
      ;; допуск близости центров — 20% от меньшей ширины пары
      (setq tolc (* 0.20 (min aw bw)))
      (if (and (<= (abs (- acx bcx)) tolc)
               (<= (abs (- acy bcy)) tolc))
        ;; центры совпали -> это одна рамка (внешн./внутр.)
        (if (< (* aw ah) (* bw bh))
          (setq keep nil)               ; a меньше b -> a не берём
          (setq out (vl-remove b out))) ; a больше b -> убрать b из принятых
      )
    )
    (if keep (setq out (cons a out)))
  )
  ;; зафиксировать число отброшенных дублей
  (setq *FF-STAT-DUP* (- (length lst) (length out)))
  (reverse out)
)

(defun ff-process-ent (ent res / bb w h det)
  (setq bb (ff-bbox ent))
  (if bb
    (progn
      (setq w (- (nth 2 bb) (nth 0 bb))
            h (- (nth 3 bb) (nth 1 bb)))
      (setq det (ff-detect w h))
      (if det
        (cons (list ent (nth 0 bb) (nth 1 bb)
                    (nth 2 bb) (nth 3 bb)
                    (nth 0 det) (nth 1 det) (nth 2 det))
              res)
        res))
    res))

(defun ff-collect (searchMode / ss n i ent dxf typ res iu)
  (setq res nil)
  ;; Предупреждение о единицах чертежа. Рамки ГОСТ заданы в ММ (210, 297 ...),
  ;; поэтому распознавание рассчитано на модель в миллиметрах (INSUNITS=4).
  ;; Если единицы иные (или не заданы) — это лишь предупреждение, не блокировка:
  ;; при правильном масштабе оформления распознавание всё равно может сработать.
  (setq iu (getvar "INSUNITS"))
  (if (and iu (/= iu 4) (/= iu 0))   ; 4=мм (ок), 0=без единиц (часто тоже мм-геометрия)
    (ff-msg (strcat "\n   ! Внимание: единицы чертежа (INSUNITS=" (itoa iu)
                    ") не миллиметры. Если рамки не находятся —"
                    "\n     проверьте масштаб оформления или приведите чертёж к мм.")))
  ;; --- блоки ---
  (if (or (= searchMode "B") (= searchMode "M"))
    (progn
      (setq ss (ssget "_X" '((0 . "INSERT") (410 . "Model"))))
      (if ss
        (progn
          (setq i 0 n (sslength ss))
          (while (< i n)
            (setq res (ff-process-ent (ssname ss i) res))
            (setq i (1+ i)))))))
  ;; --- полилинии (замкнутые рамки) ---
  ;; Одиночные LINE как рамку не берём: их bbox = сам отрезок, а не контур.
  (if (or (= searchMode "L") (= searchMode "M"))
    (progn
      (setq ss (ssget "_X"
                 '((-4 . "<OR")
                     (0 . "LWPOLYLINE")
                     (0 . "POLYLINE")
                   (-4 . "OR>")
                   (410 . "Model"))))
      (if ss
        (progn
          (setq i 0 n (sslength ss))
          (while (< i n)
            (setq res (ff-process-ent (ssname ss i) res))
            (setq i (1+ i)))))))
  ;; убрать дубли вложенных рамок (внешняя+внутренняя линия одного формата)
  (setq res (ff-dedup res))
  ;; статистика: сколько распознано и сколько дублей отброшено
  (setq *FF-STAT-FOUND* (length res))
  res
)

;; Сортировка: сверху-вниз рядами, внутри ряда слева-направо.
;; Группируем по Y с допуском в ЧЕТВЕРТЬ высоты самой мелкой рамки.
;; (Четверть выбрана намеренно: меньший допуск надёжнее разделяет
;;  соседние ряды рамок разных форматов и не сливает их в один ряд.
;;  Если рамки одного ряда с заметным смещением по Y "расслаиваются" —
;;  увеличьте делитель... т.е. уменьшите знаменатель, напр. до 2.0.)
(defun ff-sort (lst / tolY)
  ;; допуск ряда — четверть минимальной высоты рамок (см. комментарий выше)
  (setq tolY
    (if lst
      (/ (apply 'min (mapcar '(lambda (e) (- (nth 4 e) (nth 2 e))) lst)) 4.0)
      0.0))
  (vl-sort lst
    (function
      (lambda (a b / ya yb)
        (setq ya (nth 2 a) yb (nth 2 b))
        (if (> (abs (- ya yb)) tolY)
          (> ya yb)                  ; разные ряды: выше (больше Y) — раньше
          (< (nth 1 a) (nth 1 b))    ; один ряд: левее (меньше X) — раньше
        )
      )
    )
  )
)

;;; ====================================================================
;;;  ПЕЧАТЬ НАБОРА РАМОК
;;; ====================================================================
;; Подобрать свободное имя файла: если "base.pdf" занят — пробуем
;; base_2.pdf, base_3.pdf ... Возвращает полный путь к свободному имени.
(defun ff-unique-filename (path / dir base ext i cand)
  (setq dir  (vl-filename-directory path)
        base (vl-filename-base path)
        ext  (vl-filename-extension path))
  (if (null (findfile path))
    path
    (progn
      (setq i 2 cand path)
      (while (findfile cand)
        (setq cand (strcat dir "\\" base "_" (itoa i) ext))
        (setq i (1+ i)))
      cand))
)

;; ПРЯМАЯ ПЕЧАТЬ РАМОК — через ВРЕМЕННЫЕ ЛИСТЫ.
;; Раз печать готового ЛИСТА надёжна, а печать окна из модели — нет,
;; делаем так: создаём листы (тот же проверенный путь, ВЭ на весь лист),
;; печатаем каждый лист, затем временные листы удаляем.
;; Если выходной PDF уже существует — спрашиваем (Перезаписать/Новое имя/Пропустить).
(defun ff-plot (frames plotter style / adoc aplot alayouts made nm
                       cnt total done dwgdir fname outfile isfileplot err
                       ans skip cmd_ec bgp olderr *error*)
  (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  ;; кэшируем COM-объекты один раз (не дёргаем их в циклах)
  (setq aplot    (vla-get-plot adoc)
        alayouts (vla-get-layouts adoc))
  (setq dwgdir (getvar "DWGPREFIX")
        fname  (vl-filename-base (getvar "DWGNAME")))
  ;; печатает ли устройство в файл? Только PDF-вывод (по имени).
  ;; ".PC3" НЕ используем — он есть у любого pc3-плоттера, в т.ч. бумажного.
  (setq isfileplot (or (vl-string-search "PDF" (strcase plotter))
                       (vl-string-search "FILE" (strcase plotter))))

  ;; 1) создаём ТОЛЬКО свои временные листы (старые листы НЕ трогаем).
  ;;    Имена при коллизии получают суффикс _2/_3 (ff-unique-layname).
  (princ "\n>>> Готовлю временные листы для печати рамок ...")
  (setq made (ff-make-layouts frames plotter style nil))

  ;; 2) печатаем каждый созданный лист (если есть)
  (setq total (length made) cnt 0 done 0)
  ;; Сохранить настройки пользователя и временно отключить эхо команд
  ;; и фоновую печать. В конце функции значения возвращаются,
  ;; а при ошибке/Esc их возвращает локальный обработчик *error*.
  (setq cmd_ec (getvar "CMDECHO")
        bgp    (getvar "BACKGROUNDPLOT"))
  (setq olderr *error*)
  (defun *error* (msg)
    (setvar "CMDECHO" cmd_ec)
    (setvar "BACKGROUNDPLOT" bgp)
    (setq *error* olderr)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*QUIT*,*EXIT*,*ПРЕРВАНА*")))
      (princ (strcat "\nFF: ошибка - " msg))
    (princ))
  )
  (setvar "CMDECHO" 0)
  (setvar "BACKGROUNDPLOT" 0)
  (foreach nm made
    (setq cnt (1+ cnt) skip nil)
    (princ (strcat "\n[" (itoa cnt) "/" (itoa total) "] Печать листа " nm " ..."))
    ;; для файловой печати — проверить, не занят ли выходной PDF
    (if isfileplot
      (progn
        (setq outfile (strcat dwgdir fname "-" nm ".pdf"))
        (if (findfile outfile)
          (progn
            (initget "Да Нет Пропустить")
            (setq ans (getkword
              (strcat "\nФайл " (vl-filename-base outfile)
                      ".pdf уже есть. Перезаписать? [Да/Нет/Пропустить] <Да>: ")))
            (cond
              ((= ans "Нет")
               (setq outfile (ff-unique-filename outfile)))
              ((= ans "Пропустить")
               (setq skip t)
               (ff-msg (strcat "\n   Лист " nm
                               " — пропущен (файл уже существует).")))
            )
          )
        )
      )
    )
    (if (not skip)
      (progn
        (setq err
          (vl-catch-all-apply
            '(lambda ( / )
               (setvar "CTAB" nm)
               (if isfileplot
                 (vla-PlotToFile aplot outfile plotter)
                 (vla-PlotToDevice aplot plotter)))))
        (if (vl-catch-all-error-p err)
          (ff-msg (strcat "\n   ! Лист " nm " — ошибка печати: "
                         (vl-catch-all-error-message err) " (пропущен)"))
          (setq done (1+ done))))   ; успешно напечатан
    )
  )

  ;; 3) удалить временные листы
  (setvar "CTAB" "Model")
  (foreach nm made
    (vl-catch-all-apply
      '(lambda () (vla-delete (vla-item alayouts nm)))))

  ;; вернуть пользовательские настройки (эхо, фоновая печать)
  (setvar "CMDECHO" cmd_ec)
  (setvar "BACKGROUNDPLOT" bgp)

  (setq *FF-STAT-DONE* done)   ; для summary (перезаписывает счётчик от make-layouts)
  (princ (strcat "\n>>> Готово. Напечатано рамок: " (itoa done)
                 " из " (itoa total)
                 "\n    (временные листы удалены)\n"))
  (princ)
)

;;; ====================================================================
;;;  СОЗДАНИЕ ЛИСТОВ (LAYOUT) ИЗ РАМОК
;;; ====================================================================
;; --- (1) Устройство, бумага, ориентация, стиль для готового листа ---
;; lay — vla-объект листа; paper — выбранный носитель (или nil);
;; orient "L"/"P"; plotter/style — устройство и стиль печати.
(defun ff-setup-device (lay plotter paper orient style / mediaLand)
  (vl-catch-all-apply '(lambda () (vla-put-configname lay plotter)))
  (vl-catch-all-apply '(lambda () (vla-RefreshPlotDeviceInfo lay)))
  (if paper
    (vl-catch-all-apply '(lambda () (vla-put-CanonicalMediaName lay paper))))
  (vl-catch-all-apply '(lambda () (vla-RefreshPlotDeviceInfo lay)))
  ;; ОРИЕНТАЦИЯ по реальному размеру носителя
  (setq mediaLand (ff-media-is-landscape lay))
  (vl-catch-all-apply
    '(lambda ()
       (cond
         ((and (= orient "L") (not mediaLand)) (vla-put-PlotRotation lay 1))
         ((and (= orient "P") mediaLand)       (vla-put-PlotRotation lay 1))
         (t (vla-put-PlotRotation lay 0)))))
  ;; стиль печати и прочее
  (if (and style (/= style ""))
    (vl-catch-all-apply '(lambda () (vla-put-stylesheet lay style))))
  (vl-catch-all-apply '(lambda () (vla-put-PlotWithPlotStyles  lay :vlax-true)))
  (vl-catch-all-apply '(lambda () (vla-put-PlotWithLineweights lay :vlax-true)))
  (vl-catch-all-apply '(lambda () (vla-put-PaperUnits lay 1)))
  (vl-catch-all-apply '(lambda () (vla-RefreshPlotDeviceInfo lay)))
  (princ)
)

;; --- (2) Создание видового экрана и наведение на рамку ---
;; ВЭ размером w/scl x h/scl, центр через zoomcenter, масштаб через zoom XP.
;; Логика 1-в-1 как в проверенной версии; все VLA-вызовы защищены.
(defun ff-create-viewport (adoc layName cx cy w h scl / psp vp)
  (setvar "CTAB" layName)
  (vl-catch-all-apply
    '(lambda ( / )
       (setq psp (vla-get-paperspace adoc))
       (setq vp (vla-AddPViewport psp
                  (vlax-3d-point (list (/ (/ w scl) 2.0)
                                       (/ (/ h scl) 2.0) 0.0))
                  (/ w scl) (/ h scl)))
       (vla-display vp :vlax-true)
       (vla-put-mspace adoc :vlax-true)
       (vla-put-activepviewport adoc vp)
       (vla-zoomcenter (vlax-get-acad-object)
                       (vlax-3d-point (list cx cy 0.0)) 1.0)
       (vla-put-mspace adoc :vlax-false)))
  ;; масштаб видового экрана = 1/scl (xp)
  (vl-catch-all-apply
    '(lambda ( / )
       (vla-put-mspace adoc :vlax-true)
       (vl-cmdf "_.zoom" (strcat (rtos (/ 1.0 scl) 2 8) "xp"))
       (vla-put-mspace adoc :vlax-false)))
  (vl-catch-all-apply '(lambda () (vla-put-DisplayLocked vp :vlax-true)))
  (princ)
)

;; --- АВТООПРЕДЕЛЕНИЕ множителя масштаба по РЕАЛЬНЫМ единицам листа ---
;; Читает DXF group code 72 из настроек листа (PlotSettings):
;;   72 = 0 -> печать в дюймах  -> множитель 25.4
;;   72 = 1 -> печать в мм      -> множитель 1.0
;;   72 = 2 -> пиксели (растр)  -> fallback
;; Это ПРЯМОЙ источник единиц, который использует драйвер при печати листа
;; (надёжнее, чем MEASUREMENT). layName — имя вкладки листа.
;; Возвращает 25.4 / 1.0, либо fallback (текущий *FF-PLOTDENOM*) при неудаче.
(defun ff-layout-denom (layName / dn laydict ps code72)
  (setq code72
    (vl-catch-all-apply
      '(lambda ( / )
         (setq dn (cdr (assoc -1 (dictsearch (namedobjdict) "ACAD_LAYOUT"))))
         (setq laydict (dictsearch dn layName))
         (setq ps (member '(100 . "AcDbPlotSettings") laydict))
         (cdr (assoc 72 ps)))))
  (cond
    ((vl-catch-all-error-p code72) *FF-PLOTDENOM*)  ; не прочиталось -> fallback
    ((= code72 0) 25.4)   ; дюймы
    ((= code72 1) 1.0)    ; миллиметры
    (t *FF-PLOTDENOM*))   ; пиксели/неизвестно -> fallback
)

;; --- (3) Параметры печати листа ---
;; Область = "Лист", масштаб = ПОЛЬЗОВАТЕЛЬСКИЙ 1:denom (НЕ "Вписать").
(defun ff-configure-plot (lay denom)
  (vl-catch-all-apply '(lambda () (vla-put-PlotType lay 5)))   ; 5 = Layout
  (vl-catch-all-apply '(lambda () (vla-put-UseStandardScale lay :vlax-false)))
  (vl-catch-all-apply '(lambda () (vla-SetCustomScale lay 1.0 denom)))
  (vl-catch-all-apply '(lambda () (vla-put-CenterPlot lay :vlax-true)))
  (vl-catch-all-apply '(lambda () (vla-RefreshPlotDeviceInfo lay)))
  (princ)
)

;; --- (4) Создание одного листа — оркестратор (1)+(2)+(3) ---
;; Возвращает имя успешно созданного листа или nil (при сбое/пропуске).
;; f — запись рамки; layName — заранее вычисленное уникальное имя.
(defun ff-create-one-layout (f layName layouts adoc plotter style mediaList
                             / x1 y1 x2 y2 fmt scl orient w h cx cy
                               paper lay err)
  (setq x1 (nth 1 f) y1 (nth 2 f) x2 (nth 3 f) y2 (nth 4 f)
        fmt (nth 5 f) scl (nth 6 f) orient (nth 7 f))
  (setq w (- x2 x1) h (- y2 y1)
        cx (/ (+ x1 x2) 2.0) cy (/ (+ y1 y2) 2.0))
  (setq paper (ff-paper-for fmt mediaList orient))
  ;; КРАТНЫЙ формат без точного носителя -> пропуск + подсказка
  ;; "x" — строчная, т.к. имена кратных форматов в *FF-FORMATS* всегда
  ;; строчные (A4x3, A1x3...), и fmt берётся именно из этой таблицы.
  (if (and (vl-string-search "x" fmt) (null paper))
    (progn
      (ff-msg (strcat "\n   Рамка " fmt " — ПРОПУЩЕНА:"))
      (ff-warn-need-custom fmt)
      (setq *FF-STAT-SKIP* (1+ *FF-STAT-SKIP*))
      nil)
    (progn
      (princ (strcat "\n   Лист " layName " (" fmt "/" orient ") ..."))
      (setq err
        (vl-catch-all-apply
          '(lambda ( / )
             (command "_.-LAYOUT" "_N" layName)
             (setvar "CTAB" layName)
             (setvar "PSLTSCALE" 0)
             (setq lay (vla-item layouts layName))
             (ff-setup-device   lay plotter paper orient style)
             (ff-create-viewport adoc layName cx cy w h scl)
             ;; масштаб: авто (по реальным единицам листа) или фиксированный
             (ff-configure-plot lay
               (if *FF-PLOTAUTO* (ff-layout-denom layName) *FF-PLOTDENOM*)))))
      (if (vl-catch-all-error-p err)
        (progn
          (ff-msg (strcat "\n   ! Лист " layName " — ошибка: "
                          (vl-catch-all-error-message err) " (пропущен)"))
          nil)
        layName))    ; успех -> вернуть имя
  )
)

;; --- Удаление всех листов (кроме Model) безопасным способом ---
(defun ff-delete-layouts (layouts / delNames nm)
  (setq delNames nil)
  (vl-catch-all-apply
    '(lambda ()
       (vlax-for lay layouts
         (if (/= (strcase (vla-get-name lay)) "MODEL")
           (setq delNames (cons (vla-get-name lay) delNames))))))
  (princ (strcat " найдено к удалению: " (itoa (length delNames))))
  (vl-catch-all-apply '(lambda () (setvar "CTAB" "Model")))
  (foreach nm delNames
    (vl-catch-all-apply '(lambda () (vla-delete (vla-item layouts nm)))))
  (princ)
)

;; --- Уникальное имя листа (XX-формат, при коллизии добавляет _2, _3 ...) ---
(defun ff-unique-layname (cnt fmt / base nm i)
  (setq base (strcat (ff-pad cnt) "-" fmt) nm base i 1)
  (while (member nm (layoutlist))
    (setq i (1+ i)
          nm (strcat base "_" (itoa i))))
  nm
)

;; --- Главная функция: подготовка среды + цикл по рамкам ---
;; mediaList получается прогревом и передаётся в ff-create-one-layout явно.
;; ПРИМЕЧАНИЕ: автоотката по Esc нет (в AutoLISP *error* ненадёжно ловит
;; прерывание командных вызовов). Если прервать процесс и останутся пустые
;; листы — уберите их при следующем запуске галкой "удалить листы" (delOld).
(defun ff-make-layouts (frames plotter style delOld
                        / adoc layouts display mediaList disp
                          cnt total f layName res madeNames)
  (setq madeNames nil)
  (princ "\n[FF] этап 1: получение объектов документа ...")
  (setq adoc    (vla-get-activedocument (vlax-get-acad-object))
        layouts (vla-get-layouts adoc)
        display (vla-get-display (vla-get-preferences (vlax-get-acad-object))))

  ;; отключим автосоздание видового экрана на новых листах
  (princ "\n[FF] этап 2: LayoutCreateViewport ...")
  (setq disp (vl-catch-all-apply '(lambda () (vla-get-LayoutCreateViewport display))))
  (if (vl-catch-all-error-p disp) (setq disp :vlax-true))
  (vl-catch-all-apply '(lambda () (vla-put-LayoutCreateViewport display :vlax-false)))

  ;; удалить старые листы при запросе
  (if delOld
    (progn
      (princ "\n[FF] этап 3: удаление старых листов ...")
      (ff-delete-layouts layouts)))

  ;; список носителей с ПРОГРЕВОМ устройства
  (princ "\n[FF] этап 4: прогрев плоттера и получение форматов бумаги ...")
  (setq mediaList (ff-warmup (vla-get-activelayout adoc) plotter))
  (if (null mediaList)
    (princ "\n[FF] ! список форматов пуст — формат бумаги будет по умолчанию.")
    (princ (strcat " получено форматов: " (itoa (length mediaList)))))
  (princ (strcat "\n[FF] этап 5: рамок к обработке: " (itoa (length frames))))

  ;; цикл по рамкам
  (setq total (length frames) cnt 0)
  (foreach f frames
    (setq cnt (1+ cnt))
    (princ (strcat "\n[" (itoa cnt) "/" (itoa total) "]"))
    (setq layName (ff-unique-layname cnt (nth 5 f)))
    (setq res (ff-create-one-layout f layName layouts adoc plotter style mediaList))
    (if res (setq madeNames (cons res madeNames)))
  )

  ;; вернуть настройку автосоздания ВЭ
  (vl-catch-all-apply '(lambda () (vla-put-LayoutCreateViewport display disp)))
  (setvar "CTAB" "Model")
  (setq madeNames (reverse madeNames))
  (setq *FF-STAT-DONE* (length madeNames))   ; для summary
  (princ (strcat "\n>>> Готово. Создано листов: " (itoa (length madeNames))
                 ".\n    Печать: МЕНЮ Файл > Пакетная печать (PUBLISH) "
                 "или команда PUBLISH.\n"))
  madeNames        ; вернуть список имён созданных листов
)

;; форматирование номера с ведущими нулями (01,02,...)
;; Номер с ведущими нулями до 3 разрядов (корректная сортировка до 999):
;; 9 -> "009", 99 -> "099", 100 -> "100".
(defun ff-pad (n / s)
  (setq s (itoa n))
  (while (< (strlen s) 3) (setq s (strcat "0" s)))
  s)

;;; ====================================================================
;;;  ВЫБОР МАСШТАБА ОФОРМЛЕНИЯ
;;;  Устанавливает глобальную *FF-CURSCALE* (число или nil = Авто).
;;; ====================================================================
(defun ff-ask-scale ( / s)
  (princ "\nМасштаб оформления рамок (множитель размера относительно мм).")
  (princ "\n  Примеры: 1 = рамки 1:1 (A4=210x297);  100 = рамки x100.")
  (initget 6)   ; запрет нуля и отрицательных
  (setq s (getreal "\nМасштаб <1>: "))
  (cond
    ((null s) (setq *FF-CURSCALE* 1.0))   ; Enter = 1:1
    (t        (setq *FF-CURSCALE* s)))
  *FF-CURSCALE*
)

;;; ====================================================================
;;;  ВЫБОР РЕЖИМА ПОИСКА
;;; ====================================================================
(defun ff-ask-mode ( / k)
  (initget "Блоки Линии Все")
  (setq k (getkword
            "\nГде искать рамки? [Блоки/Линии/Все] <Все>: "))
  (cond ((= k "Блоки") "B")
        ((= k "Линии") "L")
        (t "M")))

;;; ====================================================================
;;;  ОТЧЁТ ПО НАЙДЕННОМУ
;;; ====================================================================
;; Порядковый «вес» формата = его индекс в *FF-FORMATS* (там форматы уже
;; идут логично: A4..A0, затем кратные). Неизвестные — в конец.
;; Ранг формата = его индекс в *FF-FORMATS* (assoc возвращает тот же cons
;; из списка, vl-position находит его по eq). Неизвестный формат -> 9999.
(defun ff-format-rank (name / p)
  (setq p (vl-position (assoc name *FF-FORMATS*) *FF-FORMATS*))
  (if p p 9999))

(defun ff-report (frames / tally f fmt a)
  (setq tally nil)
  (foreach f frames
    (setq fmt (nth 5 f))
    (if (setq a (assoc fmt tally))
      (setq tally (subst (cons fmt (1+ (cdr a))) a tally))
      (setq tally (cons (cons fmt 1) tally))))
  (princ (strcat "\nНайдено рамок: " (itoa (length frames))))
  ;; предвычислить ранг каждого формата ОДИН раз: (имя кол-во ранг),
  ;; затем сортировать по готовому рангу (без перебора таблицы в компараторе).
  (setq tally (mapcar
                '(lambda (a) (list (car a) (cdr a) (ff-format-rank (car a))))
                tally))
  (foreach a (vl-sort tally '(lambda (x y) (< (caddr x) (caddr y))))
    (princ (strcat "\n   " (car a) " : " (itoa (cadr a)) " шт.")))
  (princ "\n")
)

;;; ====================================================================
;;;  DCL-ДИАЛОГ
;;;  .dcl-файл генерируется во временную папку автоматически,
;;;  таскать рядом отдельный файл не нужно.
;;; ====================================================================

;; Временная папка — ГАРАНТИРОВАННО строка. На некоторых сборках/версиях
;; (напр. AutoCAD 2026) getenv может вернуть не строку (T) — фильтруем это.
;; На AutoCAD 2022 и др. getenv возвращает обычную строку — поведение не меняется.
(defun ff-temp-dir ( / v)
  (setq v (vl-catch-all-apply '(lambda () (getenv "TEMP"))))
  (if (not (and (not (vl-catch-all-error-p v)) (= (type v) 'STR)))
    (setq v (vl-catch-all-apply '(lambda () (getenv "TMP")))))
  (if (and (not (vl-catch-all-error-p v)) (= (type v) 'STR) (/= v ""))
    v
    "."))   ; фолбэк — текущая папка

;; путь к временному .dcl главного диалога (без создания лишнего файла)
(defun ff-dcl-path ()
  (strcat (ff-temp-dir) "\\ff_main.dcl"))

;; отдельный путь для диалога настроек (чтобы не пересекаться с главным)
(defun ff-set-dcl-path ()
  (strcat (ff-temp-dir) "\\ff_set.dcl"))

;; получить список доступных устройств печати (плоттеров)
(defun ff-get-plotters ( / pl res)
  (setq res nil)
  (vl-catch-all-apply
    '(lambda ()
       (foreach pl (vlax-safearray->list
                     (vlax-variant-value
                       (vla-GetPlotDeviceNames
                         (vla-get-activelayout
                           (vla-get-activedocument (vlax-get-acad-object))))))
         (setq res (cons pl res)))))
  (setq res (reverse res))
  (if (null res) (setq res (list *FF-PLOTTER*)))
  res
)

;; получить список стилей печати (.ctb/.stb) + "Без стиля"
(defun ff-get-styles ( / st res)
  (setq res nil)
  (vl-catch-all-apply
    '(lambda ()
       (foreach st (vlax-safearray->list
                     (vlax-variant-value
                       (vla-GetPlotStyleTableNames
                         (vla-get-activelayout
                           (vla-get-activedocument (vlax-get-acad-object))))))
         (setq res (cons st res)))))
  (setq res (reverse res))
  (cons "Без стиля (None)" res)
)

;; записать .dcl-файл
(defun ff-write-dcl (path / f)
  (setq f (open path "w"))
  (write-line "ff_dialog : dialog {"                                        f)
  (write-line "  label = \"FrameFinder — поиск рамок ГОСТ\";"               f)
  (write-line "  : column {"                                                f)
  (write-line "    : text { label = \"Автопоиск рамок A4..A0 и кратных в модели\"; alignment = centered; }" f)
  (write-line "    spacer;"                                                 f)
  (write-line "    : boxed_column { label = \"Параметры поиска\";"          f)
  (write-line "      : edit_box { label = \"Масштаб (1 = 1:1, 100 = x100):\"; key = \"scale\"; edit_width = 10; }" f)
  (write-line "      : radio_row {"                                         f)
  (write-line "        : radio_button { label = \"Блоки\"; key = \"m_b\"; }" f)
  (write-line "        : radio_button { label = \"Линии\"; key = \"m_l\"; }" f)
  (write-line "        : radio_button { label = \"Все\";   key = \"m_m\"; }" f)
  (write-line "      }"                                                     f)
  (write-line "    }"                                                       f)
  (write-line "    spacer;"                                                 f)
  (write-line "    : boxed_column { label = \"Печать\";"                    f)
  (write-line "      : popup_list { label = \"Устройство:\"; key = \"dev\";   width = 40; }" f)
  (write-line "      : popup_list { label = \"Стиль печати:\"; key = \"style\"; width = 40; }" f)
  (write-line "    }"                                                       f)
  (write-line "    spacer;"                                                 f)
  (write-line "    : boxed_radio_row { label = \"Действие\";"               f)
  (write-line "      : radio_button { label = \"Печать рамок\";       key = \"a_plot\"; }" f)
  (write-line "      : radio_button { label = \"Создать листы\";       key = \"a_lay\"; }" f)
  (write-line "    }"                                                       f)
  (write-line "    : toggle { label = \"Удалить существующие листы (для режима Листы)\"; key = \"del\"; }" f)
  (write-line "    spacer;"                                                 f)
  (write-line "    ok_cancel;"                                              f)
  (write-line "  }"                                                         f)
  (write-line "}"                                                          f)
  (close f)
)

;; Главный диалог. Возвращает список (mode action del) для выполнения
;; или nil при отмене. *FF-CURSCALE*, *FF-PLOTTER*, *FF-STYLE* — это
;; настоящие настройки (используются во всём скрипте), их оставляем
;; глобальными; а режим/действие/флаг-удаления возвращаем ЯВНО.
(defun ff-show-dialog ( / dclfile dcl_id devs styles res scl
                          d-mode d-action d-del)
  (setq dclfile (ff-dcl-path))
  (ff-write-dcl dclfile)
  (setq dcl_id (load_dialog dclfile))
  (if (< dcl_id 0)
    (progn (alert "Не удалось загрузить DCL-диалог.") (exit)))
  (if (not (new_dialog "ff_dialog" dcl_id))
    (progn (unload_dialog dcl_id) (alert "Не удалось открыть диалог.") (exit)))

  (setq devs   (ff-get-plotters)
        styles (ff-get-styles))

  ;; масштаб оформления (число; пусто/0 трактуется как 1)
  (set_tile "scale" (rtos (if *FF-CURSCALE* *FF-CURSCALE* 1.0) 2 2))
  ;; режим поиска (по умолчанию Все)
  (set_tile "m_m" "1")
  ;; устройства
  (start_list "dev") (foreach d devs (add_list d)) (end_list)
  ;; выбрать текущее, если есть в списке
  (if (member *FF-PLOTTER* devs)
    (set_tile "dev" (itoa (- (length devs) (length (member *FF-PLOTTER* devs))))))
  ;; стили
  (start_list "style") (foreach s styles (add_list s)) (end_list)
  (if (and *FF-STYLE* (member *FF-STYLE* styles))
    (set_tile "style" (itoa (- (length styles) (length (member *FF-STYLE* styles)))))
    (set_tile "style" "0"))
  ;; действие
  (set_tile "a_plot" "1")
  (set_tile "del" "0")

  ;; OK — результаты режима/действия/удаления кладём в ЛОКАЛЬНЫЕ d-mode/...
  (action_tile "accept"
    (strcat
      "(progn "
      "  (setq scl (atof (get_tile \"scale\")))"
      "  (setq *FF-CURSCALE* (if (> scl 0.0) scl 1.0))"
      "  (setq d-mode (cond ((= (get_tile \"m_b\") \"1\") \"B\")"
      "                     ((= (get_tile \"m_l\") \"1\") \"L\") (t \"M\")))"
      "  (setq *FF-PLOTTER* (nth (atoi (get_tile \"dev\")) devs))"
      "  (setq *FF-STYLE* (if (= (atoi (get_tile \"style\")) 0)"
      "                       \"\" (nth (atoi (get_tile \"style\")) styles)))"
      "  (setq d-action (if (= (get_tile \"a_lay\") \"1\") \"L\" \"P\"))"
      "  (setq d-del (= (get_tile \"del\") \"1\"))"
      "  (done_dialog 1))"
    )
  )
  (action_tile "cancel" "(done_dialog 0)")

  (setq res (start_dialog))
  (unload_dialog dcl_id)
  (vl-catch-all-apply '(lambda () (vl-file-delete dclfile)))
  (if (= res 1)
    (list d-mode d-action d-del)   ; явный возврат параметров
    nil)
)

;;; ====================================================================
;;;  КОМАНДЫ
;;; ====================================================================

;; --- сразу печать ---
(defun c:FFPLOT ( / mode frames)
  (ff-msg-reset)
  (ff-ask-scale)
  (setq mode (ff-ask-mode))
  (princ "\nПоиск рамок ...")
  (setq frames (ff-sort (ff-collect mode)))
  (if (null frames)
    (princ "\nРамки не найдены. Проверьте режим поиска/масштаб.")
    (progn
      (ff-report frames)
      (ff-plot frames *FF-PLOTTER* *FF-STYLE*)
      (ff-msg-flush)
      (ff-summary "P")
    )
  )
  (princ)
)

;; --- сразу листы ---
(defun c:FFLAYOUT ( / mode frames del)
  (ff-msg-reset)
  (ff-ask-scale)
  (setq mode (ff-ask-mode))
  (princ "\nПоиск рамок ...")
  (setq frames (ff-sort (ff-collect mode)))
  (if (null frames)
    (princ "\nРамки не найдены. Проверьте режим поиска/масштаб.")
    (progn
      (ff-report frames)
      (initget "Да Нет")
      (setq del (getkword "\nУдалить существующие листы? [Да/Нет] <Нет>: "))
      (ff-make-layouts frames *FF-PLOTTER* *FF-STYLE* (= del "Да"))
      (ff-msg-flush)
      (ff-summary "L")
    )
  )
  (princ)
)

;; --- общий запуск с ЯВНЫМИ параметрами (mode action del) ---
(defun ff-run-with-params (mode action del / frames)
  (ff-msg-reset)
  (princ "\nПоиск рамок ...")
  (setq frames (ff-sort (ff-collect mode)))
  (if (null frames)
    (princ "\nРамки не найдены. Проверьте режим поиска/масштаб.")
    (progn
      (ff-report frames)
      (if (= action "L")
        (ff-make-layouts frames *FF-PLOTTER* *FF-STYLE* del)
        (ff-plot frames *FF-PLOTTER* *FF-STYLE*)
      )
      (ff-msg-flush)
      (ff-summary action)
    )
  )
  (princ)
)

;; --- главная команда: ДИАЛОГ (DCL) ---
(defun c:FF ( / params)
  (setq params (ff-show-dialog))
  (if params
    (ff-run-with-params (nth 0 params) (nth 1 params) (nth 2 params))
    (princ "\nОтмена."))
  (princ)
)
(defun c:FFDLG ( / ) (c:FF))   ; явный псевдоним

;; --- меню в командной строке (старый способ, без диалога) ---
(defun c:FFCMD ( / k)
  (princ "\n==== FrameFinder: автопоиск рамок ГОСТ в модели ====")
  (initget "Печать Листы Выход")
  (setq k (getkword
            "\nЧто сделать? [Печать/Листы/Выход] <Печать>: "))
  (cond
    ((= k "Листы")  (c:FFLAYOUT))
    ((= k "Выход")  (princ "\nОтмена."))
    (t              (c:FFPLOT))
  )
  (princ)
)

;; --- ДИАГНОСТИКА: показать носители плоттера и их размеры ---
;; Помогает проверить, видит ли скрипт нужный (в т.ч. пользовательский) формат.
(defun c:FFMEDIA ( / adoc alay ml sz)
  (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  (setq alay (vla-get-activelayout adoc))
  (setq ml (ff-warmup alay *FF-PLOTTER*))
  (princ (strcat "\n=== Носители устройства: " *FF-PLOTTER* " ==="))
  (if (null ml)
    (princ "\n  (список пуст)")
    (foreach m ml
      (setq sz (ff-media-size m))
      (princ (strcat "\n  " m
                     (if sz
                       (strcat "   => " (rtos (car sz) 2 1) " x "
                               (rtos (cadr sz) 2 1) " мм")
                       "   => размер не распознан")))))
  (princ "\n=== конец списка ===\n")
  (princ)
)

;;; ====================================================================
;;;  НАСТРОЙКИ — команда FFSET (диалог DCL)
;;;  Меняет глобальные переменные на лету, без правки кода.
;;; ====================================================================

;; записать .dcl для окна настроек
(defun ff-write-set-dcl (path / f)
  (setq f (open path "w"))
  (write-line "ffset_dialog : dialog {"                                     f)
  (write-line "  label = \"FrameFinder — настройки\";"                       f)
  (write-line "  : column {"                                                f)
  (write-line "    : boxed_radio_column { label = \"Масштаб печати листа (1:N)\";" f)
  (write-line "      : radio_button { label = \"Авто (по единицам листа)\"; key = \"dauto\"; }" f)
  (write-line "      : radio_button { label = \"1 : 25.4  (дюймовый драйвер)\"; key = \"d254\"; }" f)
  (write-line "      : radio_button { label = \"1 : 1     (метрический драйвер)\"; key = \"d1\"; }" f)
  (write-line "    }"                                                       f)
  (write-line "    : edit_box { label = \"Другое значение N:\"; key = \"dcustom\"; edit_width = 10; }" f)
  (write-line "    spacer;"                                                 f)
  (write-line "    : edit_box { label = \"Устройство печати:\"; key = \"plotter\"; edit_width = 32; }" f)
  (write-line "    : edit_box { label = \"Стиль печати (пусто = без):\"; key = \"style\"; edit_width = 32; }" f)
  (write-line "    : edit_box { label = \"Допуск распознавания, %:\"; key = \"tol\"; edit_width = 8; }" f)
  (write-line "    spacer;"                                                 f)
  (write-line "    : text { label = \"Текущие значения подставлены ниже.\"; }" f)
  (write-line "    spacer;"                                                 f)
  (write-line "    ok_cancel;"                                              f)
  (write-line "  }"                                                         f)
  (write-line "}"                                                          f)
  (close f)
)

(defun c:FFSET ( / dclfile dcl_id res denomTxt)
  (setq dclfile (ff-set-dcl-path))
  (ff-write-set-dcl dclfile)
  (setq dcl_id (load_dialog dclfile))
  (if (< dcl_id 0)
    (progn (alert "Не удалось загрузить диалог настроек.") (exit)))
  (if (not (new_dialog "ffset_dialog" dcl_id))
    (progn (unload_dialog dcl_id) (alert "Не удалось открыть диалог.") (exit)))

  ;; подставить текущие значения
  (cond
    (*FF-PLOTAUTO*                     (set_tile "dauto" "1"))
    ((equal *FF-PLOTDENOM* 25.4 0.001) (set_tile "d254" "1"))
    ((equal *FF-PLOTDENOM* 1.0  0.001) (set_tile "d1"   "1"))
    (t (set_tile "dcustom" (rtos *FF-PLOTDENOM* 2 3))))
  (set_tile "plotter" (if *FF-PLOTTER* *FF-PLOTTER* ""))
  (set_tile "style"   (if *FF-STYLE* *FF-STYLE* ""))
  (set_tile "tol"     (rtos (* *FF-TOL* 100.0) 2 1))

  ;; OK
  (action_tile "accept"
    (strcat
      "(progn "
      "  (setq denomTxt (get_tile \"dcustom\"))"
      "  (if (= (get_tile \"dauto\") \"1\")"
      "      (setq *FF-PLOTAUTO* t)"            ; авто-режим
      "      (progn "
      "        (setq *FF-PLOTAUTO* nil)"        ; ручной режим
      "        (cond "
      "          ((/= denomTxt \"\") (if (> (atof denomTxt) 0.0) (setq *FF-PLOTDENOM* (atof denomTxt))))"
      "          ((= (get_tile \"d1\")   \"1\") (setq *FF-PLOTDENOM* 1.0))"
      "          ((= (get_tile \"d254\") \"1\") (setq *FF-PLOTDENOM* 25.4)))))"
      "  (setq *FF-PLOTTER* (get_tile \"plotter\"))"
      "  (setq *FF-STYLE*   (get_tile \"style\"))"
      "  (if (> (atof (get_tile \"tol\")) 0.0)"
      "      (setq *FF-TOL* (/ (atof (get_tile \"tol\")) 100.0)))"
      "  (done_dialog 1))"
    )
  )
  (action_tile "cancel" "(done_dialog 0)")

  (setq res (start_dialog))
  (unload_dialog dcl_id)
  (vl-catch-all-apply '(lambda () (vl-file-delete dclfile)))

  (if (= res 1)
    (progn
      (ff-settings-save)   ; сохранить в реестр — переживут перезапуск
      (princ "\n=== Настройки FrameFinder обновлены ===")
      (princ (strcat "\n  Масштаб печати листа : "
                     (if *FF-PLOTAUTO*
                       "АВТО (по единицам листа)"
                       (strcat "1 : " (rtos *FF-PLOTDENOM* 2 3)))))
      (princ (strcat "\n  Устройство печати    : " *FF-PLOTTER*))
      (princ (strcat "\n  Стиль печати         : "
                     (if (= *FF-STYLE* "") "(без стиля)" *FF-STYLE*)))
      (princ (strcat "\n  Допуск распознавания : " (rtos (* *FF-TOL* 100.0) 2 1) " %\n"))
      (princ "  (сохранено — действует и после перезапуска AutoCAD)\n"))
    (princ "\nНастройки не изменены.\n"))
  (princ)
)

;;; ====================================================================
;;;  ДИАГНОСТИКА РАМОК — команда FFDIAG
;;;  Показывает габариты всех блоков/полилиний модели и результат
;;;  распознавания формата при ТЕКУЩЕМ масштабе (*FF-CURSCALE*).
;;;  Помогает понять, почему рамка не находится (размер не тот / масштаб).
;;; ====================================================================
(defun c:FFDIAG ( / ss n i ent dxf typ bb w h det scl)
  (setq scl (if *FF-CURSCALE* *FF-CURSCALE* 1.0))
  (princ (strcat "\n=== Диагностика рамок (масштаб для проверки: "
                 (rtos scl 2 2) ") ==="))
  (setq ss (ssget "_X"
             '((-4 . "<OR")
                 (0 . "INSERT") (0 . "LWPOLYLINE") (0 . "POLYLINE")
               (-4 . "OR>")
               (410 . "Model"))))
  (if (null ss)
    (princ "\n  В модели нет блоков/полилиний.")
    (progn
      (setq i 0 n (sslength ss))
      (princ (strcat "\n  Объектов к проверке: " (itoa n) "\n"))
      (while (< i n)
        (setq ent (ssname ss i))
        (setq dxf (entget ent))
        (setq typ (cdr (assoc 0 dxf)))
        (setq bb (ff-bbox ent))
        (if bb
          (progn
            (setq w (- (nth 2 bb) (nth 0 bb))
                  h (- (nth 3 bb) (nth 1 bb)))
            ;; распознать при текущем масштабе
            (setq det (ff-detect-scl w h scl))
            (princ (strcat "\n  " typ
                           "  габарит " (rtos w 2 1) " x " (rtos h 2 1)
                           "  (в мм при 1:" (rtos scl 2 2) " = "
                           (rtos (/ w scl) 2 1) " x " (rtos (/ h scl) 2 1) ")"
                           "  => "
                           (if det (car det) "НЕ распознано")))
          )
        )
        (setq i (1+ i))
      )
      (princ "\n=== конец диагностики ===\n")
      (princ "\nЕсли нужный формат 'НЕ распознано' — сравните его мм-размер")
      (princ "\nс ГОСТ (A0x3 = 1189 x 2523). Отклонение > 4% => увеличьте")
      (princ "\nдопуск через FFSET, или проверьте масштаб (FF -> поле масштаба).")
    )
  )
  (princ)
)

;; загрузить сохранённые пользователем настройки (если есть в реестре)
(ff-settings-load)

(princ "\nFrameFinder загружен.")
(princ "\n  FF / FFDLG — окно-диалог (DCL)")
(princ "\n  FFPLOT     — печать (командная строка)")
(princ "\n  FFLAYOUT   — создание листов (командная строка)")
(princ "\n  FFCMD      — меню в командной строке")
(princ "\n  FFMEDIA    — показать форматы бумаги плоттера (диагностика)")
(princ "\n  FFSET      — настройки (масштаб печати, устройство, стиль, допуск)")
(princ "\n  FFDIAG     — диагностика рамок (габариты и распознавание)\n")
(princ)
