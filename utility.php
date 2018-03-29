<?php
function sanitize($input) {
  $data = trim($input);
  $data = stripslashes($data);
  $data = htmlspecialchars($data);
  return $data;
}

function requestVar($var, $default = NULL) {
  if (isset($_REQUEST[$var])) {
    return sanitize($_REQUEST[$var]);
  } else {
    return $default;
  }
}

function sqlResultToHtmlTable($sqlresult, $delim="\n") {
  //https://stackoverflow.com/a/26891213/1431237
  // starting table
  $htmltable =  "<table>" . $delim ;   
  $counter   = 0 ;
  // putting in lines
  while ($row = $sqlresult->fetch_assoc()) {
    if ($counter===0) {
      // table header
      $htmltable .= "<tr>" . $delim;
      foreach ($row as $key => $value ) {
          $htmltable .= "<th>" . $key . "</th>" . $delim;
      }
      $htmltable .= "</tr>" . $delim; 
      $counter = 22;
    } 
      // table body
      $htmltable .=   "<tr>" . $delim;
      foreach ($row as $key => $value) {
          $htmltable .=   "<td>" . $value . "</td>" . $delim;
      }
      $htmltable .= "</tr>" . $delim;
  }
  // closing table
  $htmltable .= "</table>" . $delim; 
  // return
  return $htmltable; 
}
