# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
### Changed
### Removed

## 0.3.1
### Added
### Changed
- Make the S3 URL matcher work with all types of prefixes.
- Fix the override for the Ruby Docker image latest tag.
### Removed

## 0.3.0
### Added
- AWS SDK for S3 as a dependency.
### Changed
- Downloading the sequencer file is now done using Ruby.
- Reading the YAML file is not required anymore by the process.
### Removed
- Remove the aws-cli as a dependency of the Docker image.

## 0.2.8
### Added
### Changed
- Rename the sequencer file in entrypoint to `sequencer.yml`
### Removed

## 0.2.7
### Added
### Changed
- Normalize the Docker image tags to `latest-jruby/ruby` and `vX.X.X-jruby/ruby`
### Removed

## 0.2.6
### Added
### Changed
### Removed
- Remove the `github-script` action.

## 0.2.5
### Added
### Changed
- Multiple workflow changese to make it work.
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
