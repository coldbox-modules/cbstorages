# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

* * *

## [Unreleased]

## [3.4.0] - 2025-05-09

### Added

- `getSessionKey()` is now part of the storage interface and each storage can override it as it exists in the `AbstractStorage` class. This allows for a more consistent way of getting the session key for each storage.

## [3.3.0] - 2025-02-20

### Fixed

- Default the new `encryptionKey` setting due to non deep overrides

## [3.2.0] - 2025-02-19

### Changed

- ColdBox 6 auto-testing, as it has entered security fixes phase now.

### Added

- Harder encryption to AES for the `CookieStorage`
- New `CookieStorage` setting `encryptionKey` to allow for a custom encryption key for the cookie value
- BoxLang certification
- Adobe 2023 certification

## [3.1.0] - 2024-03-11

### Added

- Github actions updates
- Github support files
- Contribution guidelines
- Adobe 2023 builds
- Lucee 6 builds

### Fixed

- Consolidated `lockNames` so there are no missing ones used by the abstract cache.

* * *

## [3.0.1] => 2023-MAR-27

### Fixed

- Cookie is being set twice.  Appears twice in response headers, one of them does not have the attributes (only the value)

## [3.0.0] => 2022-OCT-4

### Added

- New ortus module support

### Changed

- Removed ACF 2016 support

## [2.6.1] => 2021-JUL-23

### Fixed

- Added params to the cache storage settings to avoid missing setting exceptions

## [2.6.0] => 2021-JUL-22

### Added

- New setting for `cacheStorage` : `identifierProvider` which can be a closure/lambda/udf that returns a unique tracking identifier for user requests.
- Improved session detection and fallback to request tracking if no session/cookie/url tracking is discovered thanks to @elpete : <https://github.com/coldbox-modules/cbstorages/pull/15/files>
- Migration to github actions for CI process
- Adobe 2021 automated support

## [2.5.0] => 2021-APR-01

- Added `sameSite` argument to setting cookies

## [2.4.0] => 2020-NOV-30

### Added

- Set `expires` is not defaulted to 0 which eliminates the cookie. It is now expiring as it should using the browser session as the key indicator.

## [2.3.0] => 2020-NOV-13

### Added

- Changelog publishing
- Refactored lock timeouts to be part of the `AbstractStorage` thanks to @wpdebruin

### Fixed

- Invalid argument when using `getOrSet` thanks to @wpdebruin
- Apply cookies in reverse order so the one with all the attributes is last and is persisted by Eric Peterson [eric@elpete.com](mailto:eric@elpete.com)

## [2.2.0] => 2020-JUL-09

### Added

- New module layouts and helpers
- Github auto release notes publishing
- More formatting goodness
- New Changelogs
- [BOX-77] Add CGI scope wrapper to cbStorages

## [2.1.0] => 2020-FEB-03

- `improvement` : Remove `numeric` typing on `expiry` for CookieStorage: The numeric typing on the expires argument will still allow a date object to pass through ( strangely ), but prevents the pass through of the textual arguments allowed by CFCookie: <https://helpx.adobe.com/coldfusion/cfml-reference/coldfusion-tags/tags-c/cfcookie.html>
- `improvement` : Added formatting and linting scripts
- `bug` : Fixed `toMaster` script so it could pull master incase of divergence

## [2.0.1]

- `bug` : [CCM-54](https://ortussolutions.atlassian.net/browse/CCM-54) - Left over bug on session storage looking at app storage

## [2.0.0]

- `feature` : All storages now implement a common interface : `IStorage`
- `feature` : New interface brings new storageWide methods: `setMulti(), getOrSet(), getMulti(), deleteMulti(), getSize(), getkeys(), isEmpty()`
- `feature,compat` : ColdBox 4/5 approach to settings instead of in the root, in the `moduleSettings`
- `improvement,compat` : All tag based default values where named `default` but renamed to `defaultValue` to have consistency.
- `improvement` : Dropped Lucee4.5 and ACF11 support
- `improvement` : Script migrations
- `feature` : Added support for httpOnly and secure cookies in the cookie storage.
- `improvement` : Added option to specify path when deleting a cookie. Without this option, the cookie is never deleted when specifying a path when creating a cookie. <https://github.com/coldbox-modules/cbstorages/pull/7> (@donbellamy)
- `improvement` : TestBox 3 upgrade
- `improvement` : Mark all storages as `serializable=false` to avoid serialization issues
- `compat` : Removed `ClusterStorage` as this was a lucee only feature that actually never released.
- `compat` : The following methods have been renamed: `setVar() => set()`, `getVar() => get()`, and `deleteVar() => delete()`

## [1.5.0]

- Update new template approach
- Renamed repo
- Change `getSessionKey` to public method: <https://github.com/coldbox-modules/cbox-storages/pull/6>

## [1.4.0]

- Updated to leverage workbench module template
- Remove useless entry points thanks to @tropicalista
- Make default cache for `CacheStorage` to be the `template` cache instead of `default`

## [1.3.0]

- Updated API docs with a syntax typo
- New `RequestStorage` thanks to Dan Murphy
- Updated travis process for self-publishing

## [1.2.0]

- Update build process
- Updated dependencies
- Added new storage: `CacheStorage` to allow you to simulate session/client on a distributed cache via CacheBox.

## [1.1.0]

- Travis integration
- DocBox updates
- Build process updates

## [1.0.0]

- Create first module version

[unreleased]: https://github.com/coldbox-modules/cbstorages/compare/v3.4.0...HEAD
[3.4.0]: https://github.com/coldbox-modules/cbstorages/compare/v3.3.0...v3.4.0
[3.3.0]: https://github.com/coldbox-modules/cbstorages/compare/v3.2.0...v3.3.0
[3.2.0]: https://github.com/coldbox-modules/cbstorages/compare/v3.1.0...v3.2.0
[3.1.0]: https://github.com/coldbox-modules/cbstorages/compare/9b01af208b6c582715b2dd02ce9678e3a6ea1532...v3.1.0
