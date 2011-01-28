function setup_baseline_selector(element, baselines_path) {
  jQuery(element).autocomplete({
    source: baselines_path,
    minLength: 0,
    select: function(event, ui) {
      jQuery('#baseline_type_other').attr('checked', true)
    }
  });
  jQuery(element).click(function() {
    jQuery(element).autocomplete('search');
  });
}
