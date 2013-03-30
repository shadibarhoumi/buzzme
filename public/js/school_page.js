// $('.target-name').click(function(e) {
//     e.preventDefault();
//     e.stopPropagation();
//     console.log('default prevented by jQuery');
// });

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


// $(".like_button").click(function() {
//     var messageid = $(this).data("messageid");
//     $.get("/like/" + messageid);

// });

// $(function() {

//     var $sidebar = $("#sidebar"), 
//         $window = $(window),
//         $page = $("#page")
//         initialOffset = $sidebar.offset(),
//         topPadding = 80;
//         duration = 300;

//     // sidebar follow
//     $window.scroll(function() {
//         if ($window.scrollTop() > initialOffset.top) {
            

//             $sidebar.stop().animate({
//                 // subtract initialOffset.top of sidebar because it's positioned
//                 // relative to its container, and it starts off at 0
//                 // since top is relative and window.scrollTop() is absolute,
//                 // correct window.scrollTop() to be relative to the top of the
//                 // sidebar's container element
//                 top: ($window.scrollTop() - initialOffset.top) + topPadding
//             }, duration);

//         } else {
//             $sidebar.stop().animate({
//                 top: 0
//             }, duration);
//         }
//     })
// });