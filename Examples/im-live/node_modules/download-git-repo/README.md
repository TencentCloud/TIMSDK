# download-git-repo

Download and extract a git repository (GitHub, GitLab, Bitbucket) from node.

## Installation

    $ npm install download-git-repo

## API

### download(repository, destination, options, callback)

Download a git `repository` to a `destination` folder with `options`, and `callback`.

#### repository
The shorthand repository string to download the repository from:

- **GitHub** - `github:owner/name` or simply `owner/name`
- **GitLab** - `gitlab:owner/name`
- **Bitbucket** - `bitbucket:owner/name`

The `repository` parameter defaults to the `master` branch, but you can specify a branch or tag as a URL fragment like `owner/name#my-branch`.
In addition to specifying the type of where to download, you can also specify a custom origin like `gitlab:custom.com:owner/name`.
Custom origin will default to `https` or `git@` for http and clone downloads respectively, unless protocol is specified.
Feel free to submit an issue or pull request for additional origin options.

In addition to having the shorthand for supported git hosts, you can also hit a repository directly with:

- **Direct** - `direct:url`

This will bypass the shorthand normalizer and pass `url` directly.
If using `direct` without clone, you must pass the full url to the zip file, including paths to branches if needed.
If using `direct` with clone, you must pass the full url to the git repo and you can specify a branch like `direct:url#my-branch`.

#### destination
The file path to download the repository to.

#### options
An optional options object parameter with download options. Options include:

- `clone` - boolean default `false` - If true use `git clone` instead of an http download. While this can be a bit slower, it does allow private repositories to be used if the appropriate SSH keys are setup.

#### callback
The callback function as `function (err)`.

## Examples
### Shorthand
Using http download from Github repository at master.
```javascript
download('flipxfx/download-git-repo-fixture', 'test/tmp', function (err) {
  console.log(err ? 'Error' : 'Success')
})
```

Using git clone from Bitbucket repository at my-branch.
```javascript
download('bitbucket:flipxfx/download-git-repo-fixture#my-branch', 'test/tmp', { clone: true }, function (err) {
  console.log(err ? 'Error' : 'Success')
})
```

Using http download from GitLab repository with custom origin.
```javascript
download('gitlab:mygitlab.com:flipxfx/download-git-repo-fixture#my-branch', 'test/tmp', function (err) {
  console.log(err ? 'Error' : 'Success')
})
```

Using git clone from GitLab repository with custom origin and protocol.
Note that the repository type (`github`, `gitlab` etc.) is not required if cloning from a custom origin.
```javascript
download('https://mygitlab.com:flipxfx/download-git-repo-fixture#my-branch', 'test/tmp', { clone: true }, function (err) {
  console.log(err ? 'Error' : 'Success')
})
```

### Direct
Using http download from direct url.
```javascript
download('direct:https://gitlab.com/flipxfx/download-git-repo-fixture/repository/archive.zip', 'test/tmp', function (err) {
  console.log(err ? 'Error' : 'Success')
})
```

Using git clone from direct url at master.
```javascript
download('direct:https://gitlab.com/flipxfx/download-git-repo-fixture.git', 'test/tmp', { clone: true }, function (err) {
  console.log(err ? 'Error' : 'Success')
})
```

Using git clone from direct url at my-branch.
```javascript
download('direct:https://gitlab.com/flipxfx/download-git-repo-fixture.git#my-branch', 'test/tmp', { clone: true }, function (err) {
  console.log(err ? 'Error' : 'Success')
})
```

## License

MIT

