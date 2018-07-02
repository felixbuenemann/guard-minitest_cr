## How to release a new version of guard-minitest

### During the development of the next release

1. If you don't have a release notes draft, create one at [https://github.com/felixbuenemann/guard-minitest\_cr/releases/new](https://github.com/felixbuenemann/guard-minitest_cr/releases/new) (the version should be set to `vX.Y.Z+1` for now).
1. Each time you merge a pull-request (or fix an issue, or simply push a change that should appear in the release note), update the release notes draft and keep the style consistent with previous release notes:
```markdown
### Bug fix ("Bug fixes" if there are several bug fixes, see below...)

* #XXX, #YYY Title of the pull-request/issue or any meaningful text.

### New features

* #ZZZ Title of the pull-request/issue or any meaningful text.
* owe89wq There's no issue/PR attached to this new feature (bad!), but a commit is referenced on the left.

### Improvement

* as65dah This improvement has been done in the commit referenced on the left.
```

Note that there's no need to mention the author of each change since they can be retrieved either from the issue/PR or from the actual commit.

### Once you're ready to release the next version

1. [Check that the specs pass](https://travis-ci.org/felixbuenemann/guard-minitest_cr).
2. Look at the release notes draft and update its version accordingly:
    - If there's new features, increment minor digit and reset patch digit, e.g. `vX.Y+1.0`.
    - If there's new features that break retro-compatibility, increment major digit and reset minor & patch digits, e.g. `vX+1.0.0`.
    - See [SemVer](http://semver.org) when in doubts.
3. Then, update the version of the gem accordingly too, in `lib/guard/minitestcr/version.rb`.
4. Commit `Bump to X.Y.Z` and push to GitHub.
5. Run the magic rake task: `bundle exec rake release`. This will push the gem to Rubygems.
6. Update and publish the GitHub release notes!
7. Congratulate yourself and enjoy a fresh beer, you deserve it!
