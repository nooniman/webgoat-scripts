import java.io.*;
import java.util.*;

public class AnalyzeSerializedData {
    public static void main(String[] args) {
        String[] payloads = {
            // Original WebGoat payload
            "rO0ABXQAVklmIHlvdSBkZXNlcmlhbGl6ZSBtZSBkb3duLCBJIHNoYWxsIGJlY29tZSBtb3JlIHBvd2VyZnVsIHRoYW4geW91IGNhbiBwb3NzaWJseSBpbWFnaW5l",
            // Our generated payload
            "rO0ABXNyABRWdWxuZXJhYmxlVGFza0hvbGRlcgAAAAAAAAACAgADSgAIdGFza1RpbWVMAAp0YXNrQWN0aW9udAASTGphdmEvbGFuZy9TdHJpbmc7TAAIdGFza05hbWVxAH4AAXhwAAAAAAAAE4h0AAVzbGVlcHQACURlbGF5VGFzaw=="
        };
        
        for (int i = 0; i < payloads.length; i++) {
            System.out.println("========================================");
            System.out.println("Analyzing Payload " + (i + 1));
            System.out.println("========================================");
            
            try {
                byte[] data = Base64.getDecoder().decode(payloads[i]);
                
                System.out.println("Length: " + data.length + " bytes");
                System.out.println();
                System.out.println("Hex Dump:");
                
                for (int j = 0; j < Math.min(200, data.length); j++) {
                    System.out.printf("%02X ", data[j]);
                    if ((j + 1) % 16 == 0) System.out.println();
                }
                System.out.println();
                System.out.println();
                
                // Try to extract class name
                String hex = bytesToHex(data);
                System.out.println("Looking for class name...");
                
                // Java serialization format:
                // AC ED - magic number
                // 00 05 - version
                // 73/74/75... - object type
                // 72 - class descriptor
                
                int classNameStart = -1;
                for (int j = 0; j < data.length - 2; j++) {
                    if (data[j] == (byte)0x72) { // class descriptor
                        int classNameLength = ((data[j+1] & 0xFF) << 8) | (data[j+2] & 0xFF);
                        if (classNameLength > 0 && classNameLength < 200) {
                            classNameStart = j + 3;
                            byte[] className = Arrays.copyOfRange(data, classNameStart, classNameStart + classNameLength);
                            System.out.println("Class name: " + new String(className));
                            
                            // SerialVersionUID is next (8 bytes)
                            if (classNameStart + classNameLength + 8 <= data.length) {
                                long serialVersionUID = 0;
                                for (int k = 0; k < 8; k++) {
                                    serialVersionUID = (serialVersionUID << 8) | (data[classNameStart + classNameLength + k] & 0xFF);
                                }
                                System.out.println("serialVersionUID: " + serialVersionUID + "L (0x" + Long.toHexString(serialVersionUID) + ")");
                            }
                            break;
                        }
                    }
                }
                
            } catch (Exception e) {
                System.out.println("Error: " + e.getMessage());
            }
            
            System.out.println();
        }
    }
    
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02X", b));
        }
        return sb.toString();
    }
}
