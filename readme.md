# app.jpserquina.com
## Portfolio demos and sandbox for CI backend

### Features
* has its own easy-to-deploy vagrant instance
* allows for xdebug tracing
* demoes switching between third-party vendor backends purely via config change only - no need to hardcode new methods
* exposes various helper and template modules for headless CMS
* uses a service layer in CI for reusable and abstracted methods for business logic and data access

###### * Forked from [jeremyvaught/CodeIgniter-Service-Level](https://github.com/jeremyvaught/CodeIgniter-Service-Level). Original readme.md [here](https://github.com/jeremyvaught/CodeIgniter-Service-Level/blob/master/readme.md)
###### * Uses [nltbinh/codeigniter-service-layer](https://github.com/nltbinh/codeigniter-service-layer) via composer.
###### * Uses the `mywind` Northwind test DB: [dalers/mywind](https://github.com/dalers/mywind)
###### * Uses a modified vagrant deploy from [Dave Amatulli](xojins@gmail.com)
###### * Uses CI 2.2.1 patch: [bcit-ci/CodeIgniter/commit/69b02d0](https://github.com/bcit-ci/CodeIgniter/commit/69b02d0f0bc46e914bed1604cfbd9bf74286b2e3)