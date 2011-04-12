// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.

// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
window.add(label);
window.open();

// TODO: write your module tests here
var dropbox = require('com.0x82.dropbox');
Ti.API.info("module is => " + dropbox);

var session = dropbox.createSession({
  key: '9qykzm70fl68zzl',
  secret: 'f9u07szlqan3g42'
});
Ti.API.info("session is => " + session);
Ti.API.log("  is Linked? => " + session.isLinked());

var client;

Ti.API.log("auhenticating");
session.showAuthenticationWindow({
  success: function(e) {
    Ti.API.log("SUCCESS :D");
    Ti.API.log(e);

    client = e.client;
    getAccountInfo();
  },
  cancel: function(e) {
    Ti.API.log("CANCEL....");
    Ti.API.log(e);
  }
});

function getAccountInfo() {
  client.loadAccountInfo({
    success: function(e) {
      Ti.API.log("account success");
      Ti.API.log(e);

      getMetadata();
    },
    error: function(e) {
      Ti.API.log("account error");
      Ti.API.log(e);
    }
  });
}

function getMetadata() {
  client.loadMetadata({
    path:'/Public',
    success: function(e) {
      Ti.API.log(e);

      getThumbnail();
    }
  });
}

function getThumbnail() {
  client.loadThumbnail({
    path: '/Photos/P1223189.JPG',
    success: function(e) {
      Ti.API.log("SUCCESS THUMBNAIL");
      Ti.API.log(e.thumbnail);

      var imageView = Ti.UI.createImageView({image:e.thumbnail});
      window.add(imageView);

      getFile();
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
      Ti.API.log(e);

      var imageView = Ti.UI.createImageView({image:e.file});
      window.add(imageView);

      createFolder();
    },
    error: function(e) {
      Ti.API.log("ERROR FILE");
      Ti.API.log(e);
    }
  });
}

function createFolder() {
  client.createFolder({
    path: '/newfolder',
    success: function(e) {
      Ti.API.log("SUCCESS CREATE FOLDER");
      Ti.API.log(e);

      deleteFolder();
    },
    error: function(e) {
      Ti.API.log("ERROR CREATE FOLDER");
      Ti.API.log(e);

      deleteFolder();
    }
  });
}

function deleteFolder() {
  client.deletePath({
    path: '/newfolder',
    success: function(e) {
      Ti.API.log("SUCCESS DELETE FOLDER");
      Ti.API.log(e);
      
      uploadFile();
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

      client.uploadFile({
        file: mediafile,
        path: '/Photos/',
        success: function(event) {
          Ti.API.log("UPLOAD SUCCESS");
          Ti.API.log(event);

          copyPath();
        },
        progress: function(event) {
          Ti.API.log("UPLOAD PROGRESS");
          Ti.API.log(event);
        },
        error: function(event) {
          Ti.API.log("UPLOAD ERROR");
          Ti.API.log(event);
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
      Ti.API.log(e);

      movePath();
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
      Ti.API.log(e);
    },
    error: function(e) {
      Ti.API.log("MOVE ERROR");
      Ti.API.log(e);
    }
  });
}
