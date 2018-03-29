function getData(url, callback) {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      callback(this.responseText);
      return false;
    }
  };
  xhttp.open("GET", url, true);
  xhttp.send();
}

function isUndefinedOrNull(variable) {
  return (typeof variable === 'undefined' || variable === null);
}

function getScreenWidth() {
  return window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
}
