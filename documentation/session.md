# com.0x82.dropbox.Session

## Description

A dropbox object that represents a dropbox session with the server.

## Reference

### dropbox.session.isLinked()

Returns a bool (true, false) if the current session is linked to the Dropbox API. If it's not, you should call the [showAuthenticationWindow]() method, to authenticate the user.

### dropbox.session.unlink()

Unlinkes the current session from this device.

### dropbox.session.showAuthenticationWindow({...})

Shows a modal dropbox authentication window on both iPhone and iPad.

Takes one argument, a dictionary containing the following properties:

success[callback]: a callback which is called if the authentication succeeds. The callback method takes one argument containing the following properties:
> client[object]: a [dropbox.Client](client.html) instance you should use to make your requests from this momment on

cancel[callback]: a callback which is called if the user cancels the authentication / signup process. There is no need to close the modal window.

