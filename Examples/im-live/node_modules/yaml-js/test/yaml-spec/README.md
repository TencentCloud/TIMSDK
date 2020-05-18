# YAML Spec

YAML spec seeks to provide a standardised suite of tests for YAML.

## ./spec.json

This file provides YAML inputs and expected JSON equivalents for host-language independent aspects
of YAML.  In particular the aspects tested are:

- comments
- document start + end
- basic ints, floats, booleans, nulls and strings
- sequences (inline and block)
- mappings (inline and block)
- non-recursive anchors and aliases
- string formatting modes

An implementation passing these tests would likely be suitable for parsing many YAML files that
don't use more 'advanced' features such as user-defined tags, recursive structures, etc.

## ./platform

This folder contains language-specific `spec.ext` files for different platforms.

# Contributing

If you want to add to the specs or add platform-specific specs, don't hesitate to drop a pull
request.

# License

WTFPL (http://sam.zoy.org/wtfpl/)