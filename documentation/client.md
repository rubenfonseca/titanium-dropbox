# com.0x82.dropbox.Client

## Description

A dropbox object that represents a dropbox client with the server.

## Reference

All callbacks are optional. You implement them if you want to.

### dropbox.client.loadAccountInfo({...})

Gets the current account information and passes it to the success callback. It accepts a dictionary with the following options:

- success[callback]: a function with a dictionary event with the following properties:
> country[string]<br />
> displayName[string]<br />
> userId[string]<br />
> referralLink[string]<br />
> quota[object]<br />
>> normal[long]<br />
>> shared[long]<br />
>> quota[long]<br />

- error[callback]: called if the method returns an error

### dropbox.client.loadMetadata({...})

Gets the metadata for a file. It accepts a dictionary with the following options:

- path[string]: the path you want to get metadata<br />
- hash[string]: OPTIONAL. if you are making sucessive requests on the same
  path, you should use the event.hash returned on the success callback. this in
  turn will make the server fire the 'unchanged' callback if the metadata did
  not change 
- success[callback]: the event object has the following
  properties
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
- unchanged[callback]: called if you supply a hash parameter and the metadata didn't change at that path
- error[callback]: called if the method returns an error (does the path exists?)

### dropbox.client.loadThumbnail({...})

Tries to get a thumbnail for the path. It accepts a dictionary with the following options:

- path[string]: the path you want to get the thumbnail<br />
- size[string]: OPTIONAL specify the image size. Default = 'small'<br />
- success[callback]: the thumbnail blob will come on the 'thumbnail' property
  on the event. There's also all the metadata available, like path, file size, etc.
  You can assign it to a ImageView like this:

      var imageView = Ti.UI.createImageView({image:e.thumbnail});

- error[callback]: called if the method returns an error

*CAUTION*: the size `iphone_best` does not exist anymore, so it can't be used.

### dropbox.client.loadFile({...})

Tries to get the file from a path. It accepts a dictionary with the following options:

- path[string]: the path from the file you want to get<br />
- success[callback]: the file blob will come on the 'file' property on the
  event. You can assign it to a ImageView like this:

      var imageView = Ti.UI.createImageView({image:e.file});

- error[callback]: called if the method returns an error
- progress[callback]: called during the upload. It has a 'progress' event
  property with the progress of the upload, ranging from 0 to 1

### dropbox.client.cancelFileLoad(path)

Cancels the download of the file at the given path.

### dropbox.client.createFolder({...})

Tries to create a new directory. It accepts a dictionary with the following options:

- path[string]: the path to the new directory<br />
- success[callback]: called if the operation succeeded<br />
- error[callback]: called if the operation failed (does the path already exists?)

### dropbox.client.deletePath({...})

Deletes a path from Dropbox. It accepts a dictionary with the following options:

- path[string]: the path to delete<br />
- success[callback]: called if the operation succeeded<br />
- error[callback]: called if the operation failed (does the path exists?)

### dropbox.client.uploadFile({...})

Uploads a new file to Dropbox. It accepts a dictionary with the following options:

- path[string]: the path where the file will be uplaoded<br />
- file[string]: the path of the file you want to upload<br />
- parentRev[string]: [optional] the previous revision of the file. This value can be obtained
  using the .getMetadata method, under the key `rev`
- overwrite[boolean]: [optional] if `true`, the upload doesn't create a new file
  if the target path already exists. The default value is `false`, so if the
  target file already exists, a new file is created, and never overwritten. 
- success[callback]: called if the upload succeeds<br />
- error[callback]: called if the upload fails<br />
- progress[callback]: called during the upload. It has a 'progress' event
  property with the progress of the upload, ranging from 0 to 1

### client.uploadChunkedFile({...})

Uploads large files to Dropbox in mulitple chunks. This allos for upload larger
than 150 MB files. The parameters are very similar to the `uploadFile` method.

- file[string]: the path of the file you want to upload<br />
- path[string]: the path where the file will be uplaoded. **This should include the file name** <br />
- parentRev[string]: [optional] the previous revision of the file. This value
  can be obtained using the .getMetadata method, under the key `rev`
- success[callback]: called if the upload succeeds<br />
- error[callback]: called if the upload fails<br />
- progress[callback]: called during the upload. It has a 'progress' event
  property with the progress of the upload, ranging from 0 to 1

### dropbox.client.copyPath({...})

Copies a path on Dropbox. It accepts a dictionary with the following options:

- fromPath[string]: the origin path<br />
- fromCopyRef[string]: the reference obtained from calling createCopyRef()<br />
- toPath[string]: the destination path<br />
- success[callback]: called when it's done<br />
- error[callback]: called if there's an error

*PLEASE NOTE*, you need to specify _one_ of these: fromPath or fromCopyRef

### dropbox.client.movePath({...})

Moves a path on Dropbox. It accepts a dictionary with the following options:

- fromPath[string]: the origin path<br />
- toPath[string]: the destination path<br />
- success[callback]: called when it's done<br />
- error[callback]: called if there's an error

### dropbox.client.sharePath({...})

Generates an URL link for sharing the specified directory or file. It accepts a dictionary:

- path[string]: the Dropbox path to share
- success[callback]: called if the url is retrieved. It contains one key:
> - url: the URL to share the path
- error[callback]: called if the url can't be retrieved

### dropbox.client.getStreamableURL({...})

Generates an URL link for directly sharing a file, without touching the Dropbox frontend. Usefull
for using the link into an imageview or a video player. It accepts a dictionary:

- path[string]: the Dropbox path to share
- success[callback]: called if the url is retrieved. It contains one key:
> - url: the direct URL to the shared path
- error[callback]: called if the url can't be retrived

### dropbox.client.createCopyRef({...})

Creates and returns a copy_ref to a file. This reference string can be used to
copy that file to another user's Dropbox. It accepts a dictionary:

- path[string]: the Dropbox path to get the copy_ref
- success[callback]: called if the API sends a copy_ref. It contains only one key:
> - copyRef[string]: the copyRef reference you can then use on copyPath.
- error[callback]: called if the ref can't be obtained

### dropbox.client.searchPath({...})

Searches a directory for entries matching the query. It accepts a dictionary:

- path[string]: the Dropbox directory to search in.
- query[string]: the query to search for (minimum 3 charatcters).
- success[callback]: called with the search results on the `results` key
- error[callback]: called if the search fails

### dropbox.client.loadDelta({...})

A way of letting you keep up with changes to files and folders in a user's
Dropbox. You can periodically call loadDelta to get a list of "delta entries",
which are instructions on how to update your local state to match the server's
state. It accepts a dictionary:

- cursor[string]:  A string that is used to keep track of your current state.
  On the next call pass in this value to return delta entries that have been
  recorded since the cursor was returned.
- success[callback]: called if the loadDelta succeeds
- error[callback]: called if the loadDelta fails

#### Success callback

The event on the success callback has the following keys:

- reset[boolean]: If `true`, clear your local state before processing the delta
  entries. reset is always true on the initial call.
- cursor[string]: A string that encodes the latest information that has been
  returned. On the next call to loadDelta, pass in this value.
- has_more[boolean]: If `true`, then there are more entries available; you can
  call loadDelta again immediately to retrieve those entries. If `false`, then
  wait for at least five minutes (preferably longer) before checking again.
- entries[array]: each delta entry is a 2-item list of `[path, metadata]`. See
  the [official docs for more details](https://www.dropbox.com/developers/reference/api#delta)


### dropbox.client.loadRevisions({...})

Obtains metadata for the previous revisions of a file.

Only revisions up to thirty days old are available (or more if the Dropbox user
has Pack-Rat). You can use the revision number in conjunction with the `restoreRevision`
call to revert the file to its previous state. It accepts a dictionary:

- path[string]: the Dropbox path to get revisions
- success[callback]: called with the revisions under the `revisions` key.
- error[callback]: called if the loadRevisions fails 

### dropbox.client.restoreRevision({...})

Restores a file path to a previous revision.

Unlike downloading a file at a given revision and then re-uploading it, this
call is atomic. It also saves a bunch of bandwidth. It accepts a dictionary:

- path[string]: the Dropbox path to restore
- revision[string]: the exact revision reference to restore
- success[callback]: called if the restore succeeds. It has a `metadata` key of the restored file.
- error[callback]: called if the restore fails.

