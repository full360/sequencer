# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Removed

## 0.2.0
### Added
- Add Docker image for Ruby and JRuby that will get triggered after the release.
### Changed
- Refactor the code to make it easier to read and modify.
- Update the AWS SDK for ECS to V3.
- Fix a missing logger dependency in the bin/sequencer code.
### Removed
- Tests for Ruby 3.0 as they were failing for an unknown reason and I couldn't
  reproduce locally.

## 0.1.3
### Added
- Fix release workflow.
### Changed
### Removed

## 0.1.2
### Added
- Fix release workflow.
### Changed
### Removed

## 0.1.1
### Added
- Workflows dependable.
### Changed
### Removed

## 0.1.0
### Added
- Working GitHub Actions workflow for tests and releases.
- Add Gemfile to the Gem.
### Changed
- Update the .gemspec file and dependencies.
- Update the gem file format.
- Change from single quote to double quotes.
- Fix deprecation warnings in tests
### Removed

## 0.0.7
### Added
- Working version.
### Changed
### Removed
