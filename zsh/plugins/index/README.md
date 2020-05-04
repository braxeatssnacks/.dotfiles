## The Indexables

Adds indexing to shell listed outputs with `<Tab>` completion.

Meant to be a lightweight replacement for `scm_breeze`-esque operations without being so opinionated.

### Repository Index

Configure your cloned projects directory with the `$GIT_REPO_DIR` environment variable. If unset, it will default to `~/Projects`.

Quickly jump to the cloned repostiories in your `$GIT_REPO_DIR` directory with the `c` command.

**Usage**

Assuming I have cloned the repository `foo` within the root of my repository index, I could type the following command `c f<Enter>` and would expect to jump to `~/Projects/foo`.

It also supports tab completion!

Thanks to [@sblask](https://github.com/sblask) for his [article on his own SCM breeze replacement](https://sblask.github.io/blog/tech/2017/04/10/migrating-away-from-scm-breeze.html) which I used as a basis.
