
function addForm(btn, prefix) {
    console.log("Add..... ", prefix);
    let formIndex = $(`[data-form-list="${prefix}-prefix"] tbody[class="dynamic-form-tbody"] .dynamic-form`).length;

    if ($(`[data-form-list="${prefix}-prefix"] tbody[class="dynamic-form-tbody"] .dynamic-form:visible`).length >= $(`#id_${prefix}-MAX_NUM_FORMS`).val()){
        return false;
    }

    let table_id = $(btn).closest('table').prop("id");
    let row = $(`[data-form-list="${prefix}-prefix"] .dynamic-form:first`).clone(true).get(0);

    $.each($(row).find(":input"), function(i,v){
        if (typeof $(v).data("name") === "undefined"){
            $($(v).find("td")[i]).html()
        }else {
            let new_name = $(v).data("name").replace("-0-", "-"+formIndex+"-");
            $(v).prop("name", new_name);
            $(v).prop("id", `id_${new_name}`);
            if($(v).prop("type") !== "checkbox"){
                $(v).val("");
            }
            $(v).removeAttr("data-name");

            if($(v).prop("type") === "checkbox"){
                $(v).parent().find("label").prop("for", `id_${new_name}`);
            }
            $(v).parent().find(".invalid-feedback").html("");
            $(v).parent().find(".is-valid").removeClass("is-valid");
            $(v).parent().find(".is-invalid").removeClass("is-invalid");
        }
    });

    $.each($(row).find(":button"), function (i, v) {
        if (typeof $(v).data("idx") !== "undefined") {
            let new_id = $(v).prop("id").replace("-0-", "-"+formIndex+"-");
            $(v).prop("id", new_id);
            v.dataset.idx = formIndex;
        }
    });

    $(row).prop("id", `id_${prefix}-${formIndex}-row`);

    if (formIndex === 0){
        $(`#${table_id} tbody[class="dynamic-form-tbody"]`).append(row)
    }else {
        $(row).insertAfter($(`#${table_id} tbody[class="dynamic-form-tbody"] .dynamic-form:last`));
    }

    $(row).find("ul.errorlist").remove();

    $(`#id_${prefix}-TOTAL_FORMS`).val($(`#${table_id} tbody[class="dynamic-form-tbody"] .dynamic-form`).length);

    if (typeof after_add == 'function') {
        after_add(`id_${prefix}-${formIndex}`);
    }else {
        after_add_default($(row).prop("id"));
    }

    // if ( typeof dynamic_refresh == 'function' ) {
    //     dynamic_refresh();
    // }
    return false;
}

function deleteForm(btn, prefix) {
    console.log("Delete..... ", prefix);
    let id_el = $(btn).parents('.dynamic-form').find('input[type="hidden"][name*="-id"]');
    let table_id = $(btn).closest('table').prop("id");
    if(id_el.length == 0 || $(id_el).val()==""){
        $(btn).closest("tr.dynamic-form").remove();

        if ( typeof before_rearranging == 'function' ) {
            before_rearranging(table_id);
        }else {
            before_rearranging_default(table_id);
        }

        let rows = $(`#${table_id} tbody[class="dynamic-form-tbody"] .dynamic-form`);

        // console.log(rows)
        // console.log(rows.length)
        // console.log(`#id_${prefix}-TOTAL_FORMS`)
        $(`#id_${prefix}-TOTAL_FORMS`).val(rows.length);
        // console.log(rows.length)
        // console.log($(`#id_${prefix}-TOTAL_FORMS`).val());

        // Re-order the indexing
        $.each(rows, function(ii, vv){
            $.each($(vv).children().not(':last').children(), function(i,v){
                if($(v).find("input[id],select[id]").length > 1){
                    $.each($(v).find("input[id],select[id]"), function (j, w) {
                        reorder(prefix, j, w);
                    });
                }else{
                    reorder(prefix, ii, v);
                }
            });
        });

        function reorder(prefix, ii, v,) {
            let id_regex = new RegExp(`(${prefix}-\\d+)`);
            let replacement = `${prefix}-${ii}`;
            if ($(v).find("input[id],select[id]").prop("id"))
                $(v).find("input[id],select[id]").prop("id", $(v).find("input[id],select[id]").prop("id").replace(id_regex, replacement));
            if ($(v).find("label[for]").prop("for"))
                $(v).find("label[for]").prop("for", $(v).find("label[for]").prop("for").replace(id_regex, replacement));
            if($(v).find("input[name],select[name]").prop("name"))
                $(v).find("input[name],select[name]").prop("name", $(v).find("input[name],select[name]").prop("name").replace(id_regex, replacement));
        }

        if (typeof after_rearranging == 'function') {
            after_rearranging(table_id);
        }else {
            after_rearranging_default(table_id);
        }

    }else {
        // If it is Item from DB, DO NOT Delete
        $(btn).closest("tr.dynamic-form").hide();
        $(btn).closest("tr.dynamic-form").find('input[type="checkbox"][name*="-DELETE"]').prop("checked", true);
    }

    return false;
}


$(function () {
    init_dynamics()
});


function init_dynamics(){
    setTimeout(function () {
        $.each($(".dynamic-form-row-template .dynamic-form td"), function(i, v){
            $.each($(v).find("input,select"), function(x,y){
                $(y).prop("id", "");
                if ($(y).prop("name"))
                    $(y).attr("data-name", $(y).prop("name"));
                    $(y).prop("name", "");
            });
            $.each($(v).find("label"), function(x,y){
                $(y).prop("for", "");
            });
        });
    }, 500);


    // $('[data-form-list*="prefix"] .add-row').click(function() {
    //     return addForm(this, $(this).data('prefix'));
    // });

    $('body').on("click", '[data-form-list*="prefix"] .add-row', function(){
        return addForm(this, $(this).data('prefix'));
    });
    $('body').on('click', '[data-form-list*="prefix"] .delete-row', function(e) {
    // $('[data-form-list*="prefix"] .delete-row').click(function(e) {
    //     console.log(`Triggered:  `, e)
        deleteForm(this, $(this).data('prefix'));
    });
    $.each($('input[type="checkbox"][name*="-DELETE"][id*="-DELETE"]'), function (i, v) {
        $(v).hide();
        if($(v).is(":checked")){
            //In case a form was submitted and filed (so we want to represent the form for corrections) Hide already deleted
            $(v).parents('.dynamic-form').hide();
        }
    });
}
//******************************** :New Start: *********************************//
$('body').on("click", '#add_more', function() {
    cloneMore('div.table:last', 'service');
});


function cloneMore(selector, type) {
    let newElement = $(selector).clone(true);
    let total = $('#id_' + type + '-TOTAL_FORMS').val();
    newElement.find(':input').each(function() {
        let name = $(this).attr('name').replace('-' + (total-1) + '-','-' + total + '-');
        let id = 'id_' + name;
        $(this).attr({'name': name, 'id': id}).val('').removeAttr('checked');
    });
    newElement.find('label').each(function() {
        let newFor = $(this).attr('for').replace('-' + (total-1) + '-','-' + total + '-');
        $(this).attr('for', newFor);
    });
    total++;
    $('#id_' + type + '-TOTAL_FORMS').val(total);
    $(selector).after(newElement);
}


function before_rearranging_default(table_id){
    let dates = $(`#${table_id} tbody.dynamic-form-tbody .dynamic-form input[data-type="date"]`);
    if(dates.length > 0) {
        $(dates).datetimepicker("destroy");
    }
    $.each($(`#${table_id} tbody.dynamic-form-tbody select.select2`), function (i,v) {
        $(v).select2("destroy");
        $(v).removeAttr("data-select2-id").removeAttr("tabindex").removeAttr("aria-hidden");
        $(v).find("option").removeAttr("data-select2-id");
    })
}


function after_rearranging_default(table_id){
    let dates = $(`#${table_id} tbody.dynamic-form-tbody .dynamic-form input[data-type="date"]`);
    if(dates.length > 0) {
        $('tbody.dynamic-form-tbody .dynamic-form input[data-type="date"]').datetimepicker({
            inline: false,
            viewMode: 'months',
            format: company_date_format,
            collapse: true,
            sideBySide: true
        });
    }
    $.each($(`#${table_id} tbody.dynamic-form-tbody select.select2`), function (i, v) {
        $(v).select2({width: '100%'});
    });
}


function after_add_default(row_id){
    let dates = $(`tr#${row_id} input[data-type="date"]`);
    if(dates.length > 0) {
        $('tbody.dynamic-form-tbody .dynamic-form input[data-type="date"]').datetimepicker({
            inline: false,
            viewMode: 'months',
            format: company_date_format,
            collapse: true,
            sideBySide: true
        });
    }
    $.each($(`tr#${row_id} select.select2`), function (i, v) {
        $(v).select2({width: '100%'});
    });
}

