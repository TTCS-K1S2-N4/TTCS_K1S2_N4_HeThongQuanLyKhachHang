import com.crm.util.DBConnection;
public class TestDB {
    public static void main(String[] args) {
        try {
            DBConnection.getConnection();
            System.out.println("SUCCESS");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
