import 'package:start_jwt/json_web_token.dart';

void main() {

    // Encode (i.e. sign) a payload into a JWT token.
    
    final jwt = new JsonWebTokenCodec(secret: "My secret key");
    final payload = {
      'iss': 'joe',
      'exp': 1300819380,
      'http://example.com/is_root': true
    };
    final token = jwt.encode(payload);
    print ("Payload : " + payload.toString());
    
    // Validate a token.
    
    jwt.isValid(token);
    
    // Decode (i.e. extract) the payload from a JWT token.
    
    final decoded = jwt.decode(token);
    print ("Decoded : " + decoded.toString());
}

