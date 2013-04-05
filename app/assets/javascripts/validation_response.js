function form_submit_success(jsonResponse, error_messages_element_id) {
  if(jsonResponse.status == "error") {
    errorMessagesElement = document.getElementById(error_messages_element_id);
    errorMessagesElement.style.display = "block";
    errorMessagesElement.innerHTML = jsonResponse.error_html;
  }
  else {
    if(jsonResponse.valid == "true") {
      window.location = jsonResponse.redirect_to;
    }
    else {
      confirmElement = document.createElement('div');
      confirmElement.style.position = 'absolute';
      confirmElement.style.top = '0px';
      confirmElement.style.right  = '0px';
      confirmElement.style.bottom = '0px';
      confirmElement.style.left = '0px';
      document.getElementsByTagName('body')[0].appendChild(confirmElement);
      confirmElement.innerHTML = jsonResponse.confirm_html;
    }
  }
}
