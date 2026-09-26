# AutoLISP-models

Набор курсовых работ по архитектуре и проектированию графических систем, представляющих собой программы на AutoLISP для
построения различных твердотельных 3D-моделей в AutoCAD

<details>
  <summary><h2>Скриншоты</h2></summary>
  <h3>Сложные модели — задаются динамическими параметрами (при вводе с клавиатуры):</h3>
  <p>1. <a href="./complex/holder.lsp">Подставка для телефона</a></p>
  <img src="https://github.com/user-attachments/assets/a5b66648-2894-4bd3-95c4-a8ac220f3e7b" width=70%>
  <br>
  <br>
  <p>2. <a href="./complex/organizer.lsp">Канцелярский органайзер</a></p>
  <img src="https://github.com/user-attachments/assets/e8a06721-64b0-4a9e-99a6-dbe22a5a988d" width=70%>
  <br>
  <br>
  <p>3. <a href="./complex/extender.lsp">Удлинитель</a></p>
  <img src="https://github.com/user-attachments/assets/eb5b976c-de2e-414d-9cde-4782961f7f4d" width=70%>
  <br>
  <br>
  <p>4. <a href="./complex/lamp.lsp">Настольная лампа</a></p>
  <img src="https://github.com/user-attachments/assets/efef61ce-982e-4efe-b506-47ef1a2cb51f" width=70%>
  <br>
  <br>
  <p>5. <a href="./complex/budilnik.lsp">Будильник</a></p>
  <img src="https://github.com/user-attachments/assets/40729233-ffe4-4ea2-b9c8-dc686d952f6a" width=70%>
  <br>
  <br>
  <p>6. <a href="./complex/router.lsp">Wi-Fi роутер</a></p>
  <img src="https://github.com/user-attachments/assets/e47a6fe7-ed08-4b6b-9a1d-4ace917a9ed4" width=70%>
  <br>
  <br>
  <p>7. <a href="./complex/rook.lsp">Шахматная ладья</a></p>
  <img src="https://github.com/user-attachments/assets/4646f659-f0ee-4547-a118-bebe93daeaf3" width=70%>
  <br>
  <br>
  <h3>Простые модели — задаюся статическими параметрами:</h3>
  <p><a href="./simple/1.lsp">1</a></p>
  <img src="https://github.com/user-attachments/assets/c5590ba8-f89d-41d4-a149-fbe50651f580" width=35%/>
  <img src="https://github.com/user-attachments/assets/3d7d4bf4-c2c9-4dde-9729-e1ec19c2720d" width=35%/>
  <br>
  <br>
  <p><a href="./simple/2.lsp">2</a></p>
  <img src="https://github.com/user-attachments/assets/fe11051a-1690-4554-ac57-cb90d3f24160" width=35%/>
  <img src="https://github.com/user-attachments/assets/af1a1d39-004c-47ba-aa5e-1c0f6bb5e16c" width=35%/>
  <br>
  <br>
  <p><a href="./simple/3.lsp">3</a></p>
  <img src="https://github.com/user-attachments/assets/4a6b9c9d-0de4-4cf8-abea-5248b4488167" width=35%/>
  <img src="https://github.com/user-attachments/assets/69c66376-637d-4019-aaed-ccaa3a4a674e" width=35%/>
</details>

## Требования

- уникальность модели (аналогичные модели не должны быть сданы ранее)
- достаточная сложность модели (согласовывается с преподавателем)
- задание параметров моделей перед построением (не менее 10, включая количественные)
- возможность выбора параметров по умолчанию
- проверка корректности при ручном вводе
- отличия стиля кода между работами для имитации выполнения разными людьми

## Установка и запуск

0. Клонируйте репозиторий и перейдите в его папку.
1. Установите русскоязычную версию [AutoCAD](https://www.autodesk.com/products/autocad).
2. Перейдите в `Меню / Управление / Загрузить приложение` и в открывшемся окне выберите файл нужной модели.
3. Если загрузка прошла успешно, то появится сообщение:

```
Команда: _appload <модель>.lsp успешно загружено.
```

4. В консоли AutoCAD выполните команду:

```lisp
(c:<модель>)
```

Затем введите запрашиваемые параметры (или нажимайте Enter для выбора значений по умолчанию).
