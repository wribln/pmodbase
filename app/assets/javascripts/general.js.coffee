# This function causes the bootstrap way of showing errors by inserting
# 'has-error' into the 'form-group' div

$ ->
  $('.field_with_errors').closest('div.form-group').addClass('has-error')

# A link/button with class 'show-filter-row' will toggle the visibility of
# that row. Furthermore, if the row (assuming it contains search fields)
# is then hidden, it will locate the closest form tag and reset all fields
# in that form

$ ->
  $('.show-filter-row').click ->
    r = $('.filter-row')
    r.toggle()
    if r.is(':hidden')
      r.closest('form').get(0).reset()

# provide here the defaults for all datepickers

$ ->
  $.fn.datepicker.defaults.format = "yyyy-mm-dd"
  $.fn.datepicker.defaults.todayHighlight=true
  $.fn.datepicker.defaults.clearBtn=true
  $.fn.datepicker.defaults.autoclose=true
  $.fn.datepicker.defaults.showOnFocus=false
