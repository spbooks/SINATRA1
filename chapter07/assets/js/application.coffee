$ -> 
  $('#released_on').datepicker( changeYear: true, yearRange: '1940:2000' )
  $('#like input').click (event) ->
    event.preventDefault()
    $.post(
      $('#like form').attr('action')
      (data) -> $('#like p').html(data).effect('highlight', color: '#fcd')
    )