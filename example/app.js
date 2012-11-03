// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.

// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'white',
  title: 'Dropbox module'
});

var nav = Ti.UI.iPhone.createNavigationGroup({
  window: window
});

var navigationWindow = Ti.UI.createWindow();
navigationWindow.add(nav);
navigationWindow.open();

var dropbox = require('com.0x82.dropbox');
Ti.API.info("module is => " + dropbox);

var session = dropbox.createSession({
  key: 'kx995bnohs7qvdj',
  secret: '7wuv1m3a1ldcm2x',
  root: dropbox.DROPBOX_ROOT_DROPBOX
});
Ti.API.info("session is => " + session);
Ti.API.log("  is Linked? => " + session.isLinked());

var client = dropbox.createClient();

function link_account() {
  Ti.API.log("auhenticating");

  if(session.isLinked()) {
    alert('You are already linked with dropbox');
    return;
  }

  session.link({
    success: function(e) {
      Ti.API.log("SUCCESS :D");
      Ti.API.log(e);
  
      client = e.client;
    },
    cancel: function(e) {
      Ti.API.log("CANCEL....");
      Ti.API.log(e);
    }
  });
}

function unlink() {
  if(!session.isLinked()) {
    alert('No session to unlink');
    return;
  }

  session.unlink();
  alert('Unlinked!');
}

function getAccountInfo() {
  client.loadAccountInfo({
    success: function(e) {
      Ti.API.log("account success");
      tableview.footerTitle = JSON.stringify(e);
    },
    error: function(e) {
      Ti.API.log("account error");
      Ti.API.log(e);
    }
  });
}

function getMetadata() {
  client.loadMetadata({
    path:'/Photos/foo.jpg',
    success: function(e) {
      tableview.footerTitle = JSON.stringify(e);
    }
  });
}

function getThumbnail() {
  client.loadThumbnail({
    path: '/Photos/P1223189.JPG',
    success: function(e) {
      Ti.API.log("SUCCESS THUMBNAIL");

      var new_window = Ti.UI.createWindow({title:'Thumbnail'});
      var image_view = Ti.UI.createImageView({image:e.thumbnail});
      new_window.add(image_view);
      nav.open(new_window, {animated:true});
    },
    error: function(e) {
      Ti.API.log("ERROR THUMBNAIL");
      Ti.API.log(e);
    }
  });
}

function getFile() {
  client.loadFile({
    path: '/Photos/P1223189.JPG',
    success: function(e) {
      Ti.API.log("SUCCESS FILE");

      var new_window = Ti.UI.createWindow({title:'Full file'});
      var image_view = Ti.UI.createImageView({image:e.file});
      new_window.add(image_view);
      nav.open(new_window, {animated:true});
    },
    error: function(e) {
      Ti.API.log("ERROR FILE");
      Ti.API.log(e);
    }
  });
}

function getCopyRef() {
  client.createCopyRef({
    path: '/Photos/P1223189.JPG',
    success: function(e) {
      Ti.API.log("COPYREF SUCCESS");

      Ti.API.log(e);
    },
    error: function(e) {
      Ti.API.log("ERROR COPYREF");
      Ti.API.log(e);
    }
  });
}

function copyRef() {
  client.createCopyRef({
    path: '/Photos/P1223189.JPG',
    success: function(e) {
      var copyRef = e.copyRef;

      client.copyPath({
        fromCopyRef: copyRef,
        toPath: '/Photos/to.jpg',
        success: function(e) {
          Ti.API.log("COPY COPYREF SUCCESS");
          tableview.footerTitle = JSON.stringify(e);
          alert('Ref Copied');
        },
        error: function(e) {
          Ti.API.log("COPY COPYREF ERROR");
          Ti.API.log(e);
        }
      });
    },
    error: function(e) {
      Ti.API.log("ERROR COPY COPYREF");
      Ti.API.log(e);
    }
  });
}

function createFolder() {
  client.createFolder({
    path: '/newfolder',
    success: function(e) {
      Ti.API.log("SUCCESS CREATE FOLDER");
      tableview.footerTitle = JSON.stringify(e);
    },
    error: function(e) {
      Ti.API.log("ERROR CREATE FOLDER");
      Ti.API.log(e);
    }
  });
}

function deleteFolder() {
  client.deletePath({
    path: '/newfolder',
    success: function(e) {
      Ti.API.log("SUCCESS DELETE FOLDER");
      tableview.footerTitle = JSON.stringify(e);
    },
    error: function(e) {
      Ti.API.log("ERROR CREATE FOLDER");
      Ti.API.log(e);
    }
  });
}

function uploadFile() {
  Ti.Media.openPhotoGallery({
    success: function(e) {
      var tempDir = Ti.Filesystem.createTempDirectory();
      var mediafile = Ti.Filesystem.getFile(tempDir.nativePath, "foo.jpg");
      mediafile.write(e.media);

      var progressBar = Ti.UI.createProgressBar({
        max: 1,
        min: 0,
        value: 0,
        left: 10,
        right: 10,
        style: Ti.UI.iPhone.ProgressBarStyle.PLAIN
      });
      tableview.footerView = progressBar;
      progressBar.show();

      client.uploadFile({
        file: mediafile,
        path: '/Photos/',
        overwrite: true,
        success: function(event) {
          Ti.API.log("UPLOAD SUCCESS");
          Ti.API.log(event);

          alert('File uploaded!');
          tableview.footerView = null;
        },
        progress: function(event) {
          Ti.API.log("UPLOAD PROGRESS");
          Ti.API.log(event);

          progressBar.value = event.progress;
        },
        error: function(event) {
          Ti.API.log("UPLOAD ERROR");
          Ti.API.log(event);
          tableview.footerView = null;
        }
      });
    }
  });
}

function copyPath() {
  client.copyPath({
    fromPath: '/Photos/foo.jpg',
    toPath: '/Photos/to.jpg',
    success: function(e) {
      Ti.API.log("COPY SUCCESS");
      tableview.footerTitle = JSON.stringify(e);
      alert('Copied');
    },
    error: function(e) {
      Ti.API.log("COPY ERROR");
      Ti.API.log(e);
    }
  });
}

function movePath() {
  client.movePath({
    fromPath: '/Photos/to.jpg',
    toPath: '/Photos/bar.jpg',
    success: function(e) {
      Ti.API.log("MOVE SUCCESS");
      tableview.footerTitle = JSON.stringify(e);
      alert('Moved');
    },
    error: function(e) {
      Ti.API.log("MOVE ERROR");
      Ti.API.log(e);
    }
  });
}

var cursor = null;
function loadDelta() {
  client.loadDelta({
    cursor: cursor,
    success: function(e) {
      cursor = e.cursor;

      Ti.API.log("------ DELTA RESULT ------");
      Ti.API.log("Has more? " + e.has_more);
      Ti.API.log("Should reset? " + e.reset);
      Ti.API.log("Entries: " + JSON.stringify(e.entries));
    },
    error: function(e) {
      Ti.API.log("DELTA ERROR");
      Ti.API.log(e);
    }
  });
}

var data = [
  {title:'Link account', hasChild:true, callback: link_account, header:'Authentication'},
  {title:'Unlink account', hasChild:true, callback: unlink},
  {title:'Get account Info', hasChild:true, callback: getAccountInfo, header: 'API'},
  {title:'Get path Metadata', hasChild:true, callback: getMetadata},
  {title:'Load thumbnail', hasChild:true, callback: getThumbnail},
  {title:'Load full file', hasChild:true, callback: getFile},
  {title:'Create folder', hasChild:true, callback:createFolder},
  {title:'Delete folder', hasChild:true, callback:deleteFolder},
  {title:'Upload file', hasChild:true, callback:uploadFile},
  {title:'Get copyref', hasChild:true, callback: getCopyRef},
  {title:'Copy from copyref', hasChild:true, callback:copyRef},
  {title:'Copy path', hasChild:true, callback: copyPath},
  {title:'Move path', hasChild:true, callback: movePath},
  {title:'Load delta', hasChild:true, callback: loadDelta},
];

var tableview = Ti.UI.createTableView({
  data: data,
  style: Ti.UI.iPhone.TableViewStyle.GROUPED
});
window.add(tableview);

tableview.addEventListener('click', function(e) {
  if(e.rowData.callback) {
    tableview.footerTitle = null;
    e.rowData.callback();
  }
});

window.open();
