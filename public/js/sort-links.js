// set classname of currently selected sorting option
// to 'current-sort'
var sortLinks = $("#sort a");
for (var i = 0; i < sortLinks.length; i++) {
    if (sortLinks[i].pathname === window.location.pathname) {
        sortLinks.eq(i).addClass('current-sort');
    }
}