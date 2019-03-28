<script>
$(document).ready(function(){

  var $table = $('#projectTable');

  $table.on('expand-row.bs.table', function(e, index, row, $detail) {
    var res = $("#detail_" + index ).html();
    $detail.html(res);
  });

  $("#projectFilter").change(function(){
      $(".dataNotAvailable").toggle($("#projectFilter").val() == "all");
  });

});
</script>


