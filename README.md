# Galeria de Aves - AvesCL

Aplicacion movil en Flutter para registrar, publicar y moderar avistamientos
fotograficos de aves chilenas.

## Avance para Evaluacion 2

- Vistas implementadas: Inicio, Login, Galeria, Comunidad, Reportes y Perfil.
- Navegacion funcional mediante barra inferior.
- Formularios funcionales para iniciar sesion, registrar fotos, publicar en
  comunidad, reportar contenido y crear reportes manuales.
- Persistencia local inicial: los datos se guardan en un archivo JSON dentro de
  la carpeta de documentos de la app.
- Persistencia de fotos: las imagenes seleccionadas se copian a una carpeta
  interna de la app antes de guardarse en la galeria.
- Galeria como eje principal de la app: las fotos subidas quedan guardadas en la
  bitacora personal y pueden abrirse para ver detalle del ave, lugar, fecha,
  certeza y notas. Tambien pueden eliminarse cuando el usuario ya no quiera
  conservarlas.
- Comunidad separada de la galeria personal: funciona como espacio para crear
  eventos o competencias fotograficas con participantes y likes. Cada usuario
  puede dar like y participar solo una vez por evento.
- Ave del dia seleccionada desde los registros guardados en Galeria, con
  rotacion diaria para evitar repetir la misma ave dos dias seguidos cuando sea
  posible.
- Reportes funcionales: los reportes creados desde Comunidad aparecen en el
  centro de moderacion, pueden filtrarse y cambiar de estado.

## Manejo inicial de datos

El servicio `AppDataService` centraliza los datos de la app:

- `bird_records`: registros de aves y borradores.
- `community_events`: eventos y competencias de Comunidad.
- `community_posts`: estructura reservada para futuras publicaciones sociales.
- `moderation_reports`: reportes y estado de moderacion.

Actualmente se usa almacenamiento local para que la app funcione sin depender de
credenciales externas durante la evaluacion. La estructura de datos ya queda
preparada para migrar a Firebase Firestore y Firebase Storage.

## Plan Firebase

Cuando exista un proyecto Firebase configurado, el siguiente paso es agregar:

- `firebase_core`
- `cloud_firestore`
- `firebase_storage`

Luego se reemplaza el guardado local de `AppDataService` por:

- Firestore para registros, eventos de comunidad y reportes.
- Firebase Storage para subir imagenes.
- Campo `imageUrl` en vez de `imagePath` local.

## Verificacion

- `flutter pub get`
- `flutter analyze`
- `flutter build apk --debug`
