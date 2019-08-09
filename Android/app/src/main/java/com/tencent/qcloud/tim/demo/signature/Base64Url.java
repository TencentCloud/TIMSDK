package com.tencent.qcloud.tim.demo.signature;

import org.bouncycastle.util.encoders.Base64;
import org.bouncycastle.util.encoders.DecoderException;

public class Base64Url {
    //int base64_encode_url(const unsigned char *in_str, int length, char *out_str,int *ret_length)
    public static byte[] base64EncodeUrl(byte[] in_str) {
        byte[] base64 = Base64.encode(in_str);
        for (int i = 0; i < base64.length; ++i)
            switch (base64[i]) {
                case '+':
                    base64[i] = '*';
                    break;
                case '/':
                    base64[i] = '-';
                    break;
                case '=':
                    base64[i] = '_';
                    break;
                default:
                    break;
            }
        return base64;
    }

    //int base64_decode_url(const unsigned char *in_str, int length, char *out_str, int *ret_length)
    public static byte[] base64DecodeUrl(byte[] in_str) throws DecoderException {
        byte[] base64 = in_str.clone();
        for (int i = 0; i < base64.length; ++i)
            switch (base64[i]) {
                case '*':
                    base64[i] = '+';
                    break;
                case '-':
                    base64[i] = '/';
                    break;
                case '_':
                    base64[i] = '=';
                    break;
                default:
                    break;
            }
        return Base64.decode(base64);
    }
}
