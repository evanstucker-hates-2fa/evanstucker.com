var xhr = new XMLHttpRequest();

xhr.onreadystatechange = function() {
  if (this.readyState == 4 && this.status == 200) {
    var diaryHash = JSON.parse(this.responseText);
    printDiary(diaryHash);
  }
};

xhr.open("GET", "diary.json", true);
xhr.send();

function printDiary(hash) {
  var out = "";
  var i;
  for(i = 0; i < hash.length; i += 1) {
    out += '<h2>' + hash[i].date + '</h2>\n<p>' + hash[i].entry + '</p>\n';
  }
  document.getElementById("content").innerHTML = out;
}
