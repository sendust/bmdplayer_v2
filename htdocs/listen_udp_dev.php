<?php
  error_reporting(E_ALL);
  ini_set('display_errors', '1');
  set_time_limit(0);
  ob_start();

  function flush_buffers(){
      ob_end_flush();
      ob_flush();
      flush();
      ob_start();
  }
  echo date("d-m-Y H:i:s");

?>

<body style="background-color: yellow;">
    <div style="margin: auto; margin-top: 50px;">
            <div style="margin: auto; width: 200px; font-weight: bold; font-size: 20px; margin-bottom: 20px; color: darkgreen;">Real Time View</div>

            <?php
                //Create a UDP socket
                if(!($socket = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP)))
                {
                     $errorcode = socket_last_error();
                     $errormsg = socket_strerror($errorcode);
                     die("Couldn't create socket: [$errorcode] $errormsg \n");
                }

                echo "Socket created <br>";
                flush_buffers();

                if( !socket_set_nonblock($socket) ){
                     $errorcode = socket_last_error();
                     $errormsg = socket_strerror($errorcode);
                     die("Could not nonblock socket : [$errorcode] $errormsg \n");
                }

                // Bind the source address
                if( !socket_bind($socket, '127.0.0.1', 40000) ){
                     $errorcode = socket_last_error();
                     $errormsg = socket_strerror($errorcode);
                     die("Could not bind socket : [$errorcode] $errormsg \n");
                }
                echo "Socket bind OK <br>";
                flush_buffers();

                socket_set_option($socket, SOL_SOCKET, SO_RCVTIMEO, array("sec"=>1, "usec"=>100));
                socket_set_option($socket, SOL_SOCKET, SO_SNDTIMEO, array("sec"=>1, "usec"=>100));

                try {
                  while(1){
                       usleep(0.5 * 1000000); // 0.5 seconds
                       if (False === ($r = socket_recvfrom($socket, $buf, 32, 0, $from, $port))) {
                          $errorcode = socket_last_error();
                          $errormsg = socket_strerror($errorcode);
                          if ($errorcode!='11') { echo "error reading : [$errorcode] $errormsg <br>\n"; }
                       }
                       echo $buf;
                       if ($r!='') { echo ".<br>"; }
                       flush_buffers();
                  }
                } finally {
                  socket_close($socket);
                }


            ?>
    </div>
</body>
<?
ob_end_flush();
?>
