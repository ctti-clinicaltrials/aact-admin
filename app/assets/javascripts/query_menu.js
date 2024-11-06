var currentPage = window.location.pathname;

var queryMenuItems = document.querySelectorAll('.query-menu-item');
var queryMenuRightItems = document.querySelectorAll('.query-menu-right-item');

queryMenuItems.forEach(function(item) {
  var link = item.querySelector('a');
  if (link.getAttribute('href') === currentPage) {
    item.classList.add('active');
    link.style.color = '#224989';
  } else {
    item.classList.remove('active');
    link.style.color = '';
  }
});

queryMenuRightItems.forEach(function(item) {
  var link = item.querySelector('a');
  if (link.getAttribute('href') === currentPage) {
    item.classList.add('active');
    link.style.color = '#224989';
  } else {
    item.classList.remove('active');
    link.style.color = '';
  }
});


//selectable row javascript 
$(document).ready(function() {
  $('.selectable-row').on('click', function() {
    var url = $(this).data('url');
    window.location.href = url;
  });
});