enum BackendType { memory, firebase, rest }

/// Cambiar acá el backend. memory = sin servidor (datos se pierden al cerrar).
const backend = BackendType.memory;

/// 10.0.2.2 = localhost del PC visto desde el emulador Android. En celular real usar la IP del PC.
const restBaseUrl = 'http://10.0.2.2:3000';
