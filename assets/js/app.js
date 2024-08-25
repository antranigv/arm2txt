import htmx from "../vendor/htmx"
import "../vendor/htmx-sse.js"

function copyResult(){
  var resultText = document.getElementById("resultText")
  navigator.clipboard.writeText(resultText.innerText);
  document.getElementById("copybtn").innerText = "յէ՜յ";
  setTimeout(
    function(){
      document.getElementById("copybtn").innerText = "պատճէնել";
    },
    2500
  );
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
document.body.addEventListener('htmx:configRequest', (event) => {
  event.detail.headers['x-csrf-token'] = csrfToken;
})

document.body.addEventListener('htmx:beforeSwap', function(evt) {
    if(evt.detail.xhr.status === 422){
        // allow 422 responses to swap as we are using this as a signal that
        // a form was submitted with bad data and want to rerender with the
        // errors
        //
        // set isError to false to avoid error logging in console
        evt.detail.shouldSwap = true;
        evt.detail.isError = false;
    }
})

