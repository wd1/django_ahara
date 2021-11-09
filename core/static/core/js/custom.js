function csrfSafeMethod(method) {
  // these HTTP methods do not require CSRF protection
  return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}

function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            // Does this cookie string begin with the name we want?
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

renderError = function (form, data, form_prefix) {
    $(form).find(".invalid-feedback").remove();
    $(form).find('input, select, textarea, div').removeClass("is-invalid");

    if(typeof form_prefix === "undefined" || form_prefix === null){
        $.each(JSON.parse(data), function (key, value) {
            $.each(value, function (i, v) {
                if($(form).find(`#id_${key}`).next().hasClass("select2")){
                    $(form).find(`#id_${key}`).addClass("is-invalid");
                    $(form).find(`#id_${key}`).parent().addClass("is-invalid");
                    $(form).find(`#id_${key}`).next().after(`<div class="invalid-feedback">${v}</div>`);
                }else {
                    $(form).find(`#id_${key}`).addClass("is-invalid").after(`<div class="invalid-feedback">${v}</div>`)
                }
            });
        });
    }else{
        $.each(JSON.parse(data), function (key, value) {
            $.each(value, function (i, v) {
                if($(form).find(`#id_${form_prefix}-${key}`).next().hasClass("select2")){
                    $(form).find(`#id_${form_prefix}-${key}`).addClass("is-invalid");
                    $(form).find(`#id_${form_prefix}-${key}`).parent().addClass("is-invalid");
                    $(form).find(`#id_${form_prefix}-${key}`).next().after(`<div class="invalid-feedback">${v}</div>`)
                }else {
                    $(form).find(`#id_${form_prefix}-${key}`).addClass("is-invalid").after(`<div class="invalid-feedback">${v}</div>`)
                }

            });
        });
    }
};