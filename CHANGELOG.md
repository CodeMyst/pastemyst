# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

- [2.0] Logging in with GitHub.
- [2.0] Logging out.
- [2.0] Making an account on first login with GitHub.
- [2.0] Displaying currently logged in user's username.
- [2.0] Creating pastes with a title
- [2.0] Creating account pastes.
- [2.0] Displaying all of user's paste on their profile page.
- [2.0] Displaying when a paste expires in the paste list.
- [2.0] CHANGELOG.md.

### Changed

- [2.0] Split REST and web interfaces into separate modules.
- [2.0] Moved DB stuff into its own module.
- [2.0] Using explicit access modifiers.

### Fixed

- [1.6.2] Tab size is set to 4.

### Removed

- [2.0] Unit tests (will be back).

## [1.6.1] - 2019-02-04

### Changed

- The PasteMyst content code now has a smaller font on mobile devices so you can see more at the same time.

### Fixed

- The "Expires In" and "Language" dropdowns are properly laid out on mobile devices.

## [1.6] - 2019-02-01

### Added

- Showing the current version in the page navigation (and with a link to the changelog).

### Changed

- Better language detection (using [shaman](https://github.com/Prev/shaman)).
- Ability to manually specify the language (web and api). Some notes about it:
  - The default is autodetect, but you can select from the dropdown more languages.
  - Autodetect won't change the editor's syntax highlighting.
  - If the selected language isn't supported in the editor then the editor will display as plain text.
  - The language selector isn't removed when the plain editor is used. This is of course because the language isn't used just for the editor but for the language of the paste.

## [1.5] - 2019-01-08

### Added

- Displaying when the paste expires (only displays it if the paste expires and isn't set to "never").

### Changed

- Shorter links (example link: https://paste.myst.rs/ynq, old pastes with the old URL and ID can still be accessed).

### Fixed

- The plain text editor isn't re-sizable anymore.

## [1.4] - 2018-12-20

### Added

- Simple plain text editor (default on phones).
- Unit tests.

### Changed

- Using Ubuntu Mono in the monaco editor.

### Fixed

- Code is now wrapping.
- Using specific dbc version (1.1.8).
- Using absolute paths for styles, scripts, etc.
- SEO titles (API Docs title wasn't working since isn't able to override the regular title).

### Removed

- Google reCAPTCHA.

## [1.3] - 2018-11-19

### Added

- Clicking the page title redirects to the home page.
- Indexing by search engines.
- Displaying number of PasteMysts in the footer.

### Changed

- Paste page styling.
  - Easier to distinguish the paste content from the rest of the page.
  - Title and navigation combined into one codeblock.
  - Moved id and createdAt info to the bottom.

### Fixed

- Copyright symbol in footer isn't so small anymore.

## [1.2] - 2018-11-12

### Added

- SEO.
- Footer.
- Responsive and works better on mobile.

### Changed

- Using Ubuntu Mono inside code blocks.

### Fixed

- Quitting the app will now stop the expired paste deletion task immediately.

# [1.1] - 2018-11-10

### Added

- Able to set when a paste expires.

# [1.0] - 2018-11-08

### Added

- This is a lightweight and simple website for pasting text. Main purpose is for sharing and storing code snippets.

[Unreleased]: https://github.com/codemyst/pastemyst/compare/1.6.1...HEAD
[1.1]: https://github.com/codemyst/pastemyst/compare/1.0...1.1
[1.2]: https://github.com/codemyst/pastemyst/compare/1.1...1.2
[1.3]: https://github.com/codemyst/pastemyst/compare/1.2...1.3
[1.4]: https://github.com/codemyst/pastemyst/compare/1.3...1.4
[1.5]: https://github.com/codemyst/pastemyst/compare/1.4...1.5
[1.6]: https://github.com/codemyst/pastemyst/compare/1.5...1.6
[1.6.1]: https://github.com/codemyst/pastemyst/compare/1.6...1.6.1