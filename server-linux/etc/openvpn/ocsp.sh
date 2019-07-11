#!/bin/bash
#
# Created by Veselin Kolev <vlk@lcpe.uni-sofia.bg> - Wed, Jul 10, 2019
#
# if the depth is non-zero , continue processing
[ "$1" -ne 0 ] && exit 0
#
# That is a very dirty hack:
#
#    We expect to validate X.509 certificates issued by different certificate
#    authorities. Therefore, we might have to deal with different OCSP
#    responders. So far, the script cannot extract the OCPS URL from the
#    certificate. That should be in TODO.
#
#    To make the script working somehow, there are two checks of the OCSP
#    status for every certificate. First, it is checked agains the OCSP for
#    UNITe, and in case of rejection, the user's X.509 certificate is
#    checked agains the OCSP for SU ECC Identity Management CA.
#
#    That dirty hack will be removed in the future releases of this script.
#
if [ -n "${tls_serial_0}" ]
   then
      #
      # Examine the user's X.509 certificate, as if it is ussued by UNITe ECC CA:
      #
      status=$(openssl ocsp -issuer /etc/openvpn/CA_1/UNITe_ECC_CA.crt -CAfile /etc/openvpn/CA_1/SU_ECC_Root_CA.crt -url http://pki.uni-sofia.bg/ocsp/UNITe_ECC_CA -serial "${tls_serial_0}" 2>/dev/null)
      if [ $? -eq 0 ]
      then
         # debug:
         echo "OCSP status: $status"
         if echo "$status" | grep -Fq "${tls_serial_0}: good"
         then
            exit 0
         fi
         #
      fi
      #
      # Examine the user's X.509 certificate, as if it is ussued by SU ECC
      # Identify Management CA:
      #
      status=$(openssl ocsp -issuer /etc/openvpn/CA_1/SU_ECC_Identity_Management_CA.crt -CAfile /etc/openvpn/CA_1/SU_ECC_Root_CA.crt -url http://pki.uni-sofia.bg/ocsp/SU_ECC_Identity_Management_CA -serial "${tls_serial_0}" 2>/dev/null)
      if [ $? -eq 0 ]
      then
         if echo "$status" | grep -Fq "${tls_serial_0}: good"
         then
            exit 0
         fi
      fi
   #
   else
      # debug:
      echo "OCSP verification failed!"
      #
   fi
exit 1

