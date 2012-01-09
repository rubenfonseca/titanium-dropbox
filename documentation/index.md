# dropbox Module

## Description

This is a Titanium Mobile module for iOS (iPhone/iPad)
that allows to use the full power of the official Dropbox SDK 
on a Titanium project.

The official Dropbox SDK can be found
[here](https://www.dropbox.com/developers/releases).

## Basic installation instructions

Please follow the guide available [here](http://wiki.appcelerator.org/display/tis/Using+Titanium+Modules).

Also, please follow the additional instructions below.

## Changelog

See [here](changelog.html)

## Accessing the dropbox Module

To access this module from JavaScript, you would do the following:

	var dropbox = require("com.0x82.dropbox");

The dropbox variable is a reference to the Module object.	

## Additional Installation instructions (VERY IMPORTANT)

As for version 1.0 of this module, you are required to do these steps in
order for this module to work. Since the new Dropbox SDK 1.0 was released,
the only way of authenticating the user is to use an external application
(either the Dropbox app, or the browser).

That required us to set a proper UrlScheme, so the browser or the Dropbox
application can then came back to our application, after we finish the auth 
phase. To do that on the iPhone, you have to change the Info.plist file on
your build directory. Unfortunately, at this moment, it is not possible to 
change the file automatically, so you always have to do this step by hand.
This is a limitation of Titanium and I'm working with them to solve this 
problem.

### First step: generate a app key and secret

Go to the website https://www.dropbox.com/developers and generate a new 
application. Save the application key.

### Manually edit the Info.plist file

Open the `build/iphone/Info.plist` on Finder. It will probably open the file
in XCode or something.

Open the "URL Types" -> "Item 0" -> "URL Schemes" path. You should have an
"Item 0" String entry with the name of your application. Add a new item "Item 1"
with the following format "db-YOUR_API_KEY".

You can see the result on the following screenshot:

![Screenshot](http://f.cl.ly/items/30363R3R393g1L1B3r37/Screen%20Shot%202011-10-26%20at%2016.51.33.png)

### You are ready to go! 

Please notice that if you change your api credentials, you must go to your 
Info.plist file again and change the api-key on your URL Schemes.

*HOWVER*, if after you first edit the `Info.plist` file, you copy the file to the
root directory of your project, Titanium will automatically pickup the file
everytime the app is compiled! So you will never have to edit the file again!

## Reference

Here's the module API.

### dropbox.createSession({...})

Created and returns a [com.0x82.dropbox.Session](session.html) object, which is a proxy.

Takes one argument, a dictionary containing the following properties:

- key[string]: the dropbox developer application key
- secret[string]: the dropbox developer application secret
- root[string]: the level of access you want to ask. Valid options are
  `dropbox.DROPBOX_ROOT_APP_FOLDER` or `dropbox.DROPBOX_ROOT_DROPBOX`.

## Usage

Please see the examples/app.js for a full app example.

## Author

Ruben Fonseca, root (at) cpan (dot) org

You can also find me on [github](http://github.com/rubenfonseca) and on my
[blog](http://blog.0x82.com)

## License

This module is licensed under the MIT License. Please see the LICENSE file for
details
