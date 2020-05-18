require('plantation')
  mocha:
    R: 'dot'

path    = require 'path'
{spawn} = require 'child_process'

task 'build:browser', 'Builds compressed and uncompressed browser-compatible files', ->
  squash_dir = path.join __dirname, 'node_modules', 'squash'
  squash_bin = path.resolve squash_dir, require('squash/package').bin.squash

  spawn process.execPath, [ squash_bin, '--coffee', '-f', 'yaml.js', '-o', '-r', './=yaml' ], customFds: [ 0, 1, 2 ]
  spawn process.execPath, [ squash_bin, '--coffee', '-c', '-f', 'yaml.min.js', '-o', '-r', './=yaml' ], customFds: [ 0, 1, 2 ]