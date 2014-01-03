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

function register_ajax_submit(form_id) {
  jQuery(form_id).submit(function() {
    var param_form = this;
    // delay sending the data so that placeholders could be removed in non-html5 browsers before the form is serialized
    // TODO - detect native HTML5 support and if it's the case then call following code directly
    setTimeout(function() {
      jQuery.post(param_form.action, jQuery(param_form).serialize(), "json").
      success(function(data) {form_submit_success(data, 'error_messages');}).
      error(function() {alert('Oops, something went wrong!');});
    }, 0);
    return false;
  });
}

function bind_response_events(xhr_element_id, error_element_id) {
  jQuery(xhr_element_id)
    .bind("ajax:success", function(event, data, status, xhr) {
      form_submit_success(data, error_element_id);
    })
    .bind("ajax:failure", function() { alert('Oops!! An error occurred.') });
}