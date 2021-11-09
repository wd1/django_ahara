from django import template
from django.utils.safestring import mark_safe
from django.utils.encoding import force_str
from django.urls import reverse
from account.models import User


register = template.Library()


@register.filter(name='boolean')
def print_boolean(value):
    if value:
        return mark_safe("<span class='badge badge-primary'>Active</span>")
    else:
        return mark_safe("<span class='badge badge-secondary'>Disabled</span>")


@register.filter(name='boolean2')
def print_boolean2(value):
    if value:
        return mark_safe("<span class='badge badge-primary'>Yes</span>")
    else:
        return mark_safe("<span class='badge badge-secondary'>No</span>")


@register.simple_tag(name='switch_field')
def render_switch_field(field):
    field_help = force_str(mark_safe(field.help_text)) if field.help_text else ""
    is_checked = 'checked' if field.value() else ''
    disabled = 'disabled' if field.field.disabled else ''

    html = '<label class="switch switch-default switch-primary mr-2">' \
           '<input id="{id}" type="checkbox" class="switch-input" name={name} {checked} {disabled}>' \
           '<span class="switch-label"></span>' \
           '<span class="switch-handle"></span>' \
           '</label>' \
           '<label for={id}>{label}</label>' \
           '<small class="form-text text-muted">{help_text}</small>'.format(
        id=field.auto_id, name=field.html_name, label=field.label, help_text=field_help, checked=is_checked,
        disabled=disabled)
    return mark_safe(html)
