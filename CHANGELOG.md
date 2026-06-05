## 1.0.0

* **Initial Release**: Extracción completa de la lógica de conexión a la API de TMDB en un paquete desacoplado.
* **Estructura Organizada en Subcarpetas**: Migración del código interno (`lib/src/`) a subcarpetas especializadas por responsabilidad (`errors`, `result`, `network`, `models`, `dtos`, `mappers`, `services`, `repositories`).
* **Comentarios Dartdoc con Ejemplos (IDE Hover)**: Documentación de toda la interfaz pública (`MovieRepository`, `Movie`, `Actor`, `MovieSearchFilter`, `Result`, `Failure`) con explicaciones detalladas y ejemplos de uso prácticos para visualización directa en el editor al pasar el cursor (hover).
* **Parámetro `enableLogging` configurable**: Añadido parámetro opcional `enableLogging` en el constructor de factoría `MovieRepository.create`, configurado como **`false` por defecto**.
* **Filtros Avanzados (`MovieSearchFilter`)**: Nueva clase inmutable para configurar filtros avanzados de búsqueda de películas en la API de TMDB (idioma, año, clasificado para adultos, etc.).
* **Aislamiento del Cliente HTTP**: Interfaz `HttpService` independiente, permitiendo inyectar clientes HTTP personalizados (por ejemplo, basados en el paquete nativo `http`).
* **Entidades Fuertemente Tipadas**: Retorno de objetos limpios e inmutables `Movie` y `Actor` listos para ser consumidos en UI.
* **Result y Fallas Personalizadas**: Manejo de errores funcional mediante `Result<T>` (`Success` / `FailureResult`) que aíslan al usuario de estados HTTP crudos.
* **Zero Testing Dependencies**: Pruebas unitarias robustas utilizando Fakes escritos a mano, sin dependencias de `mocktail` o `mockito`.
