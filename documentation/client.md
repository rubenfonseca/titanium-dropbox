# com.0x82.dropbox.Client

## Description

A dropbox object that represents a dropbox client with the server.

## Reference

All callbacks are optional. You implement them if you want to.

### dropbox.client.loadAccountInfo({...})

Gets the current account information and passes it to the success callback. It accepts a dictionary with the following options:

success[callback]: a function with a dictionary event with the following properties:
> country[string]<br />
> displayName[string]<br />
> userId[string]<br />
> referralLink[string]<br />
> quota[object]<br />
>> normal[long]<br />
>> shared[long]<br />
>> quota[long]<br />

error[callback]: called if the method returns an error

### dropbox.client.loadMetadata({...})

Gets the metadata for a file. It accepts a dictionary with the following options:

path[string]: the path you want to get metadata<br />
hash[string]: OPTIONAL. if you are making sucessive requests on the same path, you should use the event.hash returned on the success callback. this in turn will make the server fire the 'unchanged' callback if the metadata did not change
success[callback]: the event object has the following properties<br/>
> hash[string]<br />
> thumbnailExists[bool]<br />
> totalBytes[long]<br />
> lastModifiedDate[date]<br />
> path[string]<br />
> isDirectory[bool]<br />
> hash[string]<br />
> humanReadableSize[string]<br />
> root[string]<br />
> icon[string]<br />
> revision[long]<br />
> isDeleted[bool]<br />
> contents[object]: an array of metadata for the directory<br />
unchanged[callback]: called if you supply a hash parameter and the metadata didn't change at that path<br />
error[callback]: called if the method returns an error (does the path exists?)

### dropbox.client.loadThumbnail({...})

Tries to get a thumbnail for the path. It accepts a dictionary with the following options:

path[string]: the path you want to get the thumbnail<br />
size[string]: OPTIONAL specify the image size. Default = 'iphone_best'<br />
success[callback]: the thumbnail blob will come on the 'thumbnail' property on the event. You can assign it to a ImageView like this:

    var imageView = Ti.UI.createImageView({image:e.thumbnail});

error[callback]: called if the method returns an error

### dropbox.client.getFile({...})

Tries to get the file from a path. It accepts a dictionary with the following options:

path[string]: the path from the file you want to get<br />
success[callback]: the file blob will come on the 'file' property on the event. You can assign it to a ImageView like this:

    var imageView = Ti.UI.createImageView({image:e.file});

error[callback]: called if the method returns an error

### dropbox.client.cancelFileLoad(path)

Cancels the download of the file at the given path.

### dropbox.client.createFolder({...})

Tries to create a new directory. It accepts a dictionary with the following options:

path[string]: the path to the new directory<br />
success[callback]: called if the operation succeeded<br />
error[callback]: called if the operation failed (does the path already exists?)

### dropbox.client.deletePath({...})

Deletes a path from Dropbox. It accepts a dictionary with the following options:

path[string]: the path to delete<br />
success[callback]: called if the operation succeeded<br />
error[callback]: called if the operation failed (does the path exists?)

### dropbox.client.uploadFile({...})

Uploads a new file to Dropbox. It accepts a dictionary with the following options:

path[string]: the path where the file will be uplaoded<br />
file[string]: the path of the file you want to upload<br />
success[callback]: called if the upload succeeds<br />
error[callback]: called if the upload fails<br />
progress[callback]: called during the upload. It has a 'progress' event property with the progress of the upload, ranging from 0 to 1

### dropbox.client.copyPath({...})

Copies a path on Dropbox. It accepts a dictionary with the following options:

fromPath[string]: the origin path<br />
toPath[string]: the destination path<br />
success[callback]: called when it's done<br />
error[callback]: called if there's an error

### dropbox.client.movePath({...})

Moves a path on Dropbox. It accepts a dictionary with the following options:

fromPath[string]: the origin path<br />
toPath[string]: the destination path<br />
success[callback]: called when it's done<br />
error[callback]: called if there's an error
