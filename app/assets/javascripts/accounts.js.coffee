# These functions were initially developed to process nested forms, i.e.
# permissions within account records. They can be used in the same manner
# elsewhere.

# In the original form, the methods are used to request removal of an existing
# permission record and addition of a new permission record; removal is done
# per Rails _destroy field, i.e. before the submission is initiated by the
# click function, the most recent hidden input field (assumed to contain the
# respective _destroy value) is set to TRUE; addition of a new record is done
# by creating a copy of the hidden subform and making it visible

# Update 2016-04-04: need to check if 'id'/'name' exist as for checkboxes,
# a hidden input field is inserted by Rails w/o 'id' but with a 'name'


$ ->
  $('.del-subform-button').click ->
    if confirm("Are you sure that you want to remove this item?")
      $(this).prevAll('input[type="hidden"]').val(true)
      $(this).closest('div.form-set').hide()

$ ->
  $('.add-subform-button').click ->
    no_form_sets = $('.form-set').length
    $template_object = $(this).closest('div.form-group').prev()
    $template_clone = $template_object.clone(true)
    $template_clone.find(':input').each ->
      if $(@).attr('id')
        old_id = $(@).attr('id')
        new_id = old_id.replace /template/,no_form_sets
        $(@).attr('id',new_id)
      old_name = $(@).attr('name')
      new_name = old_name.replace /template/,no_form_sets
      $(@).attr('name',new_name)
    $template_clone.show()
    $template_object.before($template_clone)
