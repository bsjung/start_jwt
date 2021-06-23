/**
 * [JSON Web Signature](http://self-issued.info/docs/draft-ietf-jose-json-web-signature.html)
 */
library json_web_signature;


import 'dart:convert';
import 'package:crypto/crypto.dart';

/**
 * JSON Web Signature encoder.
 */
class JsonWebSignatureEncoder extends Converter<List<int>,String> {
  const JsonWebSignatureEncoder();
  @override
  String convert(List<int> payload, {Map? header, required String secret}) {
    //print(jsonEncode(header));
    final msg = '${base64Url.encode(jsonEncode(header).codeUnits)}.${base64Url.encode(payload)}';
    return "${msg}.${_signMessage(msg, secret)}";
  }
}


/**
 * JSON Web Signature decoder.
 */
class JsonWebSignatureDecoder extends Converter<String,List<int>>{
  const JsonWebSignatureDecoder();

  bool isValid(String input, String secret) {
    final parts = input.split('.'),
          header = parts[0] as List<String>,
          payload = parts[1] as List<String>,
          signature = parts[2] as List<String>;

    return _verifyParts(header as String, payload as String, signature as String, secret);
  }

  bool _verifyParts(String header, String payload, String signature, String secret) {
    return signature == _signMessage('${header}.${payload}', secret);
  }

  @override
  List<int> convert(String input, {required String secret}) {
    final parts = input.split('.'),
          header = parts[0] as List<String>,
          payload = parts[1] as List<String>,
          signature = parts[2] as List<String>;

    if (_verifyParts(header as String, payload as String, signature as String, secret)) {
      return base64Url.decode(payload as String);
    } else {
      throw new ArgumentError("Invalid signature");
    }
  }
}


/**
 * JSON Web Signature codec.
 */
class JsonWebSignatureCodec extends Codec<List<int>,String> {
  final Map? _header;
  final String? _secret;

  const JsonWebSignatureCodec({Map? header, String? secret}) :
      _header = header,
      _secret = secret;

  @override
  JsonWebSignatureEncoder get encoder => const JsonWebSignatureEncoder();

  @override
  JsonWebSignatureDecoder get decoder => const JsonWebSignatureDecoder();

  @override
  String encode(List<int> payload, {Map? header, String? secret}) {
    return encoder.convert(payload, header: (header != null ? header : _header),
        secret: (secret != null ? secret : _secret!));
  }

  @override
  List<int> decode(String input, {String? secret}) {
    return decoder.convert(input, secret: (secret != null ? secret : _secret!));
  }

  bool isValid(String input, {String? secret}) {
    return decoder.isValid(input, secret != null ? secret : _secret!);
  }
}


String _signMessage(String msg, String secret) {
  Hmac hmac = Hmac( sha256 , secret.codeUnits);
  Digest digest = hmac.convert(msg.codeUnits);
  return base64Url.encode(digest.bytes);
}
