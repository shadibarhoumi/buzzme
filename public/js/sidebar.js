
$(function() {

    var $sidebar = $("#sidebar"), 
        $window = $(window),
        $page = $("#page")
        initialOffset = $sidebar.offset(),
        topPadding = 80;
        duration = 300;

    // sidebar follow
    $window.scroll(function() {
        if ($window.scrollTop() > initialOffset.top) {
            

            $sidebar.stop().animate({
                // subtract initialOffset.top of sidebar because it's positioned
                // relative to its container, and it starts off at 0
                // since top is relative and window.scrollTop() is absolute,
                // correct window.scrollTop() to be relative to the top of the
                // sidebar's container element
                top: ($window.scrollTop() - initialOffset.top) + topPadding
            }, duration);

        } else {
            $sidebar.stop().animate({
                top: 0
            }, duration);
        }
    })
});