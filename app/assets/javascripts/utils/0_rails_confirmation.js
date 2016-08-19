$(function () {
    $.rails.allowAction = function (link) {
        if (!link.attr('data-confirm')) {
            return true;
        }
        $.rails.showConfirmDialog(link);
        return false;
    };
    $.rails.confirmed = function (link) {
        var message;
        message = link.attr('data-confirm');
        link.removeAttr('data-confirm');
        link.trigger('click');
        return link.attr('data-confirm', message);
    };
    return $.rails.showConfirmDialog = function (link) {
        var message;
        message = link.attr('data-confirm');
        return swal({
            title: $('#confirmation_header').text(),
            text: message,
            confirmButtonText: $('#confirmation_ok').text(),
            cancelButtonText: $('#confirmation_cancel').text(),
            type: 'warning',
            showCancelButton: true
        }).then(function () {
            return $.rails.confirmed(link);
        }, function () {
        });
    };
});

// ---
// generated by coffee-script 1.9.2