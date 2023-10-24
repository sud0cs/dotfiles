function load(){
  var search = document.getElementById("search");
  search.addEventListener("keypress", function(event) {
    if (event.key === "Enter"){
      window.location.assign("https://google.com/search?q=" + search.value);
    }
  });
}

