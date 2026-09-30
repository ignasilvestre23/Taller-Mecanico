# Taller Mecánico – Flutter + Riverpod

Módulos: Resumen, Órdenes de trabajo (repuestos, mano de obra, total, estados), Clientes, Vehículos (con historial),
Repuestos/Stock (alerta de stock bajo, descuento automático), Turnos, Auditoría y Seguridad (login/enrolamiento facial).

## Puesta en marcha
```bash
flutter create --org com.taller --project-name taller_app .
flutter pub get
flutter run
```
**Modelo facial (obligatorio):** descargá un MobileFaceNet `.tflite` (entrada 112×112×3, salida = embedding) y guardalo como
`assets/models/mobilefacenet.tflite`. Sin ese archivo el login/registro facial falla. Ajustá `kThreshold` (`face_service.dart`).

**Permisos**
- Android: `<uses-permission android:name="android.permission.CAMERA"/>` y `minSdk = 26` en `android/app/build.gradle(.kts)`.
- iOS: `NSCameraUsageDescription` en `Info.plist`; iOS 15.5+.

## Backend (`lib/config.dart` → `backend`)
- `memory`: sin servidor, datos se pierden al cerrar.
- `rest`: usá json-server para probar: crear `db.json` con
  `{"clientes":[],"vehiculos":[],"repuestos":[],"ordenes":[],"turnos":[]}` y correr `npx json-server db.json --host 0.0.0.0 --port 3000`.
  Contrato: `GET /col`, `PUT /col/:id`, `POST /col`, `DELETE /col/:id`. Ajustá `restBaseUrl`.
- `firebase`: `dart pub global activate flutterfire_cli && flutterfire configure`, habilitar Firestore y agregar
  `google-services.json`. Las colecciones se crean solas. Configurá reglas de seguridad antes de producción.

## Pendiente / a tener en cuenta
- PIN fijo `1234` y usuario único: falta autenticación real (Firebase Auth o login del backend) y roles.
- Anti-spoofing: parpadeo/sonrisa no frena deepfakes ni videos; requiere un modelo específico.
- La auditoría está en memoria; persistirla en el backend si se necesita trazabilidad legal.
- Los datos del backend no están cifrados por la app; depender de HTTPS y reglas del servidor.
