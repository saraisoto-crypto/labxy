import 'dart:typed_data';
import 'dart:ui' as ui;

// LABORATORIO SEMANA 8 - VERSION CUPERTINO (estilo iOS, tema oscuro premium)
// Usamos SOLO la libreria cupertino (no importamos material.dart).
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const TiendaApp());
}

// ---------------------------------------------------------------
// COLORES DE LA APP
// ---------------------------------------------------------------
const Color colorPrincipal = Color(0xFF8B7BFF); // violeta luminoso
const Color colorAcento = Color(0xFFFF4D8D); // rosa intenso
const Color colorDorado = Color(0xFFFFC857); // dorado
const Color colorNoche = Color(0xFF0B0A1F); // fondo principal
const Color colorTexto = Color(0xFFFFFFFF); // texto principal
const Color colorSuave = Color(0xFFA9A6C9); // texto secundario
const Color vidrioFondo = Color(0x12FFFFFF); // blanco al 7% (vidrio)
const Color vidrioBorde = Color(0x1FFFFFFF); // blanco al 12% (borde)

// Degradado de botones y tarjeta principal (violeta -> rosa)
const List<Color> degradadoBoton = [Color(0xFF6D5BFF), Color(0xFFFF4D8D)];

const LinearGradient degradadoHero = LinearGradient(
  colors: [Color(0xFF5B4BFF), Color(0xFFA34DFF), Color(0xFFFF4D8D)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const String fotoPerfil = 'assets/images/perfil.jpg';

// ---------------------------------------------------------------
// MAPAS (Map<clave, valor>)
// ---------------------------------------------------------------
// Cada categoria (clave) tiene su icono (valor).
final Map<String, IconData> categorias = {
  'Cómputo': CupertinoIcons.device_laptop,
  'Accesorios': CupertinoIcons.keyboard,
  'Audio': CupertinoIcons.headphones,
  'Celulares': CupertinoIcons.device_phone_portrait,
};

// Cada categoria (clave) tiene su color (valor).
final Map<String, Color> coloresCategoria = {
  'Cómputo': const Color(0xFF6D5BFF),
  'Accesorios': const Color(0xFF22B8F0),
  'Audio': const Color(0xFF2DD4A3),
  'Celulares': const Color(0xFFFF4D8D),
};

// ---------------------------------------------------------------
// MODELOS
// ---------------------------------------------------------------
class Producto {
  String nombre;
  String descripcion;
  double precio;
  int stock;
  String categoria;
  bool destacado;
  String imagen; // foto de assets (productos de ejemplo)
  Uint8List? bytes; // foto elegida con image_picker (productos nuevos)

  Producto({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.stock,
    required this.categoria,
    this.destacado = false,
    this.imagen = '',
    this.bytes,
  });

  IconData get icono => categorias[categoria] ?? CupertinoIcons.cube_box;
  Color get color => coloresCategoria[categoria] ?? colorPrincipal;
  bool get pocoStock => stock <= 5;
}

class Perfil {
  String nombre;
  String correo;
  String telefono;
  String rol;
  Uint8List? foto;

  Perfil({
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.rol,
    this.foto,
  });
}

// ---------------------------------------------------------------
// LISTAS (List<Producto>) - datos compartidos por todas las pantallas
// ---------------------------------------------------------------
final List<Producto> listaProductos = [
  Producto(
    nombre: 'Laptop Pro 15"',
    descripcion: 'Ideal para trabajo y estudio',
    precio: 3500,
    stock: 10,
    categoria: 'Cómputo',
    destacado: true,
    imagen: 'assets/images/laptop.jpg',
  ),
  Producto(
    nombre: 'Mouse Inalámbrico',
    descripcion: 'Ergonómico y silencioso',
    precio: 50,
    stock: 25,
    categoria: 'Accesorios',
    imagen: 'assets/images/mouse.jpg',
  ),
  Producto(
    nombre: 'Teclado Mecánico',
    descripcion: 'Retroiluminado, switches rápidos',
    precio: 120,
    stock: 3,
    categoria: 'Accesorios',
    destacado: true,
    imagen: 'assets/images/teclado.jpg',
  ),
  Producto(
    nombre: 'Monitor LED 24"',
    descripcion: 'Full HD con bordes delgados',
    precio: 800,
    stock: 8,
    categoria: 'Cómputo',
    imagen: 'assets/images/monitor.jpg',
  ),
  Producto(
    nombre: 'Audífonos Bluetooth',
    descripcion: 'Sonido envolvente',
    precio: 180,
    stock: 14,
    categoria: 'Audio',
    destacado: true,
    imagen: 'assets/images/audifonos.jpg',
  ),
  Producto(
    nombre: 'iPhone 128GB',
    descripcion: 'Cámara avanzada y iOS',
    precio: 1500,
    stock: 6,
    categoria: 'Celulares',
    destacado: true,
    imagen: 'assets/images/celular.jpg',
  ),
];

final Perfil perfil = Perfil(
  nombre: 'Sarai Soto',
  correo: 'sarai@tienda.com',
  telefono: '987654321',
  rol: 'Administrador',
);

// ValueNotifier: avisa a todas las pantallas que la lista cambio
// (cuando se registra o elimina un producto) para que se redibujen.
final ValueNotifier<int> cambios = ValueNotifier<int>(0);
void notificarCambios() => cambios.value++;

// ---------------------------------------------------------------
// FUNCIONES DE AYUDA
// ---------------------------------------------------------------

// Abre la galeria (o el explorador en Chrome) y devuelve la foto en bytes.
Future<Uint8List?> elegirFoto() async {
  final archivo = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 900,
    imageQuality: 85,
  );
  if (archivo == null) return null;
  return archivo.readAsBytes();
}

// Da formato de soles con separador de miles: 54500 -> "S/ 54,500.00"
String soles(double valor) {
  final partes = valor.toStringAsFixed(2).split('.');
  final entero = partes[0];
  final buffer = StringBuffer();
  for (var i = 0; i < entero.length; i++) {
    if (i > 0 && (entero.length - i) % 3 == 0) buffer.write(',');
    buffer.write(entero[i]);
  }
  return 'S/ $buffer.${partes[1]}';
}

// Saludo segun la hora del dia
String saludo() {
  final hora = DateTime.now().hour;
  if (hora < 12) return 'Buenos días';
  if (hora < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

// Muestra una alerta estilo iOS (CupertinoAlertDialog)
void mostrarAlerta(BuildContext context, String titulo, String mensaje) {
  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(titulo),
      content: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(mensaje),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}

// Abre una ruta con nombre usando el Navigator principal de la app
// (rootNavigator: true), asi la pantalla tapa tambien la barra de pestanas.
Future<void> abrirRuta(BuildContext context, String ruta, {Object? datos}) {
  return Navigator.of(context, rootNavigator: true)
      .pushNamed(ruta, arguments: datos);
}

// Cerrar sesion con CupertinoActionSheet (menu que sube desde abajo)
void confirmarCerrarSesion(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (ctx) => CupertinoActionSheet(
      title: const Text('Cerrar sesión'),
      message: const Text('¿Seguro que quieres salir de tu cuenta?'),
      actions: [
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(ctx);
            // Vuelve al login y borra todas las pantallas anteriores
            Navigator.of(context, rootNavigator: true)
                .pushNamedAndRemoveUntil('/', (route) => false);
          },
          child: const Text('Cerrar sesión'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDefaultAction: true,
        onPressed: () => Navigator.pop(ctx),
        child: const Text('Cancelar'),
      ),
    ),
  );
}

// ---------------------------------------------------------------
// APP PRINCIPAL: CupertinoApp + TEMA GLOBAL + RUTAS
// ---------------------------------------------------------------
class TiendaApp extends StatelessWidget {
  const TiendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'TechStore',

      // TEMA GLOBAL: CupertinoThemeData define colores y textos de TODA la
      // app en un solo lugar. Brightness.dark activa el modo oscuro de iOS.
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: colorPrincipal,
        primaryContrastingColor: CupertinoColors.white,
        scaffoldBackgroundColor: colorNoche,
        barBackgroundColor: Color(0xCC0B0A1F),
        textTheme: CupertinoTextThemeData(
          primaryColor: colorPrincipal,
          textStyle: TextStyle(
            fontSize: 16,
            color: colorTexto,
            letterSpacing: -0.3,
          ),
          navLargeTitleTextStyle: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: colorTexto,
            letterSpacing: -1.2,
          ),
          navTitleTextStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colorTexto,
          ),
        ),
      ),

      // RUTAS CON NOMBRE: cada pantalla tiene un "nombre" y se abre con
      // Navigator.pushNamed(context, '/nombre').
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/registro': (context) => const RegistroPage(),
        '/detalle': (context) => const DetallePage(),
      },

      // En Chrome limita el ancho a 450 px para que se vea como celular
      // y oculta las barras de scroll grises del navegador.
      builder: (context, child) {
        final ancho = MediaQuery.of(context).size.width;
        return ColoredBox(
          color: const Color(0xFF05040F),
          child: Center(
            child: SizedBox(
              width: ancho > 450 ? 450 : ancho,
              height: double.infinity,
              child: ClipRect(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: child!,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------
// WIDGETS REUTILIZABLES
// ---------------------------------------------------------------

// Fondo nocturno con luces de colores (se usa en todas las pantallas)
class FondoPremium extends StatelessWidget {
  final Widget child;
  const FondoPremium({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B0A1F),
                  Color(0xFF17143A),
                  Color(0xFF0B0A1F),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        const Positioned(
          top: -120,
          right: -100,
          child: LuzDifusa(tamano: 300, color: Color(0xFF6D5BFF)),
        ),
        const Positioned(
          top: 380,
          left: -140,
          child: LuzDifusa(tamano: 280, color: Color(0xFFFF4D8D), opacidad: 0.3),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

// Circulo de color muy desenfocado (efecto de luz de fondo)
class LuzDifusa extends StatelessWidget {
  final double tamano;
  final Color color;
  final double opacidad;
  const LuzDifusa({
    super.key,
    required this.tamano,
    required this.color,
    this.opacidad = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    // ImageFiltered aplica un desenfoque al circulo
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacidad),
        ),
      ),
    );
  }
}

// CARD estilo "vidrio": Cupertino no trae un widget Card, asi que creamos
// nuestra propia tarjeta translucida con borde fino y esquinas redondeadas.
class Tarjeta extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radio;
  final Color color;

  const Tarjeta({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.radio = 22,
    this.color = vidrioFondo,
  });

  @override
  Widget build(BuildContext context) {
    // El recorte va POR FUERA del padding: asi las esquinas no cortan el texto
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radio),
        border: Border.all(color: vidrioBorde),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radio),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// Imagen del producto: foto elegida, foto de assets o un respaldo con icono.
class ImagenProducto extends StatelessWidget {
  final Producto? producto;
  final Uint8List? bytes;
  final IconData iconoRespaldo;

  const ImagenProducto({
    super.key,
    this.producto,
    this.bytes,
    this.iconoRespaldo = CupertinoIcons.photo,
  });

  @override
  Widget build(BuildContext context) {
    final color = producto?.color ?? colorPrincipal;
    final foto = bytes ?? producto?.bytes;
    final ruta = producto?.imagen ?? '';

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.35)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            producto?.icono ?? iconoRespaldo,
            color: CupertinoColors.white.withValues(alpha: 0.85),
            size: 44,
          ),
        ),
        if (foto != null)
          Image.memory(foto, fit: BoxFit.cover)
        else if (ruta.isNotEmpty)
          Image.asset(
            ruta,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => const SizedBox.shrink(),
          ),
      ],
    );
  }
}

// Foto de perfil circular con aro de degradado y brillo
class AvatarPerfil extends StatelessWidget {
  final double tamano;
  const AvatarPerfil({super.key, this.tamano = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      padding: EdgeInsets.all(tamano > 80 ? 4 : 2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6D5BFF), colorAcento, colorDorado],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorAcento.withValues(alpha: 0.45),
            blurRadius: tamano * 0.4,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: const Color(0xFF221E4A),
              child: Icon(
                CupertinoIcons.person_fill,
                color: colorPrincipal,
                size: tamano * 0.5,
              ),
            ),
            if (perfil.foto != null)
              Image.memory(perfil.foto!, fit: BoxFit.cover)
            else
              Image.asset(
                fotoPerfil,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

// Cuadrito de color con icono (como en Ajustes de iPhone)
class IconoIOS extends StatelessWidget {
  final IconData icono;
  final Color color;
  const IconoIOS(this.icono, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icono, color: color, size: 18),
    );
  }
}

// Boton circular de vidrio (campana, editar, etc.)
class BotonVidrio extends StatelessWidget {
  final IconData icono;
  final VoidCallback onPressed;
  final bool punto; // puntito rosa de notificacion

  const BotonVidrio({
    super.key,
    required this.icono,
    required this.onPressed,
    this.punto = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: vidrioFondo,
          shape: BoxShape.circle,
          border: Border.all(color: vidrioBorde),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icono, color: colorTexto, size: 21),
            if (punto)
              Positioned(
                top: 11,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: colorAcento,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Boton con degradado violeta -> rosa
class BotonDegradado extends StatelessWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback onPressed;
  final List<Color> colores;

  const BotonDegradado({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icono,
    this.colores = degradadoBoton,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colores),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colores.last.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icono != null) ...[
              Icon(icono, color: CupertinoColors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              texto,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Titulo de seccion
class TituloSeccion extends StatelessWidget {
  final String texto;
  final String? accion;
  final VoidCallback? onAccion;

  const TituloSeccion(this.texto, {super.key, this.accion, this.onAccion});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: colorTexto,
              ),
            ),
          ),
          if (accion != null)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: onAccion,
              child: Row(
                children: [
                  Text(
                    accion!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorPrincipal,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(CupertinoIcons.chevron_right,
                      size: 14, color: colorPrincipal),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Seccion de lista con estilo vidrio (CupertinoListSection personalizado)
class SeccionVidrio extends StatelessWidget {
  final String? titulo;
  final List<Widget> children;
  const SeccionVidrio({super.key, this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      backgroundColor: const Color(0x00000000),
      separatorColor: vidrioBorde,
      decoration: BoxDecoration(
        color: vidrioFondo,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: vidrioBorde),
      ),
      header: titulo == null
          ? null
          : Text(
              titulo!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorSuave,
                letterSpacing: 0.4,
              ),
            ),
      children: children,
    );
  }
}

// ---------------------------------------------------------------
// 1. LOGIN
// ---------------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  bool ocultarPassword = true;

  void ingresar() {
    final correo = correoController.text.trim();
    final clave = passwordController.text;

    if (correo.isEmpty || clave.isEmpty) {
      mostrarAlerta(
        context,
        'Faltan datos',
        'Ingresa tu correo y contraseña para continuar.',
      );
      return;
    }

    perfil.correo = correo;
    // Ruta con nombre: reemplaza el login por el home
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // CupertinoTextField estilo "vidrio" (fondo translucido y texto blanco)
  Widget campo({
    required TextEditingController controller,
    required String placeholder,
    required IconData icono,
    bool ocultar = false,
    Widget? sufijo,
    TextInputType? teclado,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: ocultar,
      keyboardType: teclado,
      cursorColor: colorAcento,
      style: const TextStyle(color: CupertinoColors.white, fontSize: 16),
      placeholderStyle: TextStyle(
        color: CupertinoColors.white.withValues(alpha: 0.45),
        fontSize: 16,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
      prefix: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          icono,
          color: CupertinoColors.white.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
      suffix: sufijo,
      onSubmitted: (_) => ingresar(),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: colorNoche,
      child: Stack(
        children: [
          // Fondo nocturno con degradado vertical
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F0C29),
                    Color(0xFF302B63),
                    Color(0xFF1A1740),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Luces difusas de colores
          const Positioned(
            top: -90,
            left: -70,
            child: LuzDifusa(tamano: 280, color: Color(0xFF7C3AED), opacidad: 0.55),
          ),
          const Positioned(
            top: 140,
            right: -110,
            child: LuzDifusa(tamano: 260, color: Color(0xFFFF4D8D), opacidad: 0.55),
          ),
          const Positioned(
            bottom: -120,
            left: -20,
            child: LuzDifusa(tamano: 320, color: Color(0xFF4F46E5), opacidad: 0.55),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    // Collage de productos flotando
                    const SizedBox(
                      height: 170,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FotoFlotante(
                            ruta: 'assets/images/audifonos.jpg',
                            angulo: -0.20,
                            desplazamiento: Offset(-100, 18),
                          ),
                          FotoFlotante(
                            ruta: 'assets/images/celular.jpg',
                            angulo: 0.18,
                            desplazamiento: Offset(100, 18),
                          ),
                          FotoFlotante(
                            ruta: 'assets/images/laptop.jpg',
                            angulo: 0,
                            desplazamiento: Offset(0, -6),
                            tamano: 128,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    // Etiqueta pequena
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: CupertinoColors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.sparkles,
                              size: 14, color: colorDorado),
                          SizedBox(width: 6),
                          Text(
                            'Gestión de inventario',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'TechStore',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.6,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tu catálogo, en la palma de tu mano',
                      style: TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.white.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tarjeta de VIDRIO esmerilado (BackdropFilter)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color:
                                CupertinoColors.white.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: CupertinoColors.white
                                  .withValues(alpha: 0.16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Iniciar sesión',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                  color: CupertinoColors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ingresa tus credenciales para continuar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.white
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 22),
                              campo(
                                controller: correoController,
                                placeholder: 'Correo electrónico',
                                icono: CupertinoIcons.mail,
                                teclado: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              campo(
                                controller: passwordController,
                                placeholder: 'Contraseña',
                                icono: CupertinoIcons.lock,
                                ocultar: ocultarPassword,
                                sufijo: CupertinoButton(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  onPressed: () => setState(
                                    () => ocultarPassword = !ocultarPassword,
                                  ),
                                  child: Icon(
                                    ocultarPassword
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: CupertinoColors.white
                                        .withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: CupertinoButton(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  onPressed: () => mostrarAlerta(
                                    context,
                                    'Recuperar contraseña',
                                    'Te enviaremos un enlace a tu correo.',
                                  ),
                                  child: const Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF8FB5),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              BotonDegradado(
                                texto: 'Ingresar',
                                icono: CupertinoIcons.arrow_right,
                                onPressed: ingresar,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Hecho con widgets Cupertino · Flutter',
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Foto de producto inclinada con borde blanco (collage del login)
class FotoFlotante extends StatelessWidget {
  final String ruta;
  final double angulo; // en radianes
  final Offset desplazamiento;
  final double tamano;

  const FotoFlotante({
    super.key,
    required this.ruta,
    required this.angulo,
    required this.desplazamiento,
    this.tamano = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: desplazamiento,
      child: Transform.rotate(
        angle: angulo,
        child: Container(
          width: tamano,
          height: tamano,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: CupertinoColors.white.withValues(alpha: 0.9),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withValues(alpha: 0.4),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              ruta,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: const Color(0xFF4338CA),
                child: const Icon(
                  CupertinoIcons.cube_box_fill,
                  color: CupertinoColors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// 2. HOME con CupertinoTabScaffold (barra de pestanas inferior de iOS)
// ---------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controla que pestana esta activa (permite cambiarla por codigo)
  final CupertinoTabController tabController = CupertinoTabController();

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: tabController,
            tabBar: CupertinoTabBar(
        activeColor: colorAcento,
        inactiveColor: colorSuave,
        backgroundColor: const Color(0xE60B0A1F),
        border: const Border(top: BorderSide(color: vidrioBorde)),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2_fill),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_crop_circle_fill),
            label: 'Perfil',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        // CupertinoTabView: cada pestana tiene su propio historial
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return InicioTab(
                  irAPestana: (i) => tabController.index = i,
                );
              case 1:
                return const ProductosTab();
              default:
                return const PerfilTab();
            }
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------
// 2.1 PESTANA INICIO (menu principal)
// ---------------------------------------------------------------
class InicioTab extends StatelessWidget {
  final ValueChanged<int> irAPestana;
  const InicioTab({super.key, required this.irAPestana});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: FondoPremium(
        child: ValueListenableBuilder<int>(
          valueListenable: cambios,
          builder: (context, valor, child) {
            final destacados =
                listaProductos.where((p) => p.destacado).toList();
            final bajoStock =
                listaProductos.where((p) => p.pocoStock).toList();
            final unidades =
                listaProductos.fold<int>(0, (suma, p) => suma + p.stock);
            final valorInventario = listaProductos.fold<double>(
              0,
              (suma, p) => suma + p.precio * p.stock,
            );

            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 30),
                children: [
                  // ---- Cabecera: saludo + campana + avatar ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${saludo()} 👋',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: colorSuave,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                perfil.nombre,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                  color: colorTexto,
                                ),
                              ),
                            ],
                          ),
                        ),
                        BotonVidrio(
                          icono: CupertinoIcons.bell,
                          punto: bajoStock.isNotEmpty,
                          onPressed: () => mostrarAlerta(
                            context,
                            'Notificaciones',
                            bajoStock.isEmpty
                                ? 'Todo en orden. No hay alertas de stock.'
                                : 'Tienes ${bajoStock.length} producto(s) con poco stock.',
                          ),
                        ),
                        const SizedBox(width: 10),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => irAPestana(2),
                          child: const AvatarPerfil(tamano: 46),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ---- Tarjeta principal: valor del inventario ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TarjetaInventario(
                      valor: valorInventario,
                      productos: listaProductos.length,
                      unidades: unidades,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ---- Acciones rapidas ----
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AccionRapida(
                          icono: CupertinoIcons.plus,
                          texto: 'Registrar',
                          color: const Color(0xFF6D5BFF),
                          onTap: () => abrirRuta(context, '/registro'),
                        ),
                        AccionRapida(
                          icono: CupertinoIcons.square_grid_2x2_fill,
                          texto: 'Catálogo',
                          color: const Color(0xFF22B8F0),
                          onTap: () => irAPestana(1),
                        ),
                        AccionRapida(
                          icono: CupertinoIcons.person_fill,
                          texto: 'Perfil',
                          color: const Color(0xFF2DD4A3),
                          onTap: () => irAPestana(2),
                        ),
                        AccionRapida(
                          icono: CupertinoIcons.power,
                          texto: 'Salir',
                          color: colorAcento,
                          onTap: () => confirmarCerrarSesion(context),
                        ),
                      ],
                    ),
                  ),

                  // ---- Destacados: ListView horizontal de Cards ----
                  TituloSeccion(
                    'Destacados',
                    accion: 'Ver todo',
                    onAccion: () => irAPestana(1),
                  ),
                  SizedBox(
                    height: 250,
                    child: destacados.isEmpty
                        ? const Center(
                            child: Text(
                              'Aún no hay productos destacados',
                              style: TextStyle(color: colorSuave),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: destacados.length,
                            itemBuilder: (context, index) {
                              final p = destacados[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: TarjetaDestacado(
                                  producto: p,
                                  onTap: () =>
                                      abrirRuta(context, '/detalle', datos: p),
                                ),
                              );
                            },
                          ),
                  ),

                  // ---- Categorias: se recorren las entradas del MAPA ----
                  const TituloSeccion('Categorías'),
                  SizedBox(
                    height: 74,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: categorias.entries.map((entrada) {
                        final color = coloresCategoria[entrada.key]!;
                        final cantidad = listaProductos
                            .where((p) => p.categoria == entrada.key)
                            .length;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => irAPestana(1),
                            child: Tarjeta(
                              radio: 20,
                              padding: const EdgeInsets.fromLTRB(10, 10, 18, 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          color,
                                          color.withValues(alpha: 0.5),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Icon(entrada.value,
                                        color: CupertinoColors.white,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entrada.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: colorTexto,
                                        ),
                                      ),
                                      Text(
                                        '$cantidad productos',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: colorSuave,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // ---- Poco stock: CupertinoListTile dentro de seccion ----
                  if (bajoStock.isNotEmpty) ...[
                    const TituloSeccion('Requieren atención'),
                    SeccionVidrio(
                      children: bajoStock
                          .map(
                            (p) => CupertinoListTile(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              leadingSize: 46,
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ImagenProducto(producto: p),
                              ),
                              title: Text(
                                p.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colorTexto,
                                ),
                              ),
                              subtitle: Text(
                                'Solo quedan ${p.stock} unidades',
                                style: const TextStyle(
                                  color: Color(0xFFFF8FB5),
                                ),
                              ),
                              trailing: const CupertinoListTileChevron(),
                              onTap: () =>
                                  abrirRuta(context, '/detalle', datos: p),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Tarjeta grande con degradado: valor total del inventario
class TarjetaInventario extends StatelessWidget {
  final double valor;
  final int productos;
  final int unidades;

  const TarjetaInventario({
    super.key,
    required this.valor,
    required this.productos,
    required this.unidades,
  });

  Widget chip(IconData icono, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: CupertinoColors.white),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: degradadoHero,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA34DFF).withValues(alpha: 0.45),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Anillos decorativos
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CupertinoColors.white.withValues(alpha: 0.14),
                  width: 26,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: 120,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CupertinoColors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.chart_bar_fill,
                        color: CupertinoColors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Valor del inventario',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  soles(valor),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    chip(CupertinoIcons.cube_box_fill, '$productos productos'),
                    chip(CupertinoIcons.archivebox_fill, '$unidades unidades'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Boton redondo de acceso rapido con etiqueta
class AccionRapida extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback onTap;

  const AccionRapida({
    super.key,
    required this.icono,
    required this.texto,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: vidrioFondo,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: vidrioBorde),
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.55)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Icon(icono, color: CupertinoColors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorSuave,
            ),
          ),
        ],
      ),
    );
  }
}

// Card alta de producto destacado (foto completa + panel inferior)
class TarjetaDestacado extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const TarjetaDestacado({
    super.key,
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 175,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: vidrioBorde),
          boxShadow: [
            BoxShadow(
              color: producto.color.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ImagenProducto(producto: producto),
            // Sombra inferior para que se lea el texto
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x00000000), Color(0xE60B0A1F)],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Categoria arriba a la izquierda
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x660B0A1F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: vidrioBorde),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(producto.icono,
                        size: 12, color: CupertinoColors.white),
                    const SizedBox(width: 4),
                    Text(
                      producto.categoria,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              top: 12,
              right: 12,
              child: Icon(CupertinoIcons.star_fill,
                  color: colorDorado, size: 18),
            ),
            // Nombre y precio
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          soles(producto.precio),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: colorDorado,
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: degradadoBoton),
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_up_right,
                          size: 15,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// 3. PESTANA CATALOGO (buscador, filtro, cuadricula o lista)
// ---------------------------------------------------------------
class ProductosTab extends StatefulWidget {
  const ProductosTab({super.key});

  @override
  State<ProductosTab> createState() => _ProductosTabState();
}

enum Vista { cuadricula, lista }

class _ProductosTabState extends State<ProductosTab> {
  String busqueda = '';
  String categoriaActiva = 'Todos';
  Vista vista = Vista.cuadricula;

  void opcionesProducto(Producto p) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(p.nombre),
        message: Text('${soles(p.precio)}  ·  Stock ${p.stock}'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              abrirRuta(context, '/detalle', datos: p);
            },
            child: const Text('Ver detalle'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              listaProductos.remove(p);
              notificarCambios();
            },
            child: const Text('Eliminar producto'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
      ),
    );
  }

  Widget chipCategoria(String nombre, IconData? icono) {
    final activo = categoriaActiva == nombre;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => setState(() => categoriaActiva = nombre),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            gradient: activo
                ? const LinearGradient(colors: degradadoBoton)
                : null,
            color: activo ? null : vidrioFondo,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: activo ? const Color(0x00000000) : vidrioBorde,
            ),
          ),
          child: Row(
            children: [
              if (icono != null) ...[
                Icon(icono,
                    size: 16,
                    color: activo ? CupertinoColors.white : colorSuave),
                const SizedBox(width: 6),
              ],
              Text(
                nombre,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: activo ? CupertinoColors.white : colorSuave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: FondoPremium(
        child: SafeArea(
          child: ValueListenableBuilder<int>(
            valueListenable: cambios,
            builder: (context, valor, child) {
              final filtrados = listaProductos.where((p) {
                final coincideTexto =
                    p.nombre.toLowerCase().contains(busqueda.toLowerCase());
                final coincideCategoria = categoriaActiva == 'Todos' ||
                    p.categoria == categoriaActiva;
                return coincideTexto && coincideCategoria;
              }).toList();

              return Column(
                children: [
                  // Titulo grande + boton agregar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catálogo',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.2,
                                  color: colorTexto,
                                ),
                              ),
                              Text(
                                'Administra tus productos',
                                style:
                                    TextStyle(fontSize: 14, color: colorSuave),
                              ),
                            ],
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => abrirRuta(context, '/registro'),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient:
                                  const LinearGradient(colors: degradadoBoton),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colorAcento.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Icon(CupertinoIcons.plus,
                                color: CupertinoColors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Buscador nativo de iOS (estilo vidrio)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                    child: CupertinoSearchTextField(
                      placeholder: 'Buscar producto',
                      backgroundColor: vidrioFondo,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 14),
                      style: const TextStyle(color: colorTexto),
                      placeholderStyle: const TextStyle(color: colorSuave),
                      itemColor: colorSuave,
                      onChanged: (texto) => setState(() => busqueda = texto),
                    ),
                  ),

                  // Filtro por categoria (sale del MAPA de categorias)
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        chipCategoria('Todos', null),
                        ...categorias.entries
                            .map((e) => chipCategoria(e.key, e.value)),
                      ],
                    ),
                  ),

                  // Contador + selector de vista (control segmentado de iOS).
                  // Sus opciones tambien se pasan como un Map<Vista, Widget>.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${filtrados.length} productos',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorSuave,
                            ),
                          ),
                        ),
                        CupertinoSlidingSegmentedControl<Vista>(
                          groupValue: vista,
                          backgroundColor: vidrioFondo,
                          thumbColor: const Color(0xFF3A3370),
                          onValueChanged: (v) {
                            if (v != null) setState(() => vista = v);
                          },
                          children: const {
                            Vista.cuadricula: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(CupertinoIcons.square_grid_2x2,
                                  size: 18, color: colorTexto),
                            ),
                            Vista.lista: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(CupertinoIcons.list_bullet,
                                  size: 18, color: colorTexto),
                            ),
                          },
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: filtrados.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.search,
                                    size: 48, color: colorSuave),
                                SizedBox(height: 10),
                                Text(
                                  'No se encontraron productos',
                                  style: TextStyle(color: colorSuave),
                                ),
                              ],
                            ),
                          )
                        : vista == Vista.cuadricula
                            ? GridView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 6, 20, 24),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 0.68,
                                ),
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  final p = filtrados[index];
                                  return TarjetaProducto(
                                    producto: p,
                                    onTap: () => abrirRuta(
                                        context, '/detalle',
                                        datos: p),
                                    onOpciones: () => opcionesProducto(p),
                                  );
                                },
                              )
                            // LISTVIEW + CupertinoListTile dentro de Cards
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 6, 20, 24),
                                itemCount: filtrados.length,
                                itemBuilder: (context, index) {
                                  final p = filtrados[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: Tarjeta(
                                      radio: 20,
                                      child: CupertinoListTile(
                                        padding: const EdgeInsets.all(12),
                                        leadingSize: 64,
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: ImagenProducto(producto: p),
                                        ),
                                        title: Text(
                                          p.nombre,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: colorTexto,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${p.categoria} · Stock ${p.stock}',
                                          style: const TextStyle(
                                              color: colorSuave),
                                        ),
                                        additionalInfo: Text(
                                          soles(p.precio),
                                          style: const TextStyle(
                                            color: colorDorado,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        trailing:
                                            const CupertinoListTileChevron(),
                                        onTap: () => abrirRuta(
                                            context, '/detalle',
                                            datos: p),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Card de producto para la cuadricula
class TarjetaProducto extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;
  final VoidCallback onOpciones;

  const TarjetaProducto({
    super.key,
    required this.producto,
    required this.onTap,
    required this.onOpciones,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onOpciones, // mantener presionado = opciones
      child: Tarjeta(
        radio: 24,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImagenProducto(producto: producto),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: producto.pocoStock
                              ? colorAcento
                              : const Color(0x990B0A1F),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          producto.pocoStock
                              ? 'Quedan ${producto.stock}'
                              : 'Stock ${producto.stock}',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(6),
                        onPressed: onOpciones,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0x990B0A1F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.ellipsis,
                            size: 15,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorTexto,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    producto.categoria,
                    style: const TextStyle(fontSize: 12, color: colorSuave),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          soles(producto.precio),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: colorDorado,
                          ),
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: producto.color.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(producto.icono,
                            size: 15, color: CupertinoColors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// 4. DETALLE DEL PRODUCTO (recibe el producto por la ruta)
// ---------------------------------------------------------------
class DetallePage extends StatelessWidget {
  const DetallePage({super.key});

  Widget dato(IconData icono, String valor, String etiqueta, Color color) {
    return Expanded(
      child: Tarjeta(
        radio: 18,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Icon(icono, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colorTexto,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              etiqueta,
              style: const TextStyle(fontSize: 12, color: colorSuave),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lee el producto que se envio en pushNamed(..., arguments: p)
    final p = ModalRoute.of(context)!.settings.arguments as Producto;

    void eliminar() {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Seguro que quieres eliminar "${p.nombre}"?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                listaProductos.remove(p);
                notificarCambios();
                Navigator.pop(ctx); // cierra la alerta
                Navigator.pop(context); // vuelve atras
              },
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Atrás',
        middle: Text('Detalle'),
        border: null,
      ),
      child: FondoPremium(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
            children: [
              // Foto grande con brillo del color de su categoria
              Container(
                height: 320,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: vidrioBorde),
                  boxShadow: [
                    BoxShadow(
                      color: p.color.withValues(alpha: 0.45),
                      blurRadius: 40,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: ImagenProducto(producto: p),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: p.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(p.icono, size: 14, color: CupertinoColors.white),
                        const SizedBox(width: 6),
                        Text(
                          p.categoria,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (p.destacado) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorDorado.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.star_fill,
                              size: 14, color: colorDorado),
                          SizedBox(width: 6),
                          Text(
                            'Destacado',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorDorado,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Text(
                p.nombre,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: colorTexto,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.descripcion,
                style: const TextStyle(fontSize: 16, color: colorSuave),
              ),
              const SizedBox(height: 16),
              Text(
                soles(p.precio),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: colorDorado,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  dato(CupertinoIcons.archivebox_fill, '${p.stock}', 'Stock',
                      colorPrincipal),
                  const SizedBox(width: 10),
                  dato(
                    p.pocoStock
                        ? CupertinoIcons.exclamationmark_triangle_fill
                        : CupertinoIcons.checkmark_seal_fill,
                    p.pocoStock ? 'Bajo' : 'Óptimo',
                    'Estado',
                    p.pocoStock ? colorAcento : const Color(0xFF2DD4A3),
                  ),
                  const SizedBox(width: 10),
                  dato(CupertinoIcons.money_dollar_circle_fill,
                      '${(p.precio * p.stock / 1000).toStringAsFixed(1)}k',
                      'Valor total', colorDorado),
                ],
              ),
              const SizedBox(height: 8),
              SeccionVidrio(
                titulo: 'INFORMACIÓN',
                children: [
                  CupertinoListTile(
                    leading: IconoIOS(p.icono, p.color),
                    title: const Text('Categoría',
                        style: TextStyle(color: colorTexto)),
                    additionalInfo: Text(p.categoria,
                        style: const TextStyle(color: colorSuave)),
                  ),
                  CupertinoListTile(
                    leading: const IconoIOS(
                        CupertinoIcons.tag_fill, colorAcento),
                    title: const Text('Precio unitario',
                        style: TextStyle(color: colorTexto)),
                    additionalInfo: Text(soles(p.precio),
                        style: const TextStyle(color: colorSuave)),
                  ),
                  CupertinoListTile(
                    leading: const IconoIOS(
                        CupertinoIcons.chart_bar_fill, colorDorado),
                    title: const Text('Valor en inventario',
                        style: TextStyle(color: colorTexto)),
                    additionalInfo: Text(soles(p.precio * p.stock),
                        style: const TextStyle(color: colorSuave)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: eliminar,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: colorAcento.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: colorAcento.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.trash,
                          color: colorAcento, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Eliminar producto',
                        style: TextStyle(
                          color: colorAcento,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// 5. REGISTRAR PRODUCTO (formulario estilo iOS)
// ---------------------------------------------------------------
class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();
  final stockController = TextEditingController();

  Uint8List? fotoBytes;
  String categoria = categorias.keys.first;
  bool destacado = false;

  Future<void> seleccionarImagen() async {
    final bytes = await elegirFoto();
    if (bytes == null || !mounted) return;
    setState(() => fotoBytes = bytes);
  }

  // CupertinoPicker: la "ruedita" de iOS para elegir la categoria
  void elegirCategoria() {
    final opciones = categorias.keys.toList();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 290,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1740),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Elige una categoría',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorTexto,
                      ),
                    ),
                  ),
                  const Spacer(),
                  CupertinoButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Listo',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colorAcento,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 44,
                  scrollController: FixedExtentScrollController(
                    initialItem: opciones.indexOf(categoria),
                  ),
                  onSelectedItemChanged: (i) =>
                      setState(() => categoria = opciones[i]),
                  children: opciones
                      .map(
                        (c) => Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(categorias[c], color: coloresCategoria[c]),
                              const SizedBox(width: 10),
                              Text(
                                c,
                                style: const TextStyle(color: colorTexto),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void guardar() {
    final nombre = nombreController.text.trim();
    final descripcion = descripcionController.text.trim();
    final precio =
        double.tryParse(precioController.text.trim().replaceAll(',', '.'));
    final stock = int.tryParse(stockController.text.trim());

    if (nombre.isEmpty ||
        descripcion.isEmpty ||
        precio == null ||
        precio <= 0 ||
        stock == null ||
        stock < 0) {
      mostrarAlerta(
        context,
        'Datos incompletos',
        'Completa todos los campos con datos válidos.',
      );
      return;
    }

    listaProductos.add(
      Producto(
        nombre: nombre,
        descripcion: descripcion,
        precio: precio,
        stock: stock,
        categoria: categoria,
        destacado: destacado,
        bytes: fotoBytes,
      ),
    );
    notificarCambios(); // avisa a Inicio y Catalogo
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    precioController.dispose();
    stockController.dispose();
    super.dispose();
  }

  // Fila del formulario con texto blanco
  Widget fila(
    TextEditingController controller,
    String etiqueta,
    String ejemplo, {
    TextInputType? teclado,
  }) {
    return CupertinoTextFormFieldRow(
      controller: controller,
      prefix: Text(etiqueta, style: const TextStyle(color: colorTexto)),
      placeholder: ejemplo,
      placeholderStyle: const TextStyle(color: Color(0xFF6E6A93)),
      style: const TextStyle(color: colorTexto),
      cursorColor: colorAcento,
      textAlign: TextAlign.end,
      keyboardType: teclado,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: colorSuave)),
        ),
        middle: const Text('Nuevo producto'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: guardar,
          child: const Text(
            'Guardar',
            style: TextStyle(fontWeight: FontWeight.w700, color: colorAcento),
          ),
        ),
      ),
      child: FondoPremium(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              // Zona para elegir la foto
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: GestureDetector(
                  onTap: seleccionarImagen,
                  child: Container(
                    height: 220,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: vidrioFondo,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: vidrioBorde, width: 1.5),
                    ),
                    child: fotoBytes != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(fotoBytes!, fit: BoxFit.cover),
                              Positioned(
                                right: 14,
                                bottom: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xB30B0A1F),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(CupertinoIcons.camera_fill,
                                          size: 14,
                                          color: CupertinoColors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Cambiar',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: CupertinoColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: degradadoBoton),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorAcento.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  CupertinoIcons.camera_fill,
                                  color: CupertinoColors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Agregar foto del producto',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colorTexto,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Toca para elegir desde tu galería',
                                style:
                                    TextStyle(fontSize: 13, color: colorSuave),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // Formulario agrupado de iOS (estilo vidrio)
              CupertinoFormSection.insetGrouped(
                backgroundColor: const Color(0x00000000),
                decoration: BoxDecoration(
                  color: vidrioFondo,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: vidrioBorde),
                ),
                header: const Text(
                  'DATOS DEL PRODUCTO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorSuave,
                  ),
                ),
                children: [
                  fila(nombreController, 'Nombre', 'Ej. Tablet 10"'),
                  fila(descripcionController, 'Descripción', 'Breve detalle'),
                  fila(
                    precioController,
                    'Precio (S/)',
                    '0.00',
                    teclado:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  fila(stockController, 'Stock', '0',
                      teclado: TextInputType.number),
                ],
              ),

              SeccionVidrio(
                titulo: 'CLASIFICACIÓN',
                children: [
                  CupertinoListTile(
                    leading: IconoIOS(
                      categorias[categoria]!,
                      coloresCategoria[categoria]!,
                    ),
                    title: const Text('Categoría',
                        style: TextStyle(color: colorTexto)),
                    additionalInfo: Text(categoria,
                        style: const TextStyle(color: colorSuave)),
                    trailing: const CupertinoListTileChevron(),
                    onTap: elegirCategoria,
                  ),
                  CupertinoListTile(
                    leading: const IconoIOS(
                        CupertinoIcons.star_fill, colorDorado),
                    title: const Text('Producto destacado',
                        style: TextStyle(color: colorTexto)),
                    trailing: CupertinoSwitch(
                      value: destacado,
                      activeTrackColor: colorAcento,
                      onChanged: (v) => setState(() => destacado = v),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: BotonDegradado(
                  texto: 'Guardar producto',
                  icono: CupertinoIcons.checkmark_alt_circle_fill,
                  onPressed: guardar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------
// 6. PESTANA PERFIL
// ---------------------------------------------------------------
class PerfilTab extends StatefulWidget {
  const PerfilTab({super.key});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  bool notificaciones = true;
  bool alertasStock = true;

  Future<void> cambiarFoto() async {
    final bytes = await elegirFoto();
    if (bytes == null || !mounted) return;
    setState(() => perfil.foto = bytes);
    notificarCambios(); // actualiza el avatar en Inicio
  }

  void editarPerfil() {
    final nombre = TextEditingController(text: perfil.nombre);
    final correo = TextEditingController(text: perfil.correo);
    final telefono = TextEditingController(text: perfil.telefono);

    Widget campo(TextEditingController c, String ph, TextInputType t) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: CupertinoTextField(
          controller: c,
          placeholder: ph,
          keyboardType: t,
          padding: const EdgeInsets.all(10),
        ),
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Editar perfil'),
        content: Column(
          children: [
            campo(nombre, 'Nombre', TextInputType.name),
            campo(correo, 'Email', TextInputType.emailAddress),
            campo(telefono, 'Teléfono', TextInputType.phone),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              setState(() {
                perfil.nombre = nombre.text.trim();
                perfil.correo = correo.text.trim();
                perfil.telefono = telefono.text.trim();
              });
              notificarCambios();
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget numero(String valor, String etiqueta) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colorTexto,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            style: const TextStyle(fontSize: 12, color: colorSuave),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unidades = listaProductos.fold<int>(0, (s, p) => s + p.stock);
    final destacados = listaProductos.where((p) => p.destacado).length;

    return CupertinoPageScaffold(
      child: FondoPremium(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 30),
            children: [
              // Titulo + boton editar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Perfil',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.2,
                          color: colorTexto,
                        ),
                      ),
                    ),
                    BotonVidrio(
                      icono: CupertinoIcons.pencil,
                      onPressed: editarPerfil,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // Foto con boton de camara
              Center(
                child: GestureDetector(
                  onTap: cambiarFoto,
                  child: Stack(
                    children: [
                      const AvatarPerfil(tamano: 124),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            gradient:
                                const LinearGradient(colors: degradadoBoton),
                            shape: BoxShape.circle,
                            border: Border.all(color: colorNoche, width: 3),
                          ),
                          child: const Icon(
                            CupertinoIcons.camera_fill,
                            size: 16,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  perfil.nombre,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: colorTexto,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Center(
                child: Text(
                  perfil.correo,
                  style: const TextStyle(fontSize: 15, color: colorSuave),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: degradadoBoton),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.checkmark_seal_fill,
                          size: 14, color: CupertinoColors.white),
                      const SizedBox(width: 6),
                      Text(
                        perfil.rol,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Resumen en una tarjeta de vidrio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Tarjeta(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      numero('${listaProductos.length}', 'Productos'),
                      Container(width: 1, height: 34, color: vidrioBorde),
                      numero('$unidades', 'Unidades'),
                      Container(width: 1, height: 34, color: vidrioBorde),
                      numero('$destacados', 'Destacados'),
                    ],
                  ),
                ),
              ),

              // Datos del usuario (CupertinoListTile)
              SeccionVidrio(
                titulo: 'INFORMACIÓN PERSONAL',
                children: [
                  CupertinoListTile(
                    leading: const IconoIOS(
                        CupertinoIcons.person_fill, colorPrincipal),
                    title: const Text('Nombre',
                        style: TextStyle(color: colorTexto)),
                    additionalInfo: Text(perfil.nombre,
                        style: const TextStyle(color: colorSuave)),
                  ),
                  CupertinoListTile(
                    leading: const IconoIOS(
                        CupertinoIcons.mail_solid, Color(0xFF22B8F0)),
                    title: const Text('Email',
                        style: TextStyle(color: colorTexto)),
                    additionalInfo: Text(perfil.correo,
                        style: const TextStyle(color: colorSuave)),
                  ),
                  CupertinoListTile(
                    leading: const IconoIOS(
                        CupertinoIcons.phone_fill, Color(0xFF2DD4A3)),
                    title: const Text('Teléfono',
                        style: TextStyle(color: colorTexto)),
                    additionalInfo: Text(perfil.telefono,
                        style: const TextStyle(color: colorSuave)),
                  ),
                  CupertinoListTile(
                    leading: const IconoIOS(
                        CupertinoIcons.shield_fill, colorDorado),
                    title: const Text('Rol',
                        style: TextStyle(color: colorTexto)),
                    additionalInfo: Text(perfil.rol,
                        style: const TextStyle(color: colorSuave)),
                  ),
                ],
              ),

              // Preferencias con CupertinoSwitch
              SeccionVidrio(
                titulo: 'PREFERENCIAS',
                children: [
                  CupertinoListTile(
                    leading:
                        const IconoIOS(CupertinoIcons.bell_fill, colorAcento),
                    title: const Text('Notificaciones',
                        style: TextStyle(color: colorTexto)),
                    trailing: CupertinoSwitch(
                      value: notificaciones,
                      activeTrackColor: colorAcento,
                      onChanged: (v) => setState(() => notificaciones = v),
                    ),
                  ),
                  CupertinoListTile(
                    leading: const IconoIOS(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      colorDorado,
                    ),
                    title: const Text('Alertas de poco stock',
                        style: TextStyle(color: colorTexto)),
                    trailing: CupertinoSwitch(
                      value: alertasStock,
                      activeTrackColor: colorAcento,
                      onChanged: (v) => setState(() => alertasStock = v),
                    ),
                  ),
                ],
              ),

              // Cerrar sesion
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => confirmarCerrarSesion(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: colorAcento.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorAcento.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.power,
                            color: colorAcento, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: colorAcento,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}