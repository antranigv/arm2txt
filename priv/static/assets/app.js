// For Phoenix.HTML support, including form and button helpers
// copy the following scripts into your javascript bundle:
// * deps/phoenix_html/priv/static/phoenix_html.js

// For Phoenix.Channels support, copy the following scripts
// into your javascript bundle:
// * deps/phoenix/priv/static/phoenix.js

// For Phoenix.LiveView support, copy the following scripts
// into your javascript bundle:
// * deps/phoenix_live_view/priv/static/phoenix_live_view.js


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

