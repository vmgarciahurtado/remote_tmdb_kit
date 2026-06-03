## 1.0.0

* **Initial Release**: Complete extraction of TMDB API client.
* **Flat Library Architecture**: Flat codebase within `lib/src/` for ease of maintenance.
* **Result Wrapper**: Implemented functional `Result<T>` with `Success` and `FailureResult` states.
* **Custom Failures**: Structured exceptions (`ConnectionFailure`, `ServerFailure`, `NotFoundFailure`, `UnauthorizedFailure`, `UnexpectedFailure`) that provide clean, localized user messages.
* **HTTP Client Abstraction**: Decoupled `HttpService` interface with `DioHttpService` as the default engine, leaving it open to customization.
* **Movie & Actor Entities**: Clean data classes (`Movie`, `Actor`) mapping TMDB results.
* **Zero Testing Dependencies**: High-coverage unit tests utilizing hand-written `Fake` classes instead of mocking frameworks.
