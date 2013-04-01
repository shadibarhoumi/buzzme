// ajax-enabled like button
Eve.scope('#feed', function() {
    
    var parent = this;

    this.listen('.like-button', 'click', function(e) {
        e.preventDefault();
        e.stopPropagation();

        // constrcut ajax url by getting value of data-message-id
        var url = '/like/' + $(e.target).data('message-id');

        $.ajax({
            type: 'POST',
            url: url,
            cache: false,
            dataType: 'text',
            success: function(likes) {
                // set likes text on button to new likes value
                $(e.target).find('.likes').text(likes);
                // disable button
                $(e.target).addClass('disabled');
                // add disabled html attribute to button
                $(e.target).prop('disabled', true);

            },
            error: function(xhr, textStatus, errorThrown) {
                console.log('An error occured during ajax call: ' + errorThrown);
            }
        });       

    });
});