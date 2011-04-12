var key = '9qykzm70fl68zzl';
var secret = 'f9u07szlqan3g42';

var dropbox = require('com.0x82.dropbox');
var session = dropbox.createSession({
  key: key,
  secret: secret
});
var client = null;

var win = Ti.UI.createWindow();
var win1 = Ti.UI.createWindow({
  backgroundColor: 'white',
  title: 'Link Dropbox'
});

var nav = Ti.UI.iPhone.createNavigationGroup({
  window: win1
});
win.add(nav);

var label = Ti.UI.createLabel({
  text: 'Press "Link Dropbox" and login to test wheter you have set your Dropbox developer account is set up correctly.',
  top: 96,
  left: 20,
  width: 280,
  height: 101,
  textAlign: 'center'
});
var link = Ti.UI.createButton({
  title: 'Link Dropbox',
  top: 219,
  left: 87,
  width: 145,
  height: 37
});
link.addEventListener('click', function(e) { 
  if(link.isLinked)
    unlinkDropbox();
  else
    linkDropbox(); 
});
win1.add(label);
win1.add(link);
win.open();

var browse_win = Ti.UI.createWindow({
});

function updateButtons() {
  if(session.isLinked()) {
    client = dropbox.createClient();
    link.title = 'Unlink Dropbox';
    link.isLinked = true;
    nav.open(browse_win, {animated: true});
  } else {
    link.title = 'Link Dropbox';
    link.isLinked = false;
  }
}

function linkDropbox() {
  session.showAuthenticationWindow({
    success: function(e) {
      updateButtons();
    }
  });
}

function unlinkDropbox() {
  session.unlink();
  updateButtons();
}

var image_view = Ti.UI.createImageView({
  top: 0,
  left: 0,
  width: '100%',
  height: '100%',
});
browse_win.add(image_view);

var random_button = Ti.UI.createButton({
  title: 'Random Photo',
  left: 72,
  top: 370,
  width: 176,
  height: 37
});
random_button.addEventListener('click', randomButtonPressed);
browse_win.add(random_button);

var photos = [];
var hash = null;

function randomButtonPressed() {
  client.loadMetadata({
    path: '/Photos',
    hash: hash,
    success: function(e) {
      photos = [];
      hash = e.hash;

      for(var i=0; i < e.contents.length; i++) {
        if(e.contents[i].path.match(/(.jpg|.png)$/))
          photos.push(e.contents[i].path);
      }

      loadRandomPhoto();
    },
    unchanged: function(e) {
      Ti.API.log("unchanged");
      loadRandomPhoto();
    },
    error: function(e) {
      alert(e.error);
    }
  });
}

function loadRandomPhoto() {
  if(!photos || photos.length == 0) {
    alert('You must have at least 1 photo in your Dropbox Photos folder to use this app');
  } else {
    var index = Math.floor(Math.random() * photos.length);
    var path = photos[index];


    client.loadThumbnail({
      path: path,
      success: function(e) {
        image_view.image = e.thumbnail;
      },
      error: function(e) {
        alert(e.error);
      }
    });
  }
}

setTimeout(updateButtons, 500);
