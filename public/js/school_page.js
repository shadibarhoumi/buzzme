Eve.scope('#feed', function() {
    
    var parent = this;

    this.listen('.like-button', 'click', function(e) {
        e.preventDefault();
        e.stopPropagation();

        var url = '/like/' + $(e.target).data('message-id');

        $.ajax({
            type: 'POST',
            url: url,
            cache: false,
            dataType: 'text',
            success: function(likes) {
                $(e.target).find('.likes').text(likes);
                $(e.target).addClass('disabled');
                $(e.target).prop('disabled', true);

            },
            error: function(xhr, textStatus, errorThrown) {
                console.log('An error occured during ajax call: ' + errorThrown);
            }
        });       

    });
});

// set classname of currently selected sorting option
// to 'current-sort'
var sortLinks = $("#sort a");
for (var i = 0; i < sortLinks.length; i++) {
    if (sortLinks[i].pathname === window.location.pathname) {
        sortLinks.eq(i).addClass('current-sort');
    }
}