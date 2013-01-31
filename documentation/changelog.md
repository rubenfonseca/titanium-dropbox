- 2013-01-28 Ruben Fonseca <fonseka@gmail.com>

    * version 2.4 released

    * moved to the latest Dropbox SDK to fix a bug with huge uploads

- 2012-11-03 Ruben Fonseca <fonseka@gmail.com>

    * verison 2.3 released

    * added a new loadDelta({..}) call

    * moved to latest Dropbox SDK (1.3.2)

- 2012-09-04 Ruben Fonseca <fonseka@gmail.com>

    * version 2.2 released

    * fix a problem when showing the Dropbox login screen on a Modal window

- 2012-08-23 Ruben Fonseca <fonseka@gmail.com>

    * version 2.1 released

    * fixed a problem where the 'cancel' callback would not work on
      the session login phase

    * fixed a problem where the interface automaticly rotates to Portrait
      when using the external Dropbox.app to authenticate

- 2012-08-02 Ruben Fonseca <fonseka@gmail.com>

    * version 2.0 released

    * dropped compatibility with older Titanium < 2.0.0 SDKs

    * added `createCopyRef` method to create copy_ref from files

    * added support for copying from copy_ref to the `copyPath` method

    * see the updated documentation and example to see how it works

- 2012-05-23 Ruben Fonseca <fonseka@gmail.com>

    * version 1.9 released

    * upgraded to official Dropbox SDK 1.2.2. Authentication now happens
      inside an ambedded web view if the Dropbox app is not installed. You
      don't have to change anything on your code for this to work

- 2012-05-04 Ruben Fonseca <fonseka@gmail.com>

    * verison 1.8 released

    * VERY IMPORTANT UPDATE: without this version your next version of your app
      will probably be rejected by App Store, because of rule "11.13"

      More info here: http://tinyurl.com/7ckb659

- 2012-04-04 Ruben Fonseca <fonseka@gmail.com>

    * version 1.7 released

    * fixed some compilation errors on SDK 1.8.2

- 2012-01-23 Ruben Fonseca <fonseka@gmail.com>

    * version 1.6 released

    * added searchPath, sharePath, getStreamableURL
      see the new documentation on the clientproxy, and the new items on the
      example/app.js file

- 2012-01-09 Ruben Fonseca <fonseka@gmail.com>
  
    * version 1.5 released

    * no code changes, just better documentation

- 2011-12-05 Ruben Fonseca <fonseka@gmail.com>

    * version 1.4 released

    * fixed a bug on loadMetadata when there we nested directiories

- 2011-11-06 Ruben Fonseca <fonseka@gmail.com>

    * version 1.2 released

    * make the Changelog available on the documentation

- 2011-11-03 Ruben Fonseca <fonseka@gmail.com>

    * version 1.1 released

    * added option to overwrite file when using the uploadFile method

    * when a file is successfully uploaded, the new metadata is now 
		  returned on the success callback

- 2011-10-26 Ruben Fonseca <fonseka@gmail.com>

    * version 1.0 released, based on the official Dropbox SDK 1.0

    * THIS IS A NEW GENERATION OF THE MODULE!!!! PLEASE DON'T UPGRADE UNLESS
		  YOU READ AND UNDERSTAND THE documentation/index.html FILE!

    * There are no major changes on the API, but the steps necessary to make
		  the app work are VERY VERY VERY DIFFERENT!

- 2011-10-24 Ruben Fonseca <fonseka@gmail.com>

    * version 0.7 released

    * fixes a bug where it's not possible to dismiss the Login window
		  on the new iOS 5 devices. Aparently, iOS 5 the API of accessing
		  the parent window.
