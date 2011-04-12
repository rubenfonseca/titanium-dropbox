# dropbox Module

## Description

This is a Titanium Mobile module for iOS (iPhone/iPad)
that allows to use the full power of the official Dropbox SDK 
on a Titanium project.

The official Dropbox SDK can be found
[here](https://www.dropbox.com/developers/releases).

## Accessing the dropbox Module

To access this module from JavaScript, you would do the following:

	var dropbox = require("com.0x82.dropbox");

The dropbox variable is a reference to the Module object.	

## Reference

Here's the module API.

### dropbox.createSession({...})

Created and returns a [com.0x82.dropbox.Session](session.html) object, which is a proxy.

Takes one argument, a dictionary containing the following properties:

key[string]: the dropbox developer application key <br/>
secret[string]: the dropbox developer application secret

## Usage

Please see the examples/app.js for a full app example.

## Author

Ruben Fonseca, root (at) cpan (dot) org

You can also find me on [github](http://github.com/rubenfonseca) and on my
[blog](http://blog.0x82.com)

## License

This module is licensed under the MIT License. Please see the LICENSE file for
details
