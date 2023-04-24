import 'package:encrypt/encrypt.dart';

class AesEncrypt {
  static main() {
    final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
    final key = Key.fromBase64('oEditeVr7OmqXSPi1ZXfOuw+F9y/4bI+VjA/YmPjT9U=');
    print("==length " + key.toString().length.toString());
    print("==length " + key.toString());
    final iv = IV.fromBase64('PHli36Hb1Bww1aBjadxk6g==');
    // final encrypter = Encrypter(AES(key, iv, mode: AESMode.cbc));
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText);
    final decrypted = encrypter.decrypt(encrypted);
    print("print decrypted" + decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
    print("print decrypted" + encrypted.base64); // R4P
    print("print decrypted" + encrypter.decrypt64("eyJpdiI6IlBIbGkzNkhiMUJ3dzFhQmphZHhrNmc9PSIsInZhbHVlIjoiZngzU1h5QVNPd1dtT25qblZHRnZGbUtIT21ZaTFPZDYyekpqTUZ0MjZDcjZXMmQ5VUdyZHVTRU1Ed1cyUjNOXC90MjRqNTlRRFhuZjloY1hjYWxVcWpNMGVHYkNJYWRTaHUySXJTaVlEendoMmtINlwvS3JvOFNZTjIybVlDNkJmZ2grZ3NCUTFPcWx4NmM0TVwvayt3Wk1VQVF5Q3dDSTY0bEJoRFpKVWdBMnRaWmhkTUFCM3NzNTFoRFNUYWZRcnNcL1ZINStZZlgxYVJUMktpSkxTam5KaVE9PSIsIm1hYyI6IjliNjA2ZWIxZDE2YmVjNTEzNWIxOThmZjM1YTZhOWRiMzczZDk3MTcwOGFiYzAyMzEzMTA2MWM5ZWExNmM0YTAifQ==")); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
    print("print decrypted" + encrypter.decrypt16("eyJpdiI6IlBIbGkzNkhiMUJ3dzFhQmphZHhrNmc9PSIsInZhbHVlIjoiZngzU1h5QVNPd1dtT25qblZHRnZGbUtIT21ZaTFPZDYyekpqTUZ0MjZDcjZXMmQ5VUdyZHVTRU1Ed1cyUjNOXC90MjRqNTlRRFhuZjloY1hjYWxVcWpNMGVHYkNJYWRTaHUySXJTaVlEendoMmtINlwvS3JvOFNZTjIybVlDNkJmZ2grZ3NCUTFPcWx4NmM0TVwvayt3Wk1VQVF5Q3dDSTY0bEJoRFpKVWdBMnRaWmhkTUFCM3NzNTFoRFNUYWZRcnNcL1ZINStZZlgxYVJUMktpSkxTam5KaVE9PSIsIm1hYyI6IjliNjA2ZWIxZDE2YmVjNTEzNWIxOThmZjM1YTZhOWRiMzczZDk3MTcwOGFiYzAyMzEzMTA2MWM5ZWExNmM0YTAifQ==")); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
  }
}
