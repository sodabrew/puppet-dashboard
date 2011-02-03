function setup_baseline_selector(element, baselines_path) {
  jQuery(element).autocomplete({
    source: baselines_path,
    minLength: 0
  });
  jQuery(element).click(function() {
    jQuery(element).autocomplete('search');
  });
  function callback() {
    jQuery('#baseline_type_other').attr('checked', true);
  }
  jQuery(element).keypress(callback);
  jQuery(element).change(callback);
}
