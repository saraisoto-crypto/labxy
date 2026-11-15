# 📱 TechStore — Laboratorio Flutter con widgets Cupertino

App móvil de **gestión de productos** hecha con **Flutter**, usando principalmente widgets **Cupertino** (estilo iOS). Es la versión Cupertino del laboratorio de la semana 8.

| | |
|---|---|
| **Estudiante** | Saraí Soto |
| **Curso** | Aplicaciones Móviles Multiplataforma |
| **Profesor** | Torrico Márquez Hugo Felipe |
| **Entregable** | `labxy` |

---

## ✨ ¿Qué hace la app?

- 🔐 **Login** con validación de campos y alerta para recuperar la contraseña.
- 🏠 **Inicio** con un saludo, el valor total del inventario, accesos rápidos, productos destacados, categorías y alertas de poco stock.
- 🗂️ **Catálogo** con buscador, filtro por categoría y vista en cuadrícula o en lista.
- 🔎 **Detalle** de cada producto: precio, stock, estado y valor en inventario.
- ➕ **Registro** de productos con foto de la galería, categoría (ruedita de iOS) y opción de destacado.
- 👤 **Perfil** editable, con cambio de foto, preferencias y cierre de sesión.

---

## ✅ Elementos de la capacidad

| Elemento | Dónde se usa |
|---|---|
| **ListView** | Destacados y categorías en horizontal; catálogo en modo lista |
| **ListTiles** | `CupertinoListTile` en Inicio, Detalle, Registro y Perfil |
| **Listas y Mapas** | `List<Producto>` con los productos; `Map` de categorías con su ícono y su color |
| **Rutas** | Rutas con nombre: `/`, `/home`, `/registro`, `/detalle` (recibe el producto con `arguments`) |
| **Tema global** | `CupertinoThemeData` en modo oscuro para toda la app |
| **Cards** | Widget propio `Tarjeta` (Cupertino no trae `Card`), con estilo de vidrio |

---

## 🍎 Widgets Cupertino utilizados

`CupertinoApp` · `CupertinoPageScaffold` · `CupertinoTabScaffold` · `CupertinoTabBar` · `CupertinoNavigationBar` · `CupertinoTextField` · `CupertinoSearchTextField` · `CupertinoButton` · `CupertinoListSection` · `CupertinoListTile` · `CupertinoFormSection` · `CupertinoTextFormFieldRow` · `CupertinoSlidingSegmentedControl` · `CupertinoPicker` · `CupertinoSwitch` · `CupertinoAlertDialog` · `CupertinoActionSheet` · `CupertinoIcons`

---

## 🛠️ Tecnologías

- Flutter / Dart
- [`image_picker`](https://pub.dev/packages/image_picker) para elegir fotos de la galería

---

## 🚀 Cómo ejecutarlo

```bash
git clone https://github.com/saraisoto-crypto/labxy.git
cd labxy
flutter pub get
flutter run -d chrome
```

> Para entrar, escribe cualquier correo y contraseña.

---

## 📁 Estructura

```
labxy/
├── assets/
│   └── images/      # Fotos de productos y de perfil
├── lib/
│   └── main.dart    # Código de la app
└── pubspec.yaml     # Dependencias y assets
```
