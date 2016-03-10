task echo_hello {
     command {
         perl -e 'print "bla!\n"'
     }

     runtime {
         docker: "perl:5.22"
          #docker: "ubuntu:latest"
     }
}

workflow basic {
  call echo_hello
}

