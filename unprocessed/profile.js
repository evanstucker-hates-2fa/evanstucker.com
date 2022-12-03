var xhr = new XMLHttpRequest();

xhr.onreadystatechange = function() {
  if (this.readyState == 4 && this.status == 200) {
    var profileHash = JSON.parse(this.responseText);
    printProfile(profileHash);
  }
};

xhr.open("GET", "profile.json", true);
xhr.send();

function printProfile(hash) {
  var out = "";
  var i;
  for(i = 0; i < hash.length; i += 1) {
    out += '<a href="' + hash[i] + '">' + hash[i] + '</a><br>\n';
  }
  document.getElementById("content").innerHTML = out;
}
